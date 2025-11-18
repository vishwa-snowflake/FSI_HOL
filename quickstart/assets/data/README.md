# Quickstart Data Files

## Overview

This directory contains all CSV and Parquet data files needed for the FSI Cortex Assistant quickstart deployment.

**Total Files**: 20 CSV files + 1 Parquet file (~21 MB)

---

## Primary Data Files (User-Facing Tables)

### 1. social_media_nrnt_collapse.csv
- **Size**: ~859 KB
- **Rows**: 4,391
- **Description**: Social media posts, news articles, and cross-company mentions about NRNT crisis
- **Features**:
  - 3 languages (English, French, Chinese)
  - 31 cities with geolocation (lat/long)
  - 338 posts with images
  - 35 news articles
  - 168 cross-company posts (SNOW/VLTA)
- **Table**: `SOCIAL_MEDIA_NRNT`

### 2. email_previews_data.csv
- **Rows**: 950
- **Description**: Analyst email previews across all 11 companies
- **Features**: Subject, content, ticker, rating, sentiment
- **Table**: `EMAIL_PREVIEWS_EXTRACTED`

### 3. companies.csv
- **Rows**: 11
- **Description**: Master company data with narratives
- **Features**: Company name, ticker, story, metrics
- **Table**: Source data for multiple tables

### 4. unique_transcripts.csv
- **Rows**: 92
- **Description**: Full earnings call transcripts
- **Features**: Company, date, full transcript text
- **Table**: `UNIQUE_TRANSCRIPTS`

### 5. fsi_data.csv
- **Rows**: 6,420
- **Description**: Stock price time series data
- **Features**: Date, ticker, prices (open, close, high, low)
- **Table**: `STOCK_PRICES`
- **Note**: For marketplace users only (optional)

### 6. stock_price_timeseries_snow.parquet
- **Rows**: ~6,420
- **Description**: Snowflake stock price data (alternative to marketplace)
- **Features**: TICKER, DATE, VARIABLE, VALUE (long format)
- **Table**: `STOCK_PRICE_TIMESERIES` → pivoted to `STOCK_PRICES`
- **Note**: Used in quickstart for free trial users without marketplace access

---

## Supporting Data Files (Intermediate/Processing Tables)

### 7. transcribed_earnings_calls.csv
- **Description**: Earnings call transcripts with segments
- **Table**: `TRANSCRIBED_EARNINGS_CALLS`

### 8. transcribed_earnings_calls_with_sentiment.csv
- **Description**: Transcripts with sentiment scores
- **Table**: Used for sentiment analysis

### 9. ai_transcripts_analysts_sentiments.csv
- **Description**: AI-analyzed transcript sentiments
- **Table**: `AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS`

### 10. analyst_reports.csv
- **Description**: Analyst report summaries and ratings
- **Table**: `ANALYST_REPORTS`

### 11. analyst_reports_all_data.csv
- **Description**: Complete analyst report data
- **Table**: Extended analyst data

### 12. ai_extract_analyst_reports_advanced.csv
- **Description**: AI-extracted data from analyst reports
- **Table**: Advanced extractions

### 13. parsed_analyst_reports.csv
- **Description**: Parsed analyst report content
- **Table**: Document parsing results

### 14. financial_reports.csv
- **Description**: Financial report data (850 rows, 11 companies)
- **Table**: `FINANCIAL_REPORTS`

### 15. infographic_metrics_extracted.csv
- **Description**: Metrics extracted from infographic images
- **Table**: Infographic data

### 16. infographics_for_search.csv
- **Description**: Infographics prepared for Cortex Search
- **Table**: `INFOGRAPHICS_FOR_SEARCH`

### 17. call_embeds.csv
- **Description**: Vector embeddings for earnings call chunks
- **Table**: `CALL_EMBEDS`

### 18. speaker_mapping.csv
- **Description**: Speaker identification in transcripts
- **Table**: `SPEAKER_MAPPING`

### 19. transcripts_by_minute.csv
- **Description**: Time-segmented transcript data
- **Table**: Minute-by-minute analysis

### 20. sentiment_analysis.csv
- **Description**: Aggregated sentiment scores by company
- **Table**: `SENTIMENT_ANALYSIS`

### 21. report_provider_summary.csv
- **Description**: Summary of analyst report providers
- **Table**: `REPORT_PROVIDER_SUMMARY`

---

## Complete File List

**Total**: 20 CSV files + 1 Parquet file = 21 data files

**Size**: ~21 MB total

**All files are loaded during `02_data_foundation.sql` deployment**

---

## Usage in Deployment

These files are automatically uploaded during deployment:

```sql
-- Example: Loading social media data
CREATE TEMPORARY STAGE social_media_stage
  FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1);

PUT file:///path/to/social_media_nrnt_collapse.csv @social_media_stage;

COPY INTO SOCIAL_MEDIA_NRNT
FROM @social_media_stage/social_media_nrnt_collapse.csv
FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 ENCODING = 'UTF8');
```

---

## File Sizes

Total data package: ~5-10 MB

Individual files:
- social_media_nrnt_collapse.csv: ~859 KB (largest)
- email_previews_data.csv: ~200 KB
- companies.csv: ~5 KB
- unique_transcripts.csv: ~500 KB
- fsi_data.csv: ~300 KB

---

## Verification

After deployment, verify row counts:

```sql
SELECT 'SOCIAL_MEDIA_NRNT' AS table_name, COUNT(*) AS rows FROM SOCIAL_MEDIA_NRNT
UNION ALL  
SELECT 'EMAIL_PREVIEWS_EXTRACTED', COUNT(*) FROM EMAIL_PREVIEWS_EXTRACTED
UNION ALL
SELECT 'UNIQUE_TRANSCRIPTS', COUNT(*) FROM UNIQUE_TRANSCRIPTS
UNION ALL
SELECT 'STOCK_PRICES', COUNT(*) FROM STOCK_PRICES;
```

Expected:
- SOCIAL_MEDIA_NRNT: 4,391
- EMAIL_PREVIEWS_EXTRACTED: 950
- UNIQUE_TRANSCRIPTS: 92
- STOCK_PRICES: 6,420

---

**All data files ready for deployment!** 📊

