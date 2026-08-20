-- R10: settlement processingEntity must match the entity on the matched charge.
select s.operationId, s.processingEntity as settlement_entity, c.processingEntity as charge_entity
from {{ ref('silver_settlement') }} s
join {{ ref('silver_charge') }} c on s.operationId = c.userChargeId
where s.processingEntity is distinct from c.processingEntity
