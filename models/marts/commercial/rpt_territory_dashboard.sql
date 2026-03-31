{{
    config(
        materialized='table',
        alias='territory_performance_summary'
    )
}}

with sales as (

    select * from {{ ref('fct_sales_performance') }}

),

final as (

    select
        territory_id,
        territory_name,
        region,
        rep_name,
        count(distinct fill_month) as months_active,
        sum(total_prescriptions) as total_prescriptions,
        sum(new_prescriptions) as total_new_prescriptions,
        sum(total_revenue_dollars) as total_revenue_dollars,
        round(avg(total_revenue_dollars), 2) as avg_monthly_revenue,
        max(unique_prescribers) as peak_prescriber_count,
        max(unique_patients) as peak_patient_count

    from sales
    group by 1, 2, 3, 4

)

select * from final
