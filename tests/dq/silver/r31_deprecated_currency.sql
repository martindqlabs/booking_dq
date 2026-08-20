-- R31: deprecated currency detection across charge, settlement, daily_captured
-- (PPSUPPORT-10833 -- BGN posted after Bulgaria's EUR switch).
select 'charge' as entity, c.userChargeId as natural_key, c.currency, date(c.transactionDatetime) as event_date
from {{ ref('silver_charge') }} c
join {{ source('reference', 'ref_deprecated_currency') }} d on c.currency = d.currency
where date(c.transactionDatetime) >= cast(d.deprecated_from_date as date)

union all

select 'daily_captured', dc.operationId, dc.currency, date(dc.transactionDatetime)
from {{ ref('silver_daily_captured') }} dc
join {{ source('reference', 'ref_deprecated_currency') }} d on dc.currency = d.currency
where date(dc.transactionDatetime) >= cast(d.deprecated_from_date as date)

union all

select 'settlement', s.operationId, s.currency, s.transactionDate
from {{ ref('silver_settlement') }} s
join {{ source('reference', 'ref_deprecated_currency') }} d on s.currency = d.currency
where s.transactionDate >= cast(d.deprecated_from_date as date)
