-- R24 (timeliness variant): DC arrival SLA breaches should stay under 1%.
select * from {{ ref('gold_dq_dc_arrival_sla') }} where breach_pct >= 1.0
