-- ================================================================
-- AI_EXTRACT Script for Analyst Reports (WITH FULL PARSED TEXT)
-- Replaces Document AI with Snowflake Cortex AI_EXTRACT
-- ================================================================

-- Step 1: Create the extraction schema with questions AND full parsed text
CREATE OR REPLACE TABLE DOCUMENT_AI.AI_EXTRACT_ANALYST_REPORTS AS
SELECT 
    RELATIVE_PATH,
    FILE_URL,
    BUILD_SCOPED_FILE_URL('@DOCUMENT_AI.ANALYST_REPORTS', RELATIVE_PATH) AS SCOPED_URL,
    
    -- Get the full parsed content first
    SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
        '@DOCUMENT_AI.ANALYST_REPORTS',
        RELATIVE_PATH,
        {'mode': 'LAYOUT'}
    ):content::text AS CONTENT,
    
    SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
        '@DOCUMENT_AI.ANALYST_REPORTS',
        RELATIVE_PATH,
        {'mode': 'LAYOUT'}
    ):metadata:pageCount AS PAGE_COUNT,
    
    -- Extract structured fields using AI_EXTRACT from the parsed content
    SNOWFLAKE.CORTEX.AI_EXTRACT(
        SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
            '@DOCUMENT_AI.ANALYST_REPORTS',
            RELATIVE_PATH,
            {'mode': 'LAYOUT'}
        ):content::text,
        {
            'DATE_REPORT': 'When was the Report Created? Return the date in format.',
            'NAME_OF_REPORT_PROVIDER': 'What is the name of the report provider or research firm?',
            'RATING': 'What is the rating recommendation? Is it BUY, SELL, HOLD, or EQUAL-WEIGHT?',
            'CLOSE_PRICE': 'What is the Close Price Value mentioned in the report?',
            'PRICE_TARGET': 'What is the Price Target Value?',
            'GROWTH': 'What is the latest revenue Growth - YoY (Year over Year)?'
        }
    ) AS EXTRACTED_DATA

FROM DIRECTORY('@DOCUMENT_AI.ANALYST_REPORTS');

-- Step 2: Create a structured view with flattened extracted fields + full text
CREATE OR REPLACE VIEW DOCUMENT_AI.AI_EXTRACT_REPORTS_STRUCTURED AS
SELECT 
    RELATIVE_PATH,
    FILE_URL,
    PAGE_COUNT,
    
    -- Extract individual fields from the JSON response
    EXTRACTED_DATA:DATE_REPORT::text AS DATE_REPORT,
    EXTRACTED_DATA:NAME_OF_REPORT_PROVIDER::text AS NAME_OF_REPORT_PROVIDER,
    EXTRACTED_DATA:RATING::text AS RATING,
    EXTRACTED_DATA:CLOSE_PRICE::text AS CLOSE_PRICE,
    EXTRACTED_DATA:PRICE_TARGET::text AS PRICE_TARGET,
    EXTRACTED_DATA:GROWTH::text AS GROWTH,
    
    -- Full parsed text as separate column
    CONTENT AS FULL_TEXT
    
FROM DOCUMENT_AI.AI_EXTRACT_ANALYST_REPORTS;

-- Step 3: View the results (with full text)
SELECT 
    RELATIVE_PATH,
    DATE_REPORT,
    NAME_OF_REPORT_PROVIDER,
    RATING,
    CLOSE_PRICE,
    PRICE_TARGET,
    GROWTH,
    PAGE_COUNT,
    LENGTH(FULL_TEXT) AS TEXT_LENGTH,
    FULL_TEXT
FROM DOCUMENT_AI.AI_EXTRACT_REPORTS_STRUCTURED;


-- ================================================================
-- Optional: More advanced version with AI_COMPLETE + full text
-- This uses AI_COMPLETE with structured outputs for higher accuracy
-- ================================================================

