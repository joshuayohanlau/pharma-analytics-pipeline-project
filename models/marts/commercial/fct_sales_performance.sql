with prescriptions as (

    select * from {{ ref('fct_prescriptions') }}

),

sales_reps as (

    select * from {{ ref('stg_sales_reps') }}

),

territories as (

    select * from {{ ref('territories') }}

),

territory_rx as (

    select
        prescriptions.territory_id,
        date_trunc('month', prescriptions.fill_date)::date as fill_month,
        count(*) as total_prescriptions,
        count(*) filter (where prescriptions.is_new_prescription) as new_prescriptions,
        sum(prescriptions.total_cost_dollars) as total_revenue_dollars,
        count(distinct prescriptions.prescriber_id) as unique_prescribers,
        count(distinct prescriptions.patient_id) as unique_patients,
        count(distinct prescriptions.drug_id) as unique_drugs

    from prescriptions
    group by 1, 2

),

final as (

    select
        territory_rx.territory_id,
        territories.territory_name,
        territories.region,
        territory_rx.fill_month,
        territory_rx.total_prescriptions,
        territory_rx.new_prescriptions,
        territory_rx.total_revenue_dollars,
        territory_rx.unique_prescribers,
        territory_rx.unique_patients,
        territory_rx.unique_drugs,

        sales_reps.rep_id,
        sales_reps.full_name as rep_name

    from territory_rx
    left join territories on territory_rx.territory_id = territories.territory_id
    left join sales_reps on territory_rx.territory_id = sales_reps.territory_id
        and sales_reps.is_active = true

)

select * from final
