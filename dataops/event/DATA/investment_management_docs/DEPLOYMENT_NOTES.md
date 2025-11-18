# Investment Management Documents - Deployment Notes

## Stage Configuration

### Stage Details
- **Name**: `investment_management`
- **Schema**: `{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}`
- **Directory Enabled**: Yes
- **Encryption**: Snowflake SSE (Server-Side Encryption)
- **Comment**: Investment management research papers from Federal Reserve and NBER

### Deployment Script
The stage is created and populated by `deploy_documentai.template.sql` (lines 47-77)

## Files Uploaded

The following 7 PDF documents are automatically uploaded to the stage:

1. `Federal_Reserve_Asset_Allocation.pdf` (684 KB, 36 pages)
2. `Federal_Reserve_Investment_Analysis.pdf` (649 KB, 26 pages)
3. `Federal_Reserve_Portfolio_Choice.pdf` (790 KB, 60 pages)
4. `Federal_Reserve_Quantitative_Investment.pdf` (817 KB, 37 pages)
5. `Federal_Reserve_Risk_Management.pdf` (443 KB, 72 pages)
6. `NBER_ESG_Investing.pdf` (389 KB)
7. `NBER_Portfolio_Optimization.pdf` (1.2 MB)

**Total Size**: ~4.9 MB

## Deployment Process

When `deploy_documentai.template.sql` runs, it will:

1. **Create Stage**
```sql
CREATE OR REPLACE STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.investment_management
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse');
```

2. **Upload Files**
```sql
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/investment_management_docs/*.pdf 
    @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.investment_management 
    auto_compress = false 
    overwrite = true;
```

3. **Refresh Directory**
```sql
ALTER STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.investment_management REFRESH;
```

4. **Verify Upload**
```sql
LIST @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.investment_management;
```

5. **Show Summary**
Returns file count and total size in MB

## Usage Examples

### List All Documents in Stage
```sql
LIST @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.investment_management;
```

### Get Presigned URL for a Document
```sql
SELECT GET_PRESIGNED_URL(
    @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.investment_management, 
    'Federal_Reserve_Portfolio_Choice.pdf',
    604800  -- 7 days expiry
) AS document_url;
```

### Process with Document AI
```sql
-- Extract text from investment management PDFs
SELECT 
    relative_path,
    SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
        @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.investment_management,
        relative_path,
        {'mode': 'LAYOUT'}
    ) AS parsed_document
FROM DIRECTORY(@{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.investment_management);
```

### Create Search Service on Investment Documents
```sql
CREATE CORTEX SEARCH SERVICE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.investment_management_search
ON document_text
ATTRIBUTES file_name, document_type, topic, source
WAREHOUSE = {{ env.EVENT_WAREHOUSE }}
TARGET_LAG = '1 hour'
AS (
    -- Your query to extract and structure document content
    SELECT 
        relative_path AS file_name,
        'research_paper' AS document_type,
        CASE 
            WHEN relative_path LIKE '%ESG%' THEN 'ESG Investing'
            WHEN relative_path LIKE '%Optimization%' THEN 'Portfolio Optimization'
            WHEN relative_path LIKE '%Risk%' THEN 'Risk Management'
            WHEN relative_path LIKE '%Asset_Allocation%' THEN 'Asset Allocation'
            WHEN relative_path LIKE '%Quantitative%' THEN 'Quantitative Strategies'
            ELSE 'Investment Analysis'
        END AS topic,
        CASE 
            WHEN relative_path LIKE 'Federal_Reserve%' THEN 'Federal Reserve Board'
            WHEN relative_path LIKE 'NBER%' THEN 'NBER'
        END AS source,
        document_text
    FROM investment_management_table  -- Create this table first
);
```

## Integration with Existing Services

### Add to Cortex Analyst Semantic Views

You can reference documents in the stage in semantic models:

```sql
CREATE SEMANTIC VIEW investment_literature_view
TABLES (
    investment_management_documents
        COMMENT='Research papers on portfolio management and investment strategies'
)
DIMENSIONS (
    document_name AS document_name
        COMMENT='Name of the investment management research paper'
        WITH CORTEX SEARCH SERVICE investment_management_search,
    topic AS topic
        COMMENT='Primary topic: Portfolio Optimization, Risk Management, Asset Allocation, ESG Investing',
    source AS source
        COMMENT='Research institution: Federal Reserve Board or NBER'
);
```

## File Locations

- **Source Directory**: `/dataops/event/DATA/investment_management_docs/`
- **Snowflake Stage**: `{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.investment_management`
- **Deployment Script**: `/dataops/event/deploy_documentai.template.sql`
- **Documentation**: `/dataops/event/DATA/investment_management_docs/README.md`

## Maintenance

### Re-upload Updated Documents
```sql
-- If documents are updated, re-run the PUT command
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/investment_management_docs/*.pdf 
    @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.investment_management 
    auto_compress = false 
    overwrite = true;

ALTER STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.investment_management REFRESH;
```

### Check Stage Status
```sql
-- View stage properties
DESCRIBE STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.investment_management;

-- Check directory table
SELECT * FROM DIRECTORY(@{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.investment_management);
```

### Remove Stage (if needed)
```sql
-- Warning: This will delete all files in the stage
DROP STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.investment_management;
```

## Security

- **Encryption**: All files encrypted at rest using Snowflake SSE
- **Access Control**: Controlled by schema-level permissions
- **Role Requirements**: `EVENT_ATTENDEE_ROLE` or equivalent

## Next Steps

1. ✅ Stage created and files uploaded (automated in deployment)
2. ⏭️ Process documents with Document AI to extract content
3. ⏭️ Create structured tables from extracted data
4. ⏭️ Build Cortex Search Service for semantic search
5. ⏭️ Integrate with Cortex Analyst semantic models
6. ⏭️ Add to Streamlit app for document viewer

---

**Created**: October 29, 2025  
**Last Updated**: October 29, 2025  
**Deployed In**: deploy_documentai.template.sql

