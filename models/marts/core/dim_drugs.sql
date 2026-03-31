with drugs as (

    select * from {{ ref('stg_drugs') }}

),

therapeutic_classes as (

    select * from {{ ref('therapeutic_classes') }}

),

final as (

    select
        drugs.drug_id,
        drugs.ndc_code,
        drugs.brand_name,
        drugs.generic_name,
        drugs.manufacturer,
        drugs.therapeutic_class_code,
        therapeutic_classes.class_name as therapeutic_class_name,
        drugs.dosage_form,
        drugs.strength,
        drugs.route_of_administration,
        drugs.approval_date,
        drugs.approval_status,
        drugs.unit_price_dollars,
        case
            when drugs.unit_price_dollars >= 5000 then 'Specialty'
            when drugs.unit_price_dollars >= 500 then 'Brand'
            else 'Generic'
        end as price_tier

    from drugs
    left join therapeutic_classes
        on drugs.therapeutic_class_code = therapeutic_classes.class_code

)

select * from final
