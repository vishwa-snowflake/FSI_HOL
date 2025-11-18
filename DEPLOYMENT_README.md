# FSI Cortex Assistant - Deployment Guide

**Version**: 2025-10-30  
**Repository**: https://app.dataops.live/snowflake/hands-on-labs/build-an-ai-assistant-for-fsi-using-aisql-and-snowflake-intelligence.git

This guide explains the deployment process, dependencies, and execution order for the FSI Cortex Assistant pipeline.

## Table of Contents

- [Overview](#overview)
- [Latest Updates](#latest-updates)
- [Pipeline Dependency Graph](#pipeline-dependency-graph)
- [Deployment Order](#deployment-order)
- [Script Dependencies](#script-dependencies)
- [Data Files Required](#data-files-required)
- [Search Services](#search-services)
- [Semantic Views](#semantic-views)
- [Streamlit Application](#streamlit-application)
- [Troubleshooting](#troubleshooting)

---

## Overview

The FSI Cortex Assistant deployment consists of multiple stages that must execute in a specific order to ensure all dependencies are met. **All objects are now created with ATTENDEE_ROLE** for proper access control.

### Key Architecture Components

- **11 Companies**: Synthetic financial data for portfolio analysis
- **5 Search Services**: Cortex Search for RAG applications  
- **2 Semantic Views**: Cortex Analyst for text-to-SQL
- **1 Streamlit App**: StockOne - AI Financial Assistant with REST API
- **4 Snowflake Notebooks**: Document AI, audio transcription, search, and ML training
- **Pre-trained ML Model**: GPU-accelerated stock prediction model

---

## Latest Updates

### 🆕 October 2025 Release

#### Role & Security
- ✅ **All pipelines now use ATTENDEE_ROLE** (not ACCOUNTADMIN)
- ✅ Objects owned by ATTENDEE_ROLE for proper access control
- ✅ CORTEX_USER role granted for AI functions and REST API

#### Streamlit Application
- ✅ **Sunset simple agent** - Only sophisticated StockOne agent remains
- ✅ **Cortex Agents REST API** integration
- ✅ **Feedback API** - Thumbs up/down on agent responses
- ✅ **5 Search Services** + **2 Semantic Views** configured
- ✅ Semantic views now use **view objects** (not YAML files)
- ✅ Fully qualified search service names for authorization

#### Homepage
- ✅ **Removed DataOps plugin** for cleaner configuration
- ✅ **Professional Snowflake blue gradient header**
- ✅ **Non-clickable logo** with white styling
- ✅ Custom FSI logo support

#### Data Enhancements
- ✅ **11 companies expanded** (was 8) - SNOW, CTLG, DFLX, GAME, ICBG, MKTG, NRNT, PROP, QRYQ, STRM, VLTA
- ✅ **950 emails** (was 660) across all 11 tickers
- ✅ **850 financial reports** (was 30) covering 11 companies
- ✅ **Pre-loaded intermediate tables** for instant notebook demos
- ✅ **STOCK_PRICES table** with pivoted structure for easier queries

---

## Pipeline Dependency Graph

```
                    ┌─────────────────────┐
                    │ Initialise Pipeline │
                    └──────────┬──────────┘
                               │
              ┌────────────────┼────────────────┬────────────────┐
              │                │                │                │
     ┌────────▼────────┐  ┌───▼────────┐  ┌───▼──────────┐ ┌──▼──────┐
     │ Share Data to   │  │   Build    │  │   Deploy     │ │ Deploy  │
     │   Attendee      │  │  Homepage  │  │ DocumentAI   │ │Notebooks│
     │   (optional)    │  └────────────┘  └──────────────┘ └─────────┘
     └────────┬────────┘
              │
     ┌────────▼──────────────┐
     │ Configure Attendee    │
     │   Account (ATTENDEE_  │  ← Creates database, schemas, roles
     │      ROLE)            │     Grants CORTEX_USER role
     └────────┬──────────────┘
              │
     ┌────────▼──────────────┐
     │  Data Foundation   ⭐  │  ← Creates ALL tables, views, search services
     │  (ATTENDEE_ROLE)      │     Uses ATTENDEE_ROLE (not ACCOUNTADMIN)
     └────────┬──────────────┘
              │
              ├───────────────┬──────────────────┬──────────────┐
              │               │                  │              │
     ┌────────▼────────┐ ┌───▼──────────┐ ┌────▼─────────┐ ┌──▼─────────┐
     │Deploy Cortex    │ │Deploy ML     │ │Deploy Snow   │ │  Deploy    │
     │Analyst (2 Views)│ │ Element      │ │  Mail        │ │ Streamlit  │
     │ ATTENDEE_ROLE ✅│ │ ATTENDEE_ROLE│ │ATTENDEE_ROLE │ │(REST API)  │
     └─────────────────┘ └──────────────┘ └──────────────┘ └────────────┘
```

---

## Deployment Order

### Stage 1: Initialization

**Job**: `Initialise Pipeline`
- Sets up pipeline variables from `variables.yml`
- No dependencies
- Always runs first

**Key Variables**:
- `EVENT_DATABASE`: ACCELERATE_AI_IN_FSI
- `EVENT_SCHEMA`: DEFAULT_SCHEMA
- `EVENT_ATTENDEE_ROLE`: ATTENDEE_ROLE  
- `EVENT_WAREHOUSE`: DEFAULT_WH

### Stage 2: Parallel Setup

**Jobs** (can run in parallel):
- `Share Data To Attendee` (optional) - If `EVENT_DATA_SHARING = "true"`
- `Build Homepage` - MkDocs documentation portal
- `Deploy DocumentAI` - Uploads PDFs, creates stages
- `Deploy Notebooks` - Deploys 4 Snowflake notebooks

**Dependencies**: Initialise Pipeline

### Stage 3: Account Configuration

**Job**: `Configure Attendee Account`

**Script**: `configure_attendee_account.template.sql`

**Creates**:
- Database: `ACCELERATE_AI_IN_FSI`
- Schemas: `DEFAULT_SCHEMA`, `DOCUMENT_AI`, `CORTEX_ANALYST`, `NOTEBOOKS`, `STREAMLIT`
- Role: `ATTENDEE_ROLE` with CORTEX_USER database role
- Warehouse: `DEFAULT_WH`
- External access integration: `SNOWFLAKE_INTELLIGENCE_EXTERNALACCESS_INTEGRATION`
- Agents: `One Ticker` (Snowflake Intelligence) and pre-built docs agent

**Dependencies**: Initialise Pipeline (+ Share Data if enabled)

### Stage 4: Data Foundation ⭐ CRITICAL

**Job**: `Data Foundation`

**Script**: `data_foundation.template.sql`

**Execution Role**: ✅ **ATTENDEE_ROLE** (changed from ACCOUNTADMIN)

**Creates**:

#### Tables (20+)
| Table | Rows | Purpose |
|-------|------|---------|
| AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS | 92 | Analyst sentiment from transcripts |
| TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT | 1,788 | Earnings call text + sentiment |
| TRANSCRIPTS_BY_MINUTE | 364 | Minute-by-minute transcript breakdown |
| SENTIMENT_ANALYSIS | 15 | Overall sentiment by earnings call |
| INFOGRAPHICS_FOR_SEARCH | 11 | Company infographic data (11 companies) |
| ANALYST_REPORTS | 30 | Analyst report summaries |
| INFOGRAPHIC_METRICS_EXTRACTED | 11 | Extracted metrics from infographics (11 companies) |
| FINANCIAL_REPORTS | 850 | AI_EXTRACT output (11 companies) |
| unique_transcripts | 92 | Unique transcript identifiers |
| call_embeds | 317 | Chunked earnings calls |
| EMAIL_PREVIEWS_EXTRACTED | 950 | Extracted email data (11 tickers) |
| EMAIL_PREVIEWS | 324 | Email metadata |
| FULL_TRANSCRIPTS | 317 | Derived from call_embeds with URLs |
| PARSED_ANALYST_REPORTS | 30 | AI_PARSE_DOCUMENT output (pre-loaded) |
| AI_EXTRACT_ANALYST_REPORTS_ADVANCED | 30 | AI_COMPLETE output (pre-loaded) |
| REPORT_PROVIDER_SUMMARY | 7 | Analyst report provider stats |
| TRANSCRIBED_EARNINGS_CALLS | 3 | Base earnings call data (pre-loaded) |
| SPEAKER_MAPPING | 53 | Speaker identification mapping (pre-loaded) |
| AI_TRANSCRIBE_NO_TIME | 3 | Transcription without timestamps (pre-loaded) |
| STOCK_PRICES | Dynamic | Pivoted stock price data with TICKER filter |

#### Views (6)
- SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH
- VW_FINANCIAL_SUMMARY
- VW_INCOME_STATEMENT
- VW_KPI_METRICS
- VW_INFOGRAPHIC_METRICS  
- (STOCK_PRICE_TIMESERIES removed - replaced by STOCK_PRICES table)

#### Search Services (5)
1. **dow_analysts_sentiment_analysis** - Analyst sentiment on earnings calls
2. **snow_full_earnings_calls** - Chunked Snowflake earnings call transcripts
3. **ANALYST_REPORTS_SEARCH** - Analyst report full-text search
4. **INFOGRAPHICS_SEARCH** - Company infographic search
5. **EMAILS** - Email content search

#### Functions & Procedures
- **WEB_SEARCH(query)** - UDF for web search via external access
- **SEND_EMAIL_NOTIFICATION()** - Stored procedure for email alerts

**Dependencies**: Configure Attendee Account

**Total Data Loaded**: ~5,000+ rows across 19 CSV files

### Stage 5: Advanced Features (Parallel after Data Foundation)

#### Deploy Cortex Analyst ⭐
- **Script**: `deploy_cortex_analyst.template.sql`
- **Execution Role**: ATTENDEE_ROLE
- **Creates**: 
  - Semantic View: `COMPANY_DATA_8_CORE_FEATURED_TICKERS` (11 companies)
  - Semantic View: `SNOWFLAKE_ANALYSTS_VIEW` (with STOCK_PRICES table and TICKER_SNOW filter)
  - Agent: `One Ticker` with WEB_SEARCH tool
- **Dependencies**: Data Foundation (tables, views, search services)

#### Deploy ML Element ⭐
- **Script**: `setup_scripts_ml_element.template.sql`
- **Execution Role**: ATTENDEE_ROLE
- **Creates**: 
  - ML models for stock prediction
  - Pre-trained model registry
  - STOCK_PERFORMANCE_PREDICTOR function
- **Dependencies**: Data Foundation

#### Deploy Snow Mail ⭐
- **Script**: `deploy_snow_mail.template.sql`
- **Execution Role**: ATTENDEE_ROLE
- **Creates**: Email notification system for Portfolio Analytics
- **Dependencies**: Data Foundation (EMAIL_PREVIEWS table)

#### Deploy Streamlit
- **Script**: `deploy_streamlit.template.sql`
- **Execution Role**: ATTENDEE_ROLE
- **Creates**: 
  - **STOCKONE_AGENT** - Sophisticated AI assistant with:
    - Cortex Agents REST API integration
    - Feedback API (thumbs up/down)
    - 5 search services
    - 2 semantic views  
    - 3 LLM options (Claude, Mistral, Llama)
- **Note**: Simple agent (1_CORTEX_AGENT_SIMPLE) has been sunset
- **Dependencies**: Configure Attendee Account + CORTEX_USER role

---

## Script Dependencies

### data_foundation.template.sql

**Execution Role**: ✅ **ATTENDEE_ROLE**

**Requires**:
- ✅ Database: `ACCELERATE_AI_IN_FSI`
- ✅ Schemas: `DEFAULT_SCHEMA`, `DOCUMENT_AI`
- ✅ Warehouse: `DEFAULT_WH`
- ✅ Role: `ATTENDEE_ROLE` with CORTEX_USER

**Provides** (for downstream jobs):
- 20+ tables with data
- 6 views
- 5 search services (all with fully qualified names)
- 1 UDF (WEB_SEARCH)
- 1 stored procedure (SEND_EMAIL_NOTIFICATION)

**Key Changes**:
- Now uses `USE ROLE {{ env.EVENT_ATTENDEE_ROLE }}` (not ACCOUNTADMIN)
- All objects owned by ATTENDEE_ROLE
- Fully qualified table names in search service definitions
- FULL_TRANSCRIPTS table with grants after creation

### deploy_cortex_analyst.template.sql

**Execution Role**: ✅ **ATTENDEE_ROLE**

**Requires** (ALL from Data Foundation):
- ✅ Tables: INFOGRAPHICS_FOR_SEARCH, TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT, TRANSCRIPTS_BY_MINUTE, SENTIMENT_ANALYSIS, ANALYST_REPORTS, STOCK_PRICES
- ✅ Views: SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH, VW_FINANCIAL_SUMMARY, VW_INCOME_STATEMENT, VW_KPI_METRICS
- ✅ Search Service: INFOGRAPHICS_SEARCH
- ✅ Schema: CORTEX_ANALYST
- ✅ Warehouse: DEFAULT_WH

**Provides**:
- 2 semantic views (using view objects, not YAML files)
- TICKER_SNOW named filter in SNOWFLAKE_ANALYSTS_VIEW
- One Ticker agent with WEB_SEARCH tool

**Key Changes**:
- STOCK_PRICE_TIMESERIES replaced with STOCK_PRICES table
- Semantic views reference objects (not @stage/file.yaml)
- Proper SQL casing and formatting

### deploy_streamlit.template.sql

**Execution Role**: ✅ **ATTENDEE_ROLE**

**Requires**:
- ✅ CORTEX_USER database role
- ✅ All search services from Data Foundation
- ✅ All semantic views from Cortex Analyst
- ✅ Schema: STREAMLIT

**Provides**:
- STOCKONE_AGENT Streamlit app with REST API features

**Key Changes**:
- Removed simple agent (1_CORTEX_AGENT_SIMPLE)  
- Only sophisticated agent (2_cortex_agent_soph) deployed
- Modern Streamlit DDL syntax (FROM vs ROOT_LOCATION)
- TITLE parameter added
- CORTEX_USER role grant (no object grants needed - owner has all privileges)

---

## Data Files Required

All data files are in `/dataops/event/DATA/`:

### CSV Files (19 files, ~5 MB)

| File | Rows | Size | Purpose |
|------|------|------|---------|
| ai_transcripts_analysts_sentiments.csv | 92 | 52 KB | Analyst sentiment data |
| analyst_reports_all_data.csv | 30 | 72 KB | Full analyst reports |
| analyst_reports.csv | 30 | 84 KB | Analyst report summaries |
| call_embeds.csv | 317 | 424 KB | Chunked earnings calls |
| email_previews_data.csv | 324 | 184 KB | Email metadata |
| email_previews_extracted.csv | 950 | 2.1 MB | Extracted email data (11 tickers) |
| financial_reports.csv | 850 | 150 KB | AI_EXTRACT output (11 companies) |
| fsi_data.csv | - | 17 MB | For ML training |
| infographic_metrics_extracted.csv | 11 | 20 KB | Extracted metrics (11 companies) |
| infographics_for_search.csv | 11 | 18 KB | Infographic data (11 companies) |
| sentiment_analysis.csv | 15 | 791 B | Overall sentiment |
| transcribed_earnings_calls_with_sentiment.csv | 1,788 | 350 KB | Transcripts with sentiment |
| transcripts_by_minute.csv | 364 | 171 KB | Minute-level transcripts |
| unique_transcripts.csv | 92 | 532 KB | Unique transcript IDs |
| parsed_analyst_reports.csv | 30 | 45 KB | AI_PARSE output (pre-loaded) |
| ai_extract_analyst_reports_advanced.csv | 30 | 38 KB | AI_COMPLETE output (pre-loaded) |
| report_provider_summary.csv | 7 | 2 KB | Provider statistics (pre-loaded) |
| transcribed_earnings_calls.csv | 3 | 15 KB | Base call data (pre-loaded) |
| speaker_mapping.csv | 53 | 8 KB | Speaker IDs (pre-loaded) |
| ai_transcribe_no_time.csv | 3 | 12 KB | Transcripts without times (pre-loaded) |

### Parquet Files
- `stock_price_timeseries_snow.parquet` - 6,420 rows, 57 KB (SNOW ticker)

### PDFs & HTML
- `/document_ai/financial_reports/` - 11 PDFs (analyst reports)
- `/document_ai/financial_reports_html/` - 850+ HTML files (financial summaries, 11 companies)
- `/document_ai/infographics_simple/` - 11 PNG infographics
- `/investment_management_docs/` - 7 PDFs (Federal Reserve & NBER papers)
- `/sound_files/` - 3 MP3 files (earnings calls)

---

## Search Services

All created in `data_foundation.template.sql` with **fully qualified table names**:

| # | Service Name | Search Field | Attributes | Source Table | Purpose |
|---|--------------|--------------|------------|--------------|---------|
| 1 | dow_analysts_sentiment_analysis | FULL_TRANSCRIPT_TEXT | primary_ticker, unique_analyst_count, sentiment_score, sentiment_reason | SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH | Analyst sentiment search |
| 2 | snow_full_earnings_calls | TEXT | URL, SENTIMENT_SCORE, SENTIMENT, SUMMARY, RELATIVE_PATH | FULL_TRANSCRIPTS | Snowflake earnings call chunks |
| 3 | ANALYST_REPORTS_SEARCH | FULL_TEXT | URL, NAME_OF_REPORT_PROVIDER, DOCUMENT_TYPE, DOCUMENT, SUMMARY, RELATIVE_PATH, RATING, DATE_REPORT | ANALYST_REPORTS | Analyst reports full-text |
| 4 | INFOGRAPHICS_SEARCH | BRANDING | URL, COMPANY_TICKER, RELATIVE_PATH, TEXT, COMPANY_NAME, REPORT_PERIOD, TICKER | INFOGRAPHICS_FOR_SEARCH | Company infographics |
| 5 | EMAILS | HTML_CONTENT | TICKER, RATING, SENTIMENT, SUBJECT, CREATED_AT, RECIPIENT_EMAIL | EMAIL_PREVIEWS_EXTRACTED | Email content search |

**Key Notes**:
- All services use `{{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.TABLE_NAME` (fully qualified)
- Created in correct order (after all tables)
- All owned by ATTENDEE_ROLE
- All services shown as UPPERCASE in Snowflake UI

---

## Semantic Views

Created in `deploy_cortex_analyst.template.sql` using **view objects** (not YAML files):

### 1. COMPANY_DATA_8_CORE_FEATURED_TICKERS

**Fully Qualified Name**: `ACCELERATE_AI_IN_FSI.CORTEX_ANALYST.COMPANY_DATA_8_CORE_FEATURED_TICKERS`

**Purpose**: Financial data and sentiment analysis for 11 featured companies

**Tables Referenced**:
- `DEFAULT_SCHEMA.INFOGRAPHICS_FOR_SEARCH` (11 companies)
- `DEFAULT_SCHEMA.SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH`
- `DOCUMENT_AI.VW_FINANCIAL_SUMMARY`
- `DOCUMENT_AI.VW_INCOME_STATEMENT`
- `DOCUMENT_AI.VW_KPI_METRICS`

**Search Service Tool**: `INFOGRAPHICS_SEARCH`

**Relationships**: 4 foreign key relationships

**Companies**: SNOW, CTLG, DFLX, GAME, ICBG, MKTG, NRNT, PROP, QRYQ, STRM, VLTA

### 2. SNOWFLAKE_ANALYSTS_VIEW

**Fully Qualified Name**: `ACCELERATE_AI_IN_FSI.CORTEX_ANALYST.SNOWFLAKE_ANALYSTS_VIEW`

**Purpose**: Snowflake-specific analyst data, earnings calls, and stock prices

**Tables Referenced**:
- `DEFAULT_SCHEMA.TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT`
- `DEFAULT_SCHEMA.TRANSCRIPTS_BY_MINUTE`
- `DEFAULT_SCHEMA.SENTIMENT_ANALYSIS`
- `DEFAULT_SCHEMA.ANALYST_REPORTS`
- ✅ `DEFAULT_SCHEMA.STOCK_PRICES` (NEW - replaces STOCK_PRICE_TIMESERIES)

**Named Filters**:
- ✅ **TICKER_SNOW** - Filters to Snowflake stock data only
  - Synonyms: snow_equity_code, snow_security_id, snow_stock_code, snow_stock_ticker, stock_symbol_snow

**Key Changes**:
- STOCK_PRICE_TIMESERIES removed
- STOCK_PRICES added with pivoted structure
- DATE as time dimension
- All stock price metrics as separate facts

---

## Streamlit Application

### STOCKONE_AGENT

**Location**: `ACCELERATE_AI_IN_FSI.STREAMLIT.STOCKONE_AGENT`

**App Version**: 2025-10-30

**Features**:
- ✅ **Cortex Agents REST API** integration
- ✅ **Feedback API** - Collect user feedback (👍👎)
- ✅ **5 Search Services** configured
- ✅ **2 Semantic Views** for Cortex Analyst
- ✅ **3 LLM Models** - Claude 3.5 Sonnet, Mistral Large2, Llama 3.3 70B
- ✅ **Tool toggles** - Enable/disable individual services
- ✅ **Interactive visualizations** - Dynamic chart configuration
- ✅ **Debug mode** - API request/response logging

**Search Services** (all fully qualified):
1. Analyst Sentiment Search (💬)
2. Analyst Reports (📄)
3. Infographics (📊)
4. Analyst Emails (📧)
5. Snowflake Earnings Calls (🎙️)

**Semantic Views**:
1. 11 Companies Data (🏢) - COMPANY_DATA_8_CORE_FEATURED_TICKERS
2. Snowflake Analysis (❄️) - SNOWFLAKE_ANALYSTS_VIEW

**Configuration**:
```python
# Agent for feedback API
AGENT_DATABASE = "SNOWFLAKE_INTELLIGENCE"
AGENT_SCHEMA = "AGENTS"
AGENT_NAME = "One Ticker"

# All services use semantic_view (not semantic_model_file)
# All services use search_service (not name)
# Execution environment required for analyst tools
```

**Key Changes from Simple Agent**:
- REST API compliant tool configuration
- Feedback submission to Snowflake
- Request ID tracking for feedback
- Proper tool_resources structure per API spec
- No max_results in search config (handled by agent)

---

## Troubleshooting

### Error: "Object does not exist or not authorized"

**Symptom**: Semantic view, search service, or table not accessible

**Causes**:
1. Pipeline ran before Data Foundation completed
2. Objects created with wrong role (ACCOUNTADMIN instead of ATTENDEE_ROLE)
3. Missing CORTEX_USER database role

**Solutions**:
```sql
-- 1. Verify role ownership
SHOW TABLES IN ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA;
-- Check "owner" column - should be ATTENDEE_ROLE

-- 2. Verify CORTEX_USER role
SHOW GRANTS TO ROLE ATTENDEE_ROLE;
-- Should include: SNOWFLAKE.CORTEX_USER

-- 3. Check pipeline dependencies
-- Ensure deploy_cortex_analyst.yml has:
needs: [..., "Data Foundation"]
```

### Error: "Cannot perform CREATE CORTEX SEARCH SERVICE"

**Symptom**: "This session does not have a current database"

**Solution**: Already fixed in `data_foundation.template.sql` (lines 1705-1707):
```sql
USE DATABASE {{ env.EVENT_DATABASE }};
USE SCHEMA {{ env.EVENT_SCHEMA }};
```

### Error: "FULL_TRANSCRIPTS does not exist"

**Symptom**: Search service `snow_full_earnings_calls` fails

**Troubleshooting Steps**:
1. Check if `call_embeds.csv` loaded successfully
   ```sql
   SELECT COUNT(*) FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.call_embeds;
   -- Should return 317 rows
   ```

2. Check if FULL_TRANSCRIPTS was created
   ```sql
   SHOW TABLES LIKE 'FULL_TRANSCRIPTS' IN ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA;
   ```

3. Check creation order in pipeline
   - call_embeds table (line ~1508)
   - call_embeds load (line ~1553)
   - FULL_TRANSCRIPTS creation (line ~1649)
   - Grants on FULL_TRANSCRIPTS (line ~1660)
   - Search service creation (line ~1730)

**Solution**: Table is created in correct order. If still failing, check if call_embeds.csv is in `/dataops/event/DATA/` (424 KB, 317 rows).

### Error: "Invalid object type 'SEMANTIC_VIEW' for privilege 'USAGE'"

**Symptom**: Grant statement fails on semantic view

**Solution**: Use `SELECT` not `USAGE` for semantic views:
```sql
-- WRONG
GRANT USAGE ON SEMANTIC VIEW ... ❌

-- CORRECT  
GRANT SELECT ON SEMANTIC VIEW ... ✅
```

**Note**: With ATTENDEE_ROLE ownership, grants are not needed (owner has all privileges).

### Streamlit Error: "The Cortex Search Service does not exist"

**Symptom**: 404 error or "399502" in Streamlit app

**Causes**:
1. Search service names don't match (case sensitivity)
2. Missing database prefix in service name
3. ATTENDEE_ROLE doesn't own the service

**Solutions**:
```python
# 1. Use exact case from Snowflake UI
"location": "ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAILS"  # All CAPS

# 2. Always include database.schema
# NOT: "DEFAULT_SCHEMA.EMAILS"
# YES: "ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAILS"

# 3. Check ownership
SHOW CORTEX SEARCH SERVICES;
-- owner column should be ATTENDEE_ROLE
```

### Pipeline Fails at "Deploy Streamlit"

**Symptom**: "MAIN_FILE cannot start with /"

**Solution**: Already fixed - use relative path:
```sql
-- WRONG
MAIN_FILE = '/app.py'  ❌

-- CORRECT
MAIN_FILE = 'app.py'  ✅
```

### Semantic View Error: "Invalid table name 'STOCK_PRICE_TIMESERIES'"

**Symptom**: SNOWFLAKE_ANALYSTS_VIEW references old table

**Solution**: Already fixed - now uses STOCK_PRICES table:
```sql
-- TABLES section
STOCK_PRICES COMMENT='This table stores historical stock price data...'

-- Not STOCK_PRICE_TIMESERIES (removed)
```

---

## Data Priming Strategy

To speed up notebook demonstrations and save Snowflake credits, intermediate AI processing results are pre-loaded as CSV files:

### Pre-Loaded Tables (7)

| Table | Notebook | AI Function | Why Pre-loaded |
|-------|----------|-------------|----------------|
| PARSED_ANALYST_REPORTS | 1 | AI_PARSE_DOCUMENT | Saves document parsing time |
| AI_EXTRACT_ANALYST_REPORTS_ADVANCED | 1 | AI_COMPLETE | Saves LLM extraction time |
| REPORT_PROVIDER_SUMMARY | 1 | Aggregation | Saves computation |
| TRANSCRIBED_EARNINGS_CALLS | 2 | AI_TRANSCRIBE | Saves audio transcription (expensive) |
| SPEAKER_MAPPING | 2 | Speaker identification | Saves processing |
| AI_TRANSCRIBE_NO_TIME | 2 | AI_TRANSCRIBE | Saves transcription |
| STOCK_PRICES | 3 | Pivot operation | Created dynamically from parquet |

**Benefit**: Notebooks load instantly and demonstrate concepts without waiting for AI processing.

---

## Homepage Portal

**Build Job**: `Build Homepage`

**Technology**: MkDocs with Material theme

**Configuration**: `/dataops/event/homepage/mkdocs.yml`

**Key Features**:
- ✅ Snowflake blue gradient header (CSS customized)
- ✅ Non-clickable logo with white styling
- ✅ Professional navigation tabs
- ✅ Custom h1black, h1blue, h1sub tags
- ✅ No DataOps plugin (cleaner configuration)

**Content**:
- Welcome / Lab overview
- Logging in & Cortex Playground
- Document AI extraction
- Audio transcription
- Market data & ML model
- Search services
- Cortex Analyst
- Snowflake Intelligence (One Ticker agent)

**Logo**: `assets/img/logo.png` (36 KB, 484×403 PNG)

---

## Agent Configuration

### One Ticker Agent

**Database**: `SNOWFLAKE_INTELLIGENCE`  
**Schema**: `AGENTS`  
**Name**: `One Ticker`

**Tools**:
1. **COMPANY_DATA_8_CORE_FEATURED_TICKERS** - Semantic view for 11 companies
2. **SNOWFLAKE_ANALYSTS_VIEW** - Semantic view for Snowflake analysis
3. **WEB_SEARCH** - UDF for web fact-checking

**Sample Questions**:
- "What is the latest closing price of Snowflake stock?"
- "Show me the revenue trend for Snowflake over the last 4 quarters"
- "What did the analysts say about Snowflake in their latest reports?"
- "Search the web to fact-check the latest Snowflake earnings announcement"

**Created In**: `deploy_cortex_analyst.template.sql`

**Key Features**:
- WEB_SEARCH tool for fact-checking
- TICKER_SNOW filter for Snowflake-specific queries
- Access to earnings calls, analyst reports, and stock prices

---

## Testing Checklist

After deployment, verify:

### Data Foundation
- [ ] All 20+ tables have data
- [ ] All 5 search services are ACTIVE
- [ ] FULL_TRANSCRIPTS has 317 rows
- [ ] STOCK_PRICES table exists with TICKER column

### Cortex Analyst
- [ ] 2 semantic views created
- [ ] SNOWFLAKE_ANALYSTS_VIEW includes STOCK_PRICES
- [ ] TICKER_SNOW filter works

### Streamlit
- [ ] STOCKONE_AGENT loads without errors
- [ ] 5 search services toggleable
- [ ] 2 semantic views toggleable
- [ ] Feedback buttons appear on responses

### Permissions
- [ ] All objects owned by ATTENDEE_ROLE
- [ ] CORTEX_USER role granted to ATTENDEE_ROLE
- [ ] No "not authorized" errors

### Agents
- [ ] One Ticker agent accessible in Snowflake UI
- [ ] WEB_SEARCH tool configured
- [ ] Sample questions work

---

## Support & Documentation

**Repository**: https://app.dataops.live/snowflake/hands-on-labs/build-an-ai-assistant-for-fsi-using-aisql-and-snowflake-intelligence.git

**Snowflake Docs**:
- [Cortex Agents REST API](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents-rest-api)
- [Cortex Agents Feedback API](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents-feedback-rest-api)
- [Cortex Search](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview)
- [Cortex Analyst](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
- [Semantic Views](https://docs.snowflake.com/en/user-guide/semantic-models/semantic-model-views)

**Key Files**:
- `/variables.yml` - Pipeline configuration
- `/dataops/event/data_foundation.template.sql` - Main data pipeline
- `/dataops/event/deploy_cortex_analyst.template.sql` - Semantic views and agents
- `/dataops/event/deploy_streamlit.template.sql` - Streamlit deployment
- `/dataops/event/streamlit/2_cortex_agent_soph/app.py` - StockOne agent code

---

**Last Updated**: October 30, 2025  
**Version**: 2.0  
**Status**: ✅ Production Ready
