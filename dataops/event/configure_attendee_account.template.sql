-- Configure Attendee Account
ALTER SESSION SET QUERY_TAG = '''{"origin":"sf_sit-is", "name":"Build an AI Assistant for FSI using AISQL and Snowflake Intelligence", "version":{"major":1, "minor":0},"attributes":{"is_quickstart":0, "source":"sql"}}''';
-- Create the warehouse
USE ROLE ACCOUNTADMIN;

DROP DATABASE IF EXISTS DEFAULT_DATABASE;

ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'ANY_REGION';

SELECT SYSTEM$DISABLE_BEHAVIOR_CHANGE_BUNDLE('2025_06');
ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'AWS_US';


CREATE OR REPLACE WAREHOUSE {{ env.EVENT_WAREHOUSE }}
WITH
  WAREHOUSE_SIZE = 'MEDIUM'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;


CREATE OR REPLACE WAREHOUSE NOTEBOOKS_WH
WITH
  WAREHOUSE_SIZE = 'MEDIUM'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;




use warehouse {{ env.EVENT_WAREHOUSE }};

-----make listings available in chosen region -----

CALL SYSTEM$REQUEST_LISTING_AND_WAIT('GZTYZ1US93D', 60);

----- Disable mandatory MFA -----
USE ROLE ACCOUNTADMIN;

CREATE DATABASE IF NOT EXISTS policy_db;
USE DATABASE policy_db;

CREATE SCHEMA IF NOT EXISTS policies;
USE SCHEMA policies;

CREATE AUTHENTICATION POLICY IF NOT EXISTS event_authentication_policy;

ALTER AUTHENTICATION POLICY event_authentication_policy SET
  MFA_ENROLLMENT=OPTIONAL
  CLIENT_TYPES = ('ALL')
  AUTHENTICATION_METHODS = ('ALL');

EXECUTE IMMEDIATE $$
    BEGIN
        ALTER ACCOUNT SET AUTHENTICATION POLICY event_authentication_policy;
    EXCEPTION
        WHEN STATEMENT_ERROR THEN
            RETURN SQLERRM;
    END;
$$
;
---------------------------------


-- Create the Attendee role if it does not exist
use role SECURITYADMIN;
create role if not exists {{ env.EVENT_ATTENDEE_ROLE }};

-- Ensure account admin can see what {{ env.EVENT_ATTENDEE_ROLE }} can see
grant role {{ env.EVENT_ATTENDEE_ROLE }} to role ACCOUNTADMIN;

-- Grant the necessary priviliges to that role.
use role ACCOUNTADMIN;
grant CREATE DATABASE on account to role {{ env.EVENT_ATTENDEE_ROLE }};
grant CREATE ROLE on account to role {{ env.EVENT_ATTENDEE_ROLE }};
grant CREATE WAREHOUSE on account to role {{ env.EVENT_ATTENDEE_ROLE }};
grant MANAGE GRANTS on account to role {{ env.EVENT_ATTENDEE_ROLE }};
grant CREATE INTEGRATION on account to role {{ env.EVENT_ATTENDEE_ROLE }};
grant CREATE APPLICATION PACKAGE on account to role {{ env.EVENT_ATTENDEE_ROLE }};
grant CREATE APPLICATION on account to role {{ env.EVENT_ATTENDEE_ROLE }};
grant IMPORT SHARE on account to role {{ env.EVENT_ATTENDEE_ROLE }};


-- Create the users
use role USERADMIN;
create user IF NOT EXISTS {{ env.EVENT_USER_NAME }}
    PASSWORD = '{{ env.EVENT_USER_PASSWORD }}'
    LOGIN_NAME = {{ env.EVENT_USER_NAME }}
    FIRST_NAME = '{{ env.EVENT_USER_FIRST_NAME }}'
    LAST_NAME = '{{ env.EVENT_USER_LAST_NAME }}'
    MUST_CHANGE_PASSWORD = false
    TYPE = PERSON;
create user IF NOT EXISTS {{ env.EVENT_ADMIN_NAME }}
    PASSWORD = '{{ env.EVENT_ADMIN_PASSWORD }}'
    LOGIN_NAME = {{ env.EVENT_ADMIN_NAME }}
    FIRST_NAME = 'EVENT'
    LAST_NAME = 'ADMIN'
    MUST_CHANGE_PASSWORD = false
    TYPE = PERSON;


