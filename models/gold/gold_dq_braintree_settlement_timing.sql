-- Gold monitoring model backing R27: Braintree EUR/GBP settlements have a
-- T+1 timing exception in the Integration Contract.
select
    operationId, transactionId, currency, transactionDate, reportCreationDate,
    datediff('day', transactionDate, reportCreationDate) as days_to_report
from {{ ref('silver_settlement') }}
where psp = 'braintree'
  and currency in ('EUR', 'GBP')
  and datediff('day', transactionDate, reportCreationDate) > {{ var('braintree_fast_track_days') }}
