ALTER SESSION SET QUERY_TAG = '''{"origin":"sf_sit-is", "name":"Build an AI Assistant for FSI using AISQL and Snowflake Intelligence", "version":{"major":1, "minor":0},"attributes":{"is_quickstart":0, "source":"sql"}}''';
use role {{ env.EVENT_ATTENDEE_ROLE }};

create schema if not exists {{ env.EVENT_DATABASE }}.{{ env.STREAMLIT_SCHEMA }};

-----create streamlit stage for sophisticated agent
CREATE STAGE IF NOT EXISTS {{ env.EVENT_DATABASE }}.{{ env.STREAMLIT_SCHEMA }}.STREAMLIT2 DIRECTORY = (ENABLE = TRUE) ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');

------put streamlit files in stage
-------put streamlit 2 (sophisticated agent) in stage
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/streamlit/2_cortex_agent_soph/app.py @{{ env.EVENT_DATABASE }}.{{ env.STREAMLIT_SCHEMA }}.STREAMLIT2 auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/streamlit/2_cortex_agent_soph/environment.yml @{{ env.EVENT_DATABASE }}.{{ env.STREAMLIT_SCHEMA }}.STREAMLIT2 auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/streamlit/2_cortex_agent_soph/config.toml @{{ env.EVENT_DATABASE }}.{{ env.STREAMLIT_SCHEMA }}.STREAMLIT2/.streamlit auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/streamlit/2_cortex_agent_soph/styles.css @{{ env.EVENT_DATABASE }}.{{ env.STREAMLIT_SCHEMA }}.STREAMLIT2/ auto_compress = false overwrite = true;



-----GRANT CORTEX PERMISSIONS FOR STREAMLIT
-- Grant CORTEX_USER role for Cortex AI functions and REST API access
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

-- Note: No object grants needed - ATTENDEE_ROLE owns all objects (search services, semantic views, tables)
-- created in data_foundation.template.sql and deploy_cortex_analyst.template.sql
-- Owner automatically has all privileges

-----CREATE STREAMLIT (Sophisticated Agent with Feedback API)

CREATE OR REPLACE STREAMLIT {{ env.EVENT_DATABASE }}.{{ env.STREAMLIT_SCHEMA }}.STOCKONE_AGENT
FROM '@{{ env.EVENT_DATABASE }}.{{ env.STREAMLIT_SCHEMA }}.STREAMLIT2'
MAIN_FILE = 'app.py'
TITLE = 'StockOne - AI Financial Assistant'
QUERY_WAREHOUSE = {{ env.EVENT_WAREHOUSE }}
COMMENT = '{"origin":"sf_sit-is", "name":"Build an AI Assistant for FSI using AISQL and Snowflake Intelligence", "version":{"major":1, "minor":0},"attributes":{"is_quickstart":0, "source":"streamlit"}, "features":["cortex_agents_rest_api","feedback_api","5_search_services","2_semantic_views"]}';

-- Note: Simple agent (1_CORTEX_AGENT_SIMPLE) has been sunset in favor of the sophisticated agent with REST API features
-- Note: Streamlit executes with {{ env.EVENT_ATTENDEE_ROLE }} which has CORTEX_USER role and access to all search services and semantic views