-- Create Hackathon Users----

--------hackathon users-------

create user IF NOT EXISTS {{ env.EVENT_HACKER1_NAME }}
    PASSWORD = '{{ env.EVENT_HACKER1_PASSWORD }}'
    LOGIN_NAME = {{ env.EVENT_HACKER1_NAME }}
    FIRST_NAME = '{{ env.EVENT_HACKER1_FIRST_NAME }}'
    LAST_NAME = '{{ env.EVENT_HACKER1_LAST_NAME }}'
    MUST_CHANGE_PASSWORD = false
    TYPE = PERSON;

create user IF NOT EXISTS {{ env.EVENT_HACKER2_NAME }}
    PASSWORD = '{{ env.EVENT_HACKER2_PASSWORD }}'
    LOGIN_NAME = {{ env.EVENT_HACKER2_NAME }}
    FIRST_NAME = '{{ env.EVENT_HACKER2_FIRST_NAME }}'
    LAST_NAME = '{{ env.EVENT_HACKER2_LAST_NAME }}'
    MUST_CHANGE_PASSWORD = false
    TYPE = PERSON;

create user IF NOT EXISTS {{ env.EVENT_HACKER3_NAME }}
    PASSWORD = '{{ env.EVENT_HACKER3_PASSWORD }}'
    LOGIN_NAME = {{ env.EVENT_HACKER3_NAME }}
    FIRST_NAME = '{{ env.EVENT_HACKER3_FIRST_NAME }}'
    LAST_NAME = '{{ env.EVENT_HACKER3_LAST_NAME }}'
    MUST_CHANGE_PASSWORD = false
    TYPE = PERSON;

create user IF NOT EXISTS {{ env.EVENT_HACKER4_NAME }}
    PASSWORD = '{{ env.EVENT_HACKER4_PASSWORD }}'
    LOGIN_NAME = {{ env.EVENT_HACKER4_NAME }}
    FIRST_NAME = '{{ env.EVENT_HACKER4_FIRST_NAME }}'
    LAST_NAME = '{{ env.EVENT_HACKER4_LAST_NAME }}'
    MUST_CHANGE_PASSWORD = false
    TYPE = PERSON;

create user IF NOT EXISTS {{ env.EVENT_HACKER5_NAME }}
    PASSWORD = '{{ env.EVENT_HACKER5_PASSWORD }}'
    LOGIN_NAME = {{ env.EVENT_HACKER5_NAME }}
    FIRST_NAME = '{{ env.EVENT_HACKER5_FIRST_NAME }}'
    LAST_NAME = '{{ env.EVENT_HACKER5_LAST_NAME }}'
    MUST_CHANGE_PASSWORD = false
    TYPE = PERSON;

create user IF NOT EXISTS {{ env.EVENT_HACKER6_NAME }}
    PASSWORD = '{{ env.EVENT_HACKER6_PASSWORD }}'
    LOGIN_NAME = {{ env.EVENT_HACKER6_NAME }}
    FIRST_NAME = '{{ env.EVENT_HACKER6_FIRST_NAME }}'
    LAST_NAME = '{{ env.EVENT_HACKER6_LAST_NAME }}'
    MUST_CHANGE_PASSWORD = false
    TYPE = PERSON;

create user IF NOT EXISTS {{ env.EVENT_HACKER7_NAME }}
    PASSWORD = '{{ env.EVENT_HACKER7_PASSWORD }}'
    LOGIN_NAME = {{ env.EVENT_HACKER7_NAME }}
    FIRST_NAME = '{{ env.EVENT_HACKER7_FIRST_NAME }}'
    LAST_NAME = '{{ env.EVENT_HACKER7_LAST_NAME }}'
    MUST_CHANGE_PASSWORD = false
    TYPE = PERSON;

create user IF NOT EXISTS {{ env.EVENT_HACKER8_NAME }}
    PASSWORD = '{{ env.EVENT_HACKER8_PASSWORD }}'
    LOGIN_NAME = {{ env.EVENT_HACKER8_NAME }}
    FIRST_NAME = '{{ env.EVENT_HACKER8_FIRST_NAME }}'
    LAST_NAME = '{{ env.EVENT_HACKER8_LAST_NAME }}'
    MUST_CHANGE_PASSWORD = false
    TYPE = PERSON;

