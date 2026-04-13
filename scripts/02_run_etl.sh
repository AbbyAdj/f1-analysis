#!/bin/bash
set -e  # Exit on error

echo "========================================="
echo "02: Running ETL Pipeline"
echo "========================================="

# Default year
YEAR=${1:-2025}

echo ""
echo "Configuration:"
echo "  Year: $YEAR"
echo ""

# Navigate to project root
PROJECT_ROOT="$(dirname "$0")/.."
cd "$PROJECT_ROOT" || exit

# Check if venv exists
if [ ! -d "venv" ]; then
    echo "❌ Error: Virtual environment not found at venv/"
    echo "Please create it with: python -m venv venv"
    exit 1
fi

# Activate virtual environment
echo "[1/4] Activating virtual environment..."
source venv/bin/activate

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "❌ Error: .env file not found"
    echo "Please create .env with required credentials"
    exit 1
fi

# Navigate to data_ingestion directory
cd data_ingestion || exit 1

echo ""
echo "[2/4] Extracting data from Jolpica API (Year: $YEAR)..."
python extract_api.py --year "$YEAR"

echo ""
echo "[3/4] Cleaning and transforming data..."
python clean_data.py --year "$YEAR"

echo ""
echo "[4/4] Uploading CSV files to S3..."
python upload_to_s3.py

echo ""
echo "✅ ETL pipeline complete!"
echo "Data extracted, cleaned, and uploaded to S3 successfully."
echo ""
