snow sql -q "SELECT CURRENT_DATABASE();"

snow sql -q "CREATE ROLE IF NOT EXISTS $EVENT_ATTENDEE_ROLE;"

snow sql -q "GRANT ROLE $EVENT_ATTENDEE_ROLE TO USER $EVENT_USER_NAME;"

snow sql -q "CREATE DATABASE IF NOT EXISTS  $EVENT_DATABASE;"

snow sql -q "GRANT OWNERSHIP ON DATABASE  $EVENT_DATABASE TO ROLE $EVENT_ATTENDEE_ROLE COPY CURRENT GRANTS;"

snow sql -q "USE ROLE $EVENT_ATTENDEE_ROLE;"
snow sql -q "USE DATABASE $EVENT_DATABASE;"

snow sql -q "CREATE SCHEMA IF NOT EXISTS $EVENT_SCHEMA;"

snow sql -q "USE SCHEMA $EVENT_SCHEMA;"

snow sql -q "
    

    USE ROLE $EVENT_ATTENDEE_ROLE;
    USE DATABASE $EVENT_DATABASE;
    USE SCHEMA $EVENT_SCHEMA;
    USE WAREHOUSE $EVENT_WAREHOUSE;

   
    CREATE STAGE IF NOT EXISTS ad_analytics DIRECTORY=(ENABLE=true) ENCRYPTION=(TYPE='SNOWFLAKE_SSE');
    
    

    PUT file:///$CI_PROJECT_DIR/dataops/data/ad_analytics/images/* @$EVENT_DATABASE.$EVENT_SCHEMA.ad_analytics auto_compress = false overwrite = true;
    PUT file:///$CI_PROJECT_DIR/dataops/data/ad_analytics/ai_sql/* @$EVENT_DATABASE.$EVENT_SCHEMA.ad_analytics auto_compress = false overwrite = true;

    PUT file:///$CI_PROJECT_DIR/dataops/event/notebooks/ADS_ANALYTICS.ipynb @$EVENT_DATABASE.$EVENT_SCHEMA.ad_analytics auto_compress = false overwrite = true;
    ALTER STAGE ad_analytics REFRESH;

    CREATE OR REPLACE TABLE images AS SELECT
    TO_FILE(FILE_URL) Img_File,
    REGEXP_SUBSTR(RELATIVE_PATH, '[^/]+$') AS image_name,
    *
    from
    directory (@$EVENT_DATABASE.$EVENT_SCHEMA.ad_analytics)
    WHERE
    RELATIVE_PATH LIKE '%.png'
    AND RELATIVE_PATH NOT LIKE '%instructions%';

    CREATE OR REPLACE NOTEBOOK AD_ANALYTICS
    FROM @$EVENT_DATABASE.$EVENT_SCHEMA.ad_analytics
    MAIN_FILE = 'ADS_ANALYTICS.ipynb'
    QUERY_WAREHOUSE = $EVENT_WAREHOUSE;

    ALTER NOTEBOOK AD_ANALYTICS ADD LIVE VERSION FROM LAST;
    "


snow sql -q "
    

    USE ROLE $EVENT_ATTENDEE_ROLE;
    USE DATABASE $EVENT_DATABASE;
    USE SCHEMA $EVENT_SCHEMA;
    USE WAREHOUSE $EVENT_WAREHOUSE;

   
    CREATE OR REPLACE FILE FORMAT csv_ff 
    TYPE = 'csv'
    SKIP_HEADER = 1;

    CREATE or REPLACE STAGE MARKETING_LOAD
    COMMENT = 'S3 Stage Connection'
    URL = 's3://sfquickstarts/misc/aisql/marketing_lead_pipelines/'
    FILE_FORMAT = csv_ff;


    CREATE OR REPLACE TABLE marketing_form_data
    (
        PERSON_ID VARCHAR(16777216),
        FIRST_NAME VARCHAR(16777216),
        LAST_NAME VARCHAR(16777216),
        TITLE VARCHAR(16777216),
        COMPANY VARCHAR(16777216)
    );

    CREATE OR REPLACE TABLE company_info
    (
    COMPANY VARCHAR(16777216),
    DESCRIPTION VARCHAR(16777216)
    );


    COPY INTO marketing_form_data
    FROM @MARKETING_LOAD/marketing_form_data.csv
    ON_ERROR = CONTINUE;

    COPY INTO company_info
    FROM @MARKETING_LOAD/company_info.csv
    ON_ERROR = CONTINUE;

    
    
    CREATE STAGE IF NOT EXISTS MARKETING_LEAD DIRECTORY=(ENABLE=true) ENCRYPTION=(TYPE='SNOWFLAKE_SSE');
    
    PUT file:///$CI_PROJECT_DIR/dataops/event/notebooks/MARKETING_LEAD.ipynb @$EVENT_DATABASE.$EVENT_SCHEMA.MARKETING_LEAD auto_compress = false overwrite = true;

    CREATE OR REPLACE NOTEBOOK MARKETING_LEAD
    FROM @$EVENT_DATABASE.$EVENT_SCHEMA.MARKETING_LEAD
    MAIN_FILE = 'MARKETING_LEAD.ipynb'
    QUERY_WAREHOUSE = $EVENT_WAREHOUSE;

    ALTER NOTEBOOK MARKETING_LEAD ADD LIVE VERSION FROM LAST;
    "

    

