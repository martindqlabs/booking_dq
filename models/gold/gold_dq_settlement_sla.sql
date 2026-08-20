-- Gold monitoring model backing R25: flag individual settlement records
-- that arrive more than T+10 days after the transaction date.
select
    operationId, transactionId, psp, merchantAccount,
    transactionDate, reportCreationDate,
    datediff('day', transactionDate, reportCreationDate) as days_to_settle
from {{ ref('silver_settlement') }}
where datediff('day', transactionDate, reportCreationDate) > {{ var('settlement_sla_days') }}
