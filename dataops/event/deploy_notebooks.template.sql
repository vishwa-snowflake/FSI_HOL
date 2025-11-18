ALTER SESSION SET QUERY_TAG = '''{"origin":"sf_sit-is", "name":"Build an AI Assistant for FSI using AISQL and Snowflake Intelligence", "version":{"major":1, "minor":0},"attributes":{"is_quickstart":0, "source":"sql"}}''';

-- Use ACCOUNTADMIN for creating compute pools and notebooks
use role ACCOUNTADMIN;

create or replace schema {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }};
CREATE STAGE IF NOT EXISTS {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK1 DIRECTORY = (ENABLE = TRUE) ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');
CREATE STAGE IF NOT EXISTS {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK2 DIRECTORY = (ENABLE = TRUE) ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');
CREATE STAGE IF NOT EXISTS {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK3 DIRECTORY = (ENABLE = TRUE) ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');
CREATE STAGE IF NOT EXISTS {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK4 DIRECTORY = (ENABLE = TRUE) ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');
CREATE STAGE IF NOT EXISTS {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK5 DIRECTORY = (ENABLE = TRUE) ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');

create stage if not exists {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.AISQL_DSA_STAGE;

------put notebook files in stages


PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/notebooks/1_EXTRACT_DATA_FROM_DOCUMENTS.ipynb @{{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK1 auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/notebooks/environment.yml @{{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK1 auto_compress = false overwrite = true;


PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/notebooks/2_ANALYSE_SOUND.ipynb @{{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK2 auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/notebooks/environment.yml @{{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK2 auto_compress = false overwrite = true;

-- Notebook 3: ML Model Training (uses ds/3_BUILD_A_QUANTITIVE_MODEL.ipynb with ds/environment.yml)
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/notebooks/ds/3_BUILD_A_QUANTITIVE_MODEL.ipynb @{{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK3 auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/notebooks/ds/environment.yml @{{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK3 auto_compress = false overwrite = true;

PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/notebooks/4_CREATE_SEARCH_SERVICE.ipynb @{{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK4 auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/notebooks/environment.yml @{{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK4 auto_compress = false overwrite = true;

PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/notebooks/5_CORTEX_ANALYST.ipynb @{{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK5 auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/notebooks/environment.yml @{{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK5 auto_compress = false overwrite = true;






-- Grant notebook creation privileges to ATTENDEE_ROLE
GRANT CREATE NOTEBOOK ON SCHEMA {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }} TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

-- Switch to ATTENDEE_ROLE to create notebooks (so they own them)
USE ROLE {{ env.EVENT_ATTENDEE_ROLE }};

--create notebooks

CREATE OR REPLACE NOTEBOOK {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}."1_EXTRACT_DATA_FROM_DOCUMENTS"
FROM '@{{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK1'
MAIN_FILE = '1_EXTRACT_DATA_FROM_DOCUMENTS.ipynb'
QUERY_WAREHOUSE = 'NOTEBOOKS_WH'
COMMENT = '''{"origin":"sf_sit-is", "name":"Build an AI Assistant for FSI using AISQL and Snowflake Intelligence", "version":{"major":1, "minor":0},"attributes":{"is_quickstart":0, "source":"notebook"}}''';

ALTER NOTEBOOK {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}."1_EXTRACT_DATA_FROM_DOCUMENTS" ADD LIVE VERSION FROM LAST;


CREATE OR REPLACE NOTEBOOK {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}."2_ANALYSE_SOUND"
FROM '@{{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK2'
MAIN_FILE = '2_ANALYSE_SOUND.ipynb'
QUERY_WAREHOUSE = 'NOTEBOOKS_WH'
COMMENT = '''{"origin":"sf_sit-is", "name":"Build an AI Assistant for FSI using AISQL and Snowflake Intelligence", "version":{"major":1, "minor":0},"attributes":{"is_quickstart":0, "source":"notebook"}}''';

ALTER NOTEBOOK {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}."2_ANALYSE_SOUND" ADD LIVE VERSION FROM LAST;

CREATE OR REPLACE NOTEBOOK {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}."4_CREATE_SEARCH_SERVICE"
FROM '@{{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK4'
MAIN_FILE = '4_CREATE_SEARCH_SERVICE.ipynb'
QUERY_WAREHOUSE = 'NOTEBOOKS_WH'
COMMENT = '''{"origin":"sf_sit-is", "name":"Build an AI Assistant for FSI using AISQL and Snowflake Intelligence", "version":{"major":1, "minor":0},"attributes":{"is_quickstart":0, "source":"notebook"}}''';

ALTER NOTEBOOK {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}."4_CREATE_SEARCH_SERVICE" ADD LIVE VERSION FROM LAST;

CREATE OR REPLACE NOTEBOOK {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}."5_CORTEX_ANALYST"
FROM '@{{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}.NOTEBOOK5'
MAIN_FILE = '5_CORTEX_ANALYST.ipynb'
QUERY_WAREHOUSE = 'NOTEBOOKS_WH'
COMMENT = '''{"origin":"sf_sit-is", "name":"Build an AI Assistant for FSI using AISQL and Snowflake Intelligence", "version":{"major":1, "minor":0},"attributes":{"is_quickstart":0, "source":"notebook"}}''';

ALTER NOTEBOOK {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }}."5_CORTEX_ANALYST" ADD LIVE VERSION FROM LAST;

-- Switch back to ACCOUNTADMIN for creating stages and compute pool
USE ROLE ACCOUNTADMIN;

create stage if not exists {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.TRAIN_AND_REGISTER_ML_MODELS_STAGE;

-- Upload ML notebook with CORRECT ds/environment.yml (not basic environment.yml!)
PUT file:///{{ env.CI_PROJECT_DIR}}/dataops/event/notebooks/ds/3_BUILD_A_QUANTITIVE_MODEL.ipynb @{{ env.EVENT_DATABASE }}.{{env.EVENT_SCHEMA}}.AISQL_DSA_STAGE auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR}}/dataops/event/notebooks/ds/environment.yml @{{ env.EVENT_DATABASE }}.{{env.EVENT_SCHEMA}}.AISQL_DSA_STAGE auto_compress = false overwrite = true;

PUT file:///{{ env.CI_PROJECT_DIR}}/dataops/event/notebooks/ds/train_and_register_ml_models.ipynb @{{ env.EVENT_DATABASE }}.{{env.EVENT_SCHEMA}}.TRAIN_AND_REGISTER_ML_MODELS_STAGE auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR}}/dataops/event/notebooks/ds/environment.yml @{{ env.EVENT_DATABASE }}.{{env.EVENT_SCHEMA}}.TRAIN_AND_REGISTER_ML_MODELS_STAGE auto_compress = false overwrite = true;

-- Create compute pool with ACCOUNTADMIN
CREATE COMPUTE POOL if not exists CP_GPU_NV_S
  MIN_NODES = 1
  MAX_NODES = 1
  INSTANCE_FAMILY = GPU_NV_S
  INITIALLY_SUSPENDED = TRUE
  AUTO_RESUME = TRUE
  AUTO_SUSPEND_SECS = 300; 

-- Grant compute pool usage to ATTENDEE_ROLE
GRANT USAGE ON COMPUTE POOL CP_GPU_NV_S TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT MONITOR ON COMPUTE POOL CP_GPU_NV_S TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

-- Grant notebook creation privileges to ATTENDEE_ROLE
GRANT CREATE NOTEBOOK ON SCHEMA {{ env.EVENT_DATABASE }}.{{ env.NOTEBOOKS_SCHEMA }} TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT CREATE NOTEBOOK ON SCHEMA {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }} TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

-- Switch to ATTENDEE_ROLE to create notebooks (so they own them)
USE ROLE {{ env.EVENT_ATTENDEE_ROLE }};

CREATE OR REPLACE NOTEBOOK {{ env.EVENT_DATABASE }}.{{env.EVENT_SCHEMA}}."3_BUILD_A_QUANTITIVE_MODEL"
    FROM '@{{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.AISQL_DSA_STAGE'
    MAIN_FILE = '3_BUILD_A_QUANTITIVE_MODEL.ipynb'
    QUERY_WAREHOUSE = '{{ env.EVENT_WAREHOUSE }}'
    COMPUTE_POOL='CP_GPU_NV_S'
    RUNTIME_NAME='SYSTEM$BASIC_RUNTIME';

ALTER NOTEBOOK {{ env.EVENT_DATABASE }}.{{env.EVENT_SCHEMA}}."3_BUILD_A_QUANTITIVE_MODEL" ADD LIVE VERSION FROM LAST;
