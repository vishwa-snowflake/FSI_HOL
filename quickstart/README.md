# FSI Cortex Assistant - Quickstart Package

## Overview

This is a self-contained quickstart package for deploying the FSI Cortex Assistant with Snowflake Cortex AI. Everything you need is in this folder.

**What's Included**:
- ✅ Complete quickstart guide (quickstart.md)
- ✅ Deployment scripts (SQL files ready to run)
- ✅ Sample data files (CSV, Parquet)
- ✅ Supporting assets (scripts, documentation)

**Deployment Time**: 15-20 minutes  
**Cost**: Free (works with Snowflake free trial)

---

## Quick Deploy

### Option 1: Automated (Recommended)

```bash
cd quickstart/assets/scripts
./deploy_all.sh
```

**What it does**:
- Prompts for your Snowflake connection name
- Runs all 6 SQL files in correct order
- Shows progress for each step
- Completes in 15-20 minutes

### Option 2: Manual (Using SnowCLI)

```bash
cd quickstart/assets/sql

# Run files in order (01 → 08)
snow sql -f 01_configure_account.sql -c <connection>
snow sql -f 02_data_foundation.sql -c <connection>
snow sql -f 03_deploy_cortex_analyst.sql -c <connection>
snow sql -f 04_deploy_streamlit.sql -c <connection>
snow sql -f 05_deploy_notebooks.sql -c <connection>
snow sql -f 06_deploy_documentai.sql -c <connection>
snow sql -f 07_deploy_snowmail.sql -c <connection>
snow sql -f 08_setup_ml_infrastructure.sql -c <connection>
```

### Option 3: Snowflake UI (No SnowCLI Required)

```bash
# Just open the SQL files and copy/paste into Snowflake worksheets
cd quickstart/assets/sql
ls *.sql  # See all files (01 → 08)

# Then in Snowflake UI:
# 1. Open SQL Worksheet
# 2. Copy contents of 01_configure_account.sql
# 3. Paste and run
# 4. Repeat for files 02 → 08 in order
```

---

## Folder Structure

```
quickstart/
├── README.md (this file)
├── quickstart.md (complete guide)
│
├── assets/
│   ├── scripts/          # Deployment automation
│   │   ├── deploy_all.sh
│   │   └── generate_sql.sh
│   │
│   ├── sql/             # Deployment SQL files (6 files)
│   │   ├── 01_configure_account.sql
│   │   ├── 02_data_foundation.sql
│   │   ├── 03_deploy_cortex_analyst.sql
│   │   ├── 04_deploy_streamlit.sql
│   │   ├── 05_deploy_notebooks.sql
│   │   └── 06_deploy_documentai.sql
│   │
│   ├── data/            # Sample CSV and data files
│   │   ├── companies.csv
│   │   ├── social_media_nrnt_collapse.csv
│   │   ├── email_previews_data.csv
│   │   └── ... (other data files)
│   │
│   └── docs/            # Additional documentation
│       ├── DEPLOYMENT_NOTES.md
│       └── TROUBLESHOOTING.md
│
└── deployment/          # Generated SQL files (after running deploy.sh)
    ├── 01_configure_account.sql
    ├── 02_data_foundation.sql
    └── ... (all deployment SQL)
```

---

## Prerequisites

1. **Snowflake Account** (free trial works)
2. **SnowCLI** installed: `pip install snowflake-cli-labs`
3. **Connection configured**: `snow connection add`

---

## What Gets Deployed

- **11 Companies** with financial data
- **4,391 Social media posts** (3 languages, images, news articles)
- **22 Annual reports** with charts
- **11 Executive bios** with AI-generated portraits
- **4 Audio files** (earnings calls + CEO interview)
- **7 Social media images** (visual crisis narrative)
- **20+ Tables** with 10,000+ rows
- **5 Cortex Search Services**
- **2 Cortex Analyst Semantic Views**
- **1 Streamlit App** (StockOne)
- **4 Snowflake Notebooks**

---

## Next Steps

1. Read `quickstart.md` for complete instructions
2. Configure your Snowflake connection
3. Run deployment scripts
4. Test the application

---

## Support

- **Issues**: Check `assets/docs/TROUBLESHOOTING.md`
- **Documentation**: See `quickstart.md`
- **Community**: https://community.snowflake.com

---

**Ready to deploy your AI assistant in 15 minutes!** 🚀

