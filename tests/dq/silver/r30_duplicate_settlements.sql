-- R30: same settlement resent across multiple files/days
-- (PPSUPPORT-9665, Braintree). Natural key excludes transactionDate on
-- purpose -- that's precisely the column PSPs vary when they resend.
select transactionId, operationId, psp, merchantAccount, batchNumber, transactionAmount, type,
       count(distinct transactionDate) as distinct_transaction_dates,
       count(*) as row_count
from {{ ref('silver_settlement') }}
group by transactionId, operationId, psp, merchantAccount, batchNumber, transactionAmount, type
having count(distinct transactionDate) > 1
