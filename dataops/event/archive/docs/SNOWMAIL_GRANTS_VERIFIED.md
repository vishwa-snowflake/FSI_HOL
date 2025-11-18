# SnowMail Native App - Grants Verified ✅

## Database References Fixed

### ❌ Before:
- Used `{{ env.HEALTHCARE_DATABASE }}` (wrong for FSI project)
- Would fail as this database doesn't exist in FSI deployment

### ✅ After:
- All references updated to `{{ env.EVENT_DATABASE }}`
- Matches where EMAIL_PREVIEWS table is created
- Consistent with FSI project structure

---

## Complete Grant Structure

### 1. Database & Schema Access
```sql
GRANT USAGE ON DATABASE {{ env.EVENT_DATABASE }} TO APPLICATION SNOWMAIL;
GRANT USAGE ON SCHEMA {{ env.EVENT_DATABASE }}.DEFAULT_SCHEMA TO APPLICATION SNOWMAIL;
```
**Purpose**: Allow app to access database and schema containing EMAIL_PREVIEWS

---

### 2. Table Permissions - EMAIL_PREVIEWS
```sql
GRANT SELECT, DELETE ON TABLE {{ env.EVENT_DATABASE }}.DEFAULT_SCHEMA.EMAIL_PREVIEWS 
TO APPLICATION SNOWMAIL;
```

**Permissions Breakdown:**
- **SELECT**: ✅ Read emails for display in SnowMail UI
- **DELETE**: ✅ Allow users to delete emails from their inbox
- **INSERT**: ❌ Not needed - handled by `SEND_EMAIL_NOTIFICATION` procedure

**Why no INSERT?**
- Emails are created by the `SEND_EMAIL_NOTIFICATION` procedure
- The procedure runs with owner rights and has full access
- The app only needs to read and delete, not create

---

### 3. Warehouse Access
```sql
GRANT USAGE ON WAREHOUSE {{ env.EVENT_WAREHOUSE }} TO APPLICATION SNOWMAIL;
```
**Purpose**: Allow Streamlit app to execute queries and load data

---

## Table Structure Referenced

### EMAIL_PREVIEWS Table
**Created in**: `data_foundation.template.sql` (line 86)
**Location**: `{{ env.EVENT_DATABASE }}.DEFAULT_SCHEMA.EMAIL_PREVIEWS`

**Schema:**
```sql
CREATE TABLE IF NOT EXISTS {{ env.EVENT_DATABASE }}.DEFAULT_SCHEMA.EMAIL_PREVIEWS (
    EMAIL_ID VARCHAR(100) PRIMARY KEY,
    RECIPIENT_EMAIL VARCHAR(500),
    SUBJECT VARCHAR(1000),
    HTML_CONTENT VARCHAR(16777216),
    CREATED_AT TIMESTAMP_NTZ
);
```

**Populated with**: 8 sample financial emails (EMAIL_001 through EMAIL_008)

---

## Sample Emails Available

| Email ID | Subject | Related Companies | Date |
|----------|---------|-------------------|------|
| EMAIL_001 | URGENT: NRNT Crisis Impact on SNOW Position | SNOW, NRNT, ICBG, QRYQ | Nov 20, 2024 |
| EMAIL_002 | Cloud Data Platform Landscape | SNOW, ICBG, QRYQ | Sept 15, 2024 |
| EMAIL_003 | Partnership Play: DFLX, STRM, VLTA, CTLG | DFLX, STRM, VLTA, CTLG | Oct 5, 2024 |
| EMAIL_004 | Q3 Earnings Recap: SNOW Addresses NRNT Threat | SNOW | Sept 19, 2024 |
| EMAIL_005 | The NRNT Saga: From $3.8B to Administration | NRNT, SNOW | Nov 22, 2024 |
| EMAIL_006 | VLTA Quarterly Deep Dive | VLTA | Sept 8, 2024 |
| EMAIL_007 | CTLG: The Governance Trade | CTLG | Oct 12, 2024 |
| EMAIL_008 | Pairs Trade Alert: Long QRYQ / Short ICBG | QRYQ, ICBG | Sept 25, 2024 |

---

## Permission Verification Checklist

✅ **Database USAGE** - App can access database  
✅ **Schema USAGE** - App can access schema  
✅ **Table SELECT** - App can read emails  
✅ **Table DELETE** - App can delete emails (user action)  
✅ **Warehouse USAGE** - App can execute queries  
❌ **Table INSERT** - Not needed (procedure handles this)  
❌ **Table UPDATE** - Not needed (immutable emails)  

---

## Application Flow

