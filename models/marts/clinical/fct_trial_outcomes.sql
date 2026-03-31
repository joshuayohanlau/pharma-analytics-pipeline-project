with trials as (

    select * from {{ ref('int_trial_enrollment') }}

),

adverse_events as (

    select
        drug_id,
        count(*) as total_adverse_events,
        count(*) filter (where severity = 'serious') as serious_events,
        count(*) filter (where severity = 'moderate') as moderate_events,
        count(*) filter (where severity = 'mild') as mild_events
    from {{ ref('stg_adverse_events') }}
    group by 1

),

final as (

    select
        trials.trial_id,
        trials.nct_number,
        trials.drug_brand_name,
        trials.phase,
        trials.status,
        trials.enrollment_pct,
        trials.enrollment_status,
        trials.trial_duration_days,
        trials.site_count,

        coalesce(adverse_events.total_adverse_events, 0) as total_adverse_events,
        coalesce(adverse_events.serious_events, 0) as serious_adverse_events,
        coalesce(adverse_events.moderate_events, 0) as moderate_adverse_events,
        coalesce(adverse_events.mild_events, 0) as mild_adverse_events

    from trials
    left join adverse_events on trials.drug_id = adverse_events.drug_id

)

select * from final
