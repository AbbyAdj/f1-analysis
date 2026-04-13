# F1 Data Pipeline & Analytics

An end-to-end data engineering pipeline that ingests Formula 1 race data, loads it into a cloud data warehouse, and transforms it into analytics-ready models.

---

## Overview

This project pulls live F1 season data from the [Jolpica API](https://github.com/jolpica/jolpica-f1/blob/main/docs/README.md), stores it in AWS S3, loads it into Snowflake, and transforms it using dbt into a set of clean, tested analytical models. The result is a fully queryable data warehouse covering race results, driver standings, and championship progression — ready for reporting or visualisation.

Built as a portfolio project to demonstrate modern data engineering practices across the full stack: infrastructure-as-code, cloud storage, data warehousing, and transformation pipelines.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Data Source | [Jolpica F1 API](https://jolpi.ca/) |
| Ingestion | Python (requests, pandas, boto3) |
| Cloud Storage | AWS S3 |
| Infrastructure | Terraform |
| Data Warehouse | Snowflake |
| Transformations | dbt (dbt-core 1.11, dbt-snowflake 1.11) |
| Orchestration | Bash deployment scripts |

---

## Architecture

```
Jolpica F1 API
      │
      ▼
 Python ETL
 (extract → clean → upload)
      │
      ▼
 AWS S3 (raw CSV files)
      │
      ▼
 Snowflake (raw schema)
 COPY INTO via external stage
      │
      ▼
 dbt Transformations
 ┌─────────────────────────────┐
 │  Staging  →  Intermediate  │
 │              ↓             │
 │           Marts            │
 └─────────────────────────────┘
      │
      ▼
 Analytics-ready tables & views
 (dimensions, facts, championship progression)
```

---

## Project Structure

```
f1-analysis/
├── data_ingestion/          # Python ETL scripts
│   ├── extract_api.py       # Fetch data from Jolpica API
│   ├── clean_data.py        # JSON → CSV transformation
│   └── upload_to_s3.py      # Upload cleaned CSVs to S3
│
├── terraform/               # Infrastructure as code
│   ├── main.tf              # S3 bucket + IAM role
│   └── terraform.tfvars     # Snowflake ARN + external ID (not committed)
│
├── snowflake/               # Snowflake setup scripts
│   ├── 001_setup_roles.sql
│   ├── 002_setup_warehouse.sql
│   ├── 003_setup_database.sql
│   ├── 004a_create_integration.sql
│   ├── 004b_create_stage.sql
│   └── 005_load_raw_data.sql
│
├── dbt/
│   └── models/
│       ├── staging/         # Clean + typed raw tables (views)
│       ├── intermediate/    # Joined, enriched results (views)
│       └── marts/           # Final analytical models (tables)
│
├── scripts/                 # Deployment automation
│   ├── 01_setup_infrastructure.sh
│   ├── 02_run_etl.sh
│   ├── 03_setup_snowflake.sh
│   ├── 04_finalize_setup.sh
│   ├── 05_run_dbt.sh
│   ├── deploy_all.sh        # Orchestrator
│   └── teardown.sh          # Destroy all infrastructure
│
└── requirements.txt
```

---

## Data Model

### Staging
Thin views over raw Snowflake tables — casting types and renaming columns.

| Model | Description |
|---|---|
| `stg_drivers` | Driver details (name, nationality, DOB) |
| `stg_constructors` | Constructor/team details |
| `stg_races` | Race schedule with timestamps |
| `stg_race_results` | Lap times, positions, points per race |

### Intermediate
| Model | Description |
|---|---|
| `int_race_results_enriched` | Joins all four staging models; adds derived flags: `IS_WINNER`, `IS_PODIUM`, `IS_DNF`, `IS_POINTS_FINISH`, `POSITIONS_GAINED` |

### Marts
| Model | Description |
|---|---|
| `dim_drivers` | Driver dimension |
| `dim_constructors` | Constructor dimension |
| `dim_races` | Race dimension |
| `fct_race_results` | Fact table of all race results |
| `driver_championship_progression` | Cumulative points and ranking per driver per round |

---

## Prerequisites

- Python 3.11+
- [Terraform](https://developer.hashicorp.com/terraform/install)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- [Snowflake account](https://signup.snowflake.com/)
- [Snowflake CLI (`snow`)](https://docs.snowflake.com/en/developer-guide/snowflake-cli/index)

---

## Setup

### 1. Clone the repo and install dependencies

```bash
cd f1-analysis
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt
```

### 2. Configure environment variables

Create a `.env` file in the root using `.env-example`

### 3. Configure Snowflake CLI

Use `snowflake/config-example.toml` to create `snowflake/config.toml` and fill in your Snowflake account details.

### 4. Run the pipeline

**First-time setup** (provisions all infrastructure):
NOTE THAT ALL SCRIPTS FOR EACH PROCESS ARE AVAILABLE TO BE RUN INDEPENDENTLY.

```bash
cd scripts
./deploy_all.sh 2025 setup
```

This pauses after creating the Snowflake storage integration. You'll need to copy the `STORAGE_AWS_IAM_USER_ARN` and `STORAGE_AWS_EXTERNAL_ID` values from the stdout. 

Alternatively you could also run:

```bash
snow --config-file ./config.toml sql -q "DESC INTEGRATION f1_s3_integration;"
```

Update `terraform/terraform.tfvars` with those values, then finalize:

```bash
./deploy_all.sh 2025 finalize
```

**Subsequent runs** (refresh data only):

```bash
./deploy_all.sh 2025 incremental
```

**Teardown** (destroy all infrastructure):

```bash
./teardown.sh
```

---

## Sample Queries

**Top 5 drivers by points after the final round:**

```sql
SELECT
    DRIVER_FULL_NAME,
    CONSTRUCTOR_NAME,
    MAX(CUM_RACE_POINTS) AS TOTAL_POINTS
FROM f1_db.f1_schema.driver_championship_progression
WHERE SEASON = 2025
GROUP BY DRIVER_FULL_NAME, CONSTRUCTOR_NAME
ORDER BY TOTAL_POINTS DESC
LIMIT 5;
```

**Races with the most overtakes (positions gained):**

```sql
SELECT
    RACE_NAME,
    CIRCUIT_NAME,
    SUM(GREATEST(POSITIONS_GAINED, 0)) AS TOTAL_POSITIONS_GAINED
FROM f1_db.f1_schema.fct_race_results
WHERE SEASON = 2025
GROUP BY RACE_NAME, CIRCUIT_NAME
ORDER BY TOTAL_POSITIONS_GAINED DESC;
```

**DNF rate by constructor:**

```sql
SELECT
    CONSTRUCTOR_NAME,
    COUNT(*) AS TOTAL_ENTRIES,
    SUM(CASE WHEN IS_DNF THEN 1 ELSE 0 END) AS DNFS,
    ROUND(100.0 * SUM(CASE WHEN IS_DNF THEN 1 ELSE 0 END) / COUNT(*), 1) AS DNF_RATE_PCT
FROM f1_db.f1_schema.fct_race_results
WHERE SEASON = 2025
GROUP BY CONSTRUCTOR_NAME
ORDER BY DNF_RATE_PCT DESC;
```

---

## Troubleshooting

**`sts:AssumeRole` error when loading data from S3**

Snowflake's IAM user ARN and external ID change every time the storage integration is recreated. After running `setup`, always check the current values before running `finalize`:

```bash
snow --config-file ./config.toml sql -q "DESC INTEGRATION f1_s3_integration;"
```

Copy `STORAGE_AWS_IAM_USER_ARN` and `STORAGE_AWS_EXTERNAL_ID` into `terraform/terraform.tfvars`, then re-run `finalize`.

---

**`sts:AssumeRole` error immediately after `terraform apply`**

AWS IAM policy changes take a few seconds to propagate globally. The `finalize` script includes a 10-second wait after Terraform applies — if you're running steps manually, just wait ~10 seconds before creating the Snowflake stage.

---

**`MalformedPolicyDocument: Invalid principal` error in Terraform**

Usually caused by a trailing space in the `snowflake_iam_user_arn` value in `terraform.tfvars`. Make sure there are no leading or trailing spaces around the ARN value.

---

**`dbt docs generate` fails (exit code 2)**

Run `dbt deps` first to install packages, then retry:

```bash
cd dbt
dbt deps
dbt docs generate
```

---

**Terraform can't destroy S3 bucket (`BucketNotEmpty`)**

The teardown script empties the bucket before destroying it. If running Terraform manually, empty the bucket first:

```bash
aws s3 rm s3://your-bucket-name --recursive
terraform destroy -auto-approve
```

---

**Jolpica API rate limiting (429 errors)**

The Jolpica API enforces rate limits. The ETL script includes a 1-second sleep between paginated requests, but if you hit a 429, wait a minute and retry. Avoid running the ETL multiple times in quick succession for the same year.

---

**AWS CLI not configured / wrong credentials**

Before running any scripts, make sure the AWS CLI is configured and pointing at the right account:

```bash
aws sts get-caller-identity
```

The `Account` field should match the account ID you intend to deploy to. If not, check your `~/.aws/credentials` or set the correct profile with `export AWS_PROFILE=your-profile`.

---

**Terraform state out of sync**

If infrastructure was partially destroyed or created outside of Terraform, the state file may be stale. Run `terraform plan` to see what Terraform thinks exists vs. what's actually there. If needed, use `terraform state rm` to remove orphaned resources from state before re-applying.

---

**Snowflake CLI auth errors**

Make sure `snowflake/config.toml` exists (copy from `config-example.toml`) and that your account identifier uses the correct format: `ORGNAME-ACCOUNTNAME` (e.g. `GHWKFMD-XC55200`). You can verify connectivity with:

```bash
snow --config-file ./config.toml connection test
```
