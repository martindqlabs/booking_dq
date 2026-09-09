-- Powers the DQ monitoring dashboard in Tableau: rejected-record counts by table,
-- rule, and run date. Reads the *_REJECTS tables written during the silver load
-- (scripts/sql_bronze_to_snowflake_silver.py), unnesting the JSON reject-reason array.

with customers_reasons as (
    select 'CUSTOMERS' as table_name, _run_date, f.value::string as reject_reason
    from {{ source('customer_pipeline_silver', 'customers_rejects') }}, lateral flatten(input => parse_json(reject_reasons)) f
),
products_reasons as (
    select 'PRODUCTS' as table_name, _run_date, f.value::string as reject_reason
    from {{ source('customer_pipeline_silver', 'products_rejects') }}, lateral flatten(input => parse_json(reject_reasons)) f
),
orders_reasons as (
    select 'ORDERS' as table_name, _run_date, f.value::string as reject_reason
    from {{ source('customer_pipeline_silver', 'orders_rejects') }}, lateral flatten(input => parse_json(reject_reasons)) f
),
order_items_reasons as (
    select 'ORDER_ITEMS' as table_name, _run_date, f.value::string as reject_reason
    from {{ source('customer_pipeline_silver', 'order_items_rejects') }}, lateral flatten(input => parse_json(reject_reasons)) f
),
transactions_reasons as (
    select 'TRANSACTIONS' as table_name, _run_date, f.value::string as reject_reason
    from {{ source('customer_pipeline_silver', 'transactions_rejects') }}, lateral flatten(input => parse_json(reject_reasons)) f
),
unioned as (
    select * from customers_reasons
    union all select * from products_reasons
    union all select * from orders_reasons
    union all select * from order_items_reasons
    union all select * from transactions_reasons
)

select
    table_name,
    _run_date,
    reject_reason,
    count(*) as reject_count
from unioned
group by table_name, _run_date, reject_reason
order by _run_date desc, reject_count desc
limit 1000
