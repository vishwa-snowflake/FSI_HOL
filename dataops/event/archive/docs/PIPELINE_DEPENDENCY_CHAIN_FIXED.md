# Pipeline Dependency Chain Fixed ✅

## Errors Fixed

### Error 1: ML Element Jinja Template Not Rendering
```
001003 (42000): SQL compilation error:
syntax error line 1 at position 45 unexpected '{'.
```

**Cause**: File named `setup_scripts_ml_element.sql` instead of `.template.sql`  
**Fix**: Renamed to `setup_scripts_ml_element.template.sql`  
**Path Fix**: Changed `data/` → `DATA/` for CSV file paths  

---

### Error 2: EMAIL_PREVIEWS Table Missing
```
002003 (42S02): SQL compilation error:
Table 'ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS' does not exist
```

**Cause**: No pipeline job to deploy data_foundation.template.sql  
**Fix**: Created `data_foundation.yml` pipeline job  
**Order**: Data Foundation now runs BEFORE SnowMail  

---

## Complete Pipeline Dependency Chain

```
Initialise Pipeline
         ↓
Configure Attendee Account
         ↓
    ┌────┴────┬────┬────┬────┬────┬────┐
    ↓         ↓    ↓    ↓    ↓    ↓    ↓
Homepage  Notebooks Streamlit DocAI Analyst DataFoundation MLElement
                                      ↓
                                 SnowMail
```

### Execution Order:
1. **Initialise Pipeline**
2. **Configure Attendee Account** (creates database, roles, users)
3. **Parallel Jobs** (all depend on Configure Attendee Account):
   - Build Homepage
   - Deploy Notebooks
   - Deploy Streamlit
   - Deploy Document AI
   - Deploy Cortex Analyst
   - **Deploy Data Foundation** ⭐ (creates EMAIL_PREVIEWS, WEB_SEARCH, SEND_EMAIL)
   - Deploy ML Element
4. **Deploy SnowMail** (depends on Data Foundation)

---

## Files Created/Modified

### Created Files:
1. ✅ `pipelines/includes/local_includes/data_foundation.yml` - NEW
2. ✅ `pipelines/includes/local_includes/deploy_snow_mail.yml` - NEW  
3. ✅ `pipelines/includes/local_includes/deploy_ml_element.yml` - NEW

### Modified Files:
1. ✅ `full-ci.yml` - Added 3 new job includes
2. ✅ `dataops/event/variables.yml` - Added control variables
3. ✅ `dataops/event/setup_scripts_ml_element.sql` → `setup_scripts_ml_element.template.sql` - Renamed
4. ✅ `setup_scripts_ml_element.template.sql` - Fixed file paths (data/ → DATA/)
5. ✅ `deploy_snow_mail.yml` - Added dependency on "Data Foundation" job

---

## Data Foundation Job Details

### What it Creates:

**1. WEB_SEARCH Function**
```sql
CREATE OR REPLACE FUNCTION {{ env.EVENT_DATABASE }}.DEFAULT_SCHEMA.WEB_SEARCH(QUERY VARCHAR)
```
- DuckDuckGo web search integration
- Returns up to 3 search results in JSON
- Used by agent for external information

**2. SEND_EMAIL_NOTIFICATION Procedure**
```sql
CREATE OR REPLACE PROCEDURE {{ env.EVENT_DATABASE }}.DEFAULT_SCHEMA.SEND_EMAIL_NOTIFICATION(
    EMAIL_SUBJECT VARCHAR,
    EMAIL_CONTENT VARCHAR,
    RECIPIENT_EMAIL VARCHAR DEFAULT 'becky.oconnor@snowflake.com',
    MIME_TYPE VARCHAR DEFAULT 'text/html'
)
```
- Sends emails with markdown-to-HTML conversion
- Stores emails in EMAIL_PREVIEWS table
- Returns SnowMail URL for viewing

**3. EMAIL_PREVIEWS Table**
```sql
CREATE TABLE IF NOT EXISTS {{ env.EVENT_DATABASE }}.DEFAULT_SCHEMA.EMAIL_PREVIEWS (
    EMAIL_ID VARCHAR(100) PRIMARY KEY,
    RECIPIENT_EMAIL VARCHAR(500),
    SUBJECT VARCHAR(1000),
    HTML_CONTENT VARCHAR(16777216),
    CREATED_AT TIMESTAMP_NTZ
);
```
- Stores all sent emails
- Pre-populated with 8 sample financial emails
- Used by SnowMail for email display

---

## Dependency Requirements

### SnowMail Depends on Data Foundation Because:
```sql
-- In deploy_snow_mail.template.sql (line 98)
GRANT SELECT, DELETE ON TABLE {{ env.EVENT_DATABASE }}.DEFAULT_SCHEMA.EMAIL_PREVIEWS 
TO APPLICATION SNOWMAIL;
```

