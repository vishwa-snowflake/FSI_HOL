ALTER SESSION SET QUERY_TAG = '''{"origin":"sf_sit-is", "name":"Build an AI Assistant for FSI using AISQL and Snowflake Intelligence", "version":{"major":1, "minor":0},"attributes":{"is_quickstart":0, "source":"sql"}}''';

-- Use ACCOUNTADMIN for creating compute pools and notebooks
use role ACCOUNTADMIN;

create or replace schema ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA;
CREATE STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.NOTEBOOK1 DIRECTORY = (ENABLE = TRUE) ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');
CREATE STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.NOTEBOOK2 DIRECTORY = (ENABLE = TRUE) ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');
CREATE STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.NOTEBOOK3 DIRECTORY = (ENABLE = TRUE) ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');
CREATE STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.NOTEBOOK4 DIRECTORY = (ENABLE = TRUE) ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');
CREATE STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.NOTEBOOK5 DIRECTORY = (ENABLE = TRUE) ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');

------put notebook files in stages


-- NOTE: Update the path below to match where you downloaded the quickstart package
-- Example: PUT file:///Users/yourname/Downloads/quickstart/assets/notebooks/...
PUT file:///../notebooks/1_EXTRACT_DATA_FROM_DOCUMENTS.ipynb @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.NOTEBOOK1 auto_compress = false overwrite = true;
PUT file:///../notebooks/environment.yml @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.NOTEBOOK1 auto_compress = false overwrite = true;


PUT file:///../notebooks/2_ANALYSE_SOUND.ipynb @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.NOTEBOOK2 auto_compress = false overwrite = true;
PUT file:///../notebooks/environment.yml @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.NOTEBOOK2 auto_compress = false overwrite = true;

-- Notebook 3 (ML Model) uses different notebook and environment
PUT file:///../notebooks/3_BUILD_A_QUANTITIVE_MODEL.ipynb @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.NOTEBOOK3 auto_compress = false overwrite = true;
PUT file:///../notebooks/ds_environment.yml @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.NOTEBOOK3 auto_compress = false overwrite = true;

PUT file:///../notebooks/4_CREATE_SEARCH_SERVICE.ipynb @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.NOTEBOOK4 auto_compress = false overwrite = true;
PUT file:///../notebooks/environment.yml @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.NOTEBOOK4 auto_compress = false overwrite = true;

-- Notebook 5 removed (only deploying 4 core notebooks in quickstart)







-- Grant notebook creation privileges to ATTENDEE_ROLE
GRANT CREATE NOTEBOOK ON SCHEMA ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA TO ROLE ATTENDEE_ROLE;

-- Switch to ATTENDEE_ROLE to create notebooks (so they own them)
USE ROLE ATTENDEE_ROLE;

--create notebooks

CREATE OR REPLACE NOTEBOOK ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA."1_EXTRACT_DATA_FROM_DOCUMENTS"
FROM '@ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.NOTEBOOK1'
MAIN_FILE = '1_EXTRACT_DATA_FROM_DOCUMENTS.ipynb'
QUERY_WAREHOUSE = 'NOTEBOOKS_WH'
COMMENT = '''{"origin":"sf_sit-is", "name":"Build an AI Assistant for FSI using AISQL and Snowflake Intelligence", "version":{"major":1, "minor":0},"attributes":{"is_quickstart":0, "source":"notebook"}}''';

ALTER NOTEBOOK ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA."1_EXTRACT_DATA_FROM_DOCUMENTS" ADD LIVE VERSION FROM LAST;


CREATE OR REPLACE NOTEBOOK ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA."2_ANALYSE_SOUND"
FROM '@ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.NOTEBOOK2'
MAIN_FILE = '2_ANALYSE_SOUND.ipynb'
QUERY_WAREHOUSE = 'NOTEBOOKS_WH'
COMMENT = '''{"origin":"sf_sit-is", "name":"Build an AI Assistant for FSI using AISQL and Snowflake Intelligence", "version":{"major":1, "minor":0},"attributes":{"is_quickstart":0, "source":"notebook"}}''';

