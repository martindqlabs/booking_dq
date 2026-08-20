-- R09: charge missing psptransactionid.
select userChargeId, psp, merchantAccount
from {{ ref('stg_charge') }}
where userChargeId is not null
  and psptransactionid is null
