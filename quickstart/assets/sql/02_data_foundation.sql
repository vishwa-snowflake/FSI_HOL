----agent tools

ALTER SESSION SET QUERY_TAG = '''{"origin":"sf_sit-is", "name":"Build an AI Assistant for FSI using AISQL and Snowflake Intelligence", "version":{"major":1, "minor":0},"attributes":{"is_quickstart":0, "source":"sql"}}''';
-- Use ATTENDEE_ROLE for all object creation
USE ROLE ATTENDEE_ROLE;
USE WAREHOUSE DEFAULT_WH;

-- External access integration SNOWFLAKE_INTELLIGENCE_EXTERNALACCESS_INTEGRATION
-- is created in configure_attendee_account.template.sql

CREATE OR REPLACE FUNCTION ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.WEB_SEARCH("QUERY" VARCHAR)
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('requests','beautifulsoup4')
HANDLER = 'search_web'
EXTERNAL_ACCESS_INTEGRATIONS = (SNOWFLAKE_INTELLIGENCE_EXTERNALACCESS_INTEGRATION)
AS '
import _snowflake
import requests
from bs4 import BeautifulSoup
import urllib.parse
import json

def search_web(query):
    encoded_query = urllib.parse.quote_plus(query)
    search_url = f"https://html.duckduckgo.com/html/?q={encoded_query}"
    
    headers = {
        ''User-Agent'': ''Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36''
    }

    try:
        response = requests.get(search_url, headers=headers, timeout=10)
        response.raise_for_status() 
        
        soup = BeautifulSoup(response.text, ''html.parser'')
        
        search_results_list = []
        
        results_container = soup.find(id=''links'')

        if results_container:
            for result in results_container.find_all(''div'', class_=''result''):
                # Check if the result is an ad and skip it.
                if ''result--ad'' in result.get(''class'', []):
                    continue

                # Find title, link, and snippet.
                title_tag = result.find(''a'', class_=''result__a'')
                link_tag = result.find(''a'', class_=''result__url'')
                snippet_tag = result.find(''a'', class_=''result__snippet'')
                
                if title_tag and link_tag and snippet_tag:
                    title = title_tag.get_text(strip=True)
                    link = link_tag[''href'']
                    snippet = snippet_tag.get_text(strip=True)
                    
                    # Append the result as a dictionary to our list.
                    search_results_list.append({
                        "title": title,
                        "link": link,
                        "snippet": snippet
                    })

                # Break the loop once we have the top 3 results.
                if len(search_results_list) >= 3:
                    break

        if search_results_list:
            # Return the list of dictionaries as a JSON string.
            return json.dumps(search_results_list, indent=2)
        else:
            # Return a JSON string indicating no results found.
            return json.dumps({"status": "No search results found."})

    except requests.exceptions.RequestException as e:
        return json.dumps({"error": f"An error occurred while making the request: {e}"})
    except Exception as e:
        return json.dumps({"error": f"An unexpected error occurred during parsing: {e}"})
';


-- Send Email Notification Procedure (Python)
-- This procedure sends email notifications using SYSTEM$SEND_EMAIL with email integration
-- Uses Python markdown library for proper HTML conversion
-- Table to store email previews for demo purposes


CREATE TABLE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS (
    EMAIL_ID VARCHAR(100) PRIMARY KEY,
    RECIPIENT_EMAIL VARCHAR(500),
    SUBJECT VARCHAR(1000),
    HTML_CONTENT VARCHAR(16777216),
    CREATED_AT TIMESTAMP_NTZ
);

-- =====================================================
-- Load Email Previews Data from CSV
-- =====================================================
-- This loads 324 realistic financial analyst emails
-- into the EMAIL_PREVIEWS table from a pipe-delimited CSV file
-- =====================================================

-- Create a temporary stage for the CSV file
CREATE TEMPORARY STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.email_data_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = '|'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
  );

-- Upload the CSV file to the stage
PUT file:///../data/email_previews_data.csv 
    @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.email_data_stage 
    auto_compress = false 
    overwrite = true;

-- Truncate the EMAIL_PREVIEWS table to avoid duplicates
TRUNCATE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS;

-- Load data from the CSV file
COPY INTO ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS (
    EMAIL_ID,
    RECIPIENT_EMAIL,
    SUBJECT,
    HTML_CONTENT,
    CREATED_AT
)
FROM @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.email_data_stage/email_previews_data.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = '|'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
)
ON_ERROR = 'CONTINUE'
PURGE = TRUE;

-- Verify the load
SELECT 
    COUNT(*) AS TOTAL_EMAILS,
    COUNT(DISTINCT EMAIL_ID) AS UNIQUE_EMAILS,
    COUNT(DISTINCT RECIPIENT_EMAIL) AS UNIQUE_RECIPIENTS,
    MIN(CREATED_AT) AS EARLIEST_EMAIL,
    MAX(CREATED_AT) AS LATEST_EMAIL
FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS;

-- Show sample of loaded emails
SELECT 
    EMAIL_ID,
    RECIPIENT_EMAIL,
    SUBJECT,
    LEFT(HTML_CONTENT, 100) AS CONTENT_PREVIEW,
    CREATED_AT
FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS
ORDER BY CREATED_AT DESC
LIMIT 10;

-- Drop the temporary stage
DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.email_data_stage;

-- Grant permissions on EMAIL_PREVIEWS for SEND_EMAIL_NOTIFICATION procedure
GRANT SELECT, INSERT ON TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS TO ROLE ATTENDEE_ROLE;
GRANT SELECT, INSERT ON TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS TO ROLE PUBLIC;

CREATE OR REPLACE PROCEDURE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SEND_EMAIL_NOTIFICATION(
    EMAIL_SUBJECT VARCHAR,
    EMAIL_CONTENT VARCHAR,
    RECIPIENT_EMAIL VARCHAR DEFAULT 'becky.oconnor@snowflake.com',
    MIME_TYPE VARCHAR DEFAULT 'text/html'
)
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python', 'markdown')
HANDLER = 'send_email'
COMMENT='Sends email notifications using SYSTEM$SEND_EMAIL with snowflake_intelligence_email_int integration. Automatically converts markdown to HTML with Snowflake brand styling using Python markdown library.'
EXECUTE AS OWNER
AS
$$
import snowflake.snowpark as snowpark
import markdown
import re

