{% snapshot snap_inventory_levels %}

{{
    config(
        target_schema='snapshots',
        unique_key='inventory_id',
        strategy='timestamp',
        updated_at='updated_at'
    )
}}

select
    inventory_id,
    warehouse_code,
    drug_id,
    quantity_on_hand,
    quantity_reserved,
    quantity_on_hand - quantity_reserved as quantity_available,
    reorder_point,
    last_restock_date,
    expiration_date,
    lot_number,
    snapshot_date,
    updated_at

from {{ source('raw', 'inventory') }}

{% endsnapshot %}
