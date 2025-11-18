-- =====================================================
-- FSI Cortex Assistant - Configuration
-- =====================================================
-- Edit these values for your environment
-- =====================================================

-- Database and schema names
SET EVENT_DATABASE = 'ACCELERATE_AI_IN_FSI';
SET EVENT_SCHEMA = 'DEFAULT_SCHEMA';
SET DOCUMENT_AI_SCHEMA = 'DOCUMENT_AI';
SET CORTEX_ANALYST_SCHEMA = 'CORTEX_ANALYST';

-- Warehouse
SET EVENT_WAREHOUSE = 'DEFAULT_WH';

-- Role (will be created if doesn't exist)
SET EVENT_ROLE = 'ATTENDEE_ROLE';

-- Query tag for tracking
ALTER SESSION SET QUERY_TAG = '''{"origin":"sf_sit-is", "name":"Build an AI Assistant for FSI using AISQL and Snowflake Intelligence", "version":{"major":1, "minor":0},"attributes":{"is_quickstart":1, "source":"sql"}}''';

-- Show configuration
SELECT 
    $EVENT_DATABASE AS database_name,
    $EVENT_SCHEMA AS default_schema,
    $EVENT_WAREHOUSE AS warehouse_name,
    $EVENT_ROLE AS role_name;

-- =====================================================
-- Configuration loaded successfully!
-- =====================================================