def send_email(session: snowpark.Session, email_subject: str, email_content: str, 
               recipient_email: str = 'demo@snowflake.com', 
               mime_type: str = 'text/html') -> str:
    
    # Validate required parameters
    if not email_subject or not email_subject.strip():
        return 'ERROR: Email subject cannot be empty'
    
    if not email_content or not email_content.strip():
        return 'ERROR: Email content cannot be empty'
    
    # Use default recipient if none provided
    if not recipient_email or not recipient_email.strip():
        recipient_email = 'becky.oconnor@snowflake.com'
    
    # Generate unique filename for this email
    import time
    import hashlib
    timestamp = str(int(time.time() * 1000))
    email_id = hashlib.md5(f"{recipient_email}{timestamp}".encode()).hexdigest()[:12]
    filename = f"email_{email_id}.html"
    
    # Convert to HTML if MIME_TYPE is text/html
    if mime_type == 'text/html':
        # Remove === and ==== underline markers (used in markdown for headers)
        # Replace them with nothing to avoid literal display
        email_content = email_content.replace('\n==========\n', '\n')
        email_content = email_content.replace('\n====\n', '\n')
        
        # Convert markdown to HTML using markdown library
        # Extensions: nl2br (newline to break), tables, fenced_code
        # Headers will only be created if content uses ## syntax
        html_body = markdown.markdown(
            email_content,
            extensions=['nl2br', 'tables', 'fenced_code']
        )
        
        # Apply Snowflake brand styling to generated HTML
        # Add explicit color to list items and strong tags
        html_body = html_body.replace('<li>', '<li style="color: #000000;">')
        html_body = html_body.replace('<strong>', '<strong style="color: #29B5E8; font-weight: 700;">')
        html_body = html_body.replace('<h2>', '<h2 style="color: #29B5E8; font-weight: 700; margin: 18px 0 8px 0; font-size: 18px; border-bottom: 2px solid #29B5E8; padding-bottom: 5px; line-height: 1.2; font-family: Lato, Arial, sans-serif;">')
        
        # Create email viewer HTML with fake email header
        from datetime import datetime
        current_time = datetime.now().strftime("%B %d, %Y at %I:%M %p")
        
        html_content = f"""<!DOCTYPE html><html><head><meta charset="UTF-8">
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Lato:wght@400;700;900">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>{email_subject}</title>
        <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{ font-family: Lato, Arial, sans-serif; background-color: #f5f7fa; padding: 20px; }}
        
        /* Email Viewer Container */
        .email-viewer {{ max-width: 900px; margin: 0 auto; background-color: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); overflow: hidden; }}
        
        /* Fake Email Header */
        .email-metadata {{ background: #ffffff; border-bottom: 2px solid #e0e0e0; padding: 25px 30px; }}
        .email-from {{ display: flex; align-items: center; margin-bottom: 15px; }}
        .email-avatar {{ width: 48px; height: 48px; border-radius: 50%; background: linear-gradient(135deg, #29B5E8 0%, #11567F 100%); display: flex; align-items: center; justify-content: center; color: white; font-weight: 900; font-size: 20px; margin-right: 15px; }}
        .email-sender {{ flex: 1; }}
        .email-sender-name {{ font-size: 16px; font-weight: 700; color: #000000; margin-bottom: 3px; }}
        .email-sender-address {{ font-size: 14px; color: #666666; }}
        .email-to {{ display: flex; margin-bottom: 12px; font-size: 14px; }}
        .email-to-label {{ font-weight: 700; color: #666666; min-width: 40px; }}
        .email-to-value {{ color: #000000; }}
        .email-subject-line {{ font-size: 20px; font-weight: 700; color: #000000; margin-bottom: 8px; }}
        .email-date {{ font-size: 13px; color: #666666; }}
        
        /* Email Body Container */
        .email-container {{ background-color: white; }}
        .email-header {{ background: #29B5E8; color: white; padding: 30px; text-align: center; }}
        .email-header .icon {{ font-size: 56px; line-height: 56px; display: block; margin-bottom: 12px; }}
        .email-header h1 {{ margin: 0; font-size: 24px; font-weight: 900; font-family: Lato, Arial, sans-serif; color: white; text-transform: uppercase; letter-spacing: 1px; }}
        .email-body {{ padding: 25px 40px; font-size: 15px; font-family: Lato, Arial, sans-serif; color: #000000; }}
        .email-body p {{ font-family: Lato, Arial, sans-serif; margin: 8px 0; }}
        .email-body ul {{ margin: 8px 0; padding-left: 0; list-style-position: inside; }}
        .email-body ol {{ margin: 8px 0; padding-left: 0; list-style-position: inside; }}
        .email-body li {{ margin: 0; padding: 0; line-height: 1.5; font-family: Lato, Arial, sans-serif; color: #000000; }}
        .email-body h2 {{ color: #29B5E8; font-weight: 700; margin: 18px 0 8px 0; font-size: 18px; border-bottom: 2px solid #29B5E8; padding-bottom: 5px; line-height: 1.2; font-family: Lato, Arial, sans-serif; }}
        .email-body strong {{ color: #29B5E8; font-weight: 700; }}
        .email-footer {{ background-color: #f5f7fa; padding: 20px 40px; text-align: center; font-size: 13px; color: #8A999E; border-top: 1px solid #e0e0e0; font-family: Lato, Arial, sans-serif; }}
        
        /* Demo Banner */
        .demo-banner {{ background: #FFF4E6; border-left: 4px solid #FF9F36; padding: 15px 20px; margin: 20px 30px; border-radius: 4px; font-size: 14px; color: #24323D; }}
        .demo-banner strong {{ color: #FF9F36; }}
        </style></head><body>
        <div class="email-viewer">
            <!-- Fake Email Header -->
            <div class="email-metadata">
                <div class="email-from">
                    <div class="email-avatar">SI</div>
                    <div class="email-sender">
                        <div class="email-sender-name">Snowflake Intelligence Portfolio Analytics</div>
                        <div class="email-sender-address">noreply@snowflake.com</div>
                    </div>
                </div>
                <div class="email-to">
                    <div class="email-to-label">To:</div>
                    <div class="email-to-value">{recipient_email}</div>
                </div>
                <div class="email-subject-line">{email_subject}</div>
                <div class="email-date">{current_time}</div>
            </div>
            
            <!-- Demo Notice -->
            <div class="demo-banner">
                <strong>📧 Demo Mode:</strong> This is a preview of the email that would be sent. In production, recipients would receive this via their email inbox.
            </div>
            
            <!-- Email Body -->
            <div class="email-container">
                <div class="email-header">
                    <div class="icon">🏥</div>
                    <h1>QUANTITIVE STOCK ANALYSIS</h1>
                </div>
                <div class="email-body">{html_body}</div>
                <div class="email-footer">
                    <p>Generated by Snowflake Intelligence Analytics Platform<br><em>Synthetic demonstration data</em></p>
                </div>
            </div>
        </div>
        </body></html>"""
    else:
        # For plain text, wrap in simple viewer
        from datetime import datetime
        current_time = datetime.now().strftime("%B %d, %Y at %I:%M %p")
        
        html_content = f"""<!DOCTYPE html><html><head><meta charset="UTF-8">
        <title>{email_subject}</title>
        <style>
        body {{ font-family: Arial, sans-serif; background-color: #f5f7fa; padding: 20px; }}
        .email-viewer {{ max-width: 800px; margin: 0 auto; background-color: white; border-radius: 8px; padding: 30px; }}
        .email-header {{ border-bottom: 2px solid #e0e0e0; padding-bottom: 15px; margin-bottom: 20px; }}
        .email-to {{ margin: 5px 0; color: #666; }}
        .email-subject {{ font-size: 20px; font-weight: bold; margin: 10px 0; }}
        .email-date {{ color: #666; font-size: 14px; }}
        .email-body {{ white-space: pre-wrap; }}
        </style></head><body>
        <div class="email-viewer">
            <div class="email-header">
                <div class="email-to">To: {recipient_email}</div>
                <div class="email-subject">{email_subject}</div>
                <div class="email-date">{current_time}</div>
            </div>
            <div class="email-body">{email_content}</div>
        </div>
        </body></html>"""
    
    # Save HTML to a table for viewing
    try:
        import time
        import hashlib
        
        # Generate unique ID for this email
        timestamp = str(int(time.time() * 1000))
        email_hash = hashlib.md5(f"{recipient_email}{timestamp}".encode()).hexdigest()[:8]
        email_id = f"email_{timestamp}_{email_hash}"
        
        # Save email to table
        insert_query = """
            INSERT INTO ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS 
            (EMAIL_ID, RECIPIENT_EMAIL, SUBJECT, HTML_CONTENT, CREATED_AT)
            VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP())
        """
        session.sql(insert_query, params=[email_id, recipient_email, email_subject, html_content]).collect()
        
        # Get account information for SnowMail link
        account_info = session.sql("SELECT CURRENT_ORGANIZATION_NAME() as org, CURRENT_ACCOUNT_NAME() as account").collect()[0]
        org_name = account_info['ORG']
        account_name = account_info['ACCOUNT']
        
        # Construct SnowMail Native App URL (new app.snowflake.com format)
        snowmail_url = f"https://app.snowflake.com/{org_name}/{account_name}/#/apps/application/SNOWMAIL/schema/APP_SCHEMA/streamlit/EMAIL_VIEWER"
        
        # Return success message with SnowMail link
        return f"""✅ Email sent successfully to: {recipient_email}

Subject: {email_subject}
Sent: {current_time}
Email ID: {email_id}

📧 VIEW YOUR EMAIL IN SNOWMAIL:

{snowmail_url}

💡 TIP: Right-click the link and select "Open in new tab" (or CMD+Click on Mac / CTRL+Click on Windows) to view your email in SnowMail while keeping this conversation open.

Note: In production deployments, this would be delivered to the recipient's inbox."""
        
    except Exception as e:
        return f'ERROR: Failed to save email preview: {str(e)}'
$$;

-- =====================================================
-- Tables and Views for Semantic Views
-- =====================================================
-- These tables and views are required by the Cortex Analyst semantic views
-- Previously created in notebooks, now part of data foundation

-- Base Tables (no dependencies)
-- =====================================================

CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS (
	PRIMARY_TICKER VARCHAR(10),
	EVENT_TIMESTAMP TIMESTAMP_NTZ(9),
	EVENT_TYPE VARCHAR(50),
	CREATED_AT TIMESTAMP_NTZ(9),
	SENTIMENT_SCORE NUMBER(38,0),
	UNIQUE_ANALYST_COUNT NUMBER(38,0),
	SENTIMENT_REASON VARCHAR(16777216)
);

CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT (
	RELATIVE_PATH VARCHAR(16777216),
	SPEAKER VARCHAR(16777216),
	SPEAKER_NAME VARCHAR(16777216),
	AUDIO_DURATION_SECONDS FLOAT,
	START_TIME FLOAT,
	END_TIME FLOAT,
	SEGMENT_TEXT VARCHAR(16777216),
	SENTIMENT FLOAT
);

CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.TRANSCRIPTS_BY_MINUTE (
	RELATIVE_PATH VARCHAR(16777216),
	SPEAKER VARCHAR(16777216),
	SPEAKER_NAME VARCHAR(16777216),
	MINUTES NUMBER(38,0),
	SENTIMENT FLOAT,
	TEXT VARCHAR(16777216) NOT NULL
);

CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SENTIMENT_ANALYSIS (
	RELATIVE_PATH VARCHAR(16777216),
	SENTIMENT VARCHAR(8),
	OVERALL NUMBER(18,0),
	COST NUMBER(18,0),
	INNOVATION NUMBER(18,0),
	PRODUCTIVITY NUMBER(18,0),
	COMPETITIVENESS NUMBER(18,0),
	CONSUMPTION NUMBER(18,0)
);

CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DOCUMENT_AI.INFOGRAPHIC_METRICS_EXTRACTED (
	RELATIVE_PATH VARCHAR(16777216),
	COMPANY_TICKER VARCHAR(16777216),
	EXTRACTED_DATA OBJECT,
	BRANDING VARCHAR(16777216)
);

CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DOCUMENT_AI.ANALYST_REPORTS_ALL_DATA (
	RELATIVE_PATH VARCHAR(16777216),
	FILE_URL VARCHAR(16777216),
	RATING VARCHAR(16777216),
	DATE_REPORT VARCHAR(16777216),
	CLOSE_PRICE FLOAT,
	PRICE_TARGET FLOAT,
	GROWTH NUMBER(38,0),
	NAME_OF_REPORT_PROVIDER VARCHAR(16777216),
	DOCUMENT_TYPE VARCHAR(15),
	DOCUMENT VARCHAR(16777216),
	SUMMARY VARCHAR(16777216),
	FULL_TEXT VARCHAR(16777216)
);

CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DOCUMENT_AI.FINANCIAL_REPORTS (
	RELATIVE_PATH VARCHAR(16777216),
	EXTRACTED_DATA OBJECT
);

CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.unique_transcripts (
	primary_ticker VARCHAR(16777216),
	event_timestamp TIMESTAMP_NTZ(9),
	event_type VARCHAR(16777216),
	created_at TIMESTAMP_NTZ(9),
	transcript VARIANT
);

-- Views that depend on base tables
-- =====================================================

CREATE OR REPLACE VIEW ACCELERATE_AI_IN_FSI.DOCUMENT_AI.VW_INFOGRAPHIC_METRICS(
	COMPANY_TICKER,
	RELATIVE_PATH,
	TEXT,
	COMPANY_NAME,
	TICKER,
	REPORT_PERIOD,
	TOTAL_REVENUE,
	YOY_GROWTH,
	PRODUCT_REVENUE,
	SERVICES_REVENUE,
	TOTAL_CUSTOMERS,
	CUSTOMERS_1M_PLUS,
	NET_REVENUE_RETENTION,
	GROSS_MARGIN,
	OPERATING_MARGIN,
	FREE_CASH_FLOW,
	RPO,
	RPO_GROWTH,
	BRANDING
) AS
SELECT 
    COMPANY_TICKER,
    RELATIVE_PATH,
    EXTRACTED_DATA:response:text::text AS TEXT,
    EXTRACTED_DATA:response:company_name::text AS COMPANY_NAME,
    EXTRACTED_DATA:response:ticker::text AS TICKER,
    EXTRACTED_DATA:response:report_period::text AS REPORT_PERIOD,
    EXTRACTED_DATA:response:total_revenue::text AS TOTAL_REVENUE,
    EXTRACTED_DATA:response:yoy_growth::text AS YOY_GROWTH,
    EXTRACTED_DATA:response:product_revenue::text AS PRODUCT_REVENUE,
    EXTRACTED_DATA:response:services_revenue::text AS SERVICES_REVENUE,
    EXTRACTED_DATA:response:total_customers::text AS TOTAL_CUSTOMERS,
    EXTRACTED_DATA:response:customers_1m_plus::text AS CUSTOMERS_1M_PLUS,
    EXTRACTED_DATA:response:nrr::text AS NET_REVENUE_RETENTION,
    EXTRACTED_DATA:response:gross_margin::text AS GROSS_MARGIN,
    EXTRACTED_DATA:response:operating_margin::text AS OPERATING_MARGIN,
    EXTRACTED_DATA:response:free_cash_flow::text AS FREE_CASH_FLOW,
    EXTRACTED_DATA:response:rpo::text AS RPO,
    EXTRACTED_DATA:response:rpo_growth::text AS RPO_GROWTH,
    BRANDING
FROM ACCELERATE_AI_IN_FSI.DOCUMENT_AI.INFOGRAPHIC_METRICS_EXTRACTED;

CREATE OR REPLACE VIEW ACCELERATE_AI_IN_FSI.DOCUMENT_AI.VW_FINANCIAL_SUMMARY(
	COMPANY,
	TICKER,
	PERIOD,
	TOTAL_REVENUE_Q2_2025,
	TOTAL_REVENUE_Q2_2024,
	TOTAL_CUSTOMERS,
	NRR,
	YOY_GROWTH,
	GROSS_MARGIN,
	OPERATING_MARGIN,
	FREE_CASH_FLOW,
	RELATIVE_PATH
) AS
SELECT 
    EXTRACTED_DATA:response:company_name::text AS COMPANY,
    EXTRACTED_DATA:response:ticker::text AS TICKER,
    EXTRACTED_DATA:response:report_period::text AS PERIOD,
    EXTRACTED_DATA:response:income_statement:q2_fy2025[2]::text AS TOTAL_REVENUE_Q2_2025,
    EXTRACTED_DATA:response:income_statement:q2_fy2024[2]::text AS TOTAL_REVENUE_Q2_2024,
    EXTRACTED_DATA:response:customer_metrics:q2_fy2025[0]::text AS TOTAL_CUSTOMERS,
    EXTRACTED_DATA:response:customer_metrics:q2_fy2025[4]::text AS NRR,
    EXTRACTED_DATA:response:kpi_metrics:value[0]::text AS YOY_GROWTH,
    EXTRACTED_DATA:response:kpi_metrics:value[1]::text AS GROSS_MARGIN,
    EXTRACTED_DATA:response:kpi_metrics:value[2]::text AS OPERATING_MARGIN,
    EXTRACTED_DATA:response:kpi_metrics:value[3]::text AS FREE_CASH_FLOW,
    RELATIVE_PATH
FROM ACCELERATE_AI_IN_FSI.DOCUMENT_AI.FINANCIAL_REPORTS
ORDER BY COMPANY;

CREATE OR REPLACE VIEW ACCELERATE_AI_IN_FSI.DOCUMENT_AI.VW_INCOME_STATEMENT(
	COMPANY,
	TICKER,
	PERIOD,
	LINE_ITEM,
	Q2_FY2025,
	Q2_FY2024,
	ROW_NUM,
	RELATIVE_PATH
) AS
WITH income_data AS (
    SELECT 
        RELATIVE_PATH,
        EXTRACTED_DATA:response:ticker::text AS TICKER,
        EXTRACTED_DATA:response:company_name::text AS COMPANY,
        EXTRACTED_DATA:response:report_period::text AS PERIOD,
        EXTRACTED_DATA:response:income_statement:line_item AS LINE_ITEMS,
        EXTRACTED_DATA:response:income_statement:q2_fy2025 AS Q2_2025,
        EXTRACTED_DATA:response:income_statement:q2_fy2024 AS Q2_2024
    FROM ACCELERATE_AI_IN_FSI.DOCUMENT_AI.FINANCIAL_REPORTS
    WHERE EXTRACTED_DATA:response:income_statement IS NOT NULL
)
SELECT 
    COMPANY,
    TICKER,
    PERIOD,
    idx.VALUE::text AS LINE_ITEM,
    Q2_2025[idx.INDEX]::text AS Q2_FY2025,
    Q2_2024[idx.INDEX]::text AS Q2_FY2024,
    idx.INDEX + 1 AS ROW_NUM,
    RELATIVE_PATH
