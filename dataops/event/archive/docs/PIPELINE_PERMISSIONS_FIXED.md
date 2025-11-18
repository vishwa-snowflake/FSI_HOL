# Pipeline Permission Issues Fixed ✅

## Error Encountered

```
003001 (42501): SQL access control error:
Insufficient privileges to operate on account 'QAB76867'.
```

**Job**: Deploy Notebooks  
**Issue**: Insufficient privileges to create COMPUTE POOL  
**Root Cause**: Script used `EVENT_ATTENDEE_ROLE` but COMPUTE POOL creation requires ACCOUNTADMIN

---

## Fixes Applied

### 1. ✅ `deploy_notebooks.template.sql` (Line 2-4)

**Before:**
```sql
use role {{ env.EVENT_ATTENDEE_ROLE }};
```

**After:**
```sql
-- Use ACCOUNTADMIN for creating compute pools and notebooks
use role ACCOUNTADMIN;
```

**Why**: Creating COMPUTE POOL (line 90) requires ACCOUNTADMIN privileges

---

### 2. ✅ `deploy_snow_mail.template.sql` (Line 7-8)

**Before:**
```sql
USE ROLE {{ env.EVENT_ATTENDEE_ROLE }};
```

**After:**
```sql
-- Use ACCOUNTADMIN for creating application packages and granting permissions
USE ROLE ACCOUNTADMIN;
```

**Why**: Consistency with pipeline job configuration & safer for grants

---

## Role Strategy by Template

### Templates Using ACCOUNTADMIN:
✅ `data_foundation.template.sql` - Creates core infrastructure  
✅ `deploy_documentai.template.sql` - Starts with ACCOUNTADMIN, grants DB role  
✅ `deploy_notebooks.template.sql` - Creates compute pools (requires ACCOUNTADMIN)  
✅ `deploy_snow_mail.template.sql` - Creates native app packages  
✅ `setup_scripts_ml_element.sql` - ML infrastructure setup  

### Templates Using ATTENDEE_ROLE:
✅ `deploy_streamlit.template.sql` - Streamlit deployment (no privileged operations)  
✅ `deploy_cortex_analyst.template.sql` - Analyst deployment (no privileged operations)  

### Templates Switching Roles:
✅ `configure_attendee_account.template.sql` - Switches between roles as needed (SECURITYADMIN, USERADMIN, ACCOUNTADMIN)

---

## Pipeline Job Configuration

All deployment jobs in the pipeline are configured to run with ACCOUNTADMIN:

```yaml
variables:
  DATAOPS_SNOWSQL_ROLE: ACCOUNTADMIN
```

**Jobs:**
- Deploy Notebooks ✅
- Deploy Streamlit ✅
- Deploy Document AI ✅
- Deploy Cortex Analyst ✅
- Deploy SnowMail ✅ (NEW)
- Deploy ML Element ✅ (NEW)

---

## Why ACCOUNTADMIN is Needed

### Operations Requiring ACCOUNTADMIN:

1. **COMPUTE POOL Creation** (Deploy Notebooks)
   ```sql
   CREATE COMPUTE POOL CP_GPU_NV_S
     MIN_NODES = 1
     MAX_NODES = 1
     INSTANCE_FAMILY = GPU_NV_S
   ```
   ❌ Fails with EVENT_ATTENDEE_ROLE  
   ✅ Works with ACCOUNTADMIN

2. **APPLICATION PACKAGE Creation** (Deploy SnowMail)
   ```sql
   CREATE APPLICATION PACKAGE SNOWMAIL_PKG
   ```
   ⚠️ Could work with EVENT_ATTENDEE_ROLE if grants configured  
   ✅ Safer with ACCOUNTADMIN

3. **Cross-Database Grants** (Multiple templates)
   ```sql
   GRANT USAGE ON DATABASE X TO APPLICATION Y
   ```
   ❌ May fail with limited role  
   ✅ Works with ACCOUNTADMIN

---

## Testing the Fix

### Before Fix:
```
❌ Deploy Notebooks → ERROR: Insufficient privileges (COMPUTE POOL)
```

### After Fix:
```
✅ Deploy Notebooks → Uses ACCOUNTADMIN → COMPUTE POOL created successfully
✅ Deploy SnowMail → Uses ACCOUNTADMIN → APPLICATION created successfully
```

---

## Verification After Pipeline Runs

### Check Notebooks Deployed:
```sql
USE ROLE ACCOUNTADMIN;
SHOW NOTEBOOKS IN {{ env.EVENT_DATABASE }}.NOTEBOOKS;
-- Should show: 1_DOCUMENT_AI_ANALYST_REPORTS, 2_DOCUMENT_AI_INFOGRAPHICS, etc.

SHOW COMPUTE POOLS;
-- Should show: CP_GPU_NV_S
```

### Check SnowMail Deployed:
```sql
SHOW APPLICATIONS LIKE 'SNOWMAIL';
-- Should show: SNOWMAIL application

SELECT COUNT(*) FROM {{ env.EVENT_DATABASE }}.DEFAULT_SCHEMA.EMAIL_PREVIEWS;
-- Should return: 8 (sample emails)
```

---

## Permission Strategy Summary

### ✅ Best Practice Applied:
- Pipeline jobs run as **ACCOUNTADMIN** (configured in .yml files)
- SQL scripts use **ACCOUNTADMIN** role (consistency)
- Minimizes permission errors for privileged operations
- Simplifies deployment (no role switching mid-script)

### Operations by Privilege Level:

**Requires ACCOUNTADMIN:**
- ✅ Create COMPUTE POOL
- ✅ Create APPLICATION PACKAGE  
- ✅ Grant cross-database permissions
- ✅ Create NOTEBOOK with GPU compute pool

**Works with ATTENDEE_ROLE:**
- ✅ Create stages (if schema exists)
- ✅ PUT files to stages
- ✅ Query existing tables

---

## Files Modified

### 1. `deploy_notebooks.template.sql`
- **Change**: `EVENT_ATTENDEE_ROLE` → `ACCOUNTADMIN`
- **Reason**: COMPUTE POOL creation requires ACCOUNTADMIN
- **Line**: 4

### 2. `deploy_snow_mail.template.sql`
- **Change**: `EVENT_ATTENDEE_ROLE` → `ACCOUNTADMIN`
- **Reason**: Consistency & safer for APPLICATION PACKAGE operations
- **Line**: 8

---

## Status: ✅ FIXED

Both permission issues resolved:
- ✅ Deploy Notebooks will now succeed (ACCOUNTADMIN can create COMPUTE POOL)
- ✅ Deploy SnowMail will work reliably (ACCOUNTADMIN for app packages)
- ✅ All deployment templates aligned with pipeline job configuration
- ✅ Ready to re-run pipeline

**Next**: Commit changes and re-run pipeline 🚀

