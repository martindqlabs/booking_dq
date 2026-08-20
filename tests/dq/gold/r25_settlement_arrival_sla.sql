-- R25: informational -- Recontool already excludes <10 day settlements from
-- its own reconciliation, so this is reported at warn severity rather than
-- failing the build outright.
{{ config(severity='warn') }}
select * from {{ ref('gold_dq_settlement_sla') }}
