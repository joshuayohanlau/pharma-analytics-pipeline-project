{% snapshot snap_drug_status %}

{{
    config(
        target_schema='snapshots',
        unique_key='drug_id',
        strategy='check',
        check_cols=['approval_status', 'unit_price_cents']
    )
}}

select
    drug_id,
    ndc_code,
    brand_name,
    generic_name,
    approval_status,
    unit_price_cents,
    updated_at

from {{ source('raw', 'drugs') }}

{% endsnapshot %}
