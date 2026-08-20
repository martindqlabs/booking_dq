with bronze_daily_captured as (
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
)
select
    nullif(trim(operationId), '')         as operationId,
    nullif(trim(originalOperationId), '') as originalOperationId,
    type,
    nullif(trim(companyAccount), '')      as companyAccount,
    nullif(trim(processingEntity), '')    as processingEntity,
    nullif(trim(psp), '')                 as psp,
    nullif(trim(merchantAccount), '')     as merchantAccount,
    currency,
    transactionDatetime,
    kafka_created_at
from bronze_daily_captured
