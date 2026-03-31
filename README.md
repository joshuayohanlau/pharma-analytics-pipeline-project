# Pharma Analytics Pipeline

An end-to-end analytics engineering project. Takes raw pharmaceutical data from 9 source systems, loads it into PostgreSQL, and transforms it into a dimensional model using dbt. Covers prescriptions, adverse events, clinical trials, inventory, and commercial sales performance.

Built this to apply dbt Core concepts in a realistic healthcare/pharma scenario: incremental models, SCD Type 2 snapshots, custom macros, model contracts, and 77 automated tests across the full pipeline.

## What this does

A pharmaceutical company has operational data spread across 9 source tables: drugs, prescriptions, prescribers, patients, pharmacies, adverse events, clinical trials, inventory, and sales reps. The pipeline transforms this into analytics-ready dimensions and facts.

This project:
- Loads ~160 records across 9 raw tables into a PostgreSQL `raw` schema
- Builds 9 staging models that clean, compute derived fields, and standardise the data
- Passes through 3 intermediate ephemeral models that join and classify records with business logic
- Transforms it into a star schema with 4 dimension tables, 4 fact tables, and 1 executive report
- Tracks historical changes with 2 SCD Type 2 snapshots (timestamp + check strategies)
- Loads 4 CSV seed files as reference data (drug products, therapeutic classes, territories, ICD-10 codes)
- Adds 77 automated tests: generic, singular, custom, and dbt_utils
- Implements model contracts, custom macros, hooks, and full dbt docs

## Data model

The core fact table (`fct_prescriptions`) sits at the individual prescription fill grain: one row per prescription. It connects to four dimensions: drugs, prescribers, patients, and pharmacies.

Additional fact tables cover adverse event reporting (`fct_adverse_events`), clinical trial outcomes (`fct_trial_outcomes`), and territory-level sales performance (`fct_sales_performance`).

## Project structure

```
pharma_analytics/
├── models/
│   ├── staging/
│   │   ├── _stg__sources.yml              # source definitions for all 9 raw tables + freshness
│   │   ├── _stg__models.yml               # staging model docs + tests
│   │   ├── stg_drugs.sql                  # converts unit_price_cents to dollars
│   │   ├── stg_prescriptions.sql          # converts cost/copay cents to dollars
│   │   ├── stg_adverse_events.sql         # computes days_to_report from event dates
│   │   ├── stg_clinical_trials.sql        # computes enrollment_pct with zero-division guard
│   │   ├── stg_patients.sql               # computes age_years from date_of_birth
│   │   ├── stg_prescribers.sql            # concatenates first/last name into full_name
│   │   ├── stg_pharmacies.sql             # clean passthrough with type validation
│   │   ├── stg_inventory.sql              # computes quantity_available and needs_reorder flag
│   │   └── stg_sales_reps.sql             # concatenates first/last name into full_name
│   ├── intermediate/
│   │   ├── int_prescription_enriched.sql  # 4-way join: prescriptions + drugs + prescribers + patients
│   │   ├── int_adverse_event_classified.sql # severity scoring (serious=3, moderate=2, mild=1)
│   │   └── int_trial_enrollment.sql       # enrollment risk classification + duration tracking
│   └── marts/
│       ├── core/
│       │   ├── _core__models.yml          # model contracts + column-level docs + tests
│       │   ├── dim_drugs.sql              # joins therapeutic_classes seed, computes price_tier
│       │   ├── dim_patients.sql           # age group segmentation (Pediatric → Senior)
│       │   ├── dim_pharmacies.sql         # is_specialty_pharmacy flag
│       │   ├── dim_prescribers.sql        # joins territories seed for region mapping
│       │   ├── fct_prescriptions.sql      # incremental (delete+insert), plan_paid calculation
│       │   └── fct_adverse_events.sql     # joins patient demographics to classified events
│       ├── clinical/
│       │   ├── dim_trials.sql             # enrollment status + trial duration from intermediate
│       │   └── fct_trial_outcomes.sql     # joins trial data with aggregated adverse event counts
│       └── commercial/
│           ├── fct_sales_performance.sql  # monthly territory aggregations (revenue, Rx count, reach)
│           └── rpt_territory_dashboard.sql # executive roll-up: months active, peak metrics, avg revenue
├── seeds/
│   ├── drug_products.csv                  # 15 drug reference records
│   ├── therapeutic_classes.csv            # 8 therapeutic classification codes
│   ├── territories.csv                    # 8 sales territories with regions
│   └── icd10_codes.csv                    # 11 diagnosis code mappings
├── snapshots/
│   ├── snap_drug_status.sql               # check strategy: tracks approval_status + price changes
│   └── snap_inventory_levels.sql          # timestamp strategy: tracks inventory level changes
├── macros/
│   ├── cents_to_dollars.sql               # reusable currency conversion with configurable precision
│   ├── generate_surrogate_key.sql         # MD5 hash surrogate key generator
│   ├── test_positive_value.sql            # custom generic test for numeric columns
│   └── log_run_event.sql                  # on-run-start/end hook logging
├── tests/
│   ├── assert_adverse_event_has_drug.sql  # every adverse event must reference a valid drug
│   └── assert_prescription_date_not_future.sql  # no fill dates in the future
├── analyses/
│   └── top_prescribed_drugs_by_region.sql # ad-hoc: top 5 drugs per territory by Rx volume
└── dbt_project.yml
```

