select
    product_id,
    product_name,
    category,
    unit_price,
    is_active,
    createddate,
    updateddate,
    _run_date,
    _silver_loaded_at
from {{ source('customer_pipeline_silver', 'products') }}
