-- R01: every CAPTURED charge must have a matching DailyCaptured record
-- (join on charge.userChargeId = dc.operationId OR dc.originalOperationId).
select c.userChargeId, c.status, c.psp, c.merchantAccount
from {{ ref('silver_charge') }} c
where c.status = 'CAPTURED'
  and not exists (
    select 1 from {{ ref('silver_daily_captured') }} dc
    where dc.operationId = c.userChargeId or dc.originalOperationId = c.userChargeId
  )