## Staging transformations

Every staging model follows the same CTE pattern: `source` CTE reads from raw, `renamed` CTE applies transformations, final select from renamed.

| Staging Model | Key Transformations |
|---------------|-------------------|
| stg_drugs | Converts `unit_price_cents` → `unit_price_dollars` (cents / 100, rounded to 2) |
| stg_prescriptions | Converts `total_cost_cents` → `total_cost_dollars`, `copay_cents` → `copay_dollars` |
| stg_adverse_events | Computes `days_to_report` as difference between reported and event dates |
| stg_clinical_trials | Computes `enrollment_pct` with zero-division guard on target enrollment |
| stg_patients | Computes `age_years` dynamically from date_of_birth using `date_part` |
| stg_prescribers | Concatenates first/last name into `full_name` |
| stg_pharmacies | Clean passthrough with pharmacy type validation |
| stg_inventory | Computes `quantity_available` (on_hand - reserved) and `needs_reorder` boolean flag |
| stg_sales_reps | Concatenates first/last name into `full_name` |

## Intermediate business logic

These are ephemeral models — they compile into CTEs and never create tables in the database.

| Intermediate Model | What It Does |
|-------------------|-------------|
| int_prescription_enriched | 4-way left join (prescriptions + drugs + prescribers + patients). Computes `plan_paid_dollars` as total cost minus copay. Renames to business-friendly column names. |
| int_adverse_event_classified | Joins adverse events with drug data. Assigns numeric `severity_score` (serious=3, moderate=2, mild=1). Flags `is_serious_outcome` for hospitalisations, life-threatening events, and deaths. |
| int_trial_enrollment | Joins trials with drug data. Classifies `enrollment_status` as On Track (>=90%), At Risk (>=60%), or Behind. Computes `trial_duration_days` using end date or current date for ongoing trials. |

## Materialisation strategy

| Layer | Materialisation | Why |
|-------|----------------|-----|
| Staging | **view** | Lightweight, always reflects current raw data, no storage overhead |
| Intermediate | **ephemeral** | Business logic that only exists as CTEs inside downstream models |
| Marts | **table** | Pre-computed for fast queries, involves joins and calculations |
| fct_prescriptions | **incremental** (delete+insert) | Largest fact table, only processes new records on subsequent runs |
| Snapshots | **snapshot** | SCD Type 2 change tracking with dbt-managed valid_from/valid_to columns |

## dbt features demonstrated

