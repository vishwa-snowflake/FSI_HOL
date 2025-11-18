#!/bin/bash

# FSI Cortex Assistant - Complete Deployment Script
# Self-contained deployment for quickstart package

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SQL_DIR="$SCRIPT_DIR/../sql"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  FSI Cortex Assistant - Quickstart Deployment                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check if SnowCLI is installed
if ! command -v snow &> /dev/null; then
    echo "❌ SnowCLI not found. Please install:"
    echo "   pip install snowflake-cli-labs"
    exit 1
fi

echo "✓ SnowCLI found"
echo ""

# Verify SQL files exist
if [ ! -f "$SQL_DIR/01_configure_account.sql" ]; then
    echo "❌ SQL files not found in $SQL_DIR"
    echo "   Package may be incomplete. Please re-download."
    exit 1
fi

# Get connection name
echo "Available connections:"
snow connection list
echo ""
read -p "Enter connection name to use: " CONNECTION_NAME
echo ""

# Confirm deployment
echo "This will deploy:"
echo "  • 11 companies with financial data"
echo "  • 4,391 social media posts + news articles"
echo "  • 22 annual reports with charts"
echo "  • 4 audio files, 7 images"
echo "  • 20+ tables, 5 search services"
echo "  • 1 Streamlit app, 4 Snowflake notebooks"
echo "  • SnowMail email viewer (Native App)"
echo "  • ML infrastructure (GPU compute pools)"
echo ""
read -p "Continue with deployment? (y/N): " CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "Deployment cancelled."
    exit 0
fi

echo ""
echo "[1/8] Configuring account..."
snow sql -f "$SQL_DIR/01_configure_account.sql" -c "$CONNECTION_NAME"
echo "✓ Account configured"

echo ""
echo "[2/8] Loading data foundation (this may take 10-15 minutes)..."
snow sql -f "$SQL_DIR/02_data_foundation.sql" -c "$CONNECTION_NAME"
echo "✓ Data foundation loaded"

echo ""
echo "[3/8] Deploying Cortex Analyst..."
snow sql -f "$SQL_DIR/03_deploy_cortex_analyst.sql" -c "$CONNECTION_NAME"
echo "✓ Cortex Analyst deployed"

echo ""
echo "[4/8] Deploying Streamlit app..."
snow sql -f "$SQL_DIR/04_deploy_streamlit.sql" -c "$CONNECTION_NAME"
echo "✓ Streamlit deployed"

echo ""
echo "[5/8] Deploying Snowflake notebooks..."
snow sql -f "$SQL_DIR/05_deploy_notebooks.sql" -c "$CONNECTION_NAME"
echo "✓ Notebooks deployed"

echo ""
echo "[6/8] Deploying Document AI stages..."
snow sql -f "$SQL_DIR/06_deploy_documentai.sql" -c "$CONNECTION_NAME"
echo "✓ Document AI deployed"

echo ""
echo "[7/8] Deploying SnowMail email viewer..."
snow sql -f "$SQL_DIR/07_deploy_snowmail.sql" -c "$CONNECTION_NAME"
echo "✓ SnowMail deployed"

echo ""
echo "[8/8] Setting up ML infrastructure..."
snow sql -f "$SQL_DIR/08_setup_ml_infrastructure.sql" -c "$CONNECTION_NAME"
echo "✓ ML infrastructure deployed"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  ✅ DEPLOYMENT COMPLETE!                                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  1. Open Snowflake UI"
echo "  2. Navigate to: AI & ML Studio → Streamlit → STOCKONE_AGENT"
echo "  3. Start asking questions!"
echo ""
echo "Documentation: See ../../../quickstart.md for detailed usage"
echo ""
