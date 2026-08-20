-- R18: at least one of grossCreditAmount / grossDebitAmount must be populated.
select operationId, transactionId
from {{ ref('silver_settlement') }}
where grossCreditAmount is null and grossDebitAmount is null
