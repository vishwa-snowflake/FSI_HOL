# Quickstart Package Manifest

## Package Contents

### Documentation (5 files)

| File | Purpose | Size |
|------|---------|------|
| `README.md` | Package overview and quick start | ~2 KB |
| `quickstart.md` | Complete step-by-step guide | ~50 KB |
| `assets/docs/DEPLOYMENT_NOTES.md` | Configuration and verification | ~3 KB |
| `assets/docs/TROUBLESHOOTING.md` | Common issues and fixes | ~5 KB |
| `assets/data/README.md` | Data file descriptions | ~2 KB |

### Scripts (1 file)

| File | Purpose | Executable |
|------|---------|------------|
| `assets/scripts/deploy_all.sh` | One-command automated deployment | ✅ |

### Data Files (4 CSV files, ~19 MB)

| File | Rows | Size | Description |
|------|------|------|-------------|
| `social_media_nrnt_collapse.csv` | 4,391 | 859 KB | Social + news + cross-company |
| `email_previews_data.csv` | 950 | 1.2 MB | Analyst emails |
| `unique_transcripts.csv` | 92 | 532 KB | Earnings transcripts |
| `fsi_data.csv` | 6,420 | 17 MB | Stock prices |

### SQL Deployment Files (9 files, ~185 KB)

Ready to run in `assets/sql/`:

| File | Size | Purpose |
|------|------|---------|
| `00_config.sql` | 1.1 KB | Configuration variables (optional) |
| `01_configure_account.sql` | 3.8 KB | Account setup and role creation |
| `02_data_foundation.sql` | 69 KB | Create tables and load data |
| `03_deploy_cortex_analyst.sql` | 54 KB | Deploy semantic views |
| `04_deploy_streamlit.sql` | 2.7 KB | Deploy StockOne app |
| `05_deploy_notebooks.sql` | 7.7 KB | Deploy 4 Snowflake notebooks |
| `06_deploy_documentai.sql` | 18 KB | Create stages for files |
| `07_deploy_snowmail.sql` | 4.5 KB | Deploy SnowMail email viewer (Native App) |
| `08_setup_ml_infrastructure.sql` | 23.6 KB | Setup ML infrastructure and GPU compute pools |

---

## Total Package Size

**Compressed**: ~15-20 MB (as ZIP)  
**Uncompressed**: ~25-30 MB  

---

## What Gets Deployed to Snowflake

### Database Objects

- **1 Database**: ACCELERATE_AI_IN_FSI
- **3 Schemas**: DEFAULT_SCHEMA, DOCUMENT_AI, CORTEX_ANALYST
- **2 Warehouses**: DEFAULT_WH, NOTEBOOKS_WH  
- **1 Role**: ATTENDEE_ROLE

### Data Assets

- **20+ Tables** (~10,000 rows total)
- **10+ Stages** (for Document AI files)
- **5 Cortex Search Services**
- **2 Cortex Analyst Semantic Views**
- **1 Snowflake Intelligence Agent** (8 tools)
- **1 Streamlit Application**
- **4 Snowflake Notebooks**

---

## Prerequisites

### Required

- Snowflake account (free trial works)
- SnowCLI installed: `pip install snowflake-cli-labs`
- ACCOUNTADMIN role access

### Recommended

- 15-20 minutes of time
- MEDIUM warehouse (auto-created)
- Stable internet connection

---

## Deployment Time

- **Account setup**: 1-2 minutes
- **Data loading**: 10-15 minutes  
- **Services deployment**: 3-5 minutes
- **Total**: 15-20 minutes

---

## Verification Commands

After deployment:

```sql
USE DATABASE ACCELERATE_AI_IN_FSI;

-- Check tables
SELECT COUNT(*) AS table_count 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'DEFAULT_SCHEMA';
-- Expected: 20+

-- Check key data
SELECT 'SOCIAL_MEDIA_NRNT', COUNT(*) FROM SOCIAL_MEDIA_NRNT
UNION ALL
SELECT 'EMAIL_PREVIEWS_EXTRACTED', COUNT(*) FROM EMAIL_PREVIEWS_EXTRACTED;
-- Expected: 4,391 and 950

-- Check services
SHOW CORTEX SEARCH SERVICES;
-- Expected: 5 services

-- Check Streamlit
SHOW STREAMLITS;
-- Expected: STOCKONE_AGENT
```

---

## Clean Up

To remove everything:

```sql
USE ROLE ACCOUNTADMIN;
DROP DATABASE IF EXISTS ACCELERATE_AI_IN_FSI CASCADE;
DROP WAREHOUSE IF EXISTS DEFAULT_WH;
DROP WAREHOUSE IF EXISTS NOTEBOOKS_WH;
DROP ROLE IF EXISTS ATTENDEE_ROLE;
```

---

**Package Version**: 1.0  
**Last Updated**: November 1, 2025  
**Compatible**: Snowflake Enterprise Edition (any cloud)  
**Status**: Production-ready  