snow sql -q "
    

    USE ROLE $EVENT_ATTENDEE_ROLE;
    USE DATABASE $EVENT_DATABASE;
    USE SCHEMA $EVENT_SCHEMA;
    USE WAREHOUSE $EVENT_WAREHOUSE;

   
    CREATE STAGE IF NOT EXISTS CALL_RECORDINGS DIRECTORY=(ENABLE=true) ENCRYPTION=(TYPE='SNOWFLAKE_SSE');
    CREATE STAGE IF NOT EXISTS MEDICAL_IMAGES DIRECTORY=(ENABLE=true) ENCRYPTION=(TYPE='SNOWFLAKE_SSE');
    CREATE STAGE IF NOT EXISTS MEDICAL_TRANSCRIPTS DIRECTORY=(ENABLE=true) ENCRYPTION=(TYPE='SNOWFLAKE_SSE');
    
    CREATE STAGE IF NOT EXISTS multimodal_analytics_healthcare DIRECTORY=(ENABLE=true) ENCRYPTION=(TYPE='SNOWFLAKE_SSE');
    
    PUT file:///$CI_PROJECT_DIR/dataops/data/multimodal_analytics/CALL_RECORDINGS/* @$EVENT_DATABASE.$EVENT_SCHEMA.CALL_RECORDINGS auto_compress = false overwrite = true;
    PUT file:///$CI_PROJECT_DIR/dataops/data/multimodal_analytics/MEDICAL_IMAGES/* @$EVENT_DATABASE.$EVENT_SCHEMA.MEDICAL_IMAGES auto_compress = false overwrite = true;
    PUT file:///$CI_PROJECT_DIR/dataops/data/multimodal_analytics/MEDICAL_TRANSCRIPTS/* @$EVENT_DATABASE.$EVENT_SCHEMA.MEDICAL_TRANSCRIPTS auto_compress = false overwrite = true;
    ALTER STAGE CALL_RECORDINGS REFRESH;
    ALTER STAGE MEDICAL_IMAGES REFRESH;
    ALTER STAGE MEDICAL_TRANSCRIPTS REFRESH;

    -- Create enhanced healthcare data structures
    CREATE OR REPLACE TABLE patient_demographics (
    PATIENT_ID VARCHAR,
    AGE VARCHAR,
    GENDER VARCHAR,
    RACE_ETHNICITY VARCHAR,
    INSURANCE_TYPE VARCHAR,
    ZIP_CODE VARCHAR,
    CHRONIC_CONDITIONS VARCHAR,
    RISK_FACTORS VARCHAR,
    ADMISSION_DATE DATE,
    DISCHARGE_DATE DATE,
    ADMISSION_TYPE VARCHAR,
    PRIMARY_DIAGNOSIS VARCHAR,
    SECONDARY_DIAGNOSES VARCHAR
    );

    CREATE OR REPLACE TABLE clinical_notes (
    NOTE_ID VARCHAR,
    PATIENT_ID VARCHAR,
    NOTE_TYPE VARCHAR,
    PROVIDER_ID VARCHAR,
    NOTE_DATE DATE,
    NOTE_TEXT VARCHAR,
    VISIT_TYPE VARCHAR,
    DEPARTMENT VARCHAR,
    CHIEF_COMPLAINT VARCHAR,
    ASSESSMENT VARCHAR,
    PLAN VARCHAR
    );

    -- Load sample healthcare data
    INSERT INTO patient_demographics VALUES
    ('PT-00001', '67', 'Female', 'Caucasian', 'Medicare', '10001', 'Diabetes Type 2, Hypertension', 'Smoking History, Family History of Heart Disease', '2024-01-15', '2024-01-18', 'Emergency', 'Acute Myocardial Infarction', 'Diabetes, Hypertension'),
    ('PT-00002', '45', 'Male', 'African American', 'Private Insurance', '10002', 'Hypertension', 'Obesity', '2024-01-20', '2024-01-22', 'Elective', 'Routine Colonoscopy', 'Polyps'),
    ('PT-00003', '28', 'Female', 'Hispanic', 'Medicaid', '10003', '', 'Pregnancy', '2024-01-25', '2024-01-27', 'Emergency', 'Preterm Labor', ''),
    ('PT-00004', '72', 'Male', 'Caucasian', 'Medicare', '10004', 'COPD, Diabetes Type 2', 'Smoking History', '2024-02-01', '2024-02-05', 'Emergency', 'COPD Exacerbation', 'Pneumonia'),
    ('PT-00005', '55', 'Female', 'Asian', 'Private Insurance', '10005', 'Breast Cancer History', 'Family History of Cancer', '2024-02-10', NULL, 'Elective', 'Mammography Follow-up', 'Suspicious Mass'),
    ('PT-00006', '34', 'Male', 'Caucasian', 'Private Insurance', '10006', '', 'Previous Fractures', '2024-02-15', '2024-02-16', 'Emergency', 'Motor Vehicle Accident', 'Multiple Fractures'),
    ('PT-00007', '80', 'Female', 'Caucasian', 'Medicare', '10007', 'Alzheimer Disease, Osteoporosis', 'Fall Risk', '2024-02-20', '2024-02-25', 'Emergency', 'Hip Fracture', 'Delirium'),
    ('PT-00008', '42', 'Male', 'Hispanic', 'Uninsured', '10008', 'Hypertension', 'Alcohol Use', '2024-02-25', '2024-02-26', 'Emergency', 'Chest Pain Rule Out MI', ''),
    ('PT-00009', '59', 'Female', 'African American', 'Medicare', '10009', 'Diabetes Type 2, Chronic Kidney Disease', 'Medication Non-compliance', '2024-03-01', '2024-03-03', 'Emergency', 'Diabetic Ketoacidosis', 'Acute Kidney Injury'),
    ('PT-00010', '25', 'Male', 'Caucasian', 'Private Insurance', '10010', '', 'Athletic Activity', '2024-03-05', '2024-03-06', 'Emergency', 'Sports Injury', 'ACL Tear');

    -- Load sample clinical notes
    INSERT INTO clinical_notes VALUES
    ('NOTE-00001', 'PT-00001', 'Progress Note', 'DR-CARDIO-01', '2024-01-16', 'Patient experienced acute chest pain at 3 AM. EKG shows ST elevation in leads II, III, aVF. Troponin elevated at 15.2. Patient has history of diabetes and hypertension, both poorly controlled. Immediate cardiac catheterization performed with successful PCI to RCA. Patient stable post-procedure but will require intensive cardiac monitoring.', 'Inpatient', 'Cardiology', 'Acute chest pain', 'STEMI', 'Cardiac catheterization, dual antiplatelet therapy'),
    ('NOTE-00002', 'PT-00002', 'Procedure Note', 'DR-GASTRO-01', '2024-01-21', 'Routine screening colonoscopy performed. Excellent bowel preparation. Two small polyps identified in ascending colon, both removed with cold snare technique. Pathology pending. Patient tolerated procedure well without complications. No signs of malignancy noted.', 'Outpatient', 'Gastroenterology', 'Screening colonoscopy', 'Two adenomatous polyps removed', 'Follow-up in 3 years'),
    ('NOTE-00003', 'PT-00003', 'Labor & Delivery Note', 'DR-OBGYN-01', '2024-01-26', 'Patient presented at 32 weeks gestation with regular uterine contractions and cervical dilation. Despite tocolytic therapy, labor progressed rapidly. Emergency cesarean section performed due to fetal distress. Baby delivered with Apgar scores 7 and 9. Patient recovering well, planning discharge in 48 hours.', 'Inpatient', 'Obstetrics', 'Preterm labor', 'Successful emergency C-section', 'NICU follow-up for infant'),
    ('NOTE-00004', 'PT-00004', 'Emergency Note', 'DR-PULM-01', '2024-02-02', 'Patient with known COPD presented with severe dyspnea, productive cough with purulent sputum, and fever. Chest X-ray shows new infiltrate in right lower lobe consistent with pneumonia. ABG reveals respiratory acidosis. Started on broad-spectrum antibiotics and systemic corticosteroids. Patient required BiPAP for respiratory support.', 'Emergency', 'Pulmonology', 'Shortness of breath', 'COPD exacerbation with pneumonia', 'Antibiotics, steroids, respiratory support'),
    ('NOTE-00005', 'PT-00005', 'Radiology Report', 'DR-RAD-01', '2024-02-11', 'Follow-up mammography shows new 2.2 cm irregular mass in upper outer quadrant of left breast. Mass demonstrates spiculated margins and increased density compared to prior study 6 months ago. Suspicious for malignancy. Recommend urgent breast MRI and tissue sampling. Patient counseled on findings and referred to breast surgery.', 'Outpatient', 'Radiology', 'Breast mass follow-up', 'Suspicious breast mass', 'Urgent MRI and biopsy');

    PUT file:///$CI_PROJECT_DIR/dataops/event/notebooks/multimodal_analytics_healthcare.ipynb @$EVENT_DATABASE.$EVENT_SCHEMA.multimodal_analytics_healthcare auto_compress = false overwrite = true;

    CREATE OR REPLACE NOTEBOOK multimodal_analytics_healthcare
    FROM @$EVENT_DATABASE.$EVENT_SCHEMA.multimodal_analytics_healthcare
    MAIN_FILE = 'multimodal_analytics_healthcare.ipynb'
    QUERY_WAREHOUSE = $EVENT_WAREHOUSE;

    ALTER NOTEBOOK multimodal_analytics_healthcare ADD LIVE VERSION FROM LAST;


    "