❌ **Before**: Data Foundation not deployed → EMAIL_PREVIEWS doesn't exist → GRANT fails  
✅ **After**: Data Foundation runs first → EMAIL_PREVIEWS created → GRANT succeeds  

---

## Pipeline Job Configuration

### Data Foundation Job:
```yaml
Data Foundation:
  stage: "Additional Configuration"
  needs:
    - job: "Initialise Pipeline"
    - job: "Configure Attendee Account"
  rules:
    - if: $EVENT_DEPLOY_DATA_FOUNDATION == "true"
  variables:
    DATAOPS_RUN_SQL: $CI_PROJECT_DIR/dataops/event/data_foundation.sql
```

### SnowMail Job (Updated):
```yaml
Deploy SnowMail:
  stage: "Additional Configuration"
  needs:
    - job: "Initialise Pipeline"
    - job: "Configure Attendee Account"
    - job: "Data Foundation"  # ⭐ NEW DEPENDENCY
  rules:
    - if: $EVENT_DEPLOY_SNOW_MAIL == "true"
  variables:
    DATAOPS_RUN_SQL: $CI_PROJECT_DIR/dataops/event/deploy_snow_mail.sql
```

---

## Control Variables

### In `dataops/event/variables.yml`:
```yaml
EVENT_DEPLOY_DATA_FOUNDATION: "true"  # ⭐ NEW
EVENT_DEPLOY_SNOW_MAIL: "true"
EVENT_DEPLOY_ML_ELEMENT: "true"
```

---

## File Naming Convention

### Template Files (Source):
- `*.template.sql` - Contains Jinja variables `{{ env.VAR }}`
- Pipeline automatically renders these to `*.sql`

### Rendered Files (Generated):
- `*.sql` - Final SQL with variables replaced
- These are what get executed by Snowflake

### Files That Need .template.sql Extension:
✅ `configure_attendee_account.template.sql`  
✅ `data_foundation.template.sql`  
✅ `deploy_cortex_analyst.template.sql`  
✅ `deploy_documentai.template.sql`  
✅ `deploy_notebooks.template.sql`  
✅ `deploy_snow_mail.template.sql`  
✅ `deploy_streamlit.template.sql`  
✅ `setup_scripts_ml_element.template.sql` ⭐ **FIXED** (was .sql)  

---

## Complete Fix Summary

### Issue 1: ML Element Syntax Error
- ❌ File: `setup_scripts_ml_element.sql` (wrong extension)
- ✅ Fixed: Renamed to `setup_scripts_ml_element.template.sql`
- ✅ Fixed: Changed file paths from `data/` to `DATA/`

### Issue 2: EMAIL_PREVIEWS Missing
- ❌ Problem: No pipeline job for data_foundation.template.sql
- ✅ Created: `data_foundation.yml` pipeline job
- ✅ Added: To `full-ci.yml` includes
- ✅ Added: Control variable `EVENT_DEPLOY_DATA_FOUNDATION: "true"`

### Issue 3: Wrong Deployment Order
- ❌ Problem: SnowMail could run before EMAIL_PREVIEWS created
- ✅ Fixed: SnowMail now depends on "Data Foundation" job
- ✅ Result: Guaranteed execution order

---

## Testing After Fix

### Check Data Foundation Deployed:
```sql
-- WEB_SEARCH function exists
SHOW FUNCTIONS LIKE 'WEB_SEARCH' IN {{ env.EVENT_DATABASE }}.DEFAULT_SCHEMA;

-- SEND_EMAIL_NOTIFICATION procedure exists
SHOW PROCEDURES LIKE 'SEND_EMAIL%' IN {{ env.EVENT_DATABASE }}.DEFAULT_SCHEMA;

-- EMAIL_PREVIEWS table exists with 8 sample emails
SELECT COUNT(*) FROM {{ env.EVENT_DATABASE }}.DEFAULT_SCHEMA.EMAIL_PREVIEWS;
-- Should return: 8
```

### Check SnowMail Deployed:
```sql
SHOW APPLICATIONS LIKE 'SNOWMAIL';
-- Should show SNOWMAIL application

-- Verify grants work (table exists)
SELECT COUNT(*) FROM {{ env.EVENT_DATABASE }}.DEFAULT_SCHEMA.EMAIL_PREVIEWS;
-- SnowMail app should be able to read these
```

---

## Status: ✅ ALL ISSUES FIXED

**Files:**
- ✅ 3 pipeline jobs created (data_foundation, deploy_snow_mail, deploy_ml_element)
- ✅ ML element renamed to .template.sql
- ✅ File paths corrected (DATA/ not data/)
- ✅ Dependencies configured correctly
- ✅ Control variables added

**Ready for Pipeline Re-run:** 🚀

**Expected Result:**
1. Data Foundation deploys first (creates EMAIL_PREVIEWS + WEB_SEARCH + SEND_EMAIL)
2. SnowMail deploys second (grants work because table exists)
3. ML Element renders correctly (Jinja templates processed)
4. All jobs succeed ✅

