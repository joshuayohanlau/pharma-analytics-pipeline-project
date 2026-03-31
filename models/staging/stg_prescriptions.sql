with source as (

    select * from {{ source('raw', 'prescriptions') }}

),

renamed as (

    select
        prescription_id,
        rx_number,
        patient_id,
        prescriber_id,
        drug_id,
        pharmacy_id,
        fill_date,
        days_supply,
        quantity,
        total_cost_cents,
        round(total_cost_cents / 100.0, 2) as total_cost_dollars,
        copay_cents,
        round(copay_cents / 100.0, 2) as copay_dollars,
        refill_number,
        is_new_prescription,
        created_at,
        loaded_at

    from source

)

select * from renamed
