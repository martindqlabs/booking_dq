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
from {{ ref('bronze_daily_captured') }}
