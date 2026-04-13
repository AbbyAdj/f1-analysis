#!/bin/bash
set -e  # Exit on error

echo "========================================="
echo "01: Setting Up Infrastructure (Terraform)"
echo "========================================="

# Navigate to terraform directory
cd "$(dirname "$0")/../terraform" || exit 1

echo ""
echo "[1/2] Initializing Terraform..."
terraform init

echo ""
echo "[2/2] Applying Terraform configuration..."
echo "This will create:"
echo "  - S3 bucket for raw data"
echo "  - IAM role for Snowflake access"
echo ""
terraform apply -auto-approve

echo ""
echo "✅ Infrastructure setup complete!"
echo "S3 bucket and IAM role created successfully."
echo "Please copy the storage_aws_role_arn and update the create_integration.sql file with the value."
echo ""
