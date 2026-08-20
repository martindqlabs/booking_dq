-- SILVER (final): promotes stg_charge to the conformed grain of one row
-- per (userChargeId, status).
--
-- >>> KNOWN SILVER-LAYER DQ DEFECT ("SILVER-BUG-1", see docs/README.md) <<<
-- The de-duplication window below partitions by userChargeId ONLY, not by
-- (userChargeId, status). For a charge that legitimately transitions
-- AUTHORISED -> CAPTURED, this silently drops the AUTHORISED row and keeps
-- only the latest status -- a real-world "over-aggressive dedup" bug, not
-- a hypothetical one. It also happens to still collapse the true R20
-- duplicate rows seeded in the raw file, which is why the R20 test is run
-- against stg_charge (pre-dedup) rather than this model: testing here
-- would hide the very defect this comment is flagging.
with ranked as (
    select
        *,
        row_number() over (
            partition by userChargeId        -- BUG: should also partition by status
            order by kafka_created_at desc
        ) as rn
    from {{ ref('stg_charge') }}
    where userChargeId is not null
)
select
    userChargeId, status, processingEntity, psptransactionid, psp, merchantAccount,
    currency, amount, transactionDatetime, kafka_date, kafka_created_at, source_file
from ranked
where rn = 1
