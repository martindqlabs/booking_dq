-- R22: orphan settlements -- no operationId and no originalOperationId,
-- for non Reserve/Fee/DepositCorrection types.
select transactionId, psp, merchantAccount, type
from {{ ref('silver_settlement') }}
where operationId is null
  and originalOperationId is null
  and type not in ('Reserve', 'Fee', 'DepositCorrection')
