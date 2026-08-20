select * from {{ ref('gold_dq_volume_completeness') }} where metric_type = 'captured'
