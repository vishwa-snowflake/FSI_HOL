-- =====================================================
-- FSI Cortex Assistant - Account Configuration
-- =====================================================
-- Run as ACCOUNTADMIN
-- =====================================================

USE ROLE ACCOUNTADMIN;

-- Enable Cortex AI for cross-region access
ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'AWS_US';

-- Disable behavior change bundle (compatibility)

-- Create warehouse
CREATE OR REPLACE WAREHOUSE DEFAULT_WH
WITH
  WAREHOUSE_SIZE = 'MEDIUM'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
COMMENT = 'Default warehouse for FSI Cortex Assistant';

-- Create notebooks warehouse  
CREATE OR REPLACE WAREHOUSE NOTEBOOKS_WH
WITH
  WAREHOUSE_SIZE = 'MEDIUM'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE
COMMENT = 'Warehouse for Snowflake notebooks';

USE WAREHOUSE DEFAULT_WH;

-- Request Cybersyn listing (financial data)
CALL SYSTEM$REQUEST_LISTING_AND_WAIT('GZTYZ1US93D', 60);


-- =====================================================
-- Create Attendee Role
-- =====================================================

USE ROLE SECURITYADMIN;

CREATE ROLE IF NOT EXISTS ATTENDEE_ROLE
COMMENT = 'Role for FSI Cortex Assistant attendees';

-- Grant to ACCOUNTADMIN for visibility
GRANT ROLE ATTENDEE_ROLE TO ROLE ACCOUNTADMIN;

-- Grant privileges
USE ROLE ACCOUNTADMIN;

GRANT CREATE DATABASE ON ACCOUNT TO ROLE ATTENDEE_ROLE;
GRANT CREATE ROLE ON ACCOUNT TO ROLE ATTENDEE_ROLE;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE ATTENDEE_ROLE;
GRANT MANAGE GRANTS ON ACCOUNT TO ROLE ATTENDEE_ROLE;
GRANT CREATE INTEGRATION ON ACCOUNT TO ROLE ATTENDEE_ROLE;
GRANT IMPORT SHARE ON ACCOUNT TO ROLE ATTENDEE_ROLE;
GRANT CREATE STREAMLIT ON ACCOUNT TO ROLE ATTENDEE_ROLE;
GRANT CREATE COMPUTE POOL ON ACCOUNT TO ROLE ATTENDEE_ROLE;

-- Grant warehouse usage
GRANT USAGE ON WAREHOUSE DEFAULT_WH TO ROLE ATTENDEE_ROLE;
GRANT USAGE ON WAREHOUSE NOTEBOOKS_WH TO ROLE ATTENDEE_ROLE;
GRANT OPERATE ON WAREHOUSE DEFAULT_WH TO ROLE ATTENDEE_ROLE;
GRANT OPERATE ON WAREHOUSE NOTEBOOKS_WH TO ROLE ATTENDEE_ROLE;

-- Grant Cortex AI privileges
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE ATTENDEE_ROLE;
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE TO ROLE ATTENDEE_ROLE;

-- =====================================================
-- Create Database and Schemas
-- =====================================================

USE ROLE ATTENDEE_ROLE;

CREATE DATABASE IF NOT EXISTS ACCELERATE_AI_IN_FSI
COMMENT = 'FSI Cortex Assistant - Multi-Modal AI Platform';

USE DATABASE ACCELERATE_AI_IN_FSI;

CREATE SCHEMA IF NOT EXISTS DEFAULT_SCHEMA
COMMENT = 'Main schema for structured data tables';

CREATE SCHEMA IF NOT EXISTS DOCUMENT_AI
COMMENT = 'Schema for Document AI stages and files';

CREATE SCHEMA IF NOT EXISTS CORTEX_ANALYST
COMMENT = 'Schema for Cortex Analyst semantic views';

-- =====================================================
-- Configuration Complete!
-- =====================================================

SHOW DATABASES LIKE 'ACCELERATE_AI_IN_FSI';
SHOW SCHEMAS IN DATABASE ACCELERATE_AI_IN_FSI;
SHOW WAREHOUSES LIKE '%WH';

SELECT 'Account configuration complete!' AS status;

