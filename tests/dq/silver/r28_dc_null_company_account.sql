-- R28: Braintree Refunded DC rows missing companyAccount cause whole-file
-- rejection by PSP Reporting (PPSUPPORT-10587/10052/10051/9494).
select operationId, psp, type
from {{ ref('silver_daily_captured') }}
where psp = 'braintree'
  and type = 'Refunded'
  and (companyAccount is null or companyAccount = '')
