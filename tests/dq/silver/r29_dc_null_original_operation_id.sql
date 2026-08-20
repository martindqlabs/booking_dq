-- R29: originalOperationId is required on Captured/Refunded DC rows to link
-- back to the charge/refund (PPSUPPORT-10126, Revolut).
select operationId, psp, type
from {{ ref('silver_daily_captured') }}
where type in ('Captured', 'Refunded')
  and (originalOperationId is null or originalOperationId = '')
