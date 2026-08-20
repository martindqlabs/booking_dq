-- SILVER staging: standardize blanks -> NULL, trim strings. Intentionally
-- does NOT deduplicate and does NOT drop invalid domain values -- that is
-- exactly what makes this the right place to run the row-level DQ tests
-- (R09, R11, R12, R13, R16, R17, R20, R24_PSP_LIST, R31): we want the test
-- suite to see the data as it truly arrived, before any fix-up logic can
-- mask a defect.
--
-- Bronze itself is not a dbt-managed relation in this project -- it's the
-- physical landing table already in BOOKING_DQ.BRONZE (see ../_sources.yml)
-- -- so the typed pass-through that dbt_demo does as a separate bronze_charge
-- model is folded in here as a CTE instead.
with bronze_charge as (
    select
        userChargeId,
        status,
        cast(processingEntity as varchar)      as processingEntity,
        psptransactionid,
        psp,
        merchantAccount,
        currency,
        cast(amount as decimal(18,2))          as amount,
        cast(transactionDatetime as timestamp) as transactionDatetime,
        cast(kafka_date as date)               as kafka_date,
        cast(kafka_created_at as timestamp)    as kafka_created_at,
        source_file
    from {{ source('bronze', 'bronze_charge') }}
)
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
from bronze_charge
