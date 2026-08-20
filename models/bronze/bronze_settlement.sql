-- BRONZE (Flow 2 / SAP HANA, replicated into SQL Server hana_replica schema).
select
    operationId,
    originalOperationId,
    type,
    cast(processingEntity as varchar) as processingEntity,
    psp,
    merchantAccount,
    purchaseId,
    cast(nullif(cast(grossCreditAmount as varchar), '') as decimal(18,2)) as grossCreditAmount,
    cast(nullif(cast(grossDebitAmount as varchar), '') as decimal(18,2))  as grossDebitAmount,
    transactionId,
    cast(batchNumber as integer)              as batchNumber,
    cast(transactionAmount as decimal(18,2))  as transactionAmount,
    cast(transactionDate as date)             as transactionDate,
    cast(reportCreationDate as date)          as reportCreationDate,
    originalFilename,
    cast(reportRecordCount as integer)        as reportRecordCount,
    currency,
    cast(feeAmount as decimal(18,4))          as feeAmount,
    feeCurrency
from {{ source('bronze', 'bronze_settlement') }}