snow sql -q "
    

    USE ROLE $EVENT_ATTENDEE_ROLE;
    USE DATABASE $EVENT_DATABASE;
    USE SCHEMA $EVENT_SCHEMA;
    USE WAREHOUSE $EVENT_WAREHOUSE;

   
    CREATE OR REPLACE FILE FORMAT csv_ff 
    TYPE = 'csv'
    SKIP_HEADER = 1;

    CREATE OR REPLACE STAGE customer_review
        COMMENT = 'Quickstarts S3 Stage Connection'
        URL = 's3://sfquickstarts/misc/aisql/ecommerce_customer_review/'
        FILE_FORMAT = csv_ff;

    CREATE OR REPLACE TABLE customer_data
    (
        CUSTOMER_ID	VARCHAR(16777216),
        CUSTOMER_SEGMENT	VARCHAR(16777216),
        JOIN_DATE	DATE,
        LIFETIME_VALUE	NUMBER(38,2),
        PREVIOUS_PURCHASES	NUMBER(38,0),
        AGE_RANGE	VARCHAR(16777216),
        GENDER	VARCHAR(16777216),
        PREFERRED_CATEGORY	VARCHAR(16777216)
    );

    CREATE OR REPLACE TABLE product_catalog
    (
        PRODUCT_ID	VARCHAR(16777216),
        PRODUCT_NAME	VARCHAR(16777216),
        CATEGORY	VARCHAR(16777216),
        SUBCATEGORY	VARCHAR(16777216),
        MANUFACTURER	VARCHAR(16777216),
        PRICE	NUMBER(38,2),
        RELEASE_DATE	DATE,
        REVIEW_COUNT	NUMBER(38,0)
    );

    CREATE OR REPLACE TABLE product_reviews
    (
        REVIEW_ID	VARCHAR(16777216),
        PRODUCT_ID	VARCHAR(16777216),
        CUSTOMER_ID	VARCHAR(16777216),
        REVIEW_TEXT	VARCHAR(16777216),
        RATING	NUMBER(38,0),
        REVIEW_DATE	DATE,
        PURCHASE_DATE	DATE,
        VERIFIED_PURCHASE	BOOLEAN,
        HELPFUL_VOTES	NUMBER(38,0)
    );
    
    COPY INTO customer_data
    FROM @customer_review/customer_data.csv
    ON_ERROR = CONTINUE;

    COPY INTO product_catalog   
    FROM @customer_review/product_catalog.csv
    ON_ERROR = CONTINUE;

    COPY INTO product_reviews
    FROM @customer_review/product_reviews.csv
    ON_ERROR = CONTINUE;

    
    
    CREATE STAGE IF NOT EXISTS CUSTOMER_REVIEWS_INSIGHT DIRECTORY=(ENABLE=true) ENCRYPTION=(TYPE='SNOWFLAKE_SSE');
    
    PUT file:///$CI_PROJECT_DIR/dataops/event/notebooks/CUSTOMER_REVIEWS_INSIGHT.ipynb @$EVENT_DATABASE.$EVENT_SCHEMA.CUSTOMER_REVIEWS_INSIGHT auto_compress = false overwrite = true;

    CREATE OR REPLACE NOTEBOOK CUSTOMER_REVIEWS_INSIGHT
    FROM @$EVENT_DATABASE.$EVENT_SCHEMA.CUSTOMER_REVIEWS_INSIGHT
    MAIN_FILE = 'CUSTOMER_REVIEWS_INSIGHT.ipynb'
    QUERY_WAREHOUSE = $EVENT_WAREHOUSE;

    ALTER NOTEBOOK CUSTOMER_REVIEWS_INSIGHT ADD LIVE VERSION FROM LAST;
    "
