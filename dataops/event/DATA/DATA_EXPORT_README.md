# Data Export Files

This directory contains CSV exports of all tables required for the FSI Cortex Assistant semantic views.

## Exported Tables

These CSV files are automatically loaded by `data_foundation.template.sql` when deploying to a new account:

### Default Schema Tables
1. **ai_transcripts_analysts_sentiments.csv** (92 rows)
   - Contains analyst sentiment data and scores from earnings call transcripts
   - Columns: PRIMARY_TICKER, EVENT_TIMESTAMP, EVENT_TYPE, CREATED_AT, SENTIMENT_SCORE, UNIQUE_ANALYST_COUNT, SENTIMENT_REASON

2. **transcribed_earnings_calls_with_sentiment.csv** (1,788 rows)
   - Individual segments from transcribed earnings calls with sentiment scores
   - Columns: RELATIVE_PATH, SPEAKER, SPEAKER_NAME, AUDIO_DURATION_SECONDS, START_TIME, END_TIME, SEGMENT_TEXT, SENTIMENT

3. **transcripts_by_minute.csv** (364 rows)
   - Aggregated transcript segments by minute
   - Columns: RELATIVE_PATH, SPEAKER, SPEAKER_NAME, MINUTES, SENTIMENT, TEXT

4. **sentiment_analysis.csv** (15 rows)
   - Overall sentiment analysis across different dimensions
   - Columns: RELATIVE_PATH, SENTIMENT, OVERALL, COST, INNOVATION, PRODUCTIVITY, COMPETITIVENESS, CONSUMPTION

5. **infographics_for_search.csv** (8 rows)
   - Searchable infographic metrics data
   - Columns: COMPANY_TICKER, RELATIVE_PATH, TEXT, COMPANY_NAME, TICKER, REPORT_PERIOD, TOTAL_REVENUE, YOY_GROWTH, PRODUCT_REVENUE, SERVICES_REVENUE, TOTAL_CUSTOMERS, CUSTOMERS_1M_PLUS, NET_REVENUE_RETENTION, GROSS_MARGIN, OPERATING_MARGIN, FREE_CASH_FLOW, RPO, RPO_GROWTH, BRANDING, URL

6. **analyst_reports.csv** (30 rows)
   - Analyst report summaries and ratings
   - Columns: RELATIVE_PATH, FILE_URL, RATING, DATE_REPORT, CLOSE_PRICE, PRICE_TARGET, GROWTH, NAME_OF_REPORT_PROVIDER, DOCUMENT_TYPE, DOCUMENT, SUMMARY, FULL_TEXT, URL

7. **unique_transcripts.csv** (92 rows)
   - Complete earnings call transcripts with speaker mappings
   - Columns: primary_ticker, event_timestamp, event_type, created_at, transcript (VARIANT/JSON)

### Document AI Schema Tables
8. **infographic_metrics_extracted.csv** (8 rows)
   - Extracted metrics from infographic documents using Document AI
   - Columns: RELATIVE_PATH, COMPANY_TICKER, EXTRACTED_DATA (VARIANT/JSON), BRANDING

9. **analyst_reports_all_data.csv** (30 rows)
   - Complete analyst report data with full text
   - Columns: RELATIVE_PATH, FILE_URL, RATING, DATE_REPORT, CLOSE_PRICE, PRICE_TARGET, GROWTH, NAME_OF_REPORT_PROVIDER, DOCUMENT_TYPE, DOCUMENT, SUMMARY, FULL_TEXT

10. **financial_reports.csv** (8 rows)
    - Financial report data extracted using Document AI
    - Columns: RELATIVE_PATH, FILE_URL, SCOPED_FILE_URL, EXTRACTED_DATA (VARIANT/JSON)

11. **call_embeds.csv** (317 rows)
    - Chunked earnings call transcripts for full-text search (EMBED vector column excluded)
    - Columns: RELATIVE_PATH, SUMMARY, TEXT, SENTIMENT, SENTIMENT_SCORE

12. **email_previews_extracted.csv** (660 rows)
    - Extracted email data with metadata for email search service
    - Columns: EMAIL_ID, RECIPIENT_EMAIL, SUBJECT, HTML_CONTENT, CREATED_AT, TICKER, RATING, SENTIMENT

## Data Loading

The data is loaded automatically when running `data_foundation.template.sql`:
- Creates temporary stages for each table
- Uploads CSV files using PUT command
- Loads data using COPY INTO with proper CSV format settings
- Truncates existing data to avoid duplicates
- Cleans up temporary stages after loading
- Provides verification queries to confirm row counts

## Export Details

- **Export Date**: October 29, 2025
- **Source Account**: sfsehol-test_fsi_ai_assistant_upgrades_mlxttt
- **Source Database**: ACCELERATE_AI_IN_FSI
- **Tool Used**: Snow CLI with JSON export, converted to CSV
- **Format**: CSV with comma delimiter, quoted fields, UTF-8 encoding

## Views Created from This Data

After loading this data, `data_foundation.template.sql` creates the following views:
- SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH (joins unique_transcripts with sentiment data)
- VW_FINANCIAL_SUMMARY (extracts summary metrics from FINANCIAL_REPORTS)
- VW_INCOME_STATEMENT (flattens income statement data from FINANCIAL_REPORTS)
- VW_KPI_METRICS (extracts KPI metrics from FINANCIAL_REPORTS)
- VW_INFOGRAPHIC_METRICS (extracts structured data from INFOGRAPHIC_METRICS_EXTRACTED)
- STOCK_PRICE_TIMESERIES (references external data share)

## Cortex Search Services Created

The script also creates 5 Cortex Search Services for semantic search capabilities:

1. **dow_analysts_sentiment_analysis**
   - Searches across earnings call transcripts with analyst sentiment
   - Search Field: FULL_TRANSCRIPT_TEXT
   - Attributes: primary_ticker, unique_analyst_count, sentiment_score, sentiment_reason

2. **snow_full_earnings_calls**
   - Searches chunked Snowflake earnings call transcripts
   - Search Field: TEXT
   - Attributes: URL, SENTIMENT_SCORE, SENTIMENT, SUMMARY, RELATIVE_PATH

3. **ANALYST_REPORTS_SEARCH**
   - Searches analyst report full text
   - Search Field: FULL_TEXT
   - Attributes: URL, NAME_OF_REPORT_PROVIDER, DOCUMENT_TYPE, DOCUMENT, SUMMARY, RELATIVE_PATH, RATING, DATE_REPORT

4. **INFOGRAPHICS_SEARCH**
   - Searches infographic metadata and summaries
   - Search Field: BRANDING
   - Attributes: URL, COMPANY_TICKER, RELATIVE_PATH, TEXT, COMPANY_NAME, REPORT_PERIOD, TICKER

5. **EMAILS**
   - Searches email content
   - Search Field: HTML_CONTENT
   - Attributes: TICKER, RATING, SENTIMENT, SUBJECT, CREATED_AT, RECIPIENT_EMAIL

## Derived Tables for Search Services

The script also creates derived tables that combine data for search services:
- **FULL_TRANSCRIPTS**: Derived from call_embeds with URL placeholders
- URL columns added to ANALYST_REPORTS and INFOGRAPHICS_FOR_SEARCH

Note: URL placeholders are set in the data. In production with file stages, optional tasks can be enabled to refresh presigned URLs every 5 days.

## Notes

- VARIANT/JSON columns are preserved as-is in the CSV exports
- All timestamps are in TIMESTAMP_NTZ format
- File paths are relative paths within the Snowflake staging area
- The data represents synthetic demonstration data for the FSI AI Assistant showcase

