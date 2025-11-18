-- ========================================
-- Deploy SnowMail Native App
-- ========================================
-- This script deploys SnowMail as a Snowflake Native Application
-- providing a Gmail-style email viewer for FSI Cortex Assistant demos

-- Use ACCOUNTADMIN for creating application packages and granting permissions
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE {{ env.EVENT_WAREHOUSE }};

-- ========================================
-- Step 1: Create Application Package Infrastructure
-- ========================================

CREATE DATABASE IF NOT EXISTS {{ env.EVENT_DATABASE }}_SNOWMAIL_PKG;
CREATE SCHEMA IF NOT EXISTS {{ env.EVENT_DATABASE }}_SNOWMAIL_PKG.APP_CODE;

CREATE STAGE IF NOT EXISTS {{ env.EVENT_DATABASE }}_SNOWMAIL_PKG.APP_CODE.SNOWMAIL_STAGE
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage for SnowMail Native App artifacts';

-- ========================================
-- Step 2: Upload Application Files
-- ========================================

-- Note: PUT commands execute relative to where the SQL script runs from (project root)
-- Upload manifest.yml
PUT file://dataops/event/native_app_snowmail/manifest.yml 
    @{{ env.EVENT_DATABASE }}_SNOWMAIL_PKG.APP_CODE.SNOWMAIL_STAGE/ 
    OVERWRITE=TRUE 
    AUTO_COMPRESS=FALSE
    SOURCE_COMPRESSION=NONE;

-- Upload setup.sql
PUT file://dataops/event/native_app_snowmail/setup.sql 
    @{{ env.EVENT_DATABASE }}_SNOWMAIL_PKG.APP_CODE.SNOWMAIL_STAGE/ 
    OVERWRITE=TRUE 
    AUTO_COMPRESS=FALSE
    SOURCE_COMPRESSION=NONE;

-- Upload Streamlit email_viewer.py
PUT file://dataops/event/native_app_snowmail/streamlit/email_viewer.py 
    @{{ env.EVENT_DATABASE }}_SNOWMAIL_PKG.APP_CODE.SNOWMAIL_STAGE/streamlit/ 
    OVERWRITE=TRUE 
    AUTO_COMPRESS=FALSE
    SOURCE_COMPRESSION=NONE;

-- Verify files uploaded
LIST @{{ env.EVENT_DATABASE }}_SNOWMAIL_PKG.APP_CODE.SNOWMAIL_STAGE;

-- ========================================
-- Step 3: Clean Deployment - Drop and Recreate Package
-- ========================================

-- Drop the application first
DROP APPLICATION IF EXISTS SNOWMAIL;

-- Drop and recreate the application package completely
-- This is the cleanest approach to avoid version accumulation issues
DROP APPLICATION PACKAGE IF EXISTS SNOWMAIL_PKG;

CREATE APPLICATION PACKAGE SNOWMAIL_PKG
    COMMENT = 'SnowMail - Gmail-style email viewer for FSI Cortex Assistant'
    ENABLE_RELEASE_CHANNELS = FALSE;

-- Add the version (simpler syntax when release channels are disabled)
ALTER APPLICATION PACKAGE SNOWMAIL_PKG 
    ADD VERSION V1_0
    USING '@{{ env.EVENT_DATABASE }}_SNOWMAIL_PKG.APP_CODE.SNOWMAIL_STAGE'
    LABEL = 'SnowMail v1.0 - Pipeline {{ env.CI_PIPELINE_ID | default("Manual") }} - Deployed {{ env.CI_COMMIT_TIMESTAMP | default("Manual") }}';

-- Set as the default version
ALTER APPLICATION PACKAGE SNOWMAIL_PKG
    SET DEFAULT RELEASE DIRECTIVE
    VERSION = V1_0
    PATCH = 0;

-- ========================================
-- Step 4: Create Application Instance
-- ========================================

-- Create the application from the package
CREATE APPLICATION SNOWMAIL
    FROM APPLICATION PACKAGE SNOWMAIL_PKG
    COMMENT = 'SnowMail Email Viewer for FSI Cortex Assistant Demos';

-- ========================================
-- Step 5: Grant Permissions to SnowMail Application
-- ========================================

-- Grant database and schema access
GRANT USAGE ON DATABASE {{ env.EVENT_DATABASE }} TO APPLICATION SNOWMAIL;
GRANT USAGE ON SCHEMA {{ env.EVENT_DATABASE }}.DEFAULT_SCHEMA TO APPLICATION SNOWMAIL;

-- Grant table permissions on EMAIL_PREVIEWS
-- SELECT: Read emails for display in UI
-- DELETE: Allow users to delete emails from inbox
-- Note: INSERT is handled by SEND_EMAIL_NOTIFICATION procedure, not by the app
GRANT SELECT, DELETE ON TABLE {{ env.EVENT_DATABASE }}.DEFAULT_SCHEMA.EMAIL_PREVIEWS TO APPLICATION SNOWMAIL;

-- Grant warehouse access for Streamlit execution
GRANT USAGE ON WAREHOUSE {{ env.EVENT_WAREHOUSE }} TO APPLICATION SNOWMAIL;

-- ========================================
-- Deployment Complete
-- ========================================

SELECT 'SnowMail Native App deployed successfully!' as STATUS,
       'Application: SNOWMAIL' as APP_NAME,
       'Package: SNOWMAIL_PKG' as PACKAGE_NAME,
       'Version: V1_0' as VERSION,
       'Pipeline: {{ env.CI_PIPELINE_ID | default("Manual") }}' as PIPELINE_ID,
       'Access URL: https://app.snowflake.com/<org>/<account>/#/apps/application/SNOWMAIL/schema/APP_SCHEMA/streamlit/EMAIL_VIEWER' as URL;
