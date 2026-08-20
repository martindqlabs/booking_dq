-- SILVER staging: standardize blanks -> NULL, trim strings. Intentionally
-- does NOT deduplicate and does NOT drop invalid domain values -- that is
-- exactly what makes this the right place to run the row-level DQ tests
-- (R09, R11, R12, R13, R16, R17, R20, R24_PSP_LIST, R31): we want the test
-- suite to see the data as it truly arrived, before any fix-up logic can
-- mask a defect.
select
    nullif(trim(userChargeId), '')        as userChargeId,
    status,
    nullif(trim(processingEntity), '')    as processingEntity,
    nullif(trim(psptransactionid), '')    as psptransactionid,
    nullif(trim(psp), '')                 as psp,
    nullif(trim(merchantAccount), '')     as merchantAccount,
    currency,
    amount,
    transactionDatetime,
    kafka_date,
    kafka_created_at,
    source_file
from {{ ref('bronze_charge') }}
