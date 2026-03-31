{% macro log_run_event(event_type) %}
    {% if execute %}
        {{ log("dbt run " ~ event_type ~ " at " ~ run_started_at, info=True) }}
    {% endif %}
    select 1
{% endmacro %}