### Reading Emails (SnowMail UI):
```
1. User opens SnowMail app
2. App queries: SELECT * FROM EMAIL_PREVIEWS ORDER BY CREATED_AT DESC
   → Uses SELECT grant ✅
3. Displays emails in Gmail-style interface
4. User clicks email to view HTML_CONTENT
   → Uses SELECT grant ✅
```

### Deleting Emails:
```
1. User clicks delete button
2. App executes: DELETE FROM EMAIL_PREVIEWS WHERE EMAIL_ID = ?
   → Uses DELETE grant ✅
3. Email removed from inbox
```

### Sending Emails (Agent):
```
1. Agent calls SEND_EMAIL_NOTIFICATION procedure
2. Procedure executes with OWNER rights (has all permissions)
3. Procedure inserts: INSERT INTO EMAIL_PREVIEWS (...)
   → Uses procedure owner rights, not app grants ✅
4. Returns SnowMail URL for viewing
```

---

## Files Updated

### deploy_snow_mail.template.sql
**Changes:**
- Line 14: `HEALTHCARE_DATABASE` → `EVENT_DATABASE` (database package)
- Line 15: `HEALTHCARE_DATABASE` → `EVENT_DATABASE` (schema package)
- Line 17: `HEALTHCARE_DATABASE` → `EVENT_DATABASE` (stage)
- Line 28: `HEALTHCARE_DATABASE` → `EVENT_DATABASE` (PUT manifest)
- Line 35: `HEALTHCARE_DATABASE` → `EVENT_DATABASE` (PUT setup)
- Line 42: `HEALTHCARE_DATABASE` → `EVENT_DATABASE` (PUT streamlit)
- Line 48: `HEALTHCARE_DATABASE` → `EVENT_DATABASE` (LIST stage)
- Line 68: `HEALTHCARE_DATABASE` → `EVENT_DATABASE` (version stage)
- Line 62: Comment updated to "FSI Cortex Assistant"
- Line 84: Comment updated to "FSI Cortex Assistant Demos"
- Line 91-92: Database/schema grants use `EVENT_DATABASE`
- Line 98: Table grant uses `EVENT_DATABASE`

---

## Deployment Order

For correct deployment:

1. **data_foundation.template.sql** - Creates EMAIL_PREVIEWS table & populates with 8 sample emails
2. **deploy_snow_mail.template.sql** - Deploys SnowMail app & grants permissions
3. **configure_attendee_account.template.sql** - Creates agent with SEND_EMAIL tool

---

## Testing the Grants

### Test 1: View Emails
```sql
-- As the SNOWMAIL application (simulated)
USE ROLE {{ env.EVENT_ATTENDEE_ROLE }};
SELECT COUNT(*) FROM {{ env.EVENT_DATABASE }}.DEFAULT_SCHEMA.EMAIL_PREVIEWS;
-- Should return: 8
```

### Test 2: Delete Email
```sql
-- This will be executed by the app when user deletes
DELETE FROM {{ env.EVENT_DATABASE }}.DEFAULT_SCHEMA.EMAIL_PREVIEWS 
WHERE EMAIL_ID = 'EMAIL_001';
-- Should succeed with DELETE grant
```

### Test 3: Send Email via Agent
```
User: "Email me a summary of SNOW's latest earnings"
Agent: Calls SEND_EMAIL_NOTIFICATION(...)
Result: New email appears in EMAIL_PREVIEWS, SnowMail URL returned
```

---

## Security Notes

### Principle of Least Privilege:
✅ App only has SELECT and DELETE (read and remove)  
✅ App cannot INSERT or UPDATE (prevents unauthorized email creation)  
✅ Only SEND_EMAIL_NOTIFICATION procedure can INSERT (controlled access)  
✅ Procedure runs with OWNER rights (secure, audited)  

### Why This is Secure:
- Users can't inject fake emails into the system
- All emails must come through the official procedure
- Procedure validates inputs and creates audit trail
- App can only display and delete, not create or modify

---

## Status: ✅ COMPLETE

All grants are now correct for the SnowMail Native App:

- ✅ Database references fixed (`EVENT_DATABASE` instead of `HEALTHCARE_DATABASE`)
- ✅ All stage references updated
- ✅ Complete permission set granted (USAGE, SELECT, DELETE)
- ✅ Warehouse access granted for Streamlit
- ✅ Security follows least privilege principle
- ✅ Ready for deployment

**Updated Files:**
- `deploy_snow_mail.template.sql` - All 8 database references corrected + grants verified

**Sample Emails Ready:**
- 8 financial emails covering all core tickers (SNOW, NRNT, ICBG, QRYQ, DFLX, STRM, VLTA, CTLG)

**Deployment Ready:** ✅ Yes

