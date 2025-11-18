# Email Previews Data - Loading Instructions

## Overview

This directory contains **324 realistic financial analyst emails** covering the 8 core companies in the FSI Cortex Assistant demo. The emails are stored in a pipe-delimited CSV file for easy management and bulk loading into Snowflake.

## Files

- **`DATA/email_previews_data.csv`** - Pipe-delimited CSV containing 324 emails (EMAIL_001 to EMAIL_324)
- **`generate_emails_csv.py`** - Python script to regenerate the CSV file if needed (outputs to DATA/)
- **`generate_emails_narrative.py`** - Enhanced script with NRNT/SNOW narrative arc (outputs to DATA/)
- **`data_foundation.template.sql`** - Main SQL script that creates tables and loads email data automatically

## Data Schema

The CSV file contains the following columns (pipe-delimited `|`):

| Column | Data Type | Description |
|--------|-----------|-------------|
| `EMAIL_ID` | VARCHAR(100) | Unique identifier (EMAIL_001 to EMAIL_324) |
| `RECIPIENT_EMAIL` | VARCHAR(500) | Recipient email address |
| `SUBJECT` | VARCHAR(1000) | Email subject line |
| `HTML_CONTENT` | VARCHAR(16777216) | Full HTML email body |
| `CREATED_AT` | TIMESTAMP_NTZ | Email creation timestamp |

## CSV Format Details

- **Delimiter**: Pipe (`|`)
- **Text Qualifier**: Double quotes (`"`)
- **Escape Character**: Backslash (`\`)
- **Encoding**: UTF-8
- **Header**: First row contains column names
- **Total Records**: 325 lines (1 header + 324 data rows)

## Loading Data into Snowflake

### Automated Loading (Recommended)

The email data is **automatically loaded** when you run `data_foundation.template.sql` as part of your deployment pipeline. The script:

1. Creates the `EMAIL_PREVIEWS` table
2. Creates a temporary stage with proper CSV format settings
3. Uploads `email_previews_data.csv` to the stage
4. Truncates the table (to avoid duplicates on re-runs)
5. Bulk loads all 324 emails using `COPY INTO`
6. Verifies the load with summary statistics
7. Cleans up the temporary stage

```bash
# Part of your standard deployment
snowsql -f data_foundation.template.sql
```

**No separate loading script is needed** - it's all integrated!

### Manual Loading

If you prefer manual steps:

```sql
-- 1. Create temporary stage with proper format
CREATE TEMPORARY STAGE email_data_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = '|'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ENCODING = 'UTF8'
  );

-- 2. Upload CSV file
PUT file:///path/to/DATA/email_previews_data.csv @email_data_stage 
    auto_compress = false 
    overwrite = true;

-- 3. Clear existing data (optional)
TRUNCATE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS;

-- 4. Load data
COPY INTO ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS
FROM @email_data_stage/email_previews_data.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = '|'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
)
ON_ERROR = 'CONTINUE'
PURGE = TRUE;

-- 5. Verify load
SELECT COUNT(*) FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS;
-- Expected: 324 records
```

## Email Content Distribution

The 324 emails are distributed across:

### Companies (8 core tickers)
- **SNOW** (Snowflake)
- **CTLG** (CatalogX)
- **DFLX** (DataFlex Analytics)
- **ICBG** (ICBG Data Systems)
- **NRNT** (Neuro-Nectar)
- **QRYQ** (Querybase)
- **STRM** (StreamPipe Systems)
- **VLTA** (Voltaic AI)

### Email Types
1. **Earnings Preview** - Pre-earnings guidance and expectations
2. **Earnings Results** - Post-earnings beat/miss analysis
3. **Investment Updates** - Strategic developments and recommendations
4. **Risk Alerts** - Downside scenarios and risk management
5. **Customer Win Announcements** - Major enterprise deals
6. **Technical Analysis** - Chart patterns and trade setups

### Date Range
- **Start**: January 1, 2024
- **End**: December 31, 2024
- All emails have realistic timestamps throughout 2024

### Recipients
27 unique recipients from major financial institutions:
- Goldman Sachs, Morgan Stanley, JP Morgan
- BlackRock, Vanguard, T. Rowe Price
- Hedge funds and investment committees

## Regenerating the CSV File

If you need to modify or regenerate the email data:

```bash
# Edit generate_emails_csv.py to adjust templates, companies, or date ranges
python3 generate_emails_csv.py

# This will regenerate DATA/email_previews_data.csv with new content

# Or use the narrative version with NRNT collapse and SNOW recovery arc
python3 generate_emails_narrative.py
```

## Benefits of CSV Approach

✅ **Easier Version Control** - CSV diffs are more readable than SQL INSERT statements  
✅ **Faster Loading** - Bulk COPY INTO is faster than row-by-row INSERTs  
✅ **No Escaping Issues** - CSV format handles HTML quotes and special characters  
✅ **DataOps Friendly** - Standard delimited file format for data pipelines  
✅ **Portable** - Can be easily imported into Excel, Python pandas, or other tools  

## Previous Approach (Deprecated)

Previously, emails were hardcoded in `data_foundation.template.sql` as SQL INSERT statements. This approach had several issues:

- ❌ Difficult to review 600+ lines of SQL with HTML content
- ❌ Prone to SQL escaping errors with quotes and special characters
- ❌ Slow row-by-row insertion
- ❌ Hard to maintain and update individual emails

The new CSV approach solves all these issues.

## Integration with SnowMail

The `SEND_EMAIL_NOTIFICATION` stored procedure automatically saves emails to the `EMAIL_PREVIEWS` table. These can be viewed through the SnowMail Native App:

```sql
-- Send an email (automatically saved to EMAIL_PREVIEWS)
CALL SEND_EMAIL_NOTIFICATION(
    'SNOW Q4 Results',
    'Snowflake beat on revenue and raised guidance...',
    'analyst@fund.com'
);

-- View in SnowMail app
-- Navigate to: Projects > Apps > SnowMail > Email Viewer
```

## Troubleshooting

### Issue: "File format error" during COPY INTO

**Solution**: Ensure the file format matches exactly:
- Delimiter: `|` (pipe)
- Text qualifier: `"` (double quote)
- Escape: `\\` (backslash)

### Issue: Some emails missing after load

**Solution**: Check for errors during COPY INTO:
```sql
-- View copy history and errors
SELECT * FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
    TABLE_NAME => 'EMAIL_PREVIEWS',
    START_TIME => DATEADD(hours, -1, CURRENT_TIMESTAMP())
));
```

### Issue: HTML content not rendering

**Solution**: Verify the HTML_CONTENT column is intact:
```sql
SELECT EMAIL_ID, LENGTH(HTML_CONTENT) AS HTML_SIZE 
FROM EMAIL_PREVIEWS 
WHERE HTML_SIZE < 100; -- Should be empty
```

## Support

For questions or issues with the email data loading process, contact the DataOps team or file an issue in the project repository.

