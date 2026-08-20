-- R03: Settled settlements with no matching DailyCaptured record.
select s.operationId, s.transactionId, s.psp, s.merchantAccount
from {{ ref('silver_settlement') }} s
where s.type = 'Settled'
  and not exists (
    select 1 from {{ ref('silver_daily_captured') }} dc where dc.operationId = s.operationId
  )
