with source as (

    select * from {{ source('raw', 'clinical_trials') }}

),

renamed as (

    select
        trial_id,
        nct_number,
        trial_title,
        drug_id,
        phase,
        status,
        start_date,
        estimated_end_date,
        actual_end_date,
        target_enrollment,
        actual_enrollment,
        case
            when target_enrollment > 0
            then round(actual_enrollment::numeric / target_enrollment * 100, 1)
            else 0
        end as enrollment_pct,
        principal_investigator,
        site_count,
        created_at,
        updated_at

    from source

)

select * from renamed