CREATE OR REPLACE TABLE DOCUMENT_AI.AI_EXTRACT_ANALYST_REPORTS_ADVANCED AS
SELECT 
    RELATIVE_PATH,
    FILE_URL,
    BUILD_SCOPED_FILE_URL('@DOCUMENT_AI.ANALYST_REPORTS', RELATIVE_PATH) AS SCOPED_URL,
    CONTENT AS FULL_TEXT,
    PAGE_COUNT,
    
    -- Use AI_COMPLETE with structured output schema
    SNOWFLAKE.CORTEX.AI_COMPLETE(
        model => 'claude-3-7-sonnet',
        prompt => CONCAT(
            'Extract the following information from this analyst report:\n',
            '1. Report creation date\n',
            '2. Name of the report provider/research firm\n',
            '3. Stock rating (BUY, SELL, HOLD, or EQUAL-WEIGHT)\n',
            '4. Close price value\n',
            '5. Price target value\n',
            '6. Latest revenue growth YoY\n\n',
            'Document content:\n',
            CONTENT
        ),
        response_format => {
            'type': 'json',
            'schema': {
                'type': 'object',
                'properties': {
                    'date_report': {'type': 'string', 'description': 'Date when the report was created'},
                    'name_of_report_provider': {'type': 'string', 'description': 'Name of the research firm or report provider'},
                    'rating': {'type': 'string', 'enum': ['BUY', 'SELL', 'HOLD', 'EQUAL-WEIGHT'], 'description': 'Stock rating recommendation'},
                    'close_price': {'type': 'string', 'description': 'Close price value'},
                    'price_target': {'type': 'string', 'description': 'Price target value'},
                    'growth': {'type': 'string', 'description': 'Latest revenue growth YoY'}
                },
                'required': ['date_report', 'name_of_report_provider', 'rating']
            }
        }
    ) AS EXTRACTED_DATA

FROM (
    SELECT 
        RELATIVE_PATH,
        BUILD_SCOPED_FILE_URL('@DOCUMENT_AI.ANALYST_REPORTS', RELATIVE_PATH) AS FILE_URL,
        SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
            '@DOCUMENT_AI.ANALYST_REPORTS',
            RELATIVE_PATH,
            {'mode': 'LAYOUT'}
        ):content::text AS CONTENT,
        SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
            '@DOCUMENT_AI.ANALYST_REPORTS',
            RELATIVE_PATH,
            {'mode': 'LAYOUT'}
        ):metadata:pageCount AS PAGE_COUNT
    FROM DIRECTORY('@DOCUMENT_AI.ANALYST_REPORTS')
);

-- Step 4: Create structured view from advanced extraction (with full text and fallback logic)
CREATE OR REPLACE VIEW DOCUMENT_AI.AI_EXTRACT_REPORTS_STRUCTURED_ADVANCED AS
SELECT 
    RELATIVE_PATH,
    FILE_URL,
    PAGE_COUNT,
    
    -- Extract individual fields from the structured JSON response
    EXTRACTED_DATA:date_report::text AS DATE_REPORT,
    
    -- NAME_OF_REPORT_PROVIDER with fallback to filename parsing
    COALESCE(
        NULLIF(TRIM(EXTRACTED_DATA:name_of_report_provider::text), ''),
        CASE 
            WHEN RELATIVE_PATH ILIKE '%Sterling%Partners%' OR RELATIVE_PATH ILIKE '%Sterling_Partners%' THEN 'Sterling Partners'
            WHEN RELATIVE_PATH ILIKE '%Apex%Analytics%' OR RELATIVE_PATH ILIKE '%Apex_Analytics%' THEN 'Apex Analytics'
            WHEN RELATIVE_PATH ILIKE '%Veridian%Capital%' OR RELATIVE_PATH ILIKE '%Veridian_Capital%' THEN 'Veridian Capital'
            WHEN RELATIVE_PATH ILIKE '%Momentum%Metrics%' OR RELATIVE_PATH ILIKE '%Momentum_Metrics%' THEN 'Momentum Metrics'
            WHEN RELATIVE_PATH ILIKE '%Quant%Vestor%' OR RELATIVE_PATH ILIKE '%Quant-Vestor%' THEN 'Quant-Vestor'
            WHEN RELATIVE_PATH ILIKE '%Consensus%Point%' OR RELATIVE_PATH ILIKE '%Consensus_Point%' THEN 'Consensus Point'
            WHEN RELATIVE_PATH ILIKE '%Pinnacle%Growth%' OR RELATIVE_PATH ILIKE '%Pinnacle_Growth%' THEN 'Pinnacle Growth Investors'
            WHEN RELATIVE_PATH ILIKE '%Morgan%Stanley%' THEN 'Morgan Stanley'
            WHEN RELATIVE_PATH ILIKE '%Argus%' THEN 'Argus'
            WHEN RELATIVE_PATH ILIKE '%MarketEdge%' OR RELATIVE_PATH ILIKE '%Market%Edge%' THEN 'MarketEdge'
            WHEN RELATIVE_PATH ILIKE '%Refinitiv%' THEN 'Refinitiv'
            WHEN RELATIVE_PATH ILIKE '%SmartConsensus%' OR RELATIVE_PATH ILIKE '%Smart%Consensus%' THEN 'SmartConsensus'
            ELSE 'Unknown Provider'
        END
    ) AS NAME_OF_REPORT_PROVIDER,
    
    EXTRACTED_DATA:rating::text AS RATING,
    EXTRACTED_DATA:close_price::text AS CLOSE_PRICE,
    EXTRACTED_DATA:price_target::text AS PRICE_TARGET,
    EXTRACTED_DATA:growth::text AS GROWTH,
    
    -- Full parsed text as separate column
    FULL_TEXT
    