ALTER NOTEBOOK ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA."2_ANALYSE_SOUND" ADD LIVE VERSION FROM LAST;

CREATE OR REPLACE NOTEBOOK ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA."4_CREATE_SEARCH_SERVICE"
FROM '@ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.NOTEBOOK4'
MAIN_FILE = '4_CREATE_SEARCH_SERVICE.ipynb'
QUERY_WAREHOUSE = 'NOTEBOOKS_WH'
COMMENT = '''{"origin":"sf_sit-is", "name":"Build an AI Assistant for FSI using AISQL and Snowflake Intelligence", "version":{"major":1, "minor":0},"attributes":{"is_quickstart":0, "source":"notebook"}}''';

ALTER NOTEBOOK ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA."4_CREATE_SEARCH_SERVICE" ADD LIVE VERSION FROM LAST;

CREATE OR REPLACE NOTEBOOK ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA."5_CORTEX_ANALYST"
FROM '@ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.NOTEBOOK5'
MAIN_FILE = '5_CORTEX_ANALYST.ipynb'
QUERY_WAREHOUSE = 'NOTEBOOKS_WH'
COMMENT = '''{"origin":"sf_sit-is", "name":"Build an AI Assistant for FSI using AISQL and Snowflake Intelligence", "version":{"major":1, "minor":0},"attributes":{"is_quickstart":0, "source":"notebook"}}''';

ALTER NOTEBOOK ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA."5_CORTEX_ANALYST" ADD LIVE VERSION FROM LAST;

-- Switch back to ACCOUNTADMIN for creating stages and compute pool
USE ROLE ACCOUNTADMIN;

create stage if not exists ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.AISQL_DSA_STAGE;

create stage if not exists ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.TRAIN_AND_REGISTER_ML_MODELS_STAGE;

-- Already uploaded as NOTEBOOK3 above (3_BUILD_A_QUANTITIVE_MODEL.ipynb with ds_environment.yml)

-- Create compute pool with ACCOUNTADMIN
CREATE COMPUTE POOL if not exists CP_GPU_NV_S
  MIN_NODES = 1
  MAX_NODES = 1
  INSTANCE_FAMILY = GPU_NV_S
  INITIALLY_SUSPENDED = TRUE
  AUTO_RESUME = TRUE
  AUTO_SUSPEND_SECS = 300; 

-- Grant compute pool usage to ATTENDEE_ROLE
GRANT USAGE ON COMPUTE POOL CP_GPU_NV_S TO ROLE ATTENDEE_ROLE;
GRANT MONITOR ON COMPUTE POOL CP_GPU_NV_S TO ROLE ATTENDEE_ROLE;

-- Grant notebook creation privileges to ATTENDEE_ROLE
GRANT CREATE NOTEBOOK ON SCHEMA ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA TO ROLE ATTENDEE_ROLE;
GRANT CREATE NOTEBOOK ON SCHEMA ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA TO ROLE ATTENDEE_ROLE;

-- Switch to ATTENDEE_ROLE to create notebooks (so they own them)
USE ROLE ATTENDEE_ROLE;

CREATE OR REPLACE NOTEBOOK ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA."3_BUILD_A_QUANTITIVE_MODEL"
    FROM '@ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.AISQL_DSA_STAGE'
    MAIN_FILE = '3_BUILD_A_QUANTITIVE_MODEL.ipynb'
    QUERY_WAREHOUSE = 'DEFAULT_WH'
    COMPUTE_POOL='CP_GPU_NV_S'
    RUNTIME_NAME='SYSTEM$BASIC_RUNTIME';

ALTER NOTEBOOK ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA."3_BUILD_A_QUANTITIVE_MODEL" ADD LIVE VERSION FROM LAST;





