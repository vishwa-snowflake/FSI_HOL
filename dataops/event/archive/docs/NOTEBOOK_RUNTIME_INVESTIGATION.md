# AISQL_DSA Notebook Runtime Investigation

## Issue: Notebook Stuck on "Starting..."

**Notebook**: ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.AISQL_DSA  
**Compute Pool**: CP_GPU_NV_S  
**Instance Family**: GPU_NV_S  

---

## Investigation Findings

### 1. Notebook Configuration ✅
```
Name: AISQL_DSA
Database: ACCELERATE_AI_IN_FSI
Schema: DEFAULT_SCHEMA
Owner: ATTENDEE_ROLE ✅
Query Warehouse: DEFAULT_WH
Code Warehouse: None (uses compute pool)
```

### 2. Compute Pool Status ✅
```
Name: CP_GPU_NV_S
State: ACTIVE ✅
Min Nodes: 1
Max Nodes: 1
Instance Family: GPU_NV_S
Auto Resume: TRUE
Auto Suspend: 300 seconds
Num Services: 0 ⚠️ (NO SERVICES RUNNING)
```

### 3. Services in Compute Pool ⚠️
```
SHOW SERVICES IN COMPUTE POOL CP_GPU_NV_S;
Result: Empty (no services)
```

**This is the problem**: The compute pool is ACTIVE but has no services running.

---

## Root Cause Analysis

### Why "Starting..." Hangs:

When you start a notebook with a GPU compute pool, Snowflake needs to:
1. ✅ Resume compute pool (already active)
2. ⚠️ Start a service in the compute pool (STUCK HERE)
3. Pull container image
4. Initialize Python runtime
5. Start notebook kernel

**The service isn't starting**, which suggests:

### Possible Causes:

#### 1. GPU Capacity Unavailable ⚠️ (Most Likely)
- **Issue**: No GPU instances available in region
- **GPU Type**: NVIDIA GPU_NV_S (expensive, limited availability)
- **Region**: Depends on account configuration
- **Solution**: Wait or switch to different region/instance type

#### 2. Container Image Pull Timeout
- **Issue**: Runtime image taking too long to download
- **Runtime**: SYSTEM$BASIC_RUNTIME
- **Solution**: Wait (can take 10-15 minutes first time)

#### 3. Account Quota/Limits
- **Issue**: Account may have GPU quota restrictions
- **Check**: Contact Snowflake support
- **Solution**: Request quota increase

#### 4. Service Configuration Error
- **Issue**: Notebook service spec may have errors
- **Less likely**: Notebook was created successfully

---

## Recommendations

### Option 1: Wait Longer (Try This First)
GPU notebook startups can take **10-15 minutes** on first launch:
- Container image pull: 5-8 minutes
- GPU instance provisioning: 3-5 minutes
- Runtime initialization: 2-3 minutes

**Action**: Wait 15 minutes total before troubleshooting

### Option 2: Check GPU Availability
```sql
-- Check if GPU instances are available
SHOW COMPUTE POOLS;
-- Look for state and num_services

-- Try to manually start a simple service
-- (This will tell you if GPU capacity exists)
```

### Option 3: Use Regular Warehouse Instead
For testing, you could modify the notebook to use a regular warehouse:

```sql
ALTER NOTEBOOK ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.AISQL_DSA 
SET QUERY_WAREHOUSE = 'DEFAULT_WH'
COMPUTE_POOL = NULL;
```

**Trade-off**: Loses GPU acceleration but will start immediately

### Option 4: Check Account GPU Quota
Contact Snowflake support to verify:
- GPU quota for account
- GPU availability in region
- Any restrictions on GPU_NV_S instance family

### Option 5: Try Different Compute Pool
The SYSTEM_COMPUTE_POOL_GPU exists but is suspended. Try using it:

```sql
ALTER NOTEBOOK ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.AISQL_DSA 
SET COMPUTE_POOL = 'SYSTEM_COMPUTE_POOL_GPU';
```

Then resume that pool:
```sql
ALTER COMPUTE POOL SYSTEM_COMPUTE_POOL_GPU RESUME;
```

---

## Quick Diagnostic Commands

### Check Compute Pool Status:
```sql
SHOW COMPUTE POOLS;
-- Look for: state, num_services, active_nodes
```

### Check Services:
```sql
SHOW SERVICES IN COMPUTE POOL CP_GPU_NV_S;
-- Should show notebook service if started
```

### Check Recent Errors:
```sql
SELECT *
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE QUERY_TEXT ILIKE '%CP_GPU_NV_S%'
ORDER BY START_TIME DESC
LIMIT 10;
```

---

## Immediate Action Items

### 1. Wait Test (Recommended First)
- **Action**: Close notebook and wait 15 minutes
- **Reason**: GPU startup is slow
- **Check**: Try starting again after wait

### 2. Switch to Regular Warehouse (If Urgent)
```sql
USE ROLE ACCOUNTADMIN;
ALTER NOTEBOOK ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.AISQL_DSA 
SET QUERY_WAREHOUSE = 'DEFAULT_WH';
```
Then remove compute pool dependency.

### 3. Contact Support (If Persists)
- **Account**: sfsehol-test_fsi_ai_assistant_upgrades_mlxttt
- **Issue**: GPU compute pool service not starting
- **Notebook**: AISQL_DSA
- **Compute Pool**: CP_GPU_NV_S

---

## Status Summary

✅ **Notebook exists** - Created successfully  
✅ **Compute pool exists** - CP_GPU_NV_S is ACTIVE  
✅ **Permissions correct** - ATTENDEE_ROLE owns notebook  
⚠️ **No services running** - Service not starting in pool  
⚠️ **Stuck on "Starting..."** - Waiting for service to initialize  

---

## Most Likely Explanation

**GPU capacity unavailable in region**. The compute pool is active but can't provision a GPU instance to run the notebook service. This is common with GPU_NV_S instances which are:
- Expensive
- Limited availability
- High demand

**Recommendation**: Either wait (GPU capacity may become available) or switch to regular warehouse for non-GPU workloads.

---

## Test Instance Details

- **Account**: sfsehol-test_fsi_ai_assistant_upgrades_mlxttt
- **Database**: ACCELERATE_AI_IN_FSI
- **Schema**: DEFAULT_SCHEMA
- **Compute Pools**: 
  - CP_GPU_NV_S (ACTIVE, 0 services)
  - SYSTEM_COMPUTE_POOL_GPU (SUSPENDED, 0 services)

