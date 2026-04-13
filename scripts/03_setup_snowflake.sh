#!/bin/bash
set -e  # Exit on error

echo "========================================="
echo "03: Setting Up Snowflake (Initial)"
echo "========================================="

# Navigate to snowflake directory
cd "$(dirname "$0")/../snowflake" || exit 1

# Check if config.toml exists
if [ ! -f "config.toml" ]; then
    echo "❌ Error: config.toml file not found"
    echo "Please create config.toml with required credentials"
    echo "Use the config-example.toml file to set this up"
    exit 1
fi

echo ""
echo "[1/5] Creating Snowflake roles and permissions..."
snow --config-file="./config.toml" sql -f 20260329_001_setup_roles.sql

echo ""
echo "[2/5] Creating Snowflake warehouse..."
snow --config-file="./config.toml" sql -f 20260329_002_setup_warehouse.sql

echo ""
echo "[3/5] Creating Snowflake database and schemas..."
snow --config-file="./config.toml" sql -f 20260329_003_setup_database.sql

echo ""
echo "[4/5] Creating storage integration..."
snow --config-file="./config.toml" sql -f 20260329_004a_create_integration.sql

echo ""
echo "========================================="
echo "⚠️  MANUAL ACTION REQUIRED"
echo "========================================="
echo ""
echo "The storage integration has been created."
echo "You should see output above with these two values:"
echo ""
echo "  - STORAGE_AWS_IAM_USER_ARN"
echo "  - STORAGE_AWS_EXTERNAL_ID"
echo ""
echo "NEXT STEPS:"
echo "1. Copy the STORAGE_AWS_IAM_USER_ARN value"
echo "2. Copy the STORAGE_AWS_EXTERNAL_ID value"
echo "3. Edit or create the terraform/terraform.tfvars file and paste these values"
echo "snowflake_external_id=STORAGE_AWS_EXTERNAL_ID"
echo "snowflake_iam_user_arn=STORAGE_AWS_IAM_USER_ARN"
echo "4. Save the file"
echo ""
echo "After completing these steps, run:"
echo "  ./04_finalize_setup.sh"
echo ""
echo "========================================="
