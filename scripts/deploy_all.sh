#!/bin/bash
set -e  # Exit on error

echo "========================================="
echo "F1 Analysis - Full Deployment Pipeline"
echo "========================================="

# Default values
YEAR=${1:-2025}
MODE=${2:-setup}

# Get script directory
SCRIPT_DIR="$(dirname "$0")"

echo ""
echo "Configuration:"
echo "  Year: $YEAR"
echo "  Mode: $MODE"
echo ""

case "$MODE" in
    setup)
        echo "Running SETUP mode (Steps 01-03)..."
        echo "This will set up infrastructure and pause for manual configuration."
        echo ""
        
        "$SCRIPT_DIR/01_setup_infrastructure.sh"
        "$SCRIPT_DIR/02_run_etl.sh" "$YEAR"
        "$SCRIPT_DIR/03_setup_snowflake.sh"
        
        echo ""
        echo "========================================="
        echo "SETUP COMPLETE - MANUAL ACTION REQUIRED"
        echo "========================================="
        echo ""
        echo "You've completed the initial setup."
        echo "Follow the instructions above to update terraform.tfvars"
        echo ""
        echo "After updating terraform.tfvars, run:"
        echo "  ./deploy_all.sh $YEAR finalize"
        echo ""
        ;;
        
    finalize)
        echo "Running FINALIZE mode (Steps 04-05)..."
        echo "This completes the setup and runs dbt transformations."
        echo ""
        
        "$SCRIPT_DIR/04_finalize_setup.sh"
        "$SCRIPT_DIR/05_run_dbt.sh"
        
        echo ""
        echo "========================================="
        echo "🎉 DEPLOYMENT COMPLETE!"
        echo "========================================="
        echo ""
        echo "Your F1 Analysis pipeline is fully deployed:"
        echo "  ✅ Infrastructure (S3 + IAM + Snowflake)"
        echo "  ✅ Raw data loaded"
        echo "  ✅ dbt models built and tested"
        echo ""
        echo "Next steps:"
        echo "  - View dbt docs: cd dbt && dbt docs serve"
        echo "  - Query your marts in Snowflake"
        echo "  - Build visualizations!"
        echo ""
        ;;
        
    incremental)
        echo "Running INCREMENTAL mode (ETL + dbt only)..."
        echo "Assumes infrastructure already exists."
        echo ""
        
        "$SCRIPT_DIR/02_run_etl.sh" "$YEAR"
        "$SCRIPT_DIR/05_run_dbt.sh"
        
        echo ""
        echo "✅ Incremental deployment complete!"
        echo "Data refreshed for year: $YEAR"
        echo ""
        ;;
        
    *)
        echo "❌ Invalid mode: $MODE"
        echo ""
        echo "Usage:"
        echo "  ./deploy_all.sh [YEAR] [MODE]"
        echo ""
        echo "Modes:"
        echo "  setup       - Run initial setup (01-03), pause for manual config"
        echo "  finalize    - Complete setup (04-05) after manual config"
        echo "  incremental - Refresh data only (02 + 05), skip infrastructure"
        echo ""
        echo "Examples:"
        echo "  ./deploy_all.sh 2025 setup"
        echo "  ./deploy_all.sh 2025 finalize"
        echo "  ./deploy_all.sh 2024 incremental"
        echo ""
        exit 1
        ;;
esac
