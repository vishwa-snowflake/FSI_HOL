#!/bin/bash
#
# FSI Cortex Assistant - Quick Deploy for Snowflake Free Trial
# 
# This script deploys the FSI Cortex Assistant to your Snowflake account
# in one command using SnowCLI.
#
# Usage: ./quickstart_deploy.sh
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear

echo -e "${CYAN}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════╗
║                                                                          ║
║   ███████╗███████╗██╗     ██████╗ ██████╗ ██████╗ ████████╗███████╗██╗  ║
║   ██╔════╝██╔════╝██║    ██╔════╝██╔═══██╗██╔══██╗╚══██╔══╝██╔════╝╚██╗ ║
║   █████╗  ███████╗██║    ██║     ██║   ██║██████╔╝   ██║   █████╗   ╚═╝ ║
║   ██╔══╝  ╚════██║██║    ██║     ██║   ██║██╔══██╗   ██║   ██╔══╝   ██╗ ║
║   ██║     ███████║██║    ╚██████╗╚██████╔╝██║  ██║   ██║   ███████╗╚═╝  ║
║   ╚═╝     ╚══════╝╚═╝     ╚═════╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝     ║
║                                                                          ║
║               Build an AI Assistant for Financial Services              ║
║                  Using Cortex AI & Snowflake Intelligence               ║
║                                                                          ║
╚══════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${GREEN}Welcome to the FSI Cortex Assistant Quick Deploy!${NC}"
echo ""
echo "This will deploy:"
echo "  ✓ 20+ tables with financial data (11 companies)"
echo "  ✓ 5 Cortex Search Services"
echo "  ✓ 2 Cortex Analyst Semantic Views"
echo "  ✓ 1 Snowflake Intelligence Agent (One Ticker)"
echo "  ✓ 1 Streamlit App (StockOne)"
echo "  ✓ 4 Jupyter Notebooks"
echo ""
echo -e "${YELLOW}Estimated deployment time: 15-20 minutes${NC}"
echo ""

# Check prerequisites
echo -e "${BLUE}[Step 1/6] Checking prerequisites...${NC}"

if ! command -v snow &> /dev/null; then
    echo -e "${RED}✗ SnowCLI not found${NC}"
    echo ""
    echo "Please install SnowCLI:"
    echo -e "${CYAN}  pip install snowflake-cli-labs${NC}"
    echo ""
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python 3 not found${NC}"
    echo "Please install Python 3.8 or later"
    exit 1
fi

echo -e "${GREEN}✓ Prerequisites OK${NC}"
echo ""

# Check SnowCLI connection
echo -e "${BLUE}[Step 2/6] Checking SnowCLI connection...${NC}"

if ! snow connection list &> /dev/null; then
    echo -e "${YELLOW}⚠ No SnowCLI connections configured${NC}"
    echo ""
    echo "Configure a connection now:"
    echo -e "${CYAN}  snow connection add${NC}"
    echo ""
    read -p "Press Enter after configuring your connection..."
fi

# Get connection name
echo ""
echo "Available connections:"
snow connection list

echo ""
read -p "Enter connection name to use: " CONNECTION_NAME

if [ -z "$CONNECTION_NAME" ]; then
    echo -e "${RED}✗ Connection name required${NC}"
    exit 1
fi

# Test connection
echo ""
echo -e "${BLUE}Testing connection ${CONNECTION_NAME}...${NC}"
if ! snow sql -c "$CONNECTION_NAME" -q "SELECT CURRENT_ACCOUNT()" &> /dev/null; then
    echo -e "${RED}✗ Connection test failed${NC}"
    echo "Please check your connection configuration"
    exit 1
fi

echo -e "${GREEN}✓ Connection OK${NC}"
echo ""

# Generate deployment files
echo -e "${BLUE}[Step 3/6] Generating deployment files...${NC}"

# Run the main deploy.sh to generate files
if [ ! -f "./deploy.sh" ]; then
    echo -e "${RED}✗ deploy.sh not found${NC}"
    echo "Please run this script from the repository root directory"
    exit 1
fi

# Make deploy.sh executable
chmod +x ./deploy.sh

# Run deploy.sh to generate SQL files
./deploy.sh

echo -e "${GREEN}✓ Deployment files generated${NC}"
echo ""

