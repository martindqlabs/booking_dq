-- Gold monitoring model backing R05 (captured completeness) and R06
-- (settlement completeness): PSP-reported counts vs PayReport/BDX counts,
-- grouped by psp, merchantAccount, kafka_date.
select
    p.metric_type,
    p.psp,
    p.merchantAccount,
    p.kafka_date,
    p.record_count       as psp_record_count,
    r.record_count        as payreport_record_count,
    p.record_count - r.record_count as diff
from {{ ref('silver_psp_volume_counts') }} p
join {{ ref('silver_payreport_volume_counts') }} r
  on p.metric_type = r.metric_type
 and p.psp = r.psp
 and p.merchantAccount = r.merchantAccount
 and p.kafka_date = r.kafka_date
where p.record_count <> r.record_count
