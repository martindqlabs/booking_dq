-- Gold monitoring model backing R24 (DC arrival SLA, T+5): daily-captured
-- records should arrive within 5 days of the underlying transaction in
-- >99% of cases (DCC T+2/T+3/T+5 windows).
select
    count(*) as total_dc_records,
    sum(case when datediff('day', transactionDatetime, kafka_created_at) > {{ var('dc_sla_days') }} then 1 else 0 end) as breaches,
    round(
        100.0 * sum(case when datediff('day', transactionDatetime, kafka_created_at) > {{ var('dc_sla_days') }} then 1 else 0 end)
        / nullif(count(*), 0), 2
    ) as breach_pct
from {{ ref('silver_daily_captured') }}
