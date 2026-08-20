select metric_type, psp, merchantAccount, cast(kafka_date as date) as kafka_date, cast(record_count as integer) as record_count
from {{ source('bronze', 'bronze_psp_volume_counts') }}
