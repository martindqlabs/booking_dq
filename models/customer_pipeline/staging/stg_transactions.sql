select
    transaction_id,
    order_id,
    transaction_date,
    payment_method_code,
    payment_method_name,
    fee_type,
    transaction_amount,
    transaction_status,
    currency,
    createddate,
    _run_date,
    _silver_loaded_at
from {{ source('customer_pipeline_silver', 'transactions') }}
