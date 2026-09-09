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
    _run_date
from {{ ref('stg_transactions') }}
where _run_date = (select max(_run_date) from {{ ref('stg_transactions') }})
limit 1000
