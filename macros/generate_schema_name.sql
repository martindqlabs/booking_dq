{#
    dbt's default generate_schema_name macro prefixes custom schemas with
    the target's default schema (e.g. target_schema_bronze). We want models
    to land in exactly the schema named in +schema (bronze/silver/gold),
    matching the BOOKING_DQ.BRONZE / .SILVER / .GOLD layout already loaded
    in Snowflake -- so this overrides that default.
#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