# Confirm deployment
echo -e "${YELLOW}[Step 4/6] Ready to deploy!${NC}"
echo ""
echo "This will create the following in your Snowflake account:"
echo ""
echo "  Database: ${GREEN}ACCELERATE_AI_IN_FSI${NC}"
echo "  Role: ${GREEN}ATTENDEE_ROLE${NC}"
echo "  Warehouse: ${GREEN}DEFAULT_WH${NC}"
echo ""
echo "  Tables: ${GREEN}20+${NC} (with ~5,000 rows of data)"
echo "  Search Services: ${GREEN}5${NC}"
echo "  Semantic Views: ${GREEN}2${NC}"
echo "  Agents: ${GREEN}1${NC} (One Ticker)"
echo "  Streamlit Apps: ${GREEN}1${NC} (StockOne)"
echo "  Notebooks: ${GREEN}4${NC}"
echo ""
read -p "Continue with deployment? (y/N): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 0
fi

# Deploy
echo ""
echo -e "${BLUE}[Step 5/6] Deploying to Snowflake...${NC}"
echo ""
echo "This will take 15-20 minutes. Progress will be shown below."
echo ""

# Deploy each script with progress
SCRIPTS=(
    "01_configure_account.sql:Configure Account"
    "02_data_foundation.sql:Deploy Data Foundation"
    "03_deploy_cortex_analyst.sql:Deploy Cortex Analyst"
    "04_deploy_streamlit.sql:Deploy Streamlit"
    "05_deploy_notebooks.sql:Deploy Notebooks"
)

TOTAL=${#SCRIPTS[@]}
CURRENT=0

for SCRIPT_INFO in "${SCRIPTS[@]}"; do
    IFS=':' read -r SCRIPT_FILE SCRIPT_NAME <<< "$SCRIPT_INFO"
    CURRENT=$((CURRENT + 1))
    
    echo -e "${YELLOW}[$CURRENT/$TOTAL] $SCRIPT_NAME...${NC}"
    
    if snow sql -f "deployment/$SCRIPT_FILE" -c "$CONNECTION_NAME" > /tmp/deploy_$CURRENT.log 2>&1; then
        echo -e "${GREEN}✓ $SCRIPT_NAME completed${NC}"
    else
        echo -e "${RED}✗ $SCRIPT_NAME failed${NC}"
        echo "Check log: /tmp/deploy_$CURRENT.log"
        echo ""
        echo "Last 20 lines of error:"
        tail -20 /tmp/deploy_$CURRENT.log
        exit 1
    fi
    echo ""
done

# Success!
echo ""
echo -e "${GREEN}[Step 6/6] Deployment Complete!${NC}"
echo ""
echo -e "${CYAN}"
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════╗
║                    🎉 DEPLOYMENT SUCCESSFUL! 🎉                          ║
╚══════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${GREEN}What was deployed:${NC}"
echo "  ✅ Database: ACCELERATE_AI_IN_FSI"
echo "  ✅ 20+ tables with ~5,000 rows of financial data"
echo "  ✅ 5 Cortex Search Services (semantic search)"
echo "  ✅ 2 Cortex Analyst Semantic Views (text-to-SQL)"
echo "  ✅ 1 Snowflake Intelligence Agent (One Ticker)"
echo "  ✅ 1 Streamlit App (StockOne with REST API)"
echo "  ✅ 4 Jupyter Notebooks (ready to run)"
echo ""

echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo "1️⃣  ${CYAN}Open Snowflake UI${NC}"
echo "    → Navigate to AI & ML Studio"
echo ""
echo "2️⃣  ${CYAN}Try the StockOne App${NC}"
echo "    → AI & ML Studio → Streamlit → STOCKONE_AGENT"
echo "    → Ask: 'What is the latest Snowflake stock price?'"
echo ""
echo "3️⃣  ${CYAN}Test the One Ticker Agent${NC}"
echo "    → AI & ML Studio → Snowflake Intelligence → One Ticker"
echo "    → Ask: 'Show me revenue trend for Snowflake'"
echo ""
echo "4️⃣  ${CYAN}Explore Search Services${NC}"
echo "    → AI & ML Studio → Cortex Search"
echo "    → Try searching emails, reports, transcripts"
echo ""
echo "5️⃣  ${CYAN}Run the Notebooks${NC}"
echo "    → AI & ML Studio → Notebooks"
echo "    → Open 1_EXTRACT_DATA_FROM_DOCUMENTS"
echo ""

echo -e "${GREEN}📚 Documentation:${NC}"
echo "  - Quickstart Guide: ${CYAN}quickstart.md${NC}"
echo "  - Deployment Guide: ${CYAN}DEPLOYMENT_README.md${NC}"
echo "  - Homepage Portal: Deployed in Snowflake"
echo ""

echo -e "${BLUE}Happy building with Snowflake Cortex AI! ❄️${NC}"
echo ""

