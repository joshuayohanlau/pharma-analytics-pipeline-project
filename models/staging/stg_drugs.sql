with source as (

    select * from {{ source('raw', 'drugs') }}

),

renamed as (

    select
        drug_id,
        ndc_code,
        brand_name,
        generic_name,
        manufacturer,
        therapeutic_class_code,
        dosage_form,
        strength,
        route_of_administration,
        approval_date,
        approval_status,
        unit_price_cents,
        round(unit_price_cents / 100.0, 2) as unit_price_dollars,
        created_at,
        updated_at

    from source

)

select * from renamed
