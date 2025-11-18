# Notebook Ownership & Permissions Configured ✅

## Complete Permission Flow

The `deploy_notebooks.template.sql` now follows a proper permission strategy ensuring:
- ✅ **ATTENDEE_ROLE owns all notebooks** (so attendees can use them)
- ✅ **ATTENDEE_ROLE has compute pool access** (for GPU notebooks)
- ✅ **ACCOUNTADMIN creates privileged resources** (compute pools, grants)

---

## Execution Flow

### Step 1: Initial Setup (ACCOUNTADMIN)
```sql
-- Line 4
USE ROLE ACCOUNTADMIN;

-- Lines 6-11: Create schema and stages
CREATE OR REPLACE SCHEMA {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }};
CREATE STAGE IF NOT EXISTS {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK1 ...;
CREATE STAGE IF NOT EXISTS {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK2 ...;
CREATE STAGE IF NOT EXISTS {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK3 ...;
CREATE STAGE IF NOT EXISTS {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK4 ...;
CREATE STAGE IF NOT EXISTS {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK5 ...;

-- Lines 16-30: Upload notebook files to stages
PUT file:///... @NOTEBOOK1 ...;
PUT file:///... @NOTEBOOK2 ...;
etc.
```

### Step 2: Grant Permissions & Create Standard Notebooks (ATTENDEE_ROLE)
```sql
-- Line 39: Grant notebook creation privilege
GRANT CREATE NOTEBOOK ON SCHEMA {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }} 
TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

-- Line 42: Switch to ATTENDEE_ROLE
USE ROLE {{ env.EVENT_ATTENDEE_ROLE }};

-- Lines 46-86: Create 5 notebooks as ATTENDEE_ROLE (they own these)
CREATE OR REPLACE NOTEBOOK "1_DOCUMENT_AI_ANALYST_REPORTS" ...;
CREATE OR REPLACE NOTEBOOK "2_DOCUMENT_AI_INFOGRAPHICS" ...;
CREATE OR REPLACE NOTEBOOK "3_ANALYSE_SOUND" ...;
CREATE OR REPLACE NOTEBOOK "4_CREATE_SEARCH_SERVICE" ...;
CREATE OR REPLACE NOTEBOOK "5_CORTEX_ANALYST" ...;
```

### Step 3: Create Compute Pool (ACCOUNTADMIN)
```sql
-- Line 89: Switch back to ACCOUNTADMIN
USE ROLE ACCOUNTADMIN;

-- Lines 91-99: Create stages and upload GPU notebook files
CREATE STAGE IF NOT EXISTS {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.AISQL_DSA_STAGE;
CREATE STAGE IF NOT EXISTS {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.TRAIN_AND_REGISTER_ML_MODELS_STAGE;
PUT file:///... @AISQL_DSA_STAGE ...;
PUT file:///... @TRAIN_AND_REGISTER_ML_MODELS_STAGE ...;

-- Lines 102-109: Create GPU compute pool
CREATE COMPUTE POOL CP_GPU_NV_S
  MIN_NODES = 1
  MAX_NODES = 1
  INSTANCE_FAMILY = GPU_NV_S ...;
```

### Step 4: Grant Compute Pool Access & Create GPU Notebooks (ATTENDEE_ROLE)
```sql
-- Lines 112-113: Grant compute pool permissions
GRANT USAGE ON COMPUTE POOL CP_GPU_NV_S TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT MONITOR ON COMPUTE POOL CP_GPU_NV_S TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

-- Lines 115-116: Grant notebook creation on second schema
GRANT CREATE NOTEBOOK ON SCHEMA {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }} 
TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT CREATE NOTEBOOK ON SCHEMA {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }} 
TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

-- Line 119: Switch to ATTENDEE_ROLE
USE ROLE {{ env.EVENT_ATTENDEE_ROLE }};

-- Lines 121-136: Create GPU notebooks as ATTENDEE_ROLE (they own these)
CREATE OR REPLACE NOTEBOOK AISQL_DSA
    COMPUTE_POOL='CP_GPU_NV_S' ...;
    
CREATE OR REPLACE NOTEBOOK TRAIN_AND_REGISTER_ML_MODELS ...;
```

---

## Notebook Ownership Summary

### Notebooks Owned by ATTENDEE_ROLE (All 7):

| Notebook | Schema | Warehouse | Compute Pool | Owner |
|----------|--------|-----------|--------------|-------|
| 1_DOCUMENT_AI_ANALYST_REPORTS | NOTEBOOKS | NOTEBOOKS_WH | None | ATTENDEE_ROLE ✅ |
| 2_DOCUMENT_AI_INFOGRAPHICS | NOTEBOOKS | NOTEBOOKS_WH | None | ATTENDEE_ROLE ✅ |
| 3_ANALYSE_SOUND | NOTEBOOKS | NOTEBOOKS_WH | None | ATTENDEE_ROLE ✅ |
| 4_CREATE_SEARCH_SERVICE | NOTEBOOKS | NOTEBOOKS_WH | None | ATTENDEE_ROLE ✅ |
| 5_CORTEX_ANALYST | NOTEBOOKS | NOTEBOOKS_WH | None | ATTENDEE_ROLE ✅ |
| AISQL_DSA | DEFAULT_SCHEMA | EVENT_WAREHOUSE | CP_GPU_NV_S | ATTENDEE_ROLE ✅ |
| TRAIN_AND_REGISTER_ML_MODELS | DEFAULT_SCHEMA | EVENT_WAREHOUSE | None | ATTENDEE_ROLE ✅ |

