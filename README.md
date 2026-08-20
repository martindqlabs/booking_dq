# booking_dq — Snowflake DQ lineage project

dbt project that builds Silver and Gold as real dbt models on top of the
Bronze/Reference tables already loaded into Snowflake (`BOOKING_DQ`
database), giving full source → silver → gold lineage and running all 32
data-quality rules (41 test nodes) live against Snowflake.

Bronze itself is **not** built by this project — it's a physical landing
layer already in `BOOKING_DQ.BRONZE` (see [`models/_sources.yml`](models/_sources.yml)).
This project picks up from there.

## Setting up in dbt Cloud

1. **New project** → connect this repo (`martindqlabs/booking_dq`) as the
   git repository. Leave the project subdirectory blank — `dbt_project.yml`
   is at the repo root.
2. **Connection**: Snowflake.
   - Account: `tr68481.us-east-2.aws`
   - Database: `BOOKING_DQ`
   - Warehouse: `DQLABS_QA`
   - Role: leave default unless you need a specific one
3. **Credentials** (per-developer or deployment credentials, entered in the
   dbt Cloud UI — never in this repo):
   - Auth: Username & Password
   - Username: `USER_QA`
   - Password: (ask for it — not stored here)
   - Schema: your dev schema, e.g. `GOLD` (dbt Cloud requires a default
     dev schema even though every model here sets its own `+schema`)
4. Run `dbt run` then `dbt test` in the IDE or a deploy job. Expect 19/19
   models to build and 41 test nodes to finish **35 failed / 3 warned / 3
   passed** — those "failures" are the seeded DQ violations this project
   is built to catch, not a broken build.
5. `dbt docs generate` (dbt Cloud does this automatically on job runs, or
   on demand in the IDE) for the full source → silver → gold lineage graph.

## Structure

- `models/_sources.yml` — the `bronze` source (physical tables in
  `BOOKING_DQ.BRONZE`) and `reference` source (`ref_valid_psp`,
  `ref_deprecated_currency` in `BOOKING_DQ.REFERENCE`).
- `models/silver/*.sql` — standardizes and conforms the Bronze sources.
  Includes SILVER-BUG-1 (`silver_charge.sql`), a deliberate dedup defect.
- `models/gold/*.sql` — facts, the 7 `gold_dq_*` rule-check models, and
  `dq_scorecard` (one row per rule with a live violation count). Includes
  GOLD-BUG-1 (`fact_settlement_enriched_buggy.sql`), a deliberate loose-join
  defect kept isolated from the real `fact_settlement`.
- `tests/dq/silver/`, `tests/dq/gold/` — the singular DQ tests (R01-R32).
- `macros/generate_schema_name.sql` — makes models land in exactly
  `BOOKING_DQ.SILVER` / `BOOKING_DQ.GOLD` (no target-schema prefix).

## Notes

- `date_diff('day', a, b)` from the DuckDB-based sandbox version of this
  project is `datediff('day', a, b)` here (Snowflake's native name).
- R02's DQ check is a `LEFT JOIN … WHERE IS NULL` rather than a correlated
  `NOT EXISTS` — Snowflake can't evaluate a `NOT EXISTS` whose join
  condition mixes outer/inner columns inside `datediff()` ("Unsupported
  subquery type"). Same result, different shape.
