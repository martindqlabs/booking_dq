-- R20: no duplicate (userChargeId, status) rows -- the charge natural key.
-- Runs against stg_charge (pre-dedup) on purpose: see SILVER-BUG-1 in
-- models/silver/charge.sql for why the final table can't be trusted to
-- surface this on its own.
select userChargeId, status, count(*) as duplicate_count
from {{ ref('stg_charge') }}
where userChargeId is not null
group by userChargeId, status
having count(*) > 1
