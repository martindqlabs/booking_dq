-- Gold monitoring model backing R26: per-PSP daily captured-record volume
-- deviating >30% from its trailing 7-day rolling average
-- (PPSUPPORT-10973 -- an undetected Gustav ingestion failure looked exactly
-- like this: volume silently drops to near zero for one PSP on one day).
with daily as (
    select psp, kafka_date, sum(record_count) as daily_count
    from {{ ref('silver_payreport_volume_counts') }}
    where metric_type = 'captured'
    group by psp, kafka_date
),
rolling as (
    select
        *,
        avg(daily_count) over (
            partition by psp order by kafka_date
            rows between 7 preceding and 1 preceding
        ) as rolling_avg_7d
    from daily
)
select
    psp, kafka_date, daily_count, round(rolling_avg_7d, 2) as rolling_avg_7d,
    round(abs(daily_count - rolling_avg_7d) / nullif(rolling_avg_7d, 0), 3) as deviation_ratio
from rolling
where rolling_avg_7d is not null
  and abs(daily_count - rolling_avg_7d) / nullif(rolling_avg_7d, 0) > {{ var('volume_anomaly_pct_threshold') }}