create user IF NOT EXISTS {{ env.EVENT_HACKER9_NAME }}
    PASSWORD = '{{ env.EVENT_HACKER9_PASSWORD }}'
    LOGIN_NAME = {{ env.EVENT_HACKER9_NAME }}
    FIRST_NAME = '{{ env.EVENT_HACKER9_FIRST_NAME }}'
    LAST_NAME = '{{ env.EVENT_HACKER9_LAST_NAME }}'
    MUST_CHANGE_PASSWORD = false
    TYPE = PERSON;

create user IF NOT EXISTS {{ env.EVENT_HACKER10_NAME }}
    PASSWORD = '{{ env.EVENT_HACKER10_PASSWORD }}'
    LOGIN_NAME = {{ env.EVENT_HACKER10_NAME }}
    FIRST_NAME = '{{ env.EVENT_HACKER10_FIRST_NAME }}'
    LAST_NAME = '{{ env.EVENT_HACKER10_LAST_NAME }}'
    MUST_CHANGE_PASSWORD = false
    TYPE = PERSON;


-- Ensure the user can use the role and warehouse
use role SECURITYADMIN;

----GRANT ATTENDEE ROLE TO HACKERS
grant role {{ env.EVENT_ATTENDEE_ROLE }} to user {{ env.EVENT_HACKER1_NAME }};
grant role {{ env.EVENT_ATTENDEE_ROLE }} to user {{ env.EVENT_HACKER2_NAME }};
grant role {{ env.EVENT_ATTENDEE_ROLE }} to user {{ env.EVENT_HACKER3_NAME }};
grant role {{ env.EVENT_ATTENDEE_ROLE }} to user {{ env.EVENT_HACKER4_NAME }};
grant role {{ env.EVENT_ATTENDEE_ROLE }} to user {{ env.EVENT_HACKER5_NAME }};
grant role {{ env.EVENT_ATTENDEE_ROLE }} to user {{ env.EVENT_HACKER6_NAME }};
grant role {{ env.EVENT_ATTENDEE_ROLE }} to user {{ env.EVENT_HACKER7_NAME }};
grant role {{ env.EVENT_ATTENDEE_ROLE }} to user {{ env.EVENT_HACKER8_NAME }};
grant role {{ env.EVENT_ATTENDEE_ROLE }} to user {{ env.EVENT_HACKER9_NAME }};
grant role {{ env.EVENT_ATTENDEE_ROLE }} to user {{ env.EVENT_HACKER10_NAME }};


grant role {{ env.EVENT_ATTENDEE_ROLE }} to user {{ env.EVENT_USER_NAME }};
grant role ACCOUNTADMIN to user {{ env.EVENT_USER_NAME }};
grant USAGE on warehouse {{ env.EVENT_WAREHOUSE }} to role {{ env.EVENT_ATTENDEE_ROLE }};
grant USAGE on warehouse NOTEBOOKS_WH to role {{ env.EVENT_ATTENDEE_ROLE }};

-- Ensure ADMIN can use ACCOUNTADMIN role
grant role ACCOUNTADMIN to user {{ env.EVENT_ADMIN_NAME }};
grant role ACCOUNTADMIN to user {{ env.EVENT_USER_NAME }};

-- Alter the users to set default role and warehouse
use role USERADMIN;
alter user {{ env.EVENT_USER_NAME }} set
    DEFAULT_ROLE = {{ env.EVENT_ATTENDEE_ROLE }}
    DEFAULT_WAREHOUSE = {{ env.EVENT_WAREHOUSE }};
alter user {{ env.EVENT_ADMIN_NAME }} set
    DEFAULT_ROLE = ACCOUNTADMIN
    DEFAULT_WAREHOUSE = {{ env.EVENT_WAREHOUSE }};

---apply default role and warehouse to hackers

alter user {{ env.EVENT_HACKER1_NAME }} set
    DEFAULT_ROLE = {{ env.EVENT_ATTENDEE_ROLE }}
    DEFAULT_WAREHOUSE = {{ env.EVENT_WAREHOUSE }};