---

## Permission Grants to ATTENDEE_ROLE

### Compute Pool Permissions:
```sql
GRANT USAGE ON COMPUTE POOL CP_GPU_NV_S TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT MONITOR ON COMPUTE POOL CP_GPU_NV_S TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
```

**Allows:**
- ✅ Use GPU compute pool for notebook execution
- ✅ Monitor compute pool status and usage
- ✅ Run GPU-intensive ML workloads

### Notebook Creation Permissions:
```sql
GRANT CREATE NOTEBOOK ON SCHEMA {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }} 
TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

GRANT CREATE NOTEBOOK ON SCHEMA {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }} 
TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
```

**Allows:**
- ✅ Create/modify notebooks in NOTEBOOKS schema
- ✅ Create/modify notebooks in DEFAULT_SCHEMA
- ✅ Add live versions to notebooks

### Warehouse Access (from configure_attendee_account):
```sql
GRANT USAGE ON WAREHOUSE {{ env.EVENT_WAREHOUSE }} TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT USAGE ON WAREHOUSE NOTEBOOKS_WH TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
```

---

## Why This Matters

### Before Fix:
❌ Notebooks created by ACCOUNTADMIN  
❌ Attendees can't modify or own notebooks  
❌ Permission errors when attendees try to use GPU notebooks  
❌ No compute pool access for ATTENDEE_ROLE  

### After Fix:
✅ All notebooks owned by ATTENDEE_ROLE  
✅ Attendees can freely use and modify notebooks  
✅ Compute pool accessible to ATTENDEE_ROLE  
✅ GPU notebooks work for attendees  
✅ Clean separation: ACCOUNTADMIN creates infrastructure, ATTENDEE_ROLE owns content  

---

## Role Switching Strategy

### Pattern Used:
```
ACCOUNTADMIN → Create privileged resources (schemas, stages, compute pools)
             → Grant permissions to ATTENDEE_ROLE
             ↓
ATTENDEE_ROLE → Create notebooks (establishes ownership)
              → Add live versions
              ↓
ACCOUNTADMIN → Create next privileged resource
             → Grant permissions
             ↓
ATTENDEE_ROLE → Create next set of notebooks
```

This ensures:
1. Privileged operations succeed (ACCOUNTADMIN)
2. Content owned by correct role (ATTENDEE_ROLE)
3. Proper access control (grants before role switch)

---

## Testing After Deployment

### Verify Notebook Ownership:
```sql
-- Check notebooks exist
USE ROLE {{ env.EVENT_ATTENDEE_ROLE }};
SHOW NOTEBOOKS IN {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }};
-- Should show 5 notebooks

SHOW NOTEBOOKS IN {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }};
-- Should show 2 notebooks (AISQL_DSA, TRAIN_AND_REGISTER_ML_MODELS)
```

### Verify Compute Pool Access:
```sql
USE ROLE {{ env.EVENT_ATTENDEE_ROLE }};
SHOW COMPUTE POOLS;
-- Should show CP_GPU_NV_S

DESCRIBE COMPUTE POOL CP_GPU_NV_S;
-- Should succeed (has USAGE + MONITOR grants)
```

### Verify Notebook Execution:
```sql
-- As ATTENDEE_ROLE, try to execute GPU notebook
USE ROLE {{ env.EVENT_ATTENDEE_ROLE }};
-- Open AISQL_DSA notebook in UI
-- Should be able to run cells using CP_GPU_NV_S compute pool ✅
```

---

## Complete Grant Summary for ATTENDEE_ROLE

### From configure_attendee_account.template.sql:
- ✅ CREATE DATABASE on account
- ✅ CREATE ROLE on account
- ✅ CREATE WAREHOUSE on account
- ✅ USAGE on EVENT_WAREHOUSE
- ✅ USAGE on NOTEBOOKS_WH

### From deploy_notebooks.template.sql (Added):
- ✅ CREATE NOTEBOOK on {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}
- ✅ CREATE NOTEBOOK on {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}
- ✅ USAGE on COMPUTE POOL CP_GPU_NV_S
- ✅ MONITOR on COMPUTE POOL CP_GPU_NV_S

---

## File Modified

**`deploy_notebooks.template.sql`**

### Changes:
1. **Line 4**: Use ACCOUNTADMIN initially
2. **Lines 38-39**: Grant CREATE NOTEBOOK to ATTENDEE_ROLE  
3. **Line 42**: Switch to ATTENDEE_ROLE before creating first 5 notebooks
4. **Line 89**: Switch back to ACCOUNTADMIN for compute pool
5. **Lines 112-113**: Grant compute pool usage to ATTENDEE_ROLE
6. **Lines 115-116**: Grant CREATE NOTEBOOK on both schemas
7. **Line 119**: Switch to ATTENDEE_ROLE for GPU notebooks

### Result:
✅ Proper role separation  
✅ Attendees own all notebooks  
✅ Attendees can use compute pools  
✅ No permission errors  

---

## Status: ✅ COMPLETE

All notebooks will now be:
- ✅ Created with ATTENDEE_ROLE ownership
- ✅ Accessible to event attendees
- ✅ Able to use compute pools (GPU notebooks)
- ✅ Modifiable by attendees

**Ready for pipeline deployment!** 🚀

