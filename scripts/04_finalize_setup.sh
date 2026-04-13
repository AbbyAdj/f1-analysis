#!/bin/bash
set -e  # Exit on error

echo "========================================="
echo "04: Finalizing Setup (Terraform + Snowflake)"
echo "========================================="

# Navigate to project root
PROJECT_ROOT="$(dirname "$0")/.."
cd "$PROJECT_ROOT" || exit 1

echo ""
echo "[1/3] Re-applying Terraform with updated variables..."
cd terraform || exit 1
terraform apply -auto-approve
cd ..

echo ""
echo "Waiting 10s for IAM policy to propagate..."
for i in {10..1}; do
    printf "\r  %2d seconds remaining..." "$i"
    sleep 1
done
printf "\r  Done!                    \n"

echo ""
echo "[2/3] Creating Snowflake stage..."
cd snowflake || exit 1
snow --config-file="./config.toml" sql -f 20260329_004b_create_stage.sql

echo ""
echo "[3/3] Loading raw data from S3 into Snowflake..."
snow --config-file="./config.toml" sql -f 20260329_005_load_raw_data.sql

echo ""
echo "✅ Setup finalized!"
echo "  - IAM trust policy updated"
echo "  - Snowflake stage created"
echo "  - Raw data loaded from S3"
echo ""
echo "Next step: Run dbt transformations"
echo "  ./05_run_dbt.sh"
echo ""
