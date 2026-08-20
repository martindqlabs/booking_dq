select disputeId, userChargeId, psp, merchantAccount, disputeType, cast(disputeDate as date) as disputeDate,
       cast(disputeAmount as decimal(18,2)) as disputeAmount, currency
from {{ source('bronze', 'bronze_psp_dispute') }}
