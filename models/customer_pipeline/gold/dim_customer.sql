-- Gold: current run's new/updated customers only (this pipeline is a daily-snapshot
-- demo, not a full historical SCD) -- keeps every gold table naturally under the
-- 1000-row-per-run requirement. The hard LIMIT is a safety net, not the primary control.
select
    customer_id,
    first_name,
    middle_initial,
    last_name,
    email,
    phone_number,
    date_of_birth,
    customer_age,
    registration_date,
    is_active,
    is_new_customer,
    city,
    state,
    country,
    postal_code,
    is_address_valid,
    subscription_level,
    account_balance,
    credit_limit,
    loyalty_points,
    customer_rating,
    discount_rate,
    num_of_orders,
    total_order_amount,
    _run_date
from {{ ref('stg_customers') }}
where _run_date = (select max(_run_date) from {{ ref('stg_customers') }})
limit 1000
