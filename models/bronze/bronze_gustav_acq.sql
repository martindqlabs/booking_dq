select userChargeId, psp, merchantAccount, acq_status, cast(acq_load_date as timestamp) as acq_load_date
from {{ source('bronze', 'bronze_gustav_acq') }}
