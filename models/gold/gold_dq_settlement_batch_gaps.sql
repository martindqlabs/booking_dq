-- Gold monitoring model backing R32: gaps in the sequential batchNumber per
-- (psp, merchantAccount) per month (PPSUPPORT-8557, PPSUPPORT-8115,
-- PPSUPPORT-9420, FSPFA-1796 -- files never received from the PSP).
with batches as (
    select distinct psp, merchantAccount, batchNumber, date_trunc('month', transactionDate) as batch_month
    from {{ ref('silver_settlement') }}
    where batchNumber is not null and psp is not null and merchantAccount is not null
),
seq as (
    select
        *,
        lead(batchNumber) over (partition by psp, merchantAccount, batch_month order by batchNumber) as next_batch
    from batches
)
select
    psp, merchantAccount, batch_month,
    batchNumber as batch_before_gap,
    next_batch as batch_after_gap,
    next_batch - batchNumber - 1 as missing_batch_count
from seq
where next_batch is not null
  and next_batch - batchNumber > 1
