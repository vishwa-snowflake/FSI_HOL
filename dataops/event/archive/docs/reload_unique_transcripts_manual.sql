-- Reload unique_transcripts table with enhanced data
-- Run this manually in Snowflake SQL worksheet

USE DATABASE ACCELERATE_AI_IN_FSI;
USE SCHEMA DEFAULT_SCHEMA;

-- 1. First, upload the file using SnowSQL or Snowflake UI:
-- snowsql -c test_fsi_ai_assistant -q "PUT file:///Users/boconnor/fsi-cortex-assistant/dataops/event/DATA/unique_transcripts.csv @CSV_DATA_STAGE auto_compress=false overwrite=true"

-- Or run this PUT command if you're in SnowSQL:
PUT file:///Users/boconnor/fsi-cortex-assistant/dataops/event/DATA/unique_transcripts.csv @CSV_DATA_STAGE auto_compress=false overwrite=true;

-- 2. Verify the file is in stage
LIST @CSV_DATA_STAGE PATTERN='.*unique_transcripts.*';

-- 3. Backup existing data (optional but recommended)
CREATE OR REPLACE TABLE unique_transcripts_backup AS 
SELECT * FROM unique_transcripts;

-- 4. Truncate and reload table
TRUNCATE TABLE unique_transcripts;

-- 5. Copy data from stage
COPY INTO unique_transcripts
FROM @CSV_DATA_STAGE/unique_transcripts.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FORMAT')
ON_ERROR = 'CONTINUE'
PURGE = FALSE;

-- 6. Verify the load
SELECT 
    COUNT(*) as total_transcripts,
    COUNT(DISTINCT primary_ticker) as unique_tickers
FROM unique_transcripts;

-- Expected: 92 total transcripts

-- 7. Verify analyst coverage in all transcripts
WITH analyst_counts AS (
    SELECT 
        primary_ticker,
        ARRAY_SIZE(PARSE_JSON(transcript):parsed_transcript) as total_entries,
        ARRAY_SIZE(ARRAY_AGG(s.value) FILTER (WHERE s.value:speaker_data.role = 'Analyst')) as analyst_count
    FROM unique_transcripts,
    LATERAL FLATTEN(input => PARSE_JSON(transcript):speaker_mapping) s
    GROUP BY primary_ticker, transcript
)
SELECT 
    COUNT(*) as transcripts_with_analysts,
    MIN(analyst_count) as min_analysts,
    MAX(analyst_count) as max_analysts,
    AVG(analyst_count) as avg_analysts
FROM analyst_counts
WHERE analyst_count > 0;

-- Should show all 92 transcripts now have 3+ analysts

-- 8. Sample check - view one enhanced transcript
SELECT 
    primary_ticker,
    event_timestamp,
    ARRAY_SIZE(PARSE_JSON(transcript):parsed_transcript) as entries,
    ARRAY_SIZE(ARRAY_AGG(s.value) FILTER (WHERE s.value:speaker_data.role = 'Analyst')) as analysts
FROM unique_transcripts
WHERE primary_ticker = 'NXGN'
CROSS JOIN LATERAL FLATTEN(input => PARSE_JSON(transcript):speaker_mapping) s
GROUP BY primary_ticker, event_timestamp, transcript;

-- Should now show 3 analysts instead of 0

