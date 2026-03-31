{{
    config(
        materialized='ephemeral'
    )
}}

with prescriptions as (

    select * from {{ ref('stg_prescriptions') }}

),

drugs as (

    select * from {{ ref('stg_drugs') }}

),

prescribers as (

    select * from {{ ref('stg_prescribers') }}

),

patients as (

    select * from {{ ref('stg_patients') }}

),

enriched as (

    select
        prescriptions.prescription_id,
        prescriptions.rx_number,
        prescriptions.fill_date,
        prescriptions.days_supply,
        prescriptions.quantity,
        prescriptions.total_cost_dollars,
        prescriptions.copay_dollars,
        prescriptions.total_cost_dollars - prescriptions.copay_dollars as plan_paid_dollars,
        prescriptions.refill_number,
        prescriptions.is_new_prescription,

        drugs.drug_id,
        drugs.brand_name as drug_brand_name,
        drugs.generic_name as drug_generic_name,
        drugs.therapeutic_class_code,
        drugs.manufacturer,

        prescribers.prescriber_id,
        prescribers.full_name as prescriber_name,
        prescribers.specialty as prescriber_specialty,
        prescribers.territory_id,

        patients.patient_id,
        patients.member_id,
        patients.age_years as patient_age,
        patients.gender as patient_gender,
        patients.insurance_type,

        prescriptions.pharmacy_id

    from prescriptions
    left join drugs on prescriptions.drug_id = drugs.drug_id
    left join prescribers on prescriptions.prescriber_id = prescribers.prescriber_id
    left join patients on prescriptions.patient_id = patients.patient_id

)

select * from enriched
