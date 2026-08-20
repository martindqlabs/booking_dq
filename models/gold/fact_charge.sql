-- Gold fact table for BI / reporting consumption (Snowflake in production).
select
    userChargeId, status, processingEntity, psp, merchantAccount,
    currency, amount, transactionDatetime, kafka_date
from {{ ref('silver_charge') }}
