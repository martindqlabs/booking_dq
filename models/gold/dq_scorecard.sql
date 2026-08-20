-- Gold: one row per rule (R01-R32) with a live violation count, for BI
-- dashboards / DQ scorecards. This intentionally re-implements the same
-- predicates as the dbt tests in tests/dq/ -- the tests are the CI gate,
-- this table is what a reconciliation dashboard actually queries. Keeping
-- both is a standard pattern: dbt tests answer "did the build regress?",
-- the scorecard answers "how much of what, right now?".
with

r01 as (
    select count(*) as n from {{ ref('silver_charge') }} c
    where c.status = 'CAPTURED'
      and not exists (select 1 from {{ ref('silver_daily_captured') }} dc where dc.operationId = c.userChargeId or dc.originalOperationId = c.userChargeId)
),
r02 as (
    -- Snowflake can't evaluate a correlated NOT EXISTS whose join condition
    -- mixes outer+inner columns inside datediff() ("Unsupported subquery
    -- type"), so this is a LEFT JOIN / IS NULL rewrite of the same check --
    -- functionally identical to dbt_demo's NOT EXISTS version.
    select count(*) as n
    from {{ ref('silver_charge') }} c
    left join {{ ref('silver_settlement') }} s
      on s.operationId = c.userChargeId
     and s.type = 'Settled'
     and datediff('day', date(c.transactionDatetime), s.reportCreationDate) <= {{ var('settlement_sla_days') }}
    where c.status = 'CAPTURED'
      and s.operationId is null
),
r03 as (
    select count(*) as n from {{ ref('silver_settlement') }} s
    where s.type = 'Settled' and not exists (select 1 from {{ ref('silver_daily_captured') }} dc where dc.operationId = s.operationId)
),
r04 as (
    select count(*) as n from {{ ref('silver_settlement') }} s
    where s.type in ('Chargeback','SecondChargeback')
      and not exists (select 1 from {{ ref('silver_psp_dispute') }} d where d.userChargeId = s.operationId)
),
r05 as (select count(*) as n from {{ ref('gold_dq_volume_completeness') }} where metric_type = 'captured'),
r06 as (select count(*) as n from {{ ref('gold_dq_volume_completeness') }} where metric_type = 'settlement'),
r07 as (
    select count(*) as n from {{ ref('silver_charge') }} c
    where not exists (select 1 from {{ ref('silver_gustav_acq') }} g where g.userChargeId = c.userChargeId)
),
r08 as (
    select count(*) as n from {{ ref('silver_settlement') }}
    where purchaseId is null and type not in ('Reserve','Fee','DepositCorrection')
),
r09 as (select count(*) as n from {{ ref('stg_charge') }} where userChargeId is not null and psptransactionid is null),
r10 as (
    select count(*) as n from {{ ref('silver_settlement') }} s join {{ ref('silver_charge') }} c on s.operationId = c.userChargeId
    where s.processingEntity is distinct from c.processingEntity
),
r11 as (select count(*) as n from {{ ref('stg_charge') }} where processingEntity is null),
r12 as (
    select count(*) as n from (
        select processingEntity from {{ ref('stg_charge') }} where processingEntity is not null
        union all
        select processingEntity from {{ ref('silver_daily_captured') }} where processingEntity is not null
        union all
        select processingEntity from {{ ref('silver_settlement') }} where processingEntity is not null
    ) x
    where processingEntity not in ('1000','1001','1100','NOT_AVAILABLE','INCONSISTENT','BIZENT_NOT_AVAILABLE')
),
r13 as (
    select count(*) as n from {{ ref('stg_charge') }}
    where status not in ('AUTHORISED','CAPTURED','CAPTUREDECLINED','CANCELED','REFUNDED','REFUNDFAILED')
),
r14 as (
    select count(*) as n from {{ ref('silver_daily_captured') }}
    where type not in ('Captured','CaptureDeclined','Authorised','Refunded','RefundFailed','Settled','Chargeback')
),
r15 as (
    select count(*) as n from {{ ref('silver_settlement') }}
    where type not in ('Settled','Chargeback','SecondChargeback','RefundSettled','Reserve','Fee','DepositCorrection')
),
r16 as (
    select count(*) as n from (
        select psp, merchantAccount from {{ ref('stg_charge') }}
        union all
        select psp, merchantAccount from {{ ref('silver_daily_captured') }}
        union all
        select psp, merchantAccount from {{ ref('silver_settlement') }}
    ) x
    where psp is null or merchantAccount is null
),
r17 as (select count(*) as n from {{ ref('stg_charge') }} where userChargeId is null),
r18 as (select count(*) as n from {{ ref('silver_settlement') }} where grossCreditAmount is null and grossDebitAmount is null),
r19 as (select count(*) as n from {{ ref('gold_dq_report_record_count') }}),
r20 as (
    select count(*) as n from (
        select userChargeId, status from {{ ref('stg_charge') }}
        where userChargeId is not null group by userChargeId, status having count(*) > 1
    ) x
),
r22 as (
    select count(*) as n from {{ ref('silver_settlement') }}
    where operationId is null and originalOperationId is null and type not in ('Reserve','Fee','DepositCorrection')
),
r23 as (select count(*) as n from {{ ref('silver_settlement') }} where psp = 'ingenico' and (feeAmount is null or feeAmount = 0)),
r24_psp_list as (
    select count(*) as n from (
        select psp from {{ ref('stg_charge') }}
        union all select psp from {{ ref('silver_daily_captured') }}
        union all select psp from {{ ref('silver_settlement') }}
    ) x
    where psp is not null and psp not in (select psp from {{ source('reference', 'ref_valid_psp') }})
),
r24_dc_sla as (select case when breach_pct >= 1.0 then 1 else 0 end as n from {{ ref('gold_dq_dc_arrival_sla') }}),
r25 as (select count(*) as n from {{ ref('gold_dq_settlement_sla') }}),
r26 as (select count(*) as n from {{ ref('gold_dq_volume_anomaly') }}),
r27 as (select count(*) as n from {{ ref('gold_dq_braintree_settlement_timing') }}),
r28 as (
    select count(*) as n from {{ ref('silver_daily_captured') }}
    where psp = 'braintree' and type = 'Refunded' and (companyAccount is null or companyAccount = '')
),
r29 as (
    select count(*) as n from {{ ref('silver_daily_captured') }}
    where type in ('Captured','Refunded') and (originalOperationId is null or originalOperationId = '')
),
r30 as (
    select count(*) as n from (
        select transactionId, operationId, psp, merchantAccount, batchNumber, transactionAmount, type
        from {{ ref('silver_settlement') }}
        group by transactionId, operationId, psp, merchantAccount, batchNumber, transactionAmount, type
        having count(distinct transactionDate) > 1
    ) x
),
r31 as (
    select count(*) as n from (
        select c.userChargeId as k from {{ ref('silver_charge') }} c join {{ source('reference', 'ref_deprecated_currency') }} d on c.currency = d.currency where date(c.transactionDatetime) >= cast(d.deprecated_from_date as date)
        union all
        select dc.operationId from {{ ref('silver_daily_captured') }} dc join {{ source('reference', 'ref_deprecated_currency') }} d on dc.currency = d.currency where date(dc.transactionDatetime) >= cast(d.deprecated_from_date as date)
        union all
        select s.operationId from {{ ref('silver_settlement') }} s join {{ source('reference', 'ref_deprecated_currency') }} d on s.currency = d.currency where s.transactionDate >= cast(d.deprecated_from_date as date)
    ) x
),
r32 as (select count(*) as n from {{ ref('gold_dq_settlement_batch_gaps') }})

select 'R01' as rule_id, 'Charge without DailyCaptured' as rule_name, 'silver' as layer, n as violation_count from r01
union all select 'R02', 'Charge without Settlement', 'silver', n from r02
union all select 'R03', 'Settlement without Capture', 'silver', n from r03
union all select 'R04', 'Missing Chargebacks', 'silver', n from r04
union all select 'R05', 'PSP->PayReport captured completeness', 'gold', n from r05
union all select 'R06', 'PSP->PayReport settlement completeness', 'gold', n from r06
union all select 'R07', 'PayReport->Gustav gap', 'silver', n from r07
union all select 'R08', 'Settlement missing purchaseId', 'silver', n from r08
union all select 'R09', 'Charge missing psptransactionid', 'silver', n from r09
union all select 'R10', 'Settlement entity != charge entity', 'silver', n from r10
union all select 'R11', 'Null processingEntity', 'silver', n from r11
union all select 'R12', 'processingEntity domain', 'silver', n from r12
union all select 'R13', 'Charge status domain', 'silver', n from r13
union all select 'R14', 'DC type domain', 'silver', n from r14
union all select 'R15', 'Settlement type domain', 'silver', n from r15
union all select 'R16', 'Null psp / merchantAccount', 'silver', n from r16
union all select 'R17', 'Null userChargeId', 'silver', n from r17
union all select 'R18', 'Settlement amount present', 'silver', n from r18
union all select 'R19', 'reportRecordCount mismatch', 'gold', n from r19
union all select 'R20', 'Duplicate charges', 'silver', n from r20
union all select 'R22', 'Orphan settlements', 'silver', n from r22
union all select 'R23', 'Ingenico fee data health (known issue)', 'silver', n from r23
union all select 'R24_PSP_LIST', 'List of PSP', 'silver', n from r24_psp_list
union all select 'R24_DC_SLA', 'DC arrival SLA (T+5)', 'gold', n from r24_dc_sla
union all select 'R25', 'Settlement arrival SLA (T+10)', 'gold', n from r25
union all select 'R26', 'Daily volume anomaly', 'gold', n from r26
union all select 'R27', 'Braintree settlement timing', 'gold', n from r27
union all select 'R28', 'Null companyAccount on DC', 'silver', n from r28
union all select 'R29', 'Null originalOperationId on DC', 'silver', n from r29
union all select 'R30', 'Duplicate settlements', 'silver', n from r30
union all select 'R31', 'Deprecated currency detection', 'silver', n from r31
union all select 'R32', 'Settlement batch gap detection', 'gold', n from r32
