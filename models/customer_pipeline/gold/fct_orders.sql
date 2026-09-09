with order_items_agg as (
    select order_id, count(*) as item_count, sum(line_amount) as items_total_amount
    from {{ ref('stg_order_items') }}
    group by order_id
)

select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.status,
    o.order_amount,
    o.quantity,
    o.discount_applied,
    o.shipping_country,
    o.is_shipping_address_valid,
    coalesce(oia.item_count, 0) as item_count,
    coalesce(oia.items_total_amount, 0) as items_total_amount,
    t.payment_method_name,
    t.transaction_status,
    t.transaction_amount,
    o._run_date
from {{ ref('stg_orders') }} o
left join order_items_agg oia on oia.order_id = o.order_id
left join {{ ref('stg_transactions') }} t on t.order_id = o.order_id
where o._run_date = (select max(_run_date) from {{ ref('stg_orders') }})
limit 1000
