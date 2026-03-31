with source as (

    select * from {{ source('raw', 'sales_reps') }}

),

renamed as (

    select
        rep_id,
        employee_id,
        first_name,
        last_name,
        first_name || ' ' || last_name as full_name,
        territory_id,
        region,
        hire_date,
        manager_id,
        is_active,
        created_at,
        updated_at

    from source

)

select * from renamed
