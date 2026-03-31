select
    prescription_id,
    fill_date
from {{ ref('fct_prescriptions') }}
where fill_date > current_date