alter user {{ env.EVENT_HACKER2_NAME }} set
    DEFAULT_ROLE = {{ env.EVENT_ATTENDEE_ROLE }}
    DEFAULT_WAREHOUSE = {{ env.EVENT_WAREHOUSE }};

alter user {{ env.EVENT_HACKER3_NAME }} set
    DEFAULT_ROLE = {{ env.EVENT_ATTENDEE_ROLE }}
    DEFAULT_WAREHOUSE = {{ env.EVENT_WAREHOUSE }};

alter user {{ env.EVENT_HACKER4_NAME }} set
    DEFAULT_ROLE = {{ env.EVENT_ATTENDEE_ROLE }}
    DEFAULT_WAREHOUSE = {{ env.EVENT_WAREHOUSE }};

alter user {{ env.EVENT_HACKER5_NAME }} set
    DEFAULT_ROLE = {{ env.EVENT_ATTENDEE_ROLE }}
    DEFAULT_WAREHOUSE = {{ env.EVENT_WAREHOUSE }};

alter user {{ env.EVENT_HACKER6_NAME }} set
    DEFAULT_ROLE = {{ env.EVENT_ATTENDEE_ROLE }}
    DEFAULT_WAREHOUSE = {{ env.EVENT_WAREHOUSE }};

alter user {{ env.EVENT_HACKER7_NAME }} set
    DEFAULT_ROLE = {{ env.EVENT_ATTENDEE_ROLE }}
    DEFAULT_WAREHOUSE = {{ env.EVENT_WAREHOUSE }};

alter user {{ env.EVENT_HACKER8_NAME }} set
    DEFAULT_ROLE = {{ env.EVENT_ATTENDEE_ROLE }}
    DEFAULT_WAREHOUSE = {{ env.EVENT_WAREHOUSE }};

alter user {{ env.EVENT_HACKER9_NAME }} set
    DEFAULT_ROLE = {{ env.EVENT_ATTENDEE_ROLE }}
    DEFAULT_WAREHOUSE = {{ env.EVENT_WAREHOUSE }};

alter user {{ env.EVENT_HACKER10_NAME }} set
    DEFAULT_ROLE = {{ env.EVENT_ATTENDEE_ROLE }}
    DEFAULT_WAREHOUSE = {{ env.EVENT_WAREHOUSE }};

-- Create the database and schemas using {{ env.EVENT_ATTENDEE_ROLE }}
use role {{ env.EVENT_ATTENDEE_ROLE }};

create OR REPLACE DATABASE {{ env.EVENT_DATABASE }};
create schema IF NOT EXISTS {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }};
create schema IF NOT EXISTS {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }};
create schema IF NOT EXISTS {{ env.EVENT_DATABASE }}.{{ env.CORTEX_ANALYST_SCHEMA }};

