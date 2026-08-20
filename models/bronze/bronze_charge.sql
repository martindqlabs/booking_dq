-- BRONZE (Flow 1 / SQL Server): thin typed pass-through of the landed table
-- already in Snowflake (BOOKING_DQ.BRONZE.BRONZE_CHARGE). Deliberately does
-- NOT trim/nullify blanks or validate domains -- that is Silver's job.
--
-- Materializes to BOOKING_DQ.BRONZE_TYPED (see dbt_project.yml), not
-- BOOKING_DQ.BRONZE -- that schema holds the physical landing table this
-- model reads from, and building a same-named view there would make dbt
-- drop it on a table->view relation swap.
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
