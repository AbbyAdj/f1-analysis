#!/bin/bash
set -e  # Exit on error

echo "========================================="
echo "05: Running dbt Transformations"
echo "========================================="

# Navigate to project root
PROJECT_ROOT="$(dirname "$0")/.."
cd "$PROJECT_ROOT" || exit 1

# Check if venv exists
if [ ! -d "venv" ]; then
    echo "❌ Error: Virtual environment not found at venv/"
    echo "Please create it with: python -m venv venv"
    exit 1
fi

# Activate virtual environment
echo "[1/3] Activating virtual environment..."
source venv/bin/activate

# Navigate to dbt directory
cd dbt || exit 1

echo ""
echo "[2/3] Running dbt build (models + tests)..."
dbt deps
dbt build

echo ""
echo "[3/3] Generating dbt documentation..."
dbt docs generate

echo ""
echo "✅ dbt transformations complete!"
echo ""
echo "To view documentation:"
echo "  cd dbt && dbt docs serve"
echo ""