FROM DOCUMENT_AI.AI_EXTRACT_ANALYST_REPORTS_ADVANCED;

-- Step 5: View the advanced results (with full text)
SELECT 
    RELATIVE_PATH,
    DATE_REPORT,
    NAME_OF_REPORT_PROVIDER,
    RATING,
    CLOSE_PRICE,
    PRICE_TARGET,
    GROWTH,
    PAGE_COUNT,
    LENGTH(FULL_TEXT) AS TEXT_LENGTH,
    FULL_TEXT
FROM DOCUMENT_AI.AI_EXTRACT_REPORTS_STRUCTURED_ADVANCED;


-- ================================================================
-- Step 6: Create summarized and chunked data (with full text preserved)
-- ================================================================

-- Summarize the reports using AI_AGG
CREATE OR REPLACE TABLE DOCUMENT_AI.AI_EXTRACT_SUMMARISED_ANALYST_REPORTS AS
SELECT 
    RELATIVE_PATH,
    RATING,
    DATE_REPORT,
    NAME_OF_REPORT_PROVIDER,
    'ANALYST_REPORTS' AS DOCUMENT_TYPE,
    SPLIT_PART(RELATIVE_PATH, '/', 1)::text AS DOCUMENT,
    AI_AGG(FULL_TEXT, 'summarize the analyst reports in no more than 500 words') AS SUMMARY,
    FULL_TEXT  -- Include full text in summary table too
FROM DOCUMENT_AI.AI_EXTRACT_REPORTS_STRUCTURED_ADVANCED
GROUP BY RELATIVE_PATH, RATING, DATE_REPORT, NAME_OF_REPORT_PROVIDER, FULL_TEXT;

SELECT * FROM DOCUMENT_AI.AI_EXTRACT_SUMMARISED_ANALYST_REPORTS;


-- Chunk the reports for search service (with full text reference)
CREATE OR REPLACE TABLE DOCUMENT_AI.AI_EXTRACT_CHUNKED AS
SELECT 
    RELATIVE_PATH,
    RATING,
    DATE_REPORT,
    NAME_OF_REPORT_PROVIDER,
    'ANALYST_REPORTS' AS DOCUMENT_TYPE,
    SPLIT_PART(RELATIVE_PATH, '/', 1)::text AS DOCUMENT,
    VALUE::TEXT AS TEXT,
    FULL_TEXT  -- Include reference to full text
FROM DOCUMENT_AI.AI_EXTRACT_REPORTS_STRUCTURED_ADVANCED,
LATERAL FLATTEN(
    SNOWFLAKE.CORTEX.SPLIT_TEXT_RECURSIVE_CHARACTER(
        FULL_TEXT, 'none', 600, 50, ['\n\n', ' ']
    )
);

SELECT * FROM DOCUMENT_AI.AI_EXTRACT_CHUNKED LIMIT 10;


