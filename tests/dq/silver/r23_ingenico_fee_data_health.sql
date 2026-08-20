-- R23: known issue -- for psp='ingenico', all fee fields are NULL/zero.
-- Reported at warn severity since this documents a known upstream PSP data
-- gap (Pay-In Settlements Enriched) rather than a pipeline defect to "fix".
{{ config(severity='warn') }}
select operationId, transactionId, feeAmount, feeCurrency
from {{ ref('silver_settlement') }}
where psp = 'ingenico'
  and (feeAmount is null or feeAmount = 0)
