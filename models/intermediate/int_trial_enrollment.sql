with trials as (

    select * from {{ ref('stg_clinical_trials') }}

),

drugs as (

    select * from {{ ref('stg_drugs') }}

),

enrollment_analysis as (

    select
        trials.trial_id,
        trials.nct_number,
        trials.trial_title,
        trials.phase,
        trials.status,
        trials.start_date,
        trials.estimated_end_date,
        trials.actual_end_date,
        trials.target_enrollment,
        trials.actual_enrollment,
        trials.enrollment_pct,
        trials.principal_investigator,
        trials.site_count,

        drugs.drug_id,
        drugs.brand_name as drug_brand_name,
        drugs.therapeutic_class_code,

        case
            when trials.enrollment_pct >= 90 then 'On Track'
            when trials.enrollment_pct >= 60 then 'At Risk'
            else 'Behind'
        end as enrollment_status,

        case
            when trials.actual_end_date is not null
            then trials.actual_end_date - trials.start_date
            else current_date - trials.start_date
        end as trial_duration_days

    from trials
    left join drugs on trials.drug_id = drugs.drug_id

)

select * from enrollment_analysis
