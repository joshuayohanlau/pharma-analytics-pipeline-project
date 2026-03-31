with prescribers as (

    select * from {{ ref('stg_prescribers') }}

),

territories as (

    select * from {{ ref('territories') }}

),

final as (

    select
        prescribers.prescriber_id,
        prescribers.npi_number,
        prescribers.full_name,
        prescribers.specialty,
        prescribers.practice_name,
        prescribers.city,
        prescribers.state_code,
        prescribers.zip_code,
        prescribers.territory_id,
        territories.territory_name,
        territories.region

    from prescribers
    left join territories
        on prescribers.territory_id = territories.territory_id

)

select * from final
