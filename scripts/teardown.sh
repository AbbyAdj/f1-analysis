#!/bin/bash
# Note: NOT using set -e - we want to try all cleanup even if some steps fail

echo "========================================="
echo "⚠️  TEARDOWN - Destroy All Infrastructure"
echo "========================================="
echo ""
echo "This will DELETE:"
echo "  - All Snowflake objects (database, warehouse, roles)"
echo "  - S3 bucket and all data"
echo "  - IAM roles and policies"
echo "  - Local dbt artifacts"
echo ""
read -p "Are you sure? This cannot be undone! (type 'yes' to confirm): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Teardown cancelled."
    exit 0
fi

echo ""
echo "Starting teardown..."

# Get script directory
PROJECT_ROOT="$(dirname "$0")/.."
cd "$PROJECT_ROOT" || exit 1

# Step 1: Clean local artifacts
echo ""
echo "[1/3] Cleaning local artifacts in dbt..."
source venv/bin/activate
cd dbt && dbt clean && cd ..

echo "[1/3] Cleaning local artifacts in data ingestion..."
rm -rf data_ingestion/cache data_ingestion/cleaned_csv

echo "✓ Local artifacts cleaned"

# Step 2: Destroy Snowflake objects (reverse order)
echo ""
echo "[2/3] Destroying Snowflake objects..."
cd snowflake || exit 1

# Drop database (cascades to all schemas and tables)
snow --config-file="./config.toml" sql -q "DROP DATABASE IF EXISTS f1_db CASCADE;"
echo "✓ Database dropped"

# Drop warehouse
snow --config-file="./config.toml" sql -q "DROP WAREHOUSE IF EXISTS f1_wh;"
echo "✓ Warehouse dropped"

# Drop storage integration
snow --config-file="./config.toml" sql -q "DROP INTEGRATION IF EXISTS f1_s3_integration;"
echo "✓ Storage integration dropped"

# Drop role (note: can't drop if it's currently in use)
snow --config-file="./config.toml" sql -q "DROP ROLE IF EXISTS f1_role;" || echo "⚠️  Role may still be in use (run manually later)"

cd ..

# Step 3: Destroy AWS infrastructure
echo ""
echo "[3/3] Destroying AWS infrastructure (S3 + IAM)..."
cd terraform || exit 1

# Empty S3 bucket first (terraform can't destroy non-empty buckets)
echo "Emptying s3 bucket"

BUCKET_NAME=$(terraform output -raw s3_bucket_name 2>/dev/null || echo "")
if [ -n "$BUCKET_NAME" ]; then
    echo "Emptying S3 bucket: $BUCKET_NAME"
    aws s3 rm "s3://$BUCKET_NAME" --recursive || echo "⚠️  Could not empty bucket (may not exist)"
fi

echo "s3 bucket emptied"

terraform destroy -auto-approve
echo "✓ Infrastructure destroyed"

echo ""
echo "========================================="
echo "✅ TEARDOWN COMPLETE"
echo "========================================="
echo ""
echo "All infrastructure has been destroyed."
echo "Your local code and configuration files remain intact."
echo ""
