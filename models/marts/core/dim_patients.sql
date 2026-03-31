with patients as (

    select * from {{ ref('stg_patients') }}

),

final as (

    select
        patient_id,
        member_id,
        date_of_birth,
        gender,
        state_code,
        zip_code,
        insurance_type,
        age_years,
        case
            when age_years < 18 then 'Pediatric'
            when age_years between 18 and 44 then 'Young Adult'
            when age_years between 45 and 64 then 'Middle Age'
            else 'Senior'
        end as age_group

    from patients

)

select * from final
