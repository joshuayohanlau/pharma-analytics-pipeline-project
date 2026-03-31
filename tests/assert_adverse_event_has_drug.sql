select
    event_id,
    drug_id
from {{ ref('fct_adverse_events') }}
where drug_id is null
