with classified_events as (

    select * from {{ ref('int_adverse_event_classified') }}

),

patients as (

    select * from {{ ref('stg_patients') }}

),

final as (

    select
        classified_events.event_id,
        classified_events.case_number,
        classified_events.event_date,
        classified_events.reported_date,
        classified_events.days_to_report,
        classified_events.event_type,
        classified_events.severity,
        classified_events.severity_score,
        classified_events.outcome,
        classified_events.is_serious_outcome,
        classified_events.reporter_type,

        classified_events.drug_id,
        classified_events.drug_brand_name,
        classified_events.drug_generic_name,
        classified_events.therapeutic_class_code,
        classified_events.manufacturer,

        classified_events.patient_id,
        patients.gender as patient_gender,
        patients.age_years as patient_age,
        patients.insurance_type

    from classified_events
    left join patients on classified_events.patient_id = patients.patient_id

)

select * from final
