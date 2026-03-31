with source as (

    select * from {{ source('raw', 'patients') }}

),

renamed as (

    select
        patient_id,
        member_id,
        date_of_birth,
        gender,
        state_code,
        zip_code,
        insurance_type,
        date_part('year', age(current_date, date_of_birth))::integer as age_years,
        created_at,
        updated_at

    from source

)

select * from renamed
