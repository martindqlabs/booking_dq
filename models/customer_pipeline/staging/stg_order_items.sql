select
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    line_amount,
    createddate,
    _run_date,
    _silver_loaded_at
from {{ source('customer_pipeline_silver', 'order_items') }}
