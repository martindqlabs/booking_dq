-- >>> KNOWN GOLD-LAYER DQ DEFECT ("GOLD-BUG-1", see docs/README.md) <<<
-- This model exists ONLY to demonstrate a realistic Gold-layer aggregation
-- bug and is NOT what fact_settlement uses. The enrichment join below
-- matches settlement to psp_dispute on (psp, merchantAccount) instead of
-- the correct natural key (operationId) -- a "loose join" mistake that is
-- easy to make when someone widens a join to "catch more matches" without
-- checking cardinality. Every settlement row for a given psp+merchantAccount
-- combination fans out once per dispute that PSP/merchant ever had,
-- inflating both row count and any downstream SUM(transactionAmount).
-- See docs/README.md's "Gold-layer defect" section for the before/after
-- row-count and total-amount comparison captured during verification.
select
    s.operationId, s.transactionId, s.type, s.psp, s.merchantAccount,
    s.transactionAmount, s.currency,
    d.disputeId
from {{ ref('silver_settlement') }} s
left join {{ ref('silver_psp_dispute') }} d
       on d.psp = s.psp
      and d.merchantAccount = s.merchantAccount   -- BUG: should also require d.userChargeId = s.operationId
