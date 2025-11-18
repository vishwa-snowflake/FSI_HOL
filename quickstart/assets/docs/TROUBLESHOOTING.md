# Troubleshooting Guide

## Common Issues

### 1. SnowCLI Not Found

**Error**: `snow: command not found`

**Fix**:
```bash
pip install snowflake-cli-labs

# Verify
snow --version
```

---

### 2. Connection Failed

**Error**: `Connection error` or `Authentication failed`

**Fix**:
```bash
# Reconfigure connection
snow connection add

# Test connection
snow connection test -c <connection_name>
```

**Check**:
- Account URL is correct (include region)
- Username/password are correct
- Using ACCOUNTADMIN role
- Warehouse exists and is running

---

### 3. Insufficient Privileges

**Error**: `Insufficient privileges to operate on...`

**Fix**:
```sql
-- Use ACCOUNTADMIN role
USE ROLE ACCOUNTADMIN;

-- Or grant privileges to your role
GRANT CREATE DATABASE ON ACCOUNT TO ROLE <your_role>;
```

---

### 4. Warehouse Not Running

**Error**: `Warehouse ... does not exist or not authorized`

**Fix**:
```sql
-- Create warehouse if needed
CREATE WAREHOUSE IF NOT EXISTS DEFAULT_WH
  WAREHOUSE_SIZE = 'SMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

-- Or use existing warehouse
USE WAREHOUSE COMPUTE_WH;
```

---

### 5. File Upload Fails

**Error**: `PUT command failed` or `File not found`

**Fix**:
- Check file paths are correct in SQL
- Ensure you're running from correct directory
- Check file permissions (chmod 644)
- Use absolute paths if relative paths fail

---

### 6. CSV Loading Errors

**Error**: `Number of columns in file (X) does not match...`

**Fix**:
```sql
-- Check CSV format
SELECT $1, $2, $3 FROM @stage/file.csv (file_format => csv_format) LIMIT 5;

-- Adjust field delimiter if needed
CREATE FILE FORMAT csv_format
  TYPE = CSV
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"';
```

---

### 7. Search Service Creation Fails

**Error**: `CORTEX SEARCH SERVICE creation failed`

**Fix**:
- Ensure CORTEX_USER role is granted
- Check warehouse is running
- Verify table has data
- Use fully qualified table names

```sql
-- Grant Cortex role
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE ATTENDEE_ROLE;

-- Verify table
SELECT COUNT(*) FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAILS;
```

---

### 8. Streamlit App Not Showing

**Error**: App doesn't appear in Streamlit list

**Fix**:
```sql
-- Check if deployed
SHOW STREAMLITS IN SCHEMA DEFAULT_SCHEMA;

-- Verify ownership
SELECT * FROM INFORMATION_SCHEMA.STREAMLITS
WHERE STREAMLIT_NAME = 'STOCKONE_AGENT';

-- Redeploy if needed
-- Run 04_deploy_streamlit.sql again
```

---

### 9. Agent Not Responding

**Error**: Agent returns errors or empty responses

**Fix**:
- Verify search services are created
- Check Cortex Analyst views exist
- Ensure agent has proper grants

```sql
-- Test search service
SELECT * FROM EMAILS('test query');

-- Test Cortex Analyst
SELECT * FROM COMPANY_DATA_8_CORE_FEATURED_TICKERS;
-- Ask: "What is revenue for Snowflake?"
```

---

### 10. Out of Memory

**Error**: `Out of memory` during deployment

**Fix**:
```sql
-- Use larger warehouse
ALTER WAREHOUSE DEFAULT_WH SET WAREHOUSE_SIZE = 'MEDIUM';

-- Or split deployment
-- Run one SQL file at a time instead of deploy_all.sh
```

---

## Verification Commands

### Check Deployment Status

```sql
USE ROLE ACCOUNTADMIN;
USE DATABASE ACCELERATE_AI_IN_FSI;

-- Tables
SELECT COUNT(*) AS table_count 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'DEFAULT_SCHEMA';

-- Row counts
SELECT 
    'SOCIAL_MEDIA_NRNT' AS table_name, 
    COUNT(*) AS rows 
FROM SOCIAL_MEDIA_NRNT
UNION ALL
SELECT 'TRANSCRIBED_EARNINGS_CALLS', COUNT(*) FROM TRANSCRIBED_EARNINGS_CALLS
UNION ALL
SELECT 'EMAIL_PREVIEWS_EXTRACTED', COUNT(*) FROM EMAIL_PREVIEWS_EXTRACTED;

-- Stages
SHOW STAGES IN SCHEMA DOCUMENT_AI;

-- Services
SHOW CORTEX SEARCH SERVICES;
SHOW STREAMLITS;
```

Expected:
- Tables: 20+
- Social Media: 4,391 rows
- Stages: ~10
- Search Services: 5
- Streamlits: 1

---

## Performance Tips

### Speed Up Deployment

1. **Use appropriate warehouse size**:
   - SMALL for account setup
   - MEDIUM for data loading
   - SMALL for search services

2. **Run in parallel** (if comfortable with SQL):
   ```bash
   # Deploy services in parallel
   snow sql -f 03_deploy_cortex_analyst.sql -c conn &
   snow sql -f 04_deploy_streamlit.sql -c conn &
   wait
   ```

3. **Skip optional components**:
   - SnowMail deployment (if you don't need email)
   - Some notebooks (deploy only what you'll use)

---

## Getting Help

### Log Files

Check logs for detailed errors:
```bash
# SnowCLI logs
tail -100 ~/.snowflake/snowcli.log

# Deployment script logs
cat deployment.log
```

### Community Support

- **Snowflake Community**: https://community.snowflake.com
- **Documentation**: https://docs.snowflake.com
- **GitHub Issues**: Submit to repository

### Clean Up and Retry

If deployment fails partway:

```sql
-- Drop and start over
USE ROLE ACCOUNTADMIN;
DROP DATABASE IF EXISTS ACCELERATE_AI_IN_FSI CASCADE;

-- Then run deployment again
```

---

**Most issues are resolved by using ACCOUNTADMIN role and ensuring warehouse is running!**

