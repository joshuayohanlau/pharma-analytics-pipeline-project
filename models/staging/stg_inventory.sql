with source as (

    select * from {{ source('raw', 'inventory') }}

),

renamed as (

    select
        inventory_id,
        warehouse_code,
        drug_id,
        quantity_on_hand,
        quantity_reserved,
        quantity_on_hand - quantity_reserved as quantity_available,
        reorder_point,
        case
            when quantity_on_hand - quantity_reserved <= reorder_point then true
            else false
        end as needs_reorder,
        last_restock_date,
        expiration_date,
        lot_number,
        snapshot_date,
        created_at,
        updated_at

    from source

)

select * from renamed
