{{
    config(
        materialized='ephemeral'
    )
}}

with date_spine as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2024-01-01' as date)",
        end_date="cast('2025-12-31' as date)"
    ) }}

),

final as (

    select
        cast(date_day as date) as date_day,
        extract(year from date_day) as year,
        extract(month from date_day) as month,
        extract(day from date_day) as day_of_month,
        extract(dow from date_day) as day_of_week,
        to_char(date_day, 'YYYY-MM') as year_month,
        to_char(date_day, 'Q') as quarter,
        case
            when extract(dow from date_day) in (0, 6) then false
            else true
        end as is_weekday

    from date_spine

)

select * from final
