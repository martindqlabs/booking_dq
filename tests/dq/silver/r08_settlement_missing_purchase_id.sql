-- R08: enrichment failure -- transactional settlements must carry a purchaseId.
select operationId, transactionId, type
from {{ ref('silver_settlement') }}
where purchaseId is null
  and type not in ('Reserve', 'Fee', 'DepositCorrection')
