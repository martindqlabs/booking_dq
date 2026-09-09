select
    product_id,
    product_name,
    category,
    unit_price,
    is_active,
    _run_date
from {{ ref('stg_products') }}
where _run_date = (select max(_run_date) from {{ ref('stg_products') }})
limit 1000
