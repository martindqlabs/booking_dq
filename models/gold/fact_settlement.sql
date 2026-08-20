-- Gold fact table: settlement, correctly enriched with dispute info via the
-- tight (operationId) join key. This is the model BI dashboards should use.
select
    s.operationId, s.type, s.psp, s.merchantAccount, s.processingEntity,
    s.transactionAmount, s.currency, s.transactionDate, s.reportCreationDate,
    s.batchNumber, s.originalFilename,
    d.disputeId, d.disputeType
from {{ ref('silver_settlement') }} s
left join {{ ref('silver_psp_dispute') }} d on d.userChargeId = s.operationId