FROM income_data,
LATERAL FLATTEN(input => LINE_ITEMS) idx
ORDER BY COMPANY, idx.INDEX;

CREATE OR REPLACE VIEW ACCELERATE_AI_IN_FSI.DOCUMENT_AI.VW_KPI_METRICS(
	RELATIVE_PATH,
	COMPANY,
	TICKER,
	PERIOD,
	KPI_NAME,
	KPI_VALUE,
	ROW_NUM
) AS
WITH kpi_data AS (
    SELECT 
        RELATIVE_PATH,
        EXTRACTED_DATA:response:company_name::text AS COMPANY,
        EXTRACTED_DATA:response:ticker::text AS TICKER,
        EXTRACTED_DATA:response:report_period::text AS PERIOD,
        EXTRACTED_DATA:response:kpi_metrics:metric AS METRICS,
        EXTRACTED_DATA:response:kpi_metrics:value AS KPI_VALUES
    FROM ACCELERATE_AI_IN_FSI.DOCUMENT_AI.FINANCIAL_REPORTS
    WHERE EXTRACTED_DATA:response:kpi_metrics IS NOT NULL
)
SELECT 
    RELATIVE_PATH,
    COMPANY,
    TICKER,
    PERIOD,
    idx.VALUE::text AS KPI_NAME,
    KPI_VALUES[idx.INDEX]::text AS KPI_VALUE,
    idx.INDEX + 1 AS ROW_NUM
FROM kpi_data,
LATERAL FLATTEN(input => METRICS) idx
ORDER BY COMPANY, idx.INDEX;

CREATE OR REPLACE VIEW ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH(
	PRIMARY_TICKER,
	SENTIMENT_REASON,
	UNIQUE_ANALYST_COUNT,
	SENTIMENT_SCORE,
	EVENT_TIMESTAMP,
	EVENT_TYPE,
	CREATED_AT,
	FULL_TRANSCRIPT_TEXT,
	TRANSCRIPT_LENGTH
) AS
WITH 
parsed_transcripts AS (
    SELECT
        primary_ticker,
        event_timestamp,
        event_type,
        created_at,
        PARSE_JSON(transcript) AS transcript_json
    FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.unique_transcripts
),
speaker_lookup AS (
    SELECT
        primary_ticker,
        event_timestamp,
        OBJECT_AGG(
            speaker_data.value:speaker::STRING,
            OBJECT_CONSTRUCT(
                'name', speaker_data.value:speaker_data.name::STRING,
                'role', speaker_data.value:speaker_data.role::STRING,
                'company', speaker_data.value:speaker_data.company::STRING
            )
        ) AS speakers
    FROM parsed_transcripts,
    LATERAL FLATTEN(input => transcript_json:speaker_mapping) speaker_data
    GROUP BY primary_ticker, event_timestamp
),
formatted_transcripts AS (
    SELECT
        p.primary_ticker,
        p.event_timestamp,
        p.event_type,
        p.created_at,
        LISTAGG(
            s.speakers[parsed_entry.value:speaker::STRING]:name::STRING ||
            CASE 
                WHEN s.speakers[parsed_entry.value:speaker::STRING]:role::STRING IS NOT NULL
                THEN ' (' || s.speakers[parsed_entry.value:speaker::STRING]:role::STRING || '): '
                ELSE ': '
            END ||
            parsed_entry.value:text::STRING,
            '\n\n'
        ) WITHIN GROUP (ORDER BY parsed_entry.index) AS full_transcript_text
    FROM parsed_transcripts p
    JOIN speaker_lookup s ON p.primary_ticker = s.primary_ticker AND p.event_timestamp = s.event_timestamp
    CROSS JOIN LATERAL FLATTEN(input => p.transcript_json:parsed_transcript) parsed_entry
    GROUP BY p.primary_ticker, p.event_timestamp, p.event_type, p.created_at
)
SELECT
    primary_ticker,
    b.sentiment_reason,
    b.unique_analyst_count,
    b.sentiment_score,
    b.event_timestamp,
    event_type,
    created_at,
    full_transcript_text,
    LENGTH(full_transcript_text) AS transcript_length
FROM formatted_transcripts  
NATURAL JOIN ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ai_transcripts_analysts_sentiments b;

-- =====================================================
-- STOCK_PRICE_TIMESERIES - Load from Parquet (Quickstart)
-- =====================================================
-- For free trial users (no marketplace access), we load
-- SNOW stock data from included parquet file
-- =====================================================

-- Create table structure
CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.STOCK_PRICE_TIMESERIES(
	TICKER VARCHAR,
	ASSET_CLASS VARCHAR,
	PRIMARY_EXCHANGE_CODE VARCHAR,
	PRIMARY_EXCHANGE_NAME VARCHAR,
	VARIABLE VARCHAR,
	VARIABLE_NAME VARCHAR,
	DATE DATE,
	VALUE FLOAT
);

-- Create temporary stage for parquet file
CREATE TEMPORARY STAGE IF NOT EXISTS stock_price_stage;

-- Upload parquet file (adjust path as needed)
-- PUT file:///path/to/stock_price_timeseries_snow.parquet @stock_price_stage;
-- Note: Path will be set by user or deploy script

-- Load from parquet
COPY INTO ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.STOCK_PRICE_TIMESERIES
FROM @stock_price_stage/stock_price_timeseries_snow.parquet
FILE_FORMAT = (TYPE = PARQUET);

-- Verify load
SELECT 
    TICKER,
    COUNT(*) AS data_points,
    MIN(DATE) AS first_date,
    MAX(DATE) AS last_date
FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.STOCK_PRICE_TIMESERIES
GROUP BY TICKER;

-- Clean up
DROP STAGE IF EXISTS stock_price_stage;

-- Create pivoted STOCK_PRICES table for easier Cortex Analyst querying
-- This table transforms VARIABLE column into separate columns for each metric
CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.STOCK_PRICES AS
SELECT 
    TICKER,
    ASSET_CLASS,
    PRIMARY_EXCHANGE_CODE,
    PRIMARY_EXCHANGE_NAME,
    DATE,
    "'all-day_high'" AS ALL_DAY_HIGH,
    "'all-day_low'" AS ALL_DAY_LOW,
    "'nasdaq_volume'" AS NASDAQ_VOLUME,
    "'post-market_close'" AS POST_MARKET_CLOSE,
    "'pre-market_open'" AS PRE_MARKET_OPEN,
    YEAR(DATE)::text AS YEAR,
    MONTHNAME(DATE) AS MONTHNAME,
    MONTH(DATE) AS MONTHNO
FROM (
    SELECT * EXCLUDE VARIABLE_NAME
    FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.STOCK_PRICE_TIMESERIES
)
PIVOT (SUM(value) FOR VARIABLE IN (ANY ORDER BY VARIABLE));

-- Tables/Views that depend on other views
-- =====================================================

CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.INFOGRAPHICS_FOR_SEARCH (
	COMPANY_TICKER VARCHAR(16777216),
	RELATIVE_PATH VARCHAR(16777216),
	TEXT VARCHAR(16777216),
	COMPANY_NAME VARCHAR(16777216),
	TICKER VARCHAR(16777216),
	REPORT_PERIOD VARCHAR(16777216),
	TOTAL_REVENUE VARCHAR(16777216),
	YOY_GROWTH VARCHAR(16777216),
	PRODUCT_REVENUE VARCHAR(16777216),
	SERVICES_REVENUE VARCHAR(16777216),
	TOTAL_CUSTOMERS VARCHAR(16777216),
	CUSTOMERS_1M_PLUS VARCHAR(16777216),
	NET_REVENUE_RETENTION VARCHAR(16777216),
	GROSS_MARGIN VARCHAR(16777216),
	OPERATING_MARGIN VARCHAR(16777216),
	FREE_CASH_FLOW VARCHAR(16777216),
	RPO VARCHAR(16777216),
	RPO_GROWTH VARCHAR(16777216),
	BRANDING VARCHAR(16777216),
	URL VARCHAR(16777216)
);

CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ANALYST_REPORTS (
	RELATIVE_PATH VARCHAR(16777216),
	FILE_URL VARCHAR(16777216),
	RATING VARCHAR(16777216),
	DATE_REPORT VARCHAR(16777216),
	CLOSE_PRICE FLOAT,
	PRICE_TARGET FLOAT,
	GROWTH NUMBER(38,0),
	NAME_OF_REPORT_PROVIDER VARCHAR(16777216),
	DOCUMENT_TYPE VARCHAR(15),
	DOCUMENT VARCHAR(16777216),
	SUMMARY VARCHAR(16777216),
	FULL_TEXT VARCHAR(16777216),
	URL VARCHAR(16777216)
);

-- =====================================================
-- Load Data into Tables from CSV Files
-- =====================================================
-- This section loads all the data needed for the semantic views
-- Data files are in the DATA directory
-- =====================================================

-- 1. Load AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS
-- =====================================================
CREATE TEMPORARY STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ai_transcripts_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
  );

PUT file:///../data/ai_transcripts_analysts_sentiments.csv 
    @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ai_transcripts_stage 
    auto_compress = false 
    overwrite = true;

TRUNCATE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS;

COPY INTO ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS
FROM @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ai_transcripts_stage/ai_transcripts_analysts_sentiments.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
)
ON_ERROR = 'CONTINUE'
PURGE = TRUE;

DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ai_transcripts_stage;

-- 1.5. Load TRANSCRIBED_EARNINGS_CALLS (from AI_TRANSCRIBE)
-- =====================================================
-- This table contains raw AI_TRANSCRIBE output from audio files
-- Pre-loading this allows notebooks to skip AI_TRANSCRIBE execution
CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.TRANSCRIBED_EARNINGS_CALLS (
	RELATIVE_PATH VARCHAR(16777216),
	EXTRACTED_DATA VARIANT
);

CREATE TEMPORARY STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.transcribed_calls_raw_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
  );

PUT file:///../data/transcribed_earnings_calls.csv 
    @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.transcribed_calls_raw_stage 
    auto_compress = false 
    overwrite = true;

TRUNCATE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.TRANSCRIBED_EARNINGS_CALLS;

COPY INTO ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.TRANSCRIBED_EARNINGS_CALLS
FROM @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.transcribed_calls_raw_stage/transcribed_earnings_calls.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
)
ON_ERROR = 'CONTINUE'
PURGE = TRUE;

DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.transcribed_calls_raw_stage;

-- 1.6. Load SPEAKER_MAPPING
-- =====================================================
-- This table contains speaker identification from AI_COMPLETE
-- Pre-loading this allows notebooks to skip speaker identification
CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SPEAKER_MAPPING (
	RELATIVE_PATH VARCHAR(16777216),
	SPEAKER VARCHAR(16777216),
	SPEAKER_NAME VARCHAR(16777216)
);

CREATE TEMPORARY STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.speaker_mapping_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
  );

PUT file:///../data/speaker_mapping.csv 
    @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.speaker_mapping_stage 
    auto_compress = false 
    overwrite = true;

TRUNCATE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SPEAKER_MAPPING;

COPY INTO ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SPEAKER_MAPPING
FROM @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.speaker_mapping_stage/speaker_mapping.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
)
ON_ERROR = 'CONTINUE'
PURGE = TRUE;

DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.speaker_mapping_stage;

-- 1.7. Load AI_TRANSCRIBE_NO_TIME
-- =====================================================
-- This table contains AI_TRANSCRIBE output without timestamps
-- Used for full-text summarization and sentiment analysis
CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.AI_TRANSCRIBE_NO_TIME (
	RELATIVE_PATH VARCHAR(16777216),
	TEXT VARCHAR(16777216),
	DURATION FLOAT
);

CREATE TEMPORARY STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ai_transcribe_no_time_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
  );

PUT file:///../data/ai_transcribe_no_time.csv 
    @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ai_transcribe_no_time_stage 
    auto_compress = false 
    overwrite = true;

TRUNCATE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.AI_TRANSCRIBE_NO_TIME;

COPY INTO ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.AI_TRANSCRIBE_NO_TIME
FROM @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ai_transcribe_no_time_stage/ai_transcribe_no_time.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
)
ON_ERROR = 'CONTINUE'
PURGE = TRUE;

DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ai_transcribe_no_time_stage;

-- 2. Load TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT
-- =====================================================
CREATE TEMPORARY STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.transcribed_calls_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
  );

PUT file:///../data/transcribed_earnings_calls_with_sentiment.csv 
    @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.transcribed_calls_stage 
    auto_compress = false 
    overwrite = true;

TRUNCATE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT;

COPY INTO ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT
FROM @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.transcribed_calls_stage/transcribed_earnings_calls_with_sentiment.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
)
ON_ERROR = 'CONTINUE'
PURGE = TRUE;

DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.transcribed_calls_stage;

-- 3. Load TRANSCRIPTS_BY_MINUTE
-- =====================================================
CREATE TEMPORARY STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.transcripts_minute_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
  );

PUT file:///../data/transcripts_by_minute.csv 
    @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.transcripts_minute_stage 
    auto_compress = false 
    overwrite = true;

TRUNCATE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.TRANSCRIPTS_BY_MINUTE;

COPY INTO ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.TRANSCRIPTS_BY_MINUTE
FROM @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.transcripts_minute_stage/transcripts_by_minute.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
)
ON_ERROR = 'CONTINUE'
PURGE = TRUE;

DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.transcripts_minute_stage;

-- 4. Load SENTIMENT_ANALYSIS
-- =====================================================
CREATE TEMPORARY STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.sentiment_analysis_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
  );

PUT file:///../data/sentiment_analysis.csv 
    @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.sentiment_analysis_stage 
    auto_compress = false 
    overwrite = true;

TRUNCATE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SENTIMENT_ANALYSIS;

COPY INTO ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SENTIMENT_ANALYSIS
FROM @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.sentiment_analysis_stage/sentiment_analysis.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
)
ON_ERROR = 'CONTINUE'
PURGE = TRUE;

DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.sentiment_analysis_stage;

-- 5. Load INFOGRAPHICS_FOR_SEARCH
-- =====================================================
CREATE TEMPORARY STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.infographics_search_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
  );

PUT file:///../data/infographics_for_search.csv 
    @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.infographics_search_stage 
    auto_compress = false 
    overwrite = true;

TRUNCATE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.INFOGRAPHICS_FOR_SEARCH;

COPY INTO ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.INFOGRAPHICS_FOR_SEARCH
FROM @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.infographics_search_stage/infographics_for_search.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
)
ON_ERROR = 'CONTINUE'
PURGE = TRUE;

DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.infographics_search_stage;

-- 6. Load ANALYST_REPORTS
-- =====================================================
CREATE TEMPORARY STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.analyst_reports_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
  );

PUT file:///../data/analyst_reports.csv 
    @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.analyst_reports_stage 
    auto_compress = false 
    overwrite = true;

TRUNCATE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ANALYST_REPORTS;

COPY INTO ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ANALYST_REPORTS
FROM @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.analyst_reports_stage/analyst_reports.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
)
ON_ERROR = 'CONTINUE'
PURGE = TRUE;

DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.analyst_reports_stage;

-- 7. Load INFOGRAPHIC_METRICS_EXTRACTED (DOCUMENT_AI schema)
-- =====================================================
CREATE TEMPORARY STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DOCUMENT_AI.infographic_metrics_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
  );

PUT file:///../data/infographic_metrics_extracted.csv 
    @ACCELERATE_AI_IN_FSI.DOCUMENT_AI.infographic_metrics_stage 
    auto_compress = false 
    overwrite = true;

TRUNCATE TABLE ACCELERATE_AI_IN_FSI.DOCUMENT_AI.INFOGRAPHIC_METRICS_EXTRACTED;

COPY INTO ACCELERATE_AI_IN_FSI.DOCUMENT_AI.INFOGRAPHIC_METRICS_EXTRACTED
FROM @ACCELERATE_AI_IN_FSI.DOCUMENT_AI.infographic_metrics_stage/infographic_metrics_extracted.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
)
ON_ERROR = 'CONTINUE'
PURGE = TRUE;

DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DOCUMENT_AI.infographic_metrics_stage;

