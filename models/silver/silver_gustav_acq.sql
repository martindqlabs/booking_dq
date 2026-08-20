select
    nullif(trim(userChargeId), '')    as userChargeId,
    nullif(trim(psp), '')             as psp,
    nullif(trim(merchantAccount), '') as merchantAccount,
    acq_status,
    acq_load_date
from {{ ref('bronze_gustav_acq') }}
