with bronze_gustav_acq as (
    select userChargeId, psp, merchantAccount, acq_status, cast(acq_load_date as timestamp) as acq_load_date
    from {{ source('bronze', 'bronze_gustav_acq') }}
)
select
    nullif(trim(userChargeId), '')    as userChargeId,
    nullif(trim(psp), '')             as psp,
    nullif(trim(merchantAccount), '') as merchantAccount,
    acq_status,
    acq_load_date
from bronze_gustav_acq
