with adverse_events as (

    select * from {{ ref('stg_adverse_events') }}

),

drugs as (

    select * from {{ ref('stg_drugs') }}

),

classified as (

    select
        adverse_events.event_id,
        adverse_events.case_number,
        adverse_events.patient_id,
        adverse_events.drug_id,
        adverse_events.event_date,
        adverse_events.reported_date,
        adverse_events.days_to_report,
        adverse_events.event_type,
        adverse_events.severity,
        adverse_events.outcome,
        adverse_events.reporter_type,

        drugs.brand_name as drug_brand_name,
        drugs.generic_name as drug_generic_name,
        drugs.therapeutic_class_code,
        drugs.manufacturer,

        case
            when adverse_events.severity = 'serious' then 3
            when adverse_events.severity = 'moderate' then 2
            when adverse_events.severity = 'mild' then 1
            else 0
        end as severity_score,

        case
            when adverse_events.outcome in ('Hospitalized', 'Life-threatening', 'Death') then true
            else false
        end as is_serious_outcome

    from adverse_events
    left join drugs on adverse_events.drug_id = drugs.drug_id

)

select * from classified