CREATE OR REPLACE VIEW {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.STOCK_PRICE_TIMESERIES 

AS SELECT * FROM ORGDATACLOUD$INTERNAL$TRANSCRIPTS_FROM_EARNINGS_CALLS.ACCELERATE_WITH_AI_DOC_AI.STOCK_PRICE_TIMESERIES;


--------snowflake intelligence setup
use role ACCOUNTADMIN;
CREATE DATABASE IF NOT EXISTS snowflake_intelligence;
GRANT USAGE ON DATABASE snowflake_intelligence TO ROLE PUBLIC;
create schema if not exists snowflake_intelligence.agents;
GRANT USAGE ON SCHEMA snowflake_intelligence.agents TO ROLE PUBLIC;

GRANT CREATE AGENT ON SCHEMA snowflake_intelligence.agents TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

-- Create external access integration for web search (used by agent tools)
CREATE OR REPLACE NETWORK RULE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.SNOWFLAKE_INTELLIGENCE_WEBACCESS_RULE
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('0.0.0.0:80', '0.0.0.0:443');

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION SNOWFLAKE_INTELLIGENCE_EXTERNALACCESS_INTEGRATION
  ALLOWED_NETWORK_RULES = ({{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.SNOWFLAKE_INTELLIGENCE_WEBACCESS_RULE)
  ENABLED = true;  

GRANT USAGE ON INTEGRATION SNOWFLAKE_INTELLIGENCE_EXTERNALACCESS_INTEGRATION TO ROLE PUBLIC;

-- Create email notification integration for agent email tool
CREATE OR REPLACE NOTIFICATION INTEGRATION snowflake_intelligence_email_int
  TYPE=EMAIL
  ENABLED=TRUE;

GRANT USAGE ON INTEGRATION snowflake_intelligence_email_int TO ROLE PUBLIC;

-------- mfa bypass setup


-- Alter all PERSON users to MINS_TO_BYPASS_MFA to 1440 every 24hrs
{% raw %}
use role ACCOUNTADMIN;
CREATE OR REPLACE TASK POLICY_DB.POLICIES.MFA_USERS_BYPASS
    SCHEDULE = '23 HOURS'
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
    AS
    EXECUTE IMMEDIATE $$
    DECLARE
        user_cursor RESULTSET;
        user_name STRING;
    BEGIN
        user_cursor := (SELECT NAME FROM SNOWFLAKE.ACCOUNT_USAGE.USERS WHERE DELETED_ON IS NULL AND TYPE = 'PERSON');
        FOR user_record IN user_cursor DO
            user_name := user_record.NAME;
            ALTER USER identifier(:user_name) SET MINS_TO_BYPASS_MFA = 1440;
        END FOR;
    END;
    $$;

EXECUTE TASK POLICY_DB.POLICIES.MFA_USERS_BYPASS;
{% endraw %}
alter task POLICY_DB.POLICIES.MFA_USERS_BYPASS resume;

-- ========================================
-- SELF-SERVICE PROFILE MANAGEMENT SETUP
-- ========================================

-- Grant the EVENT_ATTENDEE_ROLE additional privileges to manage specific users
-- This enables self-service profile management through stored procedures

USE ROLE ACCOUNTADMIN;

-- Create a dedicated database for user profile management
CREATE OR REPLACE DATABASE CHANGE_MY_USER_SETTINGS;
CREATE OR REPLACE SCHEMA CHANGE_MY_USER_SETTINGS.PUBLIC;

-- Grant usage on the database and schema to attendee role
GRANT USAGE ON DATABASE CHANGE_MY_USER_SETTINGS TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT USAGE ON SCHEMA CHANGE_MY_USER_SETTINGS.PUBLIC TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

-- Create a procedure that allows users to update their own profile
-- This procedure runs with ACCOUNTADMIN privileges but includes security checks
USE DATABASE CHANGE_MY_USER_SETTINGS;
USE SCHEMA PUBLIC;

CREATE OR REPLACE PROCEDURE CHANGE_MY_USER_SETTINGS.PUBLIC.UPDATE_MY_PROFILE(
    NEW_FIRST_NAME STRING,
    NEW_LAST_NAME STRING,
    NEW_EMAIL STRING DEFAULT NULL
)
RETURNS STRING
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
BEGIN
    LET current_user STRING := CURRENT_USER();
    LET result_msg STRING := '';
    
    -- Security check: only allow users with the EVENT_ATTENDEE_ROLE to modify their profile
    -- Check both ACCOUNT_USAGE and current session for role grants
    LET user_roles RESULTSET;
    LET has_attendee_role BOOLEAN := FALSE;
    
    -- First check ACCOUNT_USAGE (may have delay for new users)
    user_roles := (SELECT ROLE FROM SNOWFLAKE.ACCOUNT_USAGE.GRANTS_TO_USERS
                   WHERE GRANTEE_NAME = :current_user AND DELETED_ON IS NULL);
    
    FOR role_record IN user_roles DO
        IF (role_record.ROLE = '{{ env.EVENT_ATTENDEE_ROLE }}') THEN
            SET has_attendee_role := TRUE;
        END IF;
    END FOR;
    
    -- If not found in ACCOUNT_USAGE, check current session roles (real-time)
    IF (NOT has_attendee_role) THEN
        LET current_roles RESULTSET;
        current_roles := (SELECT VALUE as role_name FROM TABLE(FLATTEN(PARSE_JSON(CURRENT_AVAILABLE_ROLES()))));
        
        FOR current_role_record IN current_roles DO
            IF (current_role_record.ROLE_NAME = '{{ env.EVENT_ATTENDEE_ROLE }}') THEN
                SET has_attendee_role := TRUE;
            END IF;
        END FOR;
    END IF;
    
    IF (NOT has_attendee_role) THEN
        RETURN 'Error: You are not authorized to use this procedure. You need the {{ env.EVENT_ATTENDEE_ROLE }} role.';
    END IF;
    
    -- Validate inputs
    IF (NEW_FIRST_NAME IS NULL OR TRIM(NEW_FIRST_NAME) = '') THEN
        RETURN 'Error: First name cannot be empty';
    END IF;
    
    IF (NEW_LAST_NAME IS NULL OR TRIM(NEW_LAST_NAME) = '') THEN
        RETURN 'Error: Last name cannot be empty';
    END IF;
    
    -- Update first and last name
    EXECUTE IMMEDIATE 'ALTER USER ' || current_user ||
        ' SET FIRST_NAME = ''' || REPLACE(NEW_FIRST_NAME, '''', '''''') ||
        ''' LAST_NAME = ''' || REPLACE(NEW_LAST_NAME, '''', '''''') || '''';
    
    SET result_msg := 'Profile updated successfully for ' || current_user;
    
    -- Update email if provided
    IF (NEW_EMAIL IS NOT NULL AND TRIM(NEW_EMAIL) != '') THEN
        -- Basic email validation
        IF (NEW_EMAIL LIKE '%@%.%') THEN
            EXECUTE IMMEDIATE 'ALTER USER ' || current_user ||
                ' SET EMAIL = ''' || REPLACE(NEW_EMAIL, '''', '''''') || '''';
            SET result_msg := result_msg || '. Email updated to ' || NEW_EMAIL;
        ELSE
            SET result_msg := result_msg || '. Warning: Invalid email format, email not updated';
        END IF;
    END IF;
    
    RETURN result_msg;
EXCEPTION
    WHEN OTHER THEN
        RETURN 'Error updating profile: ' || SQLERRM;
END;
$$;

-- Grant usage permission to attendee role for profile management procedure
GRANT USAGE ON PROCEDURE CHANGE_MY_USER_SETTINGS.PUBLIC.UPDATE_MY_PROFILE(STRING, STRING, STRING)
TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

-- Create a view for users to see their current profile
CREATE OR REPLACE SECURE VIEW CHANGE_MY_USER_SETTINGS.PUBLIC.MY_PROFILE AS
SELECT
    NAME as USERNAME,
    FIRST_NAME,
    LAST_NAME,
    EMAIL,
    CREATED_ON,
    LAST_SUCCESS_LOGIN
FROM SNOWFLAKE.ACCOUNT_USAGE.USERS
WHERE NAME = CURRENT_USER()
AND DELETED_ON IS NULL;

GRANT SELECT ON VIEW CHANGE_MY_USER_SETTINGS.PUBLIC.MY_PROFILE
TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};


-- Create a stage for Streamlit files
CREATE OR REPLACE STAGE CHANGE_MY_USER_SETTINGS.PUBLIC.STREAMLIT_STAGE;

-- Grant read/write access to the stage
GRANT READ, WRITE ON STAGE CHANGE_MY_USER_SETTINGS.PUBLIC.STREAMLIT_STAGE TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

-- Upload the Streamlit file to the stage
PUT file://dataops/event/streamlit/profile_manager.py @CHANGE_MY_USER_SETTINGS.PUBLIC.STREAMLIT_STAGE AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

-- Create a Streamlit app for profile management
CREATE OR REPLACE STREAMLIT CHANGE_MY_USER_SETTINGS.PUBLIC.PROFILE_MANAGER
ROOT_LOCATION = '@CHANGE_MY_USER_SETTINGS.PUBLIC.STREAMLIT_STAGE'
MAIN_FILE = 'profile_manager.py'
QUERY_WAREHOUSE = {{ env.EVENT_WAREHOUSE }};

-- Grant usage on the Streamlit app to attendee role
GRANT USAGE ON STREAMLIT CHANGE_MY_USER_SETTINGS.PUBLIC.PROFILE_MANAGER TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

-- Success message for profile management setup
SELECT 'Profile management enabled! Authorized users can call UPDATE_MY_PROFILE procedure or use the Streamlit app to update their profile.' as PROFILE_MANAGEMENT_STATUS;