-- 8. Load ANALYST_REPORTS_ALL_DATA (DOCUMENT_AI schema)
-- =====================================================
CREATE TEMPORARY STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DOCUMENT_AI.analyst_reports_all_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
  );

PUT file:///../data/analyst_reports_all_data.csv 
    @ACCELERATE_AI_IN_FSI.DOCUMENT_AI.analyst_reports_all_stage 
    auto_compress = false 
    overwrite = true;

TRUNCATE TABLE ACCELERATE_AI_IN_FSI.DOCUMENT_AI.ANALYST_REPORTS_ALL_DATA;

COPY INTO ACCELERATE_AI_IN_FSI.DOCUMENT_AI.ANALYST_REPORTS_ALL_DATA
FROM @ACCELERATE_AI_IN_FSI.DOCUMENT_AI.analyst_reports_all_stage/analyst_reports_all_data.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
)
ON_ERROR = 'CONTINUE'
PURGE = TRUE;

DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DOCUMENT_AI.analyst_reports_all_stage;

-- 8.5. Load PARSED_ANALYST_REPORTS (DOCUMENT_AI schema)
-- =====================================================
-- This table contains AI_PARSE_DOCUMENT output from analyst report PDFs
-- Pre-loading this speeds up notebook demonstrations
CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DOCUMENT_AI.PARSED_ANALYST_REPORTS (
	RELATIVE_PATH VARCHAR(16777216),
	EXTRACTED_DATA VARIANT
);

CREATE TEMPORARY STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DOCUMENT_AI.parsed_analyst_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
  );

PUT file:///../data/parsed_analyst_reports.csv 
    @ACCELERATE_AI_IN_FSI.DOCUMENT_AI.parsed_analyst_stage 
    auto_compress = false 
    overwrite = true;

TRUNCATE TABLE ACCELERATE_AI_IN_FSI.DOCUMENT_AI.PARSED_ANALYST_REPORTS;

COPY INTO ACCELERATE_AI_IN_FSI.DOCUMENT_AI.PARSED_ANALYST_REPORTS
FROM @ACCELERATE_AI_IN_FSI.DOCUMENT_AI.parsed_analyst_stage/parsed_analyst_reports.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
)
ON_ERROR = 'CONTINUE'
PURGE = TRUE;

DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DOCUMENT_AI.parsed_analyst_stage;

-- 8.6. Load AI_EXTRACT_ANALYST_REPORTS_ADVANCED (DOCUMENT_AI schema)
-- =====================================================
-- This table contains AI_COMPLETE output with structured analyst report data
-- Pre-loading this allows notebooks to skip AI_COMPLETE execution
CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DOCUMENT_AI.AI_EXTRACT_ANALYST_REPORTS_ADVANCED (
	RELATIVE_PATH VARCHAR(16777216),
	CONTENT VARCHAR(16777216),
	PAGE_COUNT NUMBER(38,0),
	EXTRACTED_DATA VARIANT
);

CREATE TEMPORARY STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DOCUMENT_AI.ai_extract_advanced_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
  );

PUT file:///../data/ai_extract_analyst_reports_advanced.csv 
    @ACCELERATE_AI_IN_FSI.DOCUMENT_AI.ai_extract_advanced_stage 
    auto_compress = false 
    overwrite = true;

TRUNCATE TABLE ACCELERATE_AI_IN_FSI.DOCUMENT_AI.AI_EXTRACT_ANALYST_REPORTS_ADVANCED;

COPY INTO ACCELERATE_AI_IN_FSI.DOCUMENT_AI.AI_EXTRACT_ANALYST_REPORTS_ADVANCED
FROM @ACCELERATE_AI_IN_FSI.DOCUMENT_AI.ai_extract_advanced_stage/ai_extract_analyst_reports_advanced.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
)
ON_ERROR = 'CONTINUE'
PURGE = TRUE;

DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DOCUMENT_AI.ai_extract_advanced_stage;

-- 8.7. Load REPORT_PROVIDER_SUMMARY (DOCUMENT_AI schema)
-- =====================================================
-- This table contains AI_AGG summaries by research firm
-- Pre-loading this allows notebooks to skip AI_AGG execution
CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DOCUMENT_AI.REPORT_PROVIDER_SUMMARY (
	NAME_OF_REPORT_PROVIDER VARCHAR(16777216),
	SUMMARY VARCHAR(16777216)
);

CREATE TEMPORARY STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DOCUMENT_AI.report_summary_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
  );

PUT file:///../data/report_provider_summary.csv 
    @ACCELERATE_AI_IN_FSI.DOCUMENT_AI.report_summary_stage 
    auto_compress = false 
    overwrite = true;

TRUNCATE TABLE ACCELERATE_AI_IN_FSI.DOCUMENT_AI.REPORT_PROVIDER_SUMMARY;

COPY INTO ACCELERATE_AI_IN_FSI.DOCUMENT_AI.REPORT_PROVIDER_SUMMARY
FROM @ACCELERATE_AI_IN_FSI.DOCUMENT_AI.report_summary_stage/report_provider_summary.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
)
ON_ERROR = 'CONTINUE'
PURGE = TRUE;

DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DOCUMENT_AI.report_summary_stage;

-- 9. Load FINANCIAL_REPORTS (DOCUMENT_AI schema)
-- =====================================================
CREATE TEMPORARY STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DOCUMENT_AI.financial_reports_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
  );

PUT file:///../data/financial_reports.csv 
    @ACCELERATE_AI_IN_FSI.DOCUMENT_AI.financial_reports_stage 
    auto_compress = false 
    overwrite = true;

TRUNCATE TABLE ACCELERATE_AI_IN_FSI.DOCUMENT_AI.FINANCIAL_REPORTS;

COPY INTO ACCELERATE_AI_IN_FSI.DOCUMENT_AI.FINANCIAL_REPORTS
FROM @ACCELERATE_AI_IN_FSI.DOCUMENT_AI.financial_reports_stage/financial_reports.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
)
ON_ERROR = 'CONTINUE'
PURGE = TRUE;

DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DOCUMENT_AI.financial_reports_stage;

-- 10. Load unique_transcripts
-- =====================================================
CREATE TEMPORARY STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.unique_transcripts_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
  );

PUT file:///../data/unique_transcripts.csv 
    @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.unique_transcripts_stage 
    auto_compress = false 
    overwrite = true;

TRUNCATE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.unique_transcripts;

COPY INTO ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.unique_transcripts
FROM @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.unique_transcripts_stage/unique_transcripts.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
)
ON_ERROR = 'CONTINUE'
PURGE = TRUE;

DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.unique_transcripts_stage;

-- =====================================================
-- Verification Queries
-- =====================================================
SELECT 'AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS' AS TABLE_NAME, COUNT(*) AS ROWS_LOADED FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS
UNION ALL
SELECT 'TRANSCRIBED_EARNINGS_CALLS', COUNT(*) FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.TRANSCRIBED_EARNINGS_CALLS
UNION ALL
SELECT 'SPEAKER_MAPPING', COUNT(*) FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SPEAKER_MAPPING
UNION ALL
SELECT 'AI_TRANSCRIBE_NO_TIME', COUNT(*) FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.AI_TRANSCRIBE_NO_TIME
UNION ALL
SELECT 'TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT', COUNT(*) FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT
UNION ALL
SELECT 'TRANSCRIPTS_BY_MINUTE', COUNT(*) FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.TRANSCRIPTS_BY_MINUTE
UNION ALL
SELECT 'SENTIMENT_ANALYSIS', COUNT(*) FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SENTIMENT_ANALYSIS
UNION ALL
SELECT 'INFOGRAPHICS_FOR_SEARCH', COUNT(*) FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.INFOGRAPHICS_FOR_SEARCH
UNION ALL
SELECT 'ANALYST_REPORTS', COUNT(*) FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ANALYST_REPORTS
UNION ALL
SELECT 'INFOGRAPHIC_METRICS_EXTRACTED', COUNT(*) FROM ACCELERATE_AI_IN_FSI.DOCUMENT_AI.INFOGRAPHIC_METRICS_EXTRACTED
UNION ALL
SELECT 'ANALYST_REPORTS_ALL_DATA', COUNT(*) FROM ACCELERATE_AI_IN_FSI.DOCUMENT_AI.ANALYST_REPORTS_ALL_DATA
UNION ALL
SELECT 'FINANCIAL_REPORTS', COUNT(*) FROM ACCELERATE_AI_IN_FSI.DOCUMENT_AI.FINANCIAL_REPORTS
UNION ALL
SELECT 'PARSED_ANALYST_REPORTS', COUNT(*) FROM ACCELERATE_AI_IN_FSI.DOCUMENT_AI.PARSED_ANALYST_REPORTS
UNION ALL
SELECT 'STOCK_PRICES', COUNT(*) FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.STOCK_PRICES
UNION ALL
SELECT 'AI_EXTRACT_ANALYST_REPORTS_ADVANCED', COUNT(*) FROM ACCELERATE_AI_IN_FSI.DOCUMENT_AI.AI_EXTRACT_ANALYST_REPORTS_ADVANCED
UNION ALL
SELECT 'REPORT_PROVIDER_SUMMARY', COUNT(*) FROM ACCELERATE_AI_IN_FSI.DOCUMENT_AI.REPORT_PROVIDER_SUMMARY
UNION ALL
SELECT 'unique_transcripts', COUNT(*) FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.unique_transcripts;

