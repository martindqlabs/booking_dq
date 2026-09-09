-- Hard guardrail: every gold table must have at most 1000 rows per run.
-- Fails (returns rows) only if a table exceeds the cap the model-level LIMIT should prevent.
with counts as (
    select 'dim_customer' as tbl, count(*) as cnt from {{ ref('dim_customer') }}
    union all select 'dim_product', count(*) from {{ ref('dim_product') }}
    union all select 'fct_orders', count(*) from {{ ref('fct_orders') }}
    union all select 'fct_transactions', count(*) from {{ ref('fct_transactions') }}
    union all select 'fct_customer_daily_summary', count(*) from {{ ref('fct_customer_daily_summary') }}
    union all select 'dq_summary', count(*) from {{ ref('dq_summary') }}
)
select * from counts where cnt > 1000
