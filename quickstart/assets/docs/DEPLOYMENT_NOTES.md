# Deployment Notes

## Prerequisites

1. **Snowflake Account**
   - Free trial: https://signup.snowflake.com/
   - Choose Enterprise edition
   - Any cloud region (AWS/Azure/GCP)

2. **SnowCLI** (for automated deployment)
   ```bash
   pip install snowflake-cli-labs
   snow --version
   ```

3. **Configure Connection**
   ```bash
   snow connection add
   ```

---

## Stock Price Data (Important!)

### For Free Trial Users (Recommended for Quickstart)

The quickstart package includes **stock_price_timeseries_snow.parquet** with Snowflake stock data.

**No marketplace access needed!** The SQL scripts will load from the parquet file automatically.

### For Marketplace Users (Optional)

If you have access to Snowflake Marketplace, you can:
1. Get Cybersyn Financial Data from marketplace
2. Comment out the parquet loading section in `02_data_foundation.sql`
3. Uncomment the marketplace view section

**For quickstart: Just use the included parquet file** ✅

---

## Deployment Steps

### Step 1: Run Deployment Script

**Automated** (Recommended):
```bash
cd quickstart/assets/scripts
./deploy_all.sh
```

The script will:
1. Check SnowCLI is installed
2. Verify SQL files exist
3. Prompt for connection name
4. Deploy all 6 steps automatically
5. Show progress

**Manual** (Using SnowCLI):
```bash
cd quickstart/assets/sql

snow sql -f 01_configure_account.sql -c <connection>
snow sql -f 02_data_foundation.sql -c <connection>
snow sql -f 03_deploy_cortex_analyst.sql -c <connection>
snow sql -f 04_deploy_streamlit.sql -c <connection>
snow sql -f 05_deploy_notebooks.sql -c <connection>
snow sql -f 06_deploy_documentai.sql -c <connection>
```

**UI-Based** (No SnowCLI needed):
1. Open Snowflake UI → SQL Worksheet
2. Navigate to `quickstart/assets/sql/` on your computer
3. Open `01_configure_account.sql` in text editor
4. Copy contents → Paste in Snowflake worksheet → Run
5. Repeat for files 02 → 06 in order

**Important**: Before running `02_data_foundation.sql`:
- The parquet file will be referenced from your local path
- Make sure the path in the SQL matches where you downloaded the quickstart folder
- Or manually upload via Snowflake UI (Data → Databases → Create Stage → Upload)

---

## What Gets Created

### Database & Schemas
- **ACCELERATE_AI_IN_FSI** (database)
  - DEFAULT_SCHEMA (main tables)
  - DOCUMENT_AI (stages for files)
  - CORTEX_ANALYST (semantic views)

### Tables (20+)
- SOCIAL_MEDIA_NRNT (4,391 rows) - Social + news + cross-company
- TRANSCRIBED_EARNINGS_CALLS (1,788 rows) - Earnings transcripts
- EMAIL_PREVIEWS_EXTRACTED (950 rows) - Analyst emails
- STOCK_PRICES (6,420 rows) - **Loaded from parquet file**
- FINANCIAL_REPORTS (850 rows) - Financial data
- And more...

### AI Services
- 5 Cortex Search Services
- 2 Cortex Analyst Semantic Views  
- 1 Snowflake Intelligence Agent
- 1 Streamlit Application (StockOne)
- 4 Snowflake Notebooks

---

## Verification

After deployment:

```sql
USE DATABASE ACCELERATE_AI_IN_FSI;

-- Check tables exist
SHOW TABLES IN SCHEMA DEFAULT_SCHEMA;
-- Expected: 20+ tables

-- Check stock prices loaded from parquet
SELECT 
    TICKER,
    COUNT(*) AS rows,
    MIN(DATE) AS first_date,
    MAX(DATE) AS last_date
FROM STOCK_PRICES;
-- Expected: SNOW ticker, ~6,420 rows

-- Check social media data
SELECT 
    COUNT(*) AS total_posts,
    COUNT(CASE WHEN PLATFORM = 'News Article' THEN 1 END) AS news_articles,
    COUNT(DISTINCT LANGUAGE) AS languages
FROM SOCIAL_MEDIA_NRNT;
-- Expected: 4,391 total, 35 news, 3 languages

-- Check search services
SHOW CORTEX SEARCH SERVICES IN SCHEMA DEFAULT_SCHEMA;
-- Expected: 5 services

-- Check Streamlit
SHOW STREAMLITS IN SCHEMA DEFAULT_SCHEMA;
-- Expected: STOCKONE_AGENT
```

---

## Deployment Time

- **Account setup**: 1-2 minutes
- **Data loading**: 10-15 minutes  
- **Services deployment**: 3-5 minutes
- **Total**: 15-20 minutes

---

## Troubleshooting

See `TROUBLESHOOTING.md` for common issues.

**Quick fixes**:

- **Parquet file not found**: Ensure path in SQL matches your download location
- **Insufficient privileges**: Use ACCOUNTADMIN role
- **Warehouse not running**: It will auto-resume (wait 30 seconds)
- **Connection failed**: Run `snow connection test -c <name>`

---

**Ready to deploy!** 🚀

