{{
    config(
        materialized='incremental',
        unique_key='prescription_id',
        incremental_strategy='delete+insert'
    )
}}

with prescription_enriched as (

    select * from {{ ref('int_prescription_enriched') }}

),

final as (

    select
        prescription_id,
        rx_number,
        fill_date,
        days_supply,
        quantity,
        total_cost_dollars,
        copay_dollars,
        plan_paid_dollars,
        refill_number,
        is_new_prescription,

        drug_id,
        drug_brand_name,
        drug_generic_name,
        therapeutic_class_code,
        manufacturer,

        prescriber_id,
        prescriber_name,
        prescriber_specialty,
        territory_id,

        patient_id,
        member_id,
        patient_age,
        patient_gender,
        insurance_type,

        pharmacy_id

    from prescription_enriched

    {% if is_incremental() %}
        where fill_date > (select max(fill_date) from {{ this }})
    {% endif %}

)

select * from final
