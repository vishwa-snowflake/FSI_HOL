# STOCK_PRICE_TIMESERIES Data Note

## Overview

The `STOCK_PRICE_TIMESERIES` table is sourced from an **external data share**. Due to its large size (84M rows), only **SNOW ticker data** has been exported for convenience.

## Exported Data

✅ **SNOW Ticker Data Included**: `stock_price_timeseries_snow.parquet`
- **Rows**: 6,420 rows
- **Size**: 57 KB (compressed Parquet)
- **Date Range**: 2020-09-16 to 2025-10-27
- **Columns**: TICKER, ASSET_CLASS, PRIMARY_EXCHANGE_CODE, PRIMARY_EXCHANGE_NAME, VARIABLE, VARIABLE_NAME, DATE, VALUE

## Full Data Details

- **Source**: `ORGDATACLOUD$INTERNAL$TRANSCRIPTS_FROM_EARNINGS_CALLS.ACCELERATE_WITH_AI_DOC_AI.STOCK_PRICE_TIMESERIES`
- **Full Row Count**: 83,990,972 rows (~84 million)
- **Type**: External data share (read-only)
- **Estimated Full Size**: ~700+ MB when exported

## How It's Used

The `data_foundation.template.sql` script creates a **view** that references this external data share:

```sql
CREATE OR REPLACE VIEW {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.STOCK_PRICE_TIMESERIES(
	TICKER,
	ASSET_CLASS,
	PRIMARY_EXCHANGE_CODE,
	PRIMARY_EXCHANGE_NAME,
	VARIABLE,
	VARIABLE_NAME,
	DATE,
	VALUE
) AS 
SELECT * FROM ORGDATACLOUD$INTERNAL$TRANSCRIPTS_FROM_EARNINGS_CALLS.ACCELERATE_WITH_AI_DOC_AI.STOCK_PRICE_TIMESERIES;
```

## Deployment Notes

### For Accounts WITH Data Share Access
If deploying to an account that has access to this data share, the view will work automatically. No data export/import is needed.

### For Accounts WITHOUT Data Share Access

#### Quick Start: Use SNOW Ticker Data (Included)

The included `stock_price_timeseries_snow.parquet` file contains Snowflake stock prices and can be loaded quickly:

```sql
-- Create table
CREATE OR REPLACE TABLE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.STOCK_PRICE_TIMESERIES (
    TICKER VARCHAR,
    ASSET_CLASS VARCHAR,
    PRIMARY_EXCHANGE_CODE VARCHAR,
    PRIMARY_EXCHANGE_NAME VARCHAR,
    VARIABLE VARCHAR,
    VARIABLE_NAME VARCHAR,
    DATE DATE,
    VALUE FLOAT
);

-- Create stage and upload
CREATE OR REPLACE STAGE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.stock_stage
  FILE_FORMAT = (TYPE = PARQUET);

PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/stock_price_timeseries_snow.parquet 
    @{{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.stock_stage;

-- Load data
COPY INTO {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.STOCK_PRICE_TIMESERIES
FROM @{{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.stock_stage/stock_price_timeseries_snow.parquet
FILE_FORMAT = (TYPE = PARQUET)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

DROP STAGE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.stock_stage;
```

#### Other Options:

#### Option 1: Request Data Share Access (Recommended)
Contact Snowflake to get access to the `ORGDATACLOUD$INTERNAL$TRANSCRIPTS_FROM_EARNINGS_CALLS` data share.

#### Option 2: Export and Import Manually
If needed, you can export the data using the included script:

```bash
# Run the export script (will take several minutes)
python3 export_stock_prices_to_parquet.py
```

This will:
1. Export data from the source as Parquet files
2. Download the files to the DATA directory
3. Files will be named `stock_price_timeseries_*.parquet.gz`

Then to import into a new account:

```sql
-- Create stage
CREATE OR REPLACE STAGE stock_import_stage
  FILE_FORMAT = (TYPE = PARQUET);

-- Upload files (use PUT command or UI)
PUT file:///path/to/stock_price_timeseries*.parquet.gz @stock_import_stage;

-- Create table
CREATE TABLE STOCK_PRICE_TIMESERIES (
    TICKER VARCHAR,
    ASSET_CLASS VARCHAR,
    PRIMARY_EXCHANGE_CODE VARCHAR,
    PRIMARY_EXCHANGE_NAME VARCHAR,
    VARIABLE VARCHAR,
    VARIABLE_NAME VARCHAR,
    DATE DATE,
    VALUE FLOAT
);

-- Load data
COPY INTO STOCK_PRICE_TIMESERIES
FROM @stock_import_stage
FILE_FORMAT = (TYPE = PARQUET)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;
```

#### Option 3: Use Alternative Stock Data
Replace the view with your own stock price data source if available.

## Why Not Included in Standard Export

1. **Size**: 84 million rows is too large for standard CSV export
2. **External Source**: Data is owned by external data share, not local data
3. **Deployment Flexibility**: Most deployments will have access to the data share
4. **Download Time**: Full export takes 10+ minutes

## Data Schema

| Column | Type | Description |
|--------|------|-------------|
| TICKER | VARCHAR | Stock ticker symbol |
| ASSET_CLASS | VARCHAR | Type of asset |
| PRIMARY_EXCHANGE_CODE | VARCHAR | Exchange code |
| PRIMARY_EXCHANGE_NAME | VARCHAR | Exchange name |
| VARIABLE | VARCHAR | Variable identifier |
| VARIABLE_NAME | VARCHAR | Variable description |
| DATE | DATE | Date of observation |
| VALUE | FLOAT | Stock price or metric value |

## Semantic Model Usage

This data is used by the Cortex Analyst semantic model for financial analysis queries related to stock prices over time.

---

**Last Updated**: October 29, 2025

