-- Configure Attendee Account

-- Create the warehouse
USE ROLE ACCOUNTADMIN;


-- Grant the necessary priviliges to that role.
use role ACCOUNTADMIN;


GRANT CREATE COMPUTE POOL ON ACCOUNT TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
grant MANAGE GRANTS on account to role {{ env.EVENT_ATTENDEE_ROLE }};
grant CREATE INTEGRATION on account to role {{ env.EVENT_ATTENDEE_ROLE }};
grant CREATE APPLICATION PACKAGE on account to role {{ env.EVENT_ATTENDEE_ROLE }};
grant CREATE APPLICATION on account to role {{ env.EVENT_ATTENDEE_ROLE }};
grant IMPORT SHARE on account to role {{ env.EVENT_ATTENDEE_ROLE }};



use role {{ env.EVENT_ATTENDEE_ROLE }};


USE ROLE ACCOUNTADMIN;




grant create warehouse on account to role {{env.EVENT_ATTENDEE_ROLE}};
grant create database on account to role {{env.EVENT_ATTENDEE_ROLE}};
grant create integration on account to role {{env.EVENT_ATTENDEE_ROLE}};

use role {{env.EVENT_ATTENDEE_ROLE}};

create schema if not exists {{env.EVENT_DATABASE}}.{{env.EVENT_SCHEMA}};
create or replace warehouse LARGE_WH with warehouse_size='large';

-- snowflake_intelligence database and schema already created in configure_attendee_account.template.sql
-- Grant already provided to EVENT_ATTENDEE_ROLE

use database {{env.EVENT_DATABASE}};
use schema {{env.EVENT_SCHEMA}};
use warehouse LARGE_WH;

create or replace stage semantic_models encryption = (type = 'snowflake_sse') directory = ( enable = true );

PUT file:///{{ env.CI_PROJECT_DIR}}/dataops/event/analyst/analyst_sentiments.yaml @{{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.semantic_models auto_compress = false overwrite = true;

alter stage semantic_models refresh;

create or replace table ai_transcripts_analysts_sentiments (
    primary_ticker VARCHAR(16777216),
    event_timestamp TIMESTAMP_NTZ(9),
    event_type VARCHAR(16777216),
    created_at TIMESTAMP_NTZ(9),
    sentiment_score NUMBER(38,0),
    unique_analyst_count NUMBER(38,0),
    sentiment_reason VARCHAR(16777216)
);

-- unique_transcripts table created later with correct structure matching CSV (line 128)

