-- BRONZE (Flow 2 / SAP HANA, replicated into SQL Server hana_replica schema).
select
    operationId,
    originalOperationId,
    type,
    companyAccount,
    cast(processingEntity as varchar) as processingEntity,
    psp,
    merchantAccount,
    currency,
    cast(transactionDatetime as timestamp) as transactionDatetime,
    cast(kafka_created_at as timestamp)    as kafka_created_at
from {{ source('bronze', 'bronze_daily_captured') }}
