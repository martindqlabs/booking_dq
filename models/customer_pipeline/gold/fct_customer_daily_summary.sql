with orders_with_txn as (
    select
        o.order_id,
        o.customer_id,
        o._run_date,
        o.order_amount,
        coalesce(sum(t.transaction_amount), 0) as transaction_amount
    from {{ ref('stg_orders') }} o
    left join {{ ref('stg_transactions') }} t on t.order_id = o.order_id
    group by o.order_id, o.customer_id, o._run_date, o.order_amount
)

select
    c.customer_id,
    c.first_name,
    c.last_name,
    c.subscription_level,
    c.country,
    count(distinct owt.order_id) as orders_today,
    coalesce(sum(owt.order_amount), 0) as order_amount_today,
    coalesce(sum(owt.transaction_amount), 0) as transaction_amount_today,
    c._run_date
from {{ ref('dim_customer') }} c
left join orders_with_txn owt
    on owt.customer_id = c.customer_id and owt._run_date = c._run_date
group by c.customer_id, c.first_name, c.last_name, c.subscription_level, c.country, c._run_date
limit 1000
