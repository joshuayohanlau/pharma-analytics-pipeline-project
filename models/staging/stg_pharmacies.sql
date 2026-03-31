with source as (

    select * from {{ source('raw', 'pharmacies') }}

),

renamed as (

    select
        pharmacy_id,
        ncpdp_id,
        pharmacy_name,
        pharmacy_type,
        chain_name,
        city,
        state_code,
        zip_code,
        created_at,
        updated_at

    from source

)

select * from renamed
