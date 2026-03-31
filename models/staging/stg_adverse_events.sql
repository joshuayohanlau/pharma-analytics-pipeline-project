with source as (

    select * from {{ source('raw', 'adverse_events') }}

),

renamed as (

    select
        event_id,
        case_number,
        patient_id,
        drug_id,
        event_date,
        reported_date,
        reported_date - event_date as days_to_report,
        event_type,
        severity,
        outcome,
        description,
        reporter_type,
        created_at,
        loaded_at

    from source

)

select * from renamed