-- =====================================================
-- Additional Tables for Search Services
-- =====================================================
-- These tables support Cortex Search Services created in notebook 4
-- call_embeds: Chunked earnings call transcripts (EMBED column excluded - will be regenerated by search service)
-- EMAIL_PREVIEWS_EXTRACTED: Extracted email data with metadata for search
-- =====================================================

CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.call_embeds (
	RELATIVE_PATH VARCHAR(16777216),
	SUMMARY VARCHAR(16777216),
	TEXT VARCHAR(16777216),
	SENTIMENT VARCHAR(16777216),
	SENTIMENT_SCORE FLOAT
);

CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS_EXTRACTED (
	EMAIL_ID VARCHAR(16777216),
	RECIPIENT_EMAIL VARCHAR(16777216),
	SUBJECT VARCHAR(16777216),
	HTML_CONTENT VARCHAR(16777216),
	CREATED_AT TIMESTAMP_NTZ(9),
	TICKER VARCHAR(16777216),
	RATING VARCHAR(16777216),
	SENTIMENT VARCHAR(16777216)
);

-- =====================================================
-- Load Additional Search Service Data
-- =====================================================

-- 11. Load call_embeds
-- =====================================================
CREATE TEMPORARY STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.call_embeds_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
  );

PUT file:///../data/call_embeds.csv 
    @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.call_embeds_stage 
    auto_compress = false 
    overwrite = true;

TRUNCATE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.call_embeds;

COPY INTO ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.call_embeds
FROM @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.call_embeds_stage/call_embeds.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
)
ON_ERROR = 'CONTINUE'
PURGE = TRUE;

DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.call_embeds_stage;

-- 12. Load EMAIL_PREVIEWS_EXTRACTED
-- =====================================================
CREATE TEMPORARY STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.email_extracted_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
  );

PUT file:///../data/email_previews_extracted.csv 
    @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.email_extracted_stage 
    auto_compress = false 
    overwrite = true;

TRUNCATE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS_EXTRACTED;

COPY INTO ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS_EXTRACTED
FROM @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.email_extracted_stage/email_previews_extracted.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
    TRIM_SPACE = FALSE
)
ON_ERROR = 'CONTINUE'
PURGE = TRUE;

DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.email_extracted_stage;

-- =====================================================
-- Grant Permissions for Search Services
-- =====================================================
-- Search services create internal views that need SELECT access to source tables

-- Email search service table
GRANT SELECT ON TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS_EXTRACTED TO ROLE ATTENDEE_ROLE;
GRANT SELECT ON TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS_EXTRACTED TO ROLE PUBLIC;

-- Analyst reports search service table
GRANT SELECT ON TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ANALYST_REPORTS TO ROLE ATTENDEE_ROLE;
GRANT SELECT ON TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ANALYST_REPORTS TO ROLE PUBLIC;

-- Infographics search service table
GRANT SELECT ON TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.INFOGRAPHICS_FOR_SEARCH TO ROLE ATTENDEE_ROLE;
GRANT SELECT ON TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.INFOGRAPHICS_FOR_SEARCH TO ROLE PUBLIC;



-- Sentiment analysis search service (uses view, grant on underlying tables)
GRANT SELECT ON VIEW ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH TO ROLE ATTENDEE_ROLE;
GRANT SELECT ON VIEW ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH TO ROLE PUBLIC;
GRANT SELECT ON TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.unique_transcripts TO ROLE ATTENDEE_ROLE;
GRANT SELECT ON TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.unique_transcripts TO ROLE PUBLIC;
GRANT SELECT ON TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ai_transcripts_analysts_sentiments TO ROLE ATTENDEE_ROLE;
GRANT SELECT ON TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ai_transcripts_analysts_sentiments TO ROLE PUBLIC;

-- =====================================================
-- Create Derived Tables for Search Services
-- =====================================================
-- These tables are created from the base tables and will have presigned URLs
-- Note: In production, tasks will refresh these URLs every 5 days
-- =====================================================

-- FULL_TRANSCRIPTS: Derived from call_embeds with presigned URLs
-- Note: Presigned URLs expire after 7 days, tasks refresh them every 5 days
CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.FULL_TRANSCRIPTS AS
SELECT 
    RELATIVE_PATH,
    SUMMARY,
    TEXT,
    SENTIMENT,
    SENTIMENT_SCORE,
    'PRESIGNED_URL_PLACEHOLDER' AS URL  -- Will be generated by task or manually updated
FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.call_embeds;

-- Full transcripts search service table
GRANT SELECT ON TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.FULL_TRANSCRIPTS TO ROLE ATTENDEE_ROLE;
GRANT SELECT ON TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.FULL_TRANSCRIPTS TO ROLE PUBLIC;

-- Update ANALYST_REPORTS with URL placeholder
-- (Table already created and loaded above, just adding URL column)
ALTER TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ANALYST_REPORTS 
ADD COLUMN IF NOT EXISTS URL VARCHAR(16777216);

UPDATE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ANALYST_REPORTS 
SET URL = 'PRESIGNED_URL_PLACEHOLDER';

-- Update INFOGRAPHICS_FOR_SEARCH with URL placeholder
-- (Table already created and loaded above, just adding URL column if missing)
ALTER TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.INFOGRAPHICS_FOR_SEARCH 
ADD COLUMN IF NOT EXISTS URL VARCHAR(16777216);

UPDATE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.INFOGRAPHICS_FOR_SEARCH 
SET URL = 'PRESIGNED_URL_PLACEHOLDER';

-- =====================================================
-- Create Cortex Search Services
-- =====================================================
-- These search services enable semantic search across various data types
-- Note: Requires CORTEX_USER role or appropriate privileges
-- =====================================================

-- =====================================================
-- Verify Critical Tables Before Creating Search Services
-- =====================================================
-- These queries will fail if tables are empty, preventing search service errors

SELECT 'Verifying tables for search services...' AS status;

-- Verify EMAIL_PREVIEWS_EXTRACTED has data
SELECT 'EMAIL_PREVIEWS_EXTRACTED verification' AS table_name, COUNT(*) AS row_count 
FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS_EXTRACTED;

-- Verify other search service tables
SELECT 'INFOGRAPHICS_FOR_SEARCH verification' AS table_name, COUNT(*) AS row_count 
FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.INFOGRAPHICS_FOR_SEARCH;

SELECT 'ANALYST_REPORTS verification' AS table_name, COUNT(*) AS row_count 
FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ANALYST_REPORTS;

SELECT 'FULL_TRANSCRIPTS verification' AS table_name, COUNT(*) AS row_count 
FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.FULL_TRANSCRIPTS;

SELECT 'All tables verified for search services' AS status;

-- =====================================================
-- Load Social Media Data (NRNT Collapse Timeline)
-- =====================================================
-- Social media conversations around NRNT rise and fall
-- Features: Consumer complaints, company responses, competitor commentary
-- Timeline: August - December 2024 (before, during, after collapse)
-- =====================================================

CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SOCIAL_MEDIA_NRNT (
    TIMESTAMP TIMESTAMP,
    PLATFORM VARCHAR,
    AUTHOR_HANDLE VARCHAR,
    AUTHOR_TYPE VARCHAR,
    COMPANY_AFFILIATION VARCHAR,
    TEXT VARCHAR,
    SENTIMENT FLOAT,
    LIKES INTEGER,
    RETWEETS INTEGER,
    REPLIES INTEGER,
    HASHTAGS VARCHAR,
    LOCATION VARCHAR,
    COUNTRY VARCHAR,
    LANGUAGE VARCHAR,
    LATITUDE FLOAT,
    LONGITUDE FLOAT,
    IMAGE_FILENAME VARCHAR
);

CREATE TEMPORARY STAGE IF NOT EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.social_media_stage
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
  );

PUT file:///../data/social_media_nrnt_collapse.csv 
    @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.social_media_stage 
    auto_compress = false 
    overwrite = true;

COPY INTO ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SOCIAL_MEDIA_NRNT
FROM @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.social_media_stage/social_media_nrnt_collapse.csv
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    ESCAPE = '\\'
    ESCAPE_UNENCLOSED_FIELD = '\\'
    ENCODING = 'UTF8'
    NULL_IF = ('NULL', 'null', '')
)
ON_ERROR = 'CONTINUE';

DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.social_media_stage;

-- Verify social media data loaded
SELECT 'SOCIAL_MEDIA_NRNT' AS table_name, COUNT(*) AS row_count,
       MIN(TIMESTAMP) AS earliest_post,
       MAX(TIMESTAMP) AS latest_post
FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SOCIAL_MEDIA_NRNT;

-- Grant permissions
GRANT SELECT ON TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SOCIAL_MEDIA_NRNT TO ROLE ATTENDEE_ROLE;
GRANT SELECT ON TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SOCIAL_MEDIA_NRNT TO ROLE PUBLIC;

-- Set database and schema context for search service creation
USE DATABASE ACCELERATE_AI_IN_FSI;
USE SCHEMA DEFAULT_SCHEMA;

-- 1. Search Service: Analyst Sentiment Analysis on Earnings Calls
-- Matches notebook 4 cell 5
CREATE OR REPLACE CORTEX SEARCH SERVICE dow_analysts_sentiment_analysis
ON FULL_TRANSCRIPT_TEXT
ATTRIBUTES primary_ticker, unique_analyst_count, sentiment_score, sentiment_reason
WAREHOUSE = DEFAULT_WH
TARGET_LAG = '1 hour'
AS (
    SELECT
        sentiment_reason,
        primary_ticker,
        unique_analyst_count,
        sentiment_score,
        event_timestamp,
        FULL_TRANSCRIPT_TEXT
    FROM SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH a 
    NATURAL JOIN unique_transcripts b
);

-- 2. Search Service: Full Earnings Calls (Snowflake focused)
-- Matches notebook 4 cell 8
CREATE OR REPLACE CORTEX SEARCH SERVICE snow_full_earnings_calls
ON TEXT
ATTRIBUTES URL, SENTIMENT_SCORE, SENTIMENT, SUMMARY, RELATIVE_PATH
WAREHOUSE = DEFAULT_WH
TARGET_LAG = '1 hour'
AS (
    SELECT * 
    FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.FULL_TRANSCRIPTS
);

-- 3. Search Service: Analyst Reports
-- Matches pipeline account (ANALYST_REPORTS_SEARCH with _SEARCH suffix)
CREATE OR REPLACE CORTEX SEARCH SERVICE ANALYST_REPORTS_SEARCH
ON FULL_TEXT
ATTRIBUTES URL, NAME_OF_REPORT_PROVIDER, DOCUMENT_TYPE, DOCUMENT, SUMMARY, RELATIVE_PATH, RATING, DATE_REPORT
WAREHOUSE = DEFAULT_WH
TARGET_LAG = '1 hour'
AS (
    SELECT * 
    FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ANALYST_REPORTS
);

-- 4. Search Service: Infographics
-- Matches notebook 4 cell 15
CREATE OR REPLACE CORTEX SEARCH SERVICE INFOGRAPHICS_SEARCH
ON BRANDING
ATTRIBUTES URL, COMPANY_TICKER, RELATIVE_PATH, TEXT, COMPANY_NAME, REPORT_PERIOD, TICKER
WAREHOUSE = DEFAULT_WH
TARGET_LAG = '1 hour'
AS (
    SELECT * 
    FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.INFOGRAPHICS_FOR_SEARCH
);

-- 5. Search Service: Emails
-- Matches notebook 4 cell 18
CREATE OR REPLACE CORTEX SEARCH SERVICE EMAILS
ON HTML_CONTENT
ATTRIBUTES TICKER, RATING, SENTIMENT, SUBJECT, CREATED_AT, RECIPIENT_EMAIL
WAREHOUSE = DEFAULT_WH
TARGET_LAG = '1 hour'
AS (
    SELECT * 
    FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS_EXTRACTED
);

-- =====================================================
-- Optional: Create Tasks to Refresh Presigned URLs
-- =====================================================
-- These tasks refresh presigned URLs every 5 days (URLs expire after 7 days)
-- Uncomment if you have stages set up with the document files
-- Note: Requires stages @DOCUMENT_AI.EARNINGS_CALLS, @DOCUMENT_AI.ANALYST_REPORTS, @DOCUMENT_AI.INFOGRAPHICS
-- =====================================================

/*
-- Task to refresh FULL_TRANSCRIPTS URLs
CREATE OR REPLACE TASK ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.refresh_full_transcripts_task
    WAREHOUSE = DEFAULT_WH
    SCHEDULE = '7200 MINUTE'  -- Run every 5 days
    COMMENT = 'Refreshes FULL_TRANSCRIPTS table every 5 days to regenerate presigned URLs which expire after 7 days'
AS
    CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.FULL_TRANSCRIPTS AS
    SELECT * EXCLUDE EMBED, 
           GET_PRESIGNED_URL(@ACCELERATE_AI_IN_FSI.DOCUMENT_AI.EARNINGS_CALLS, RELATIVE_PATH, 604800) AS URL  
    FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.call_embeds;

-- Task to refresh ANALYST_REPORTS URLs
CREATE OR REPLACE TASK ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.refresh_analyst_reports_url_task
    WAREHOUSE = DEFAULT_WH
    SCHEDULE = '7200 MINUTE'  -- Run every 5 days
    COMMENT = 'Refreshes url for analyst reports table every 5 days to regenerate presigned URLs which expire after 7 days'
AS
    CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ANALYST_REPORTS AS
    SELECT *, 
           GET_PRESIGNED_URL(@ACCELERATE_AI_IN_FSI.DOCUMENT_AI.ANALYST_REPORTS, RELATIVE_PATH, 604800) AS URL  
    FROM ACCELERATE_AI_IN_FSI.DOCUMENT_AI.ANALYST_REPORTS_ALL_DATA;

-- Task to refresh INFOGRAPHICS_FOR_SEARCH URLs
CREATE OR REPLACE TASK ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.refresh_infographics
    WAREHOUSE = DEFAULT_WH
    SCHEDULE = '7200 MINUTE'  -- Run every 5 days
    COMMENT = 'Refreshes url for infographics table every 5 days to regenerate presigned URLs which expire after 7 days'
AS
    CREATE OR REPLACE TABLE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.INFOGRAPHICS_FOR_SEARCH AS 
    SELECT *, 
           GET_PRESIGNED_URL(@ACCELERATE_AI_IN_FSI.DOCUMENT_AI.INFOGRAPHICS, RELATIVE_PATH, 604800) AS URL 
    FROM ACCELERATE_AI_IN_FSI.DOCUMENT_AI.VW_INFOGRAPHIC_METRICS;

-- Resume all tasks
ALTER TASK ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.refresh_full_transcripts_task RESUME;
ALTER TASK ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.refresh_analyst_reports_url_task RESUME;
ALTER TASK ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.refresh_infographics RESUME;
*/

-- =====================================================
-- Final Verification Queries for Search Service Tables
-- =====================================================
SELECT 'call_embeds' AS TABLE_NAME, COUNT(*) AS ROWS_LOADED FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.call_embeds
UNION ALL
SELECT 'EMAIL_PREVIEWS_EXTRACTED', COUNT(*) FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAIL_PREVIEWS_EXTRACTED
UNION ALL
SELECT 'FULL_TRANSCRIPTS', COUNT(*) FROM ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.FULL_TRANSCRIPTS;

-- Show all search services created
SHOW CORTEX SEARCH SERVICES;