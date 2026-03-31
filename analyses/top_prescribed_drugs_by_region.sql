with ranked_drugs as (

    select
        p.territory_id,
        t.territory_name,
        t.region,
        p.drug_brand_name,
        p.therapeutic_class_code,
        count(*) as prescription_count,
        sum(p.total_cost_dollars) as total_revenue,
        row_number() over (
            partition by p.territory_id
            order by count(*) desc
        ) as rank_in_territory

    from {{ ref('fct_prescriptions') }} p
    left join {{ ref('territories') }} t on p.territory_id = t.territory_id
    group by 1, 2, 3, 4, 5

)

select
    territory_name,
    region,
    drug_brand_name,
    therapeutic_class_code,
    prescription_count,
    total_revenue,
    rank_in_territory

from ranked_drugs
where rank_in_territory <= 5
order by territory_id, rank_in_territory