| Feature | Where in this project |
|---------|----------------------|
| **source()** | All 9 staging models reference raw tables via `{{ source('raw', 'table') }}` |
| **ref()** | All intermediate and mart models use `{{ ref('model_name') }}` for DAG dependencies |
| **Incremental models** | `fct_prescriptions.sql` — `is_incremental()`, `{{ this }}`, `unique_key`, `delete+insert` strategy |
| **Snapshots (SCD2)** | `snap_drug_status` (check strategy), `snap_inventory_levels` (timestamp strategy) |
| **Seeds** | 4 CSV reference files loaded into `reference` schema with explicit column types |
| **Model contracts** | `dim_drugs` enforces column data types at build time (`contract.enforced: true`) |
| **Custom macros** | `cents_to_dollars()`, `generate_surrogate_key()` — reusable Jinja functions |
| **Custom generic test** | `test_positive_value` — tests any numeric column for negative values |
| **Singular tests** | 2 standalone SQL tests returning failing rows |
| **dbt_utils package** | `dbt_utils.accepted_range` test on `total_cost_dollars` |
| **Hooks** | `on-run-start` / `on-run-end` call `log_run_event()` macro for run tracking |
| **doc() blocks** | Column-level documentation using `{% docs %}` markdown blocks |
| **Source freshness** | Configured with `warn_after: 24h`, `error_after: 48h` on all raw sources |
| **Analyses** | Ad-hoc query in `analyses/` — compiled but never materialised |
| **Config hierarchy** | Project-level in `dbt_project.yml`, model-level in `config()` blocks |

## KPIs supported

Once the pipeline runs, the mart layer supports:

- **Total Revenue** — SUM(total_cost_dollars) from fct_prescriptions
- **Prescription Volume** — COUNT by drug, prescriber, territory, or time period
- **New vs Refill Mix** — Prescription counts filtered on is_new_prescription flag
- **Plan vs Patient Cost Split** — plan_paid_dollars vs copay_dollars breakdown
- **Adverse Event Rate** — Event counts by drug, severity, and outcome type
- **Safety Signal Detection** — Serious outcome flags and severity scoring per drug
- **Clinical Trial Enrollment** — On Track / At Risk / Behind classification per trial
- **Territory Performance** — Monthly revenue, unique prescribers, unique patients per region
- **Sales Rep Productivity** — Revenue and Rx volume attributed to active reps
- **Inventory Reorder Alerts** — Boolean needs_reorder flag based on quantity vs reorder point

## How to run

Requires PostgreSQL and dbt Core with the postgres adapter.

```bash
# load raw data
psql -U postgres -c "CREATE DATABASE pharma_analytics;"
psql -U postgres -d pharma_analytics -f setup/create_raw_schema.sql
psql -U postgres -d pharma_analytics -f setup/seed_raw_data.sql

# install dbt postgres adapter
pip install dbt-postgres

# configure connection in profiles.yml
# (see profiles.yml in project root)

# run the pipeline
dbt deps            # install packages (dbt_utils)
dbt seed            # load reference CSVs
dbt build           # run all models + tests in DAG order
dbt docs generate   # generate documentation
dbt docs serve      # view DAG + docs at localhost:8080
```

## Test coverage

77 automated tests across the pipeline:

| Test Type | Count | Examples |
|-----------|-------|---------|
| **not_null** | 18 | All primary keys and critical foreign keys |
| **unique** | 18 | All primary keys and natural keys (NPI, member_id) |
| **accepted_values** | 8 | severity, phase, status, insurance_type, pharmacy_type, age_group, therapeutic_class |
| **relationships** | 2 | drug_id in prescriptions and adverse events → stg_drugs |
| **dbt_utils.accepted_range** | 1 | total_cost_dollars >= 0 |
| **singular tests** | 2 | No future prescription dates, every adverse event has a drug |
| **source tests** | 18 | unique + not_null on all 9 raw table primary keys |

## Tools used

- **PostgreSQL 18** — data warehouse
- **dbt Core 1.11** — transformation layer
- **dbt_utils 1.3** — testing and utility package
- **SQL** — staging transforms, dimensional modelling, business logic
