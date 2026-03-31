with pharmacies as (

    select * from {{ ref('stg_pharmacies') }}

),

final as (

    select
        pharmacy_id,
        ncpdp_id,
        pharmacy_name,
        pharmacy_type,
        chain_name,
        city,
        state_code,
        zip_code,
        case
            when pharmacy_type = 'specialty' then true
            else false
        end as is_specialty_pharmacy

    from pharmacies

)

select * from final