-- Create stages for CSV files
create stage if not exists {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.CSV_DATA_STAGE;

-- Create file format for CSV files
create or replace file format {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.CSV_FORMAT
    type = 'CSV'
    field_delimiter = ','
    record_delimiter = '\n'
    skip_header = 1
    field_optionally_enclosed_by = '"'
    null_if = ('NULL', 'null', '')
    empty_field_as_null = true
    error_on_column_count_mismatch = false;

-- Upload CSV files to stage
PUT file:///{{ env.CI_PROJECT_DIR}}/dataops/event/DATA/fsi_data.csv @{{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.CSV_DATA_STAGE auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR}}/dataops/event/DATA/ai_transcripts_analysts_sentiments.csv @{{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.CSV_DATA_STAGE auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR}}/dataops/event/DATA/unique_transcripts.csv @{{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.CSV_DATA_STAGE auto_compress = false overwrite = true;

-- Create table for FSI data (matching CSV column order)
create or replace table {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.fsi_data (
    ticker VARCHAR(16777216),
    asset_class VARCHAR(16777216),
    primary_exchange_code VARCHAR(16777216),
    primary_exchange_name VARCHAR(16777216),
    variable VARCHAR(16777216),
    variable_name VARCHAR(16777216),
    date NUMBER(38,0),
    price FLOAT,
    _effective_start_timestamp NUMBER(38,0),
    _effective_end_timestamp NUMBER(38,0),
    date_time NUMBER(38,0),
    return FLOAT,
    is_split FLOAT,
    return_lead_1 FLOAT,
    return_lead_2 FLOAT,
    return_lead_3 FLOAT,
    return_lead_4 FLOAT,
    return_lead_5 FLOAT,
    r_1 FLOAT,
    r_5_1 FLOAT,
    r_10_5 FLOAT,
    r_21_10 FLOAT,
    r_63_21 FLOAT,
    y FLOAT,
    realized_tplus2_x5 FLOAT
);

-- Create table for AI transcripts analyst sentiments
create or replace table {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.ai_transcripts_analysts_sentiments (
    primary_ticker VARCHAR(10),
    event_timestamp TIMESTAMP_NTZ(9),
    event_type VARCHAR(50),
    created_at TIMESTAMP_NTZ(9),
    sentiment_score INTEGER,
    unique_analyst_count INTEGER,
    sentiment_reason TEXT
);

-- Create table for unique transcripts (matching reference structure from swt-london-2026-keynote-demo)
create or replace table {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.unique_transcripts (
    primary_ticker VARCHAR(16777216),
    event_timestamp TIMESTAMP_NTZ(9),
    event_type VARCHAR(16777216),
    created_at TIMESTAMP_NTZ(9),
    transcript VARIANT
);

-- Load data from stage to tables
COPY INTO {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.fsi_data
FROM @{{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.CSV_DATA_STAGE/fsi_data.csv
FILE_FORMAT = (FORMAT_NAME = '{{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.CSV_FORMAT')
ON_ERROR = 'CONTINUE';

COPY INTO {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.ai_transcripts_analysts_sentiments
FROM @{{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.CSV_DATA_STAGE/ai_transcripts_analysts_sentiments.csv
FILE_FORMAT = (FORMAT_NAME = '{{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.CSV_FORMAT')
ON_ERROR = 'CONTINUE';

COPY INTO {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.unique_transcripts
FROM @{{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.CSV_DATA_STAGE/unique_transcripts.csv
FILE_FORMAT = (FORMAT_NAME = '{{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.CSV_FORMAT')
ON_ERROR = 'CONTINUE';




create or replace procedure get_top_bottom_stock_predictions(
    model_name string default 'STOCK_RETURN_PREDICTOR_GBM',
    top_n integer default 5
)
returns string
language python
runtime_version = '3.12'
packages = ('snowflake-snowpark-python', 'pandas', 'numpy')
handler = 'main'
as
$$
import pandas as pd
import json
import snowflake.snowpark as snowpark
import snowflake.snowpark.functions as F
from snowflake.snowpark.window import Window

def parse_prediction(prediction_json):
    try:
        if isinstance(prediction_json, str):
            prediction_dict = json.loads(prediction_json)
            return float(prediction_dict['output_feature_0'])
        elif isinstance(prediction_json, dict) and 'output_feature_0' in prediction_json:
            return float(prediction_json['output_feature_0'])
        else:
            return float(prediction_json)
    except:
        return None
        
def get_top_bottom_stock_predictions(session: snowpark.Session, 
                                   model_name: str = 'STOCK_RETURN_PREDICTOR_GBM',
                                   top_n: int = 3) -> str:
    """
    Generate stock forecasts using batch predictions for maximum performance.
    """
    
    try:
        # Step 1: Validate FSI data source exists
        fsi_table_name = "{{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.FSI_DATA"
        
        try:
            fsi_df = session.table(fsi_table_name)
            schema = fsi_df.schema
            column_names = [field.name for field in schema.fields]
            
            # Find column mappings
            ticker_col = None
            date_col = None
            price_col = None
            
            for col_name in column_names:
                clean_name = col_name.strip('"').upper()
                if clean_name in ['TICKER', 'SYMBOL']:
                    ticker_col = col_name
                elif clean_name in ['DATE', 'DT']:
                    date_col = col_name
                elif clean_name in ['PRICE', 'CLOSE', 'CLOSE_PRICE']:
                    price_col = col_name
            
            if not all([ticker_col, date_col, price_col]):
                return f"ERROR: FSI_DATA missing required columns. Found: {column_names}. Need: ticker, date, price columns."
                
        except Exception as e:
            raise ValueError(f"""ERROR: {str(e)}""")
        
        # Step 2: Check for pre-calculated features
        feature_columns = {}
        for col_name in column_names:
            clean_name = col_name.strip('"').upper()
            if clean_name == 'R_1':
                feature_columns['r_1'] = col_name
            elif clean_name == 'R_5_1':
                feature_columns['r_5_1'] = col_name
            elif clean_name == 'R_10_5':
                feature_columns['r_10_5'] = col_name
            elif clean_name == 'R_21_10':
                feature_columns['r_21_10'] = col_name
            elif clean_name == 'R_63_21':
                feature_columns['r_63_21'] = col_name
        
        window_spec = Window.partition_by(F.col(ticker_col)).order_by(F.col(date_col).desc())
        
        # Get latest record per ticker with complete features
        latest_features_df = fsi_df.filter(
            F.col(feature_columns['r_1']).is_not_null() &
            F.col(feature_columns['r_5_1']).is_not_null() &
            F.col(feature_columns['r_10_5']).is_not_null() &
            F.col(feature_columns['r_21_10']).is_not_null() &
            F.col(feature_columns['r_63_21']).is_not_null()
        ).with_column(
            "row_num", 
            F.row_number().over(window_spec)
        ).filter(
            F.col("row_num") == 1
        ).select(
            F.col(ticker_col).alias("ticker"),
            F.col(feature_columns['r_1']).alias("r_1"),
            F.col(feature_columns['r_5_1']).alias("r_5_1"),
            F.col(feature_columns['r_10_5']).alias("r_10_5"),
            F.col(feature_columns['r_21_10']).alias("r_21_10"),
            F.col(feature_columns['r_63_21']).alias("r_63_21")
        )
        
        batch_predictions_df = latest_features_df.with_column(
            "prediction_json",
            F.call_function(f"{model_name}!PREDICT", 
                          F.col("r_1"), 
                          F.col("r_5_1"), 
                          F.col("r_10_5"), 
                          F.col("r_21_10"), 
                          F.col("r_63_21"))
        ).select(
            F.col("ticker"),
            F.col("prediction_json")
        )
        
        prediction_results = batch_predictions_df.collect()
        
        # Process all predictions
        predictions = []
        for row in prediction_results:
            try:
                ticker = row[0]
                prediction_json = row[1]
                prediction_value = parse_prediction(prediction_json)
                
                if prediction_value is not None:
                    predictions.append((ticker, prediction_value))
                    
            except Exception as e:
                # Continue with other tickers if one fails
                continue
        
        # Step 3: Check if we have any predictions
        if not predictions:
            return "ERROR: No valid predictions could be generated for any symbols."
        
        # Step 4: Sort predictions by value (ascending to descending)
        predictions.sort(key=lambda x: x[1], reverse=True)
        
        # Step 5: Get top N and bottom N
        top_n_results = predictions[:top_n]
        bottom_n_results = predictions[-top_n:] if len(predictions) >= top_n else []
        
        # Step 6: Format the output
        result = f"TOP {top_n} PREDICTED PERFORMERS:\n"
        for i, (symbol, prediction) in enumerate(top_n_results, 1):
            result += f"{i}. {symbol}: {prediction:.6f}\n"
        
        if bottom_n_results:
            result += f"\nBOTTOM {top_n} PREDICTED PERFORMERS:\n"
            for i, (symbol, prediction) in enumerate(bottom_n_results, 1):
                result += f"{i}. {symbol}: {prediction:.6f}\n"
        
        return result
        
    except Exception as e:
        return f"ERROR generating predictions: {str(e)}"

def main(session: snowpark.Session, model_name: str = 'STOCK_RETURN_PREDICTOR_GBM', top_n: int = 5) -> str:
    """Main handler function for the stored procedure."""
    return get_top_bottom_stock_predictions(session, model_name, top_n)
$$;

-- Create EMAIL_PREVIEWS table for SnowMail integration
CREATE TABLE IF NOT EXISTS {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.EMAIL_PREVIEWS (
    EMAIL_ID VARCHAR(100) PRIMARY KEY,
    RECIPIENT_EMAIL VARCHAR(500),
    SUBJECT VARCHAR(1000),
    HTML_CONTENT VARCHAR(16777216),
    CREATED_AT TIMESTAMP_NTZ
);

create or replace notification integration email_integration
  type=email
  enabled=true
  default_subject = 'snowflake intelligence';

CREATE OR REPLACE PROCEDURE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.SEND_EMAIL_NOTIFICATION(
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
COMMENT='Sends email notifications using SYSTEM$SEND_EMAIL with email_integration. Automatically converts markdown to HTML with Snowflake brand styling using Python markdown library. Stores emails in EMAIL_PREVIEWS table for SnowMail app.'
EXECUTE AS OWNER
AS
{% raw %}$$
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
        email_content = email_content.replace('\n==========\n', '\n')
        email_content = email_content.replace('\n====\n', '\n')
        
        # Convert markdown to HTML using markdown library
        html_body = markdown.markdown(
            email_content,
            extensions=['nl2br', 'tables', 'fenced_code']
        )
        
        # Apply Snowflake brand styling
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
        .email-viewer {{ max-width: 900px; margin: 0 auto; background-color: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); overflow: hidden; }}
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
        .demo-banner {{ background: #FFF4E6; border-left: 4px solid #FF9F36; padding: 15px 20px; margin: 20px 30px; border-radius: 4px; font-size: 14px; color: #24323D; }}
        .demo-banner strong {{ color: #FF9F36; }}
        </style></head><body>
        <div class="email-viewer">
            <div class="email-metadata">
                <div class="email-from">
                    <div class="email-avatar">SI</div>
                    <div class="email-sender">
                        <div class="email-sender-name">Snowflake Intelligence Analytics</div>
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
            <div class="demo-banner">
                <strong>📧 Demo Mode:</strong> This is a preview of the email that would be sent. In production, recipients would receive this via their email inbox.
            </div>
            <div class="email-container">
                <div class="email-header">
                    <div class="icon">📊</div>
                    <h1>STOCK ANALYSIS ALERT</h1>
                </div>
                <div class="email-body">{html_body}</div>
                <div class="email-footer">
                    <p>Generated by Snowflake Intelligence Analytics Platform<br><em>Synthetic demonstration data</em></p>
                </div>
            </div>
        </div>
        </body></html>"""
    else:
        # For plain text
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
    
    # Save HTML to EMAIL_PREVIEWS table for SnowMail viewing
    try:
        import time
        import hashlib
        
        timestamp = str(int(time.time() * 1000))
        email_hash = hashlib.md5(f"{recipient_email}{timestamp}".encode()).hexdigest()[:8]
        email_id = f"email_{timestamp}_{email_hash}"
        
        # Get the database and schema from current context
        db_schema_result = session.sql("SELECT CURRENT_DATABASE() as db, CURRENT_SCHEMA() as schema").collect()[0]
        current_db = db_schema_result['DB']
        current_schema = db_schema_result['SCHEMA']
        
        # Save email to table
        insert_query = f"""
            INSERT INTO {current_db}.{current_schema}.EMAIL_PREVIEWS 
            (EMAIL_ID, RECIPIENT_EMAIL, SUBJECT, HTML_CONTENT, CREATED_AT)
            VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP())
        """
        session.sql(insert_query, params=[email_id, recipient_email, email_subject, html_content]).collect()
        
        # Get account information for SnowMail link
        account_info = session.sql("SELECT CURRENT_ORGANIZATION_NAME() as org, CURRENT_ACCOUNT_NAME() as account").collect()[0]
        org_name = account_info['ORG']
        account_name = account_info['ACCOUNT']
        
        # Construct SnowMail Native App URL
        snowmail_url = f"https://app.snowflake.com/{org_name}/{account_name}/#/apps/application/SNOWMAIL/schema/APP_SCHEMA/streamlit/EMAIL_VIEWER"
        
        # Return success message with SnowMail link
        return f"""✅ Email sent successfully to: {recipient_email}

Subject: {email_subject}
Email ID: {email_id}

📧 VIEW YOUR EMAIL IN SNOWMAIL:

{snowmail_url}

💡 TIP: Right-click the link and select "Open in new tab" (or CMD+Click on Mac / CTRL+Click on Windows) to view your email in SnowMail while keeping this conversation open.

Note: In production deployments, this would be delivered to the recipient's inbox."""
        
    except Exception as e:
        return f'ERROR: Failed to save email preview: {str(e)}'
$${% endraw %};

ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'AWS_US';

select 'Congratulations! Setup has completed successfully!' as status;
