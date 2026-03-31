with source as (

    select * from {{ source('raw', 'prescribers') }}

),

renamed as (

    select
        prescriber_id,
        npi_number,
        first_name,
        last_name,
        first_name || ' ' || last_name as full_name,
        specialty,
        practice_name,
        practice_address,
        city,
        state_code,
        zip_code,
        territory_id,
        created_at,
        updated_at

    from source

)

select * from renamed