-- Create final chunked table with sentiment and period (with full text)
CREATE OR REPLACE TABLE DOCUMENT_AI.AI_EXTRACT_ANALYST_REPORTS_CHUNKED AS
SELECT 
    *,
    -- Extract period from filename using AI_COMPLETE
    SNOWFLAKE.CORTEX.AI_COMPLETE(
        model => 'claude-3-7-sonnet',
        prompt => CONCAT(
            'Look at the following file name and return the period in this format: Q2FY25. ',
            'Assume period 1 of the financial year is January. ',
            'Return ONLY the answer without comment: ',
            RELATIVE_PATH
        ),
        response_format => {
            'type': 'json',
            'schema': {
                'type': 'object',
                'properties': {
                    'period': {'type': 'string'},
                    'date': {'type': 'string'}
                },
                'required': ['period']
            }
        }
    ):period::text AS PERIOD,
    
    -- Add sentiment analysis
    SNOWFLAKE.CORTEX.AI_SENTIMENT(TEXT):categories[0]:sentiment::text AS SENTIMENT,
    SNOWFLAKE.CORTEX.SENTIMENT(TEXT) AS SENTIMENT_SCORE
    
FROM (
    -- Combine detailed chunks and summaries
    SELECT 'DETAILED' AS AGGREGATION, * 
    FROM DOCUMENT_AI.AI_EXTRACT_CHUNKED
    
    UNION 
    
    SELECT 'SUMMARY' AS AGGREGATION, 
           RELATIVE_PATH,
           RATING,
           DATE_REPORT,
           NAME_OF_REPORT_PROVIDER,
           DOCUMENT_TYPE,
           DOCUMENT,
           SUMMARY AS TEXT,
           FULL_TEXT
    FROM DOCUMENT_AI.AI_EXTRACT_SUMMARISED_ANALYST_REPORTS
);

SELECT * FROM DOCUMENT_AI.AI_EXTRACT_ANALYST_REPORTS_CHUNKED LIMIT 10;


-- ================================================================
-- Step 7: Create combined view for all data (with full text)
-- ================================================================

CREATE OR REPLACE VIEW DOCUMENT_AI.AI_EXTRACT_REPORTS_ALL_DATA AS
SELECT 
    A.RELATIVE_PATH,
    A.FILE_URL,
    A.PAGE_COUNT,
    A.DATE_REPORT,
    A.NAME_OF_REPORT_PROVIDER,
    A.RATING,
    A.CLOSE_PRICE,
    A.PRICE_TARGET,
    A.GROWTH,
    A.FULL_TEXT AS CONTENT,
    B.EXTRACTED_DATA
FROM DOCUMENT_AI.AI_EXTRACT_REPORTS_STRUCTURED_ADVANCED A
INNER JOIN DOCUMENT_AI.AI_EXTRACT_ANALYST_REPORTS_ADVANCED B
    ON A.RELATIVE_PATH = B.RELATIVE_PATH;

SELECT * FROM DOCUMENT_AI.AI_EXTRACT_REPORTS_ALL_DATA;


-- ================================================================
-- Step 8: Provider-level summaries (matching notebook workflow)
-- ================================================================

CREATE OR REPLACE TABLE DOCUMENT_AI.AI_EXTRACT_REPORT_PROVIDER_SUMMARY AS
SELECT 
    NAME_OF_REPORT_PROVIDER, 
    AI_AGG(FULL_TEXT, 'summarize the analyst reports in no more than 500 words and compare what they have said for each report date') AS SUMMARY 
FROM DOCUMENT_AI.AI_EXTRACT_REPORTS_STRUCTURED_ADVANCED 
GROUP BY NAME_OF_REPORT_PROVIDER;

SELECT * FROM DOCUMENT_AI.AI_EXTRACT_REPORT_PROVIDER_SUMMARY;


-- ================================================================
-- Summary: Compare counts and show full text availability
-- ================================================================

SELECT 
    'AI_EXTRACT Results' AS SOURCE,
    COUNT(*) AS DOCUMENT_COUNT,
    COUNT(DISTINCT NAME_OF_REPORT_PROVIDER) AS UNIQUE_PROVIDERS,
    AVG(LENGTH(FULL_TEXT)) AS AVG_TEXT_LENGTH,
    MIN(LENGTH(FULL_TEXT)) AS MIN_TEXT_LENGTH,
    MAX(LENGTH(FULL_TEXT)) AS MAX_TEXT_LENGTH
FROM DOCUMENT_AI.AI_EXTRACT_REPORTS_STRUCTURED_ADVANCED;


