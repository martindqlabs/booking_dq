-- Gold monitoring model backing R19: reportRecordCount on the settlement
-- file header must equal the actual number of rows delivered for that file.
select
    originalFilename,
    reportRecordCount,
    count(*) as actual_row_count
from {{ ref('silver_settlement') }}
group by originalFilename, reportRecordCount
having count(*) <> reportRecordCount
