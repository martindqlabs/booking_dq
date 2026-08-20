-- R02: every CAPTURED charge needs a type=Settled settlement within T+10 days.
-- LEFT JOIN / IS NULL rewrite (see gold/dq_scorecard.sql r02 for why): a
-- correlated NOT EXISTS with datediff() mixing outer+inner columns hits a
-- Snowflake "Unsupported subquery type" error.
select c.userChargeId, c.status, c.transactionDatetime
from {{ ref('silver_charge') }} c
left join {{ ref('silver_settlement') }} s
  on s.operationId = c.userChargeId
 and s.type = 'Settled'
 and datediff('day', date(c.transactionDatetime), s.reportCreationDate) <= {{ var('settlement_sla_days') }}
where c.status = 'CAPTURED'
  and s.operationId is null
