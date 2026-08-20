-- R07: records present in PayReport/BDX (represented here by Silver charge)
-- but missing from Gustav ACQ.
select c.userChargeId, c.psp, c.merchantAccount
from {{ ref('silver_charge') }} c
where not exists (
    select 1 from {{ ref('silver_gustav_acq') }} g where g.userChargeId = c.userChargeId
)
