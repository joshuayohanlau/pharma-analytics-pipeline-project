with trial_enrollment as (

    select * from {{ ref('int_trial_enrollment') }}

),

final as (

    select
        trial_id,
        nct_number,
        trial_title,
        phase,
        status,
        start_date,
        estimated_end_date,
        actual_end_date,
        target_enrollment,
        actual_enrollment,
        enrollment_pct,
        enrollment_status,
        principal_investigator,
        site_count,
        trial_duration_days,

        drug_id,
        drug_brand_name,
        therapeutic_class_code

    from trial_enrollment

)

select * from final
