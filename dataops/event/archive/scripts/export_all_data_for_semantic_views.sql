-- =====================================================
-- Export all data needed for semantic view tables
-- =====================================================
-- Run these queries in Snowflake and export each result as CSV
-- Save files to: /Users/boconnor/fsi-cortex-assistant/dataops/event/DATA/
-- =====================================================

USE WAREHOUSE DEFAULT_WH;
USE DATABASE ACCELERATE_AI_IN_FSI;

-- =====================================================
-- 1. AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS
-- =====================================================
-- File: ai_transcripts_analysts_sentiments.csv
SELECT 
    PRIMARY_TICKER,
    EVENT_TIMESTAMP,
    EVENT_TYPE,
    CREATED_AT,
    SENTIMENT_SCORE,
    UNIQUE_ANALYST_COUNT,
    SENTIMENT_REASON
FROM DEFAULT_SCHEMA.AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS
ORDER BY PRIMARY_TICKER, EVENT_TIMESTAMP;

-- =====================================================
-- 2. TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT
-- =====================================================
-- File: transcribed_earnings_calls_with_sentiment.csv
SELECT 
    RELATIVE_PATH,
    SPEAKER,
    SPEAKER_NAME,
    AUDIO_DURATION_SECONDS,
    START_TIME,
    END_TIME,
    SEGMENT_TEXT,
    SENTIMENT
FROM DEFAULT_SCHEMA.TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT
ORDER BY RELATIVE_PATH, START_TIME;

-- =====================================================
-- 3. TRANSCRIPTS_BY_MINUTE
-- =====================================================
-- File: transcripts_by_minute.csv
SELECT 
    RELATIVE_PATH,
    SPEAKER,
    SPEAKER_NAME,
    MINUTES,
    SENTIMENT,
    TEXT
FROM DEFAULT_SCHEMA.TRANSCRIPTS_BY_MINUTE
ORDER BY RELATIVE_PATH, MINUTES;

-- =====================================================
-- 4. SENTIMENT_ANALYSIS
-- =====================================================
-- File: sentiment_analysis.csv
SELECT 
    RELATIVE_PATH,
    SENTIMENT,
    OVERALL,
    COST,
    INNOVATION,
    PRODUCTIVITY,
    COMPETITIVENESS,
    CONSUMPTION
FROM DEFAULT_SCHEMA.SENTIMENT_ANALYSIS
ORDER BY RELATIVE_PATH;

-- =====================================================
-- 5. INFOGRAPHIC_METRICS_EXTRACTED
-- =====================================================
-- File: infographic_metrics_extracted.csv
SELECT 
    RELATIVE_PATH,
    COMPANY_TICKER,
    EXTRACTED_DATA,
    BRANDING
FROM DOCUMENT_AI.INFOGRAPHIC_METRICS_EXTRACTED
ORDER BY COMPANY_TICKER;

-- =====================================================
-- 6. ANALYST_REPORTS_ALL_DATA
-- =====================================================
-- File: analyst_reports_all_data.csv
SELECT 
    RELATIVE_PATH,
    FILE_URL,
    RATING,
    DATE_REPORT,
    CLOSE_PRICE,
    PRICE_TARGET,
    GROWTH,
    NAME_OF_REPORT_PROVIDER,
    DOCUMENT_TYPE,
    DOCUMENT,
    SUMMARY,
    FULL_TEXT
FROM DOCUMENT_AI.ANALYST_REPORTS_ALL_DATA
ORDER BY DATE_REPORT, NAME_OF_REPORT_PROVIDER;

-- =====================================================
-- 7. FINANCIAL_REPORTS (source for views)
-- =====================================================
-- File: financial_reports.csv
SELECT 
    RELATIVE_PATH,
    EXTRACTED_DATA
FROM DOCUMENT_AI.FINANCIAL_REPORTS
ORDER BY RELATIVE_PATH;

-- =====================================================
-- 8. UNIQUE_TRANSCRIPTS (source for sentiment view)
-- =====================================================
-- File: unique_transcripts.csv
SELECT 
    PRIMARY_TICKER,
    EVENT_TIMESTAMP,
    EVENT_TYPE,
    CREATED_AT,
    TRANSCRIPT
FROM DEFAULT_SCHEMA.UNIQUE_TRANSCRIPTS
ORDER BY PRIMARY_TICKER, EVENT_TIMESTAMP;

-- =====================================================
-- INSTRUCTIONS:
-- =====================================================
-- For each query above:
-- 1. Run the query in a Snowflake worksheet
-- 2. Click "Download" or "Export Results"
-- 3. Save as CSV with the filename specified in the comment
-- 4. Save all files to: dataops/event/DATA/
-- =====================================================

