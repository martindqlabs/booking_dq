-- R04: Chargeback / SecondChargeback settlements must match PSP dispute data.
select s.operationId, s.type, s.psp, s.merchantAccount
from {{ ref('silver_settlement') }} s
where s.type in ('Chargeback', 'SecondChargeback')
  and not exists (
    select 1 from {{ ref('silver_psp_dispute') }} d where d.userChargeId = s.operationId
  )
