-------- Hackathon Database Configuration --------
-- This script creates a duplicate of all tables, views, and stages from EVENT_DATABASE
-- into HACKATHON_DATABASE for hackathon participants
-- Organized by meaningful content categories instead of technical schemas
-- Excludes: semantic views, search services, notebooks

USE ROLE {{ env.EVENT_ATTENDEE_ROLE }};
USE WAREHOUSE {{ env.EVENT_WAREHOUSE }};

-- Create Hackathon Database with Content-Based Schemas
CREATE OR REPLACE DATABASE {{ env.HACKATHON_DATABASE }}
    COMMENT = 'Hackathon dataset organized by content type: financial data, audio/transcripts, corporate documents, communications, and investment research';

-- Schema 1: Financial & Market Data (stock prices, analyst reports, financial statements)
CREATE SCHEMA IF NOT EXISTS {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA
    COMMENT = 'Stock prices, analyst reports, financial statements, and market analysis data';

-- Schema 2: Audio & Transcripts (earnings calls, transcripts, sentiment analysis)
CREATE SCHEMA IF NOT EXISTS {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS
    COMMENT = 'Earnings call audio files, transcripts, speaker identification, and sentiment analysis';

-- Schema 3: Corporate Documents (annual reports, executive bios, infographics)
CREATE SCHEMA IF NOT EXISTS {{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS
    COMMENT = 'Annual reports, executive biographies, financial infographics, and company documents';

-- Schema 4: Communications (emails, social media)
CREATE SCHEMA IF NOT EXISTS {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS
    COMMENT = 'Email previews and social media data';

-- Schema 5: Investment Research (academic papers, research reports)
CREATE SCHEMA IF NOT EXISTS {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH
    COMMENT = 'Federal Reserve and NBER investment research papers';

USE DATABASE {{ env.HACKATHON_DATABASE }};

-- =====================================================
-- COMMUNICATIONS Schema: Functions & Procedures
-- =====================================================

CREATE OR REPLACE FUNCTION {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.WEB_SEARCH("QUERY" VARCHAR)
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

-- =====================================================
-- FINANCIAL_DATA Schema: Stock Prices, Analyst Reports, Financial Statements
-- =====================================================

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.STOCK_PRICES 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.STOCK_PRICES
    COMMENT = 'Historical stock price data with daily highs, lows, and trading volumes';

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.ANALYST_REPORTS
    COMMENT = 'Analyst research reports with ratings, price targets, and summaries';

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS_ALL_DATA 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANALYST_REPORTS_ALL_DATA
    COMMENT = 'Complete analyst report data with full text and metadata';

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.FINANCIAL_REPORTS 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.FINANCIAL_REPORTS
    COMMENT = 'Quarterly financial reports with extracted structured data';

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.INFOGRAPHICS_FOR_SEARCH
    COMMENT = 'Financial infographics with KPIs and metrics';

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHIC_METRICS_EXTRACTED 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.INFOGRAPHIC_METRICS_EXTRACTED
    COMMENT = 'Extracted metrics from financial infographics';

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.PARSED_ANALYST_REPORTS 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.PARSED_ANALYST_REPORTS
    COMMENT = 'Parsed analyst reports from PDF documents';

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.AI_EXTRACT_ANALYST_REPORTS_ADVANCED 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.AI_EXTRACT_ANALYST_REPORTS_ADVANCED
    COMMENT = 'AI-extracted structured data from analyst reports';

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.REPORT_PROVIDER_SUMMARY 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.REPORT_PROVIDER_SUMMARY
    COMMENT = 'Summary statistics by research firm/analyst provider';

-- =====================================================
-- EARNINGS_ANALYSIS Schema: Transcripts, Audio, Sentiment
-- =====================================================

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS
    COMMENT = 'AI-generated sentiment analysis of earnings call transcripts';

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT
    COMMENT = 'Transcribed earnings calls with sentiment scores per segment';

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.TRANSCRIPTS_BY_MINUTE 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.TRANSCRIPTS_BY_MINUTE
    COMMENT = 'Earnings call transcripts aggregated by minute with sentiment';

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.SENTIMENT_ANALYSIS 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.SENTIMENT_ANALYSIS
    COMMENT = 'Detailed sentiment analysis across multiple dimensions';

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.unique_transcripts 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.unique_transcripts
    COMMENT = 'Unique earnings call transcripts with metadata';

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.TRANSCRIBED_EARNINGS_CALLS 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.TRANSCRIBED_EARNINGS_CALLS
    COMMENT = 'Raw AI transcription output from earnings call audio';

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.SPEAKER_MAPPING 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.SPEAKER_MAPPING
    COMMENT = 'Speaker identification and role mapping for transcripts';

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.AI_TRANSCRIBE_NO_TIME 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.AI_TRANSCRIBE_NO_TIME
    COMMENT = 'Transcribed text without timestamps for summarization';

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.call_embeds 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.call_embeds
    COMMENT = 'Chunked earnings call text for embedding-based search';

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.FULL_TRANSCRIPTS 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.FULL_TRANSCRIPTS
    COMMENT = 'Complete earnings call transcripts with summaries';

-- =====================================================
-- COMMUNICATIONS Schema: Emails and Social Media
-- =====================================================

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.EMAIL_PREVIEWS 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.EMAIL_PREVIEWS
    COMMENT = 'Email preview data with HTML content and metadata';

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.EMAIL_PREVIEWS_EXTRACTED 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.EMAIL_PREVIEWS_EXTRACTED
    COMMENT = 'Extracted metadata from emails (ticker, rating, sentiment)';

CREATE OR REPLACE TABLE {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SOCIAL_MEDIA_NRNT 
    CLONE {{ env.EVENT_DATABASE }}.{{ env.EVENT_SCHEMA }}.SOCIAL_MEDIA_NRNT
    COMMENT = 'Social media posts about NRNT company collapse timeline';

-- =====================================================
-- FINANCIAL_DATA Stages: Analyst Reports, Financial Documents, Infographics
-- =====================================================

CREATE OR REPLACE STAGE {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.analyst_reports
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = '30 analyst research report PDFs from 6 firms';

CREATE OR REPLACE STAGE {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.financial_reports
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = '11 quarterly financial report PDFs';

CREATE OR REPLACE STAGE {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.infographics
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = '11 earnings infographic PNGs with KPIs';

-- Copy financial data stages
COPY FILES 
  INTO '@{{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.analyst_reports'
  FROM '@{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.analyst_reports';

COPY FILES 
  INTO '@{{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.financial_reports'
  FROM '@{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.financial_reports';

COPY FILES 
  INTO '@{{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.infographics'
  FROM '@{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.infographics';

ALTER STAGE {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.analyst_reports REFRESH;
ALTER STAGE {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.financial_reports REFRESH;
ALTER STAGE {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.infographics REFRESH;

-- =====================================================
-- EARNINGS_ANALYSIS Stages: Audio Files
-- =====================================================

CREATE OR REPLACE STAGE {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.earnings_calls
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = '3 MP3 earnings call audio files';

COPY FILES 
  INTO '@{{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.earnings_calls'
  FROM '@{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.earnings_calls';

ALTER STAGE {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.earnings_calls REFRESH;

-- =====================================================
-- CORPORATE_DOCS Stages: Annual Reports, Executive Bios, Portraits, Interviews
-- =====================================================

CREATE OR REPLACE STAGE {{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.ANNUAL_REPORTS
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = '22 annual report PDFs (FY2024 + FY2025) with charts and narrative';

CREATE OR REPLACE STAGE {{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.EXECUTIVE_BIOS
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = '11 executive biography PDFs';

CREATE OR REPLACE STAGE {{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.EXECUTIVE_PORTRAITS
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = '~30 AI-generated executive portrait images';

CREATE OR REPLACE STAGE {{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.interviews
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = '1 MP3 executive interview audio file (NRNT CEO post-collapse)';

-- Copy corporate document stages
COPY FILES 
  INTO '@{{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.ANNUAL_REPORTS'
  FROM '@{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS';

COPY FILES 
  INTO '@{{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.EXECUTIVE_BIOS'
  FROM '@{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_BIOS';

COPY FILES 
  INTO '@{{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.EXECUTIVE_PORTRAITS'
  FROM '@{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_PORTRAITS';

COPY FILES 
  INTO '@{{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.interviews'
  FROM '@{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.interviews';

ALTER STAGE {{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.ANNUAL_REPORTS REFRESH;
ALTER STAGE {{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.EXECUTIVE_BIOS REFRESH;
ALTER STAGE {{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.EXECUTIVE_PORTRAITS REFRESH;
ALTER STAGE {{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.interviews REFRESH;

-- =====================================================
-- INVESTMENT_RESEARCH Stages: Academic Papers & Research Documents
-- =====================================================
-- 
-- PUBLIC SOURCES FOR ADDITIONAL DOCUMENTS:
-- 
-- 1. ESG & SUSTAINABLE INVESTING:
--    - https://www.unpri.org/research (UN Principles for Responsible Investment)
--    - https://www.msci.com/research-and-insights/esg (MSCI ESG Research)
--    - https://www.sasb.org/standards/ (SASB Standards - downloadable PDFs)
-- 
-- 2. RISK MANAGEMENT:
--    - https://www.bis.org/publ/index.htm (Bank for International Settlements)
--    - https://www.federalreserve.gov/supervisionreg.htm (Fed Supervision Reports)
--    - https://www.sec.gov/files/dera (SEC Risk Analytics)
-- 
-- 3. PORTFOLIO STRATEGY:
--    - https://www.cfainstitute.org/en/research (CFA Institute Research)
--    - https://www.nber.org/papers (NBER Working Papers - search "portfolio")
--    - https://papers.ssrn.com/ (SSRN - search "asset allocation")
-- 
-- 4. MARKET RESEARCH:
--    - https://www.imf.org/en/Publications (IMF Publications)
--    - https://www.worldbank.org/en/research (World Bank Research)
--    - https://www.ecb.europa.eu/pub/research/working-papers/ (ECB Working Papers)
-- 
-- 5. QUANTITATIVE METHODS:
--    - https://arxiv.org/list/q-fin/recent (ArXiv Quantitative Finance)
--    - https://www.risk.net/cutting-edge (Risk.net Research - some free papers)
--    - https://jfds.pm-research.com/ (Journal of Financial Data Science)
--
-- =====================================================

-- Stage 1: Investment Management (Original)
CREATE OR REPLACE STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.investment_management
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = 'Federal Reserve and NBER research papers on portfolio management and investment strategies';

COPY FILES 
  INTO '@{{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.investment_management'
  FROM '@{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.investment_management';

ALTER STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.investment_management REFRESH;

-- Stage 2: ESG & Sustainable Investing
CREATE OR REPLACE STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.esg_investing
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = 'ESG investment research, sustainability reports, and responsible investing frameworks';

PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/data/investment_research/esg/*.pdf @{{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.esg_investing auto_compress = false overwrite = true;

ALTER STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.esg_investing REFRESH;

-- Stage 3: Risk Management
CREATE OR REPLACE STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.risk_management
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = 'Risk analysis papers, stress testing methodologies, and regulatory risk frameworks';

PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/data/investment_research/risk/*.pdf @{{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.risk_management auto_compress = false overwrite = true;

ALTER STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.risk_management REFRESH;

-- Stage 4: Portfolio Strategy & Asset Allocation
CREATE OR REPLACE STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.portfolio_strategy
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = 'Modern portfolio theory, asset allocation strategies, and diversification research';

PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/data/investment_research/portfolio/*.pdf @{{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.portfolio_strategy auto_compress = false overwrite = true;

ALTER STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.portfolio_strategy REFRESH;

-- Stage 5: Market Research & Economics
CREATE OR REPLACE STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.market_research
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = 'IMF, World Bank, and ECB economic research and market analysis reports';

PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/data/investment_research/market/*.pdf @{{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.market_research auto_compress = false overwrite = true;

ALTER STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.market_research REFRESH;

-- Stage 6: Quantitative Methods & Algorithmic Trading
CREATE OR REPLACE STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.quantitative_methods
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = 'Quantitative finance papers, algorithmic trading strategies, and mathematical models';

PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/data/investment_research/quant/*.pdf @{{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.quantitative_methods auto_compress = false overwrite = true;

ALTER STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.quantitative_methods REFRESH;

-- =====================================================
-- FINANCIAL_DATA Schema: Views
-- =====================================================

CREATE OR REPLACE VIEW {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.VW_INFOGRAPHIC_METRICS(
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
FROM {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHIC_METRICS_EXTRACTED;

CREATE OR REPLACE VIEW {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.VW_FINANCIAL_SUMMARY(
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
FROM {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.FINANCIAL_REPORTS
ORDER BY COMPANY;

CREATE OR REPLACE VIEW {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.VW_INCOME_STATEMENT(
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
    FROM {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.FINANCIAL_REPORTS
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

CREATE OR REPLACE VIEW {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.VW_KPI_METRICS(
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
    FROM {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.FINANCIAL_REPORTS
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

-- =====================================================
-- EARNINGS_ANALYSIS Schema: Views
-- =====================================================

CREATE OR REPLACE VIEW {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH(
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
    FROM {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.unique_transcripts
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
NATURAL JOIN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.ai_transcripts_analysts_sentiments b;

-- Stock price timeseries view (references external share)
CREATE OR REPLACE VIEW {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.STOCK_PRICE_TIMESERIES(
	TICKER,
	ASSET_CLASS,
	PRIMARY_EXCHANGE_CODE,
	PRIMARY_EXCHANGE_NAME,
	VARIABLE,
	VARIABLE_NAME,
	DATE,
	VALUE
) AS 
SELECT * FROM ORGDATACLOUD$INTERNAL$TRANSCRIPTS_FROM_EARNINGS_CALLS.ACCELERATE_WITH_AI_DOC_AI.STOCK_PRICE_TIMESERIES;

-- =====================================================
-- COMMUNICATIONS Schema: Send Email Procedure
-- =====================================================

CREATE OR REPLACE PROCEDURE {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SEND_EMAIL_NOTIFICATION(
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
            INSERT INTO {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.EMAIL_PREVIEWS 
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
$${% endraw %};

-- =====================================================
-- Grant Permissions to ATTENDEE_ROLE
-- =====================================================

-- Grant database usage
GRANT USAGE ON DATABASE {{ env.HACKATHON_DATABASE }} TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

-- Grant usage on all schemas
GRANT USAGE ON SCHEMA {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT USAGE ON SCHEMA {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT USAGE ON SCHEMA {{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT USAGE ON SCHEMA {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT USAGE ON SCHEMA {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

-- Grant SELECT on all tables and views in each schema
GRANT SELECT ON ALL TABLES IN SCHEMA {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT SELECT ON ALL VIEWS IN SCHEMA {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

GRANT SELECT ON ALL TABLES IN SCHEMA {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT SELECT ON ALL VIEWS IN SCHEMA {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

GRANT SELECT ON ALL TABLES IN SCHEMA {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

-- Grant permissions on stages
GRANT READ ON STAGE {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.analyst_reports TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT READ ON STAGE {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.financial_reports TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT READ ON STAGE {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.infographics TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

GRANT READ ON STAGE {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.earnings_calls TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

GRANT READ ON STAGE {{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.ANNUAL_REPORTS TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT READ ON STAGE {{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.EXECUTIVE_BIOS TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT READ ON STAGE {{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.EXECUTIVE_PORTRAITS TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT READ ON STAGE {{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.interviews TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

GRANT READ ON STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.investment_management TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT READ ON STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.esg_investing TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT READ ON STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.risk_management TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT READ ON STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.portfolio_strategy TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT READ ON STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.market_research TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT READ ON STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.quantitative_methods TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

-- Grant EXECUTE on functions and procedures
GRANT USAGE ON FUNCTION {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.WEB_SEARCH(VARCHAR) TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};
GRANT USAGE ON PROCEDURE {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SEND_EMAIL_NOTIFICATION(VARCHAR, VARCHAR, VARCHAR, VARCHAR) TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

-- Grant INSERT for EMAIL_PREVIEWS (used by SEND_EMAIL_NOTIFICATION)
GRANT INSERT ON TABLE {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.EMAIL_PREVIEWS TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

-- =====================================================
-- Verification
-- =====================================================

SELECT '=== HACKATHON DATABASE SETUP COMPLETE ===' AS STATUS;

SELECT 'Tables in FINANCIAL_DATA Schema' AS verification_step, COUNT(*) AS table_count 
FROM {{ env.HACKATHON_DATABASE }}.INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'FINANCIAL_DATA' AND TABLE_TYPE = 'BASE TABLE';

SELECT 'Tables in EARNINGS_ANALYSIS Schema' AS verification_step, COUNT(*) AS table_count 
FROM {{ env.HACKATHON_DATABASE }}.INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'EARNINGS_ANALYSIS' AND TABLE_TYPE = 'BASE TABLE';

SELECT 'Tables in COMMUNICATIONS Schema' AS verification_step, COUNT(*) AS table_count 
FROM {{ env.HACKATHON_DATABASE }}.INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'COMMUNICATIONS' AND TABLE_TYPE = 'BASE TABLE';

SELECT 'Views in FINANCIAL_DATA Schema' AS verification_step, COUNT(*) AS view_count 
FROM {{ env.HACKATHON_DATABASE }}.INFORMATION_SCHEMA.VIEWS 
WHERE TABLE_SCHEMA = 'FINANCIAL_DATA';

SELECT 'Views in EARNINGS_ANALYSIS Schema' AS verification_step, COUNT(*) AS view_count 
FROM {{ env.HACKATHON_DATABASE }}.INFORMATION_SCHEMA.VIEWS 
WHERE TABLE_SCHEMA = 'EARNINGS_ANALYSIS';

SELECT 'Stages in FINANCIAL_DATA Schema' AS verification_step, COUNT(*) AS stage_count 
FROM {{ env.HACKATHON_DATABASE }}.INFORMATION_SCHEMA.STAGES 
WHERE STAGE_SCHEMA = 'FINANCIAL_DATA';

SELECT 'Stages in EARNINGS_ANALYSIS Schema' AS verification_step, COUNT(*) AS stage_count 
FROM {{ env.HACKATHON_DATABASE }}.INFORMATION_SCHEMA.STAGES 
WHERE STAGE_SCHEMA = 'EARNINGS_ANALYSIS';

SELECT 'Stages in CORPORATE_DOCS Schema' AS verification_step, COUNT(*) AS stage_count 
FROM {{ env.HACKATHON_DATABASE }}.INFORMATION_SCHEMA.STAGES 
WHERE STAGE_SCHEMA = 'CORPORATE_DOCS';

SELECT 'Stages in INVESTMENT_RESEARCH Schema' AS verification_step, COUNT(*) AS stage_count 
FROM {{ env.HACKATHON_DATABASE }}.INFORMATION_SCHEMA.STAGES 
WHERE STAGE_SCHEMA = 'INVESTMENT_RESEARCH';

SELECT 'Functions in COMMUNICATIONS Schema' AS verification_step, COUNT(*) AS function_count 
FROM {{ env.HACKATHON_DATABASE }}.INFORMATION_SCHEMA.FUNCTIONS 
WHERE FUNCTION_SCHEMA = 'COMMUNICATIONS';

SELECT 'Procedures in COMMUNICATIONS Schema' AS verification_step, COUNT(*) AS procedure_count 
FROM {{ env.HACKATHON_DATABASE }}.INFORMATION_SCHEMA.PROCEDURES 
WHERE PROCEDURE_SCHEMA = 'COMMUNICATIONS';

-- Show sample data from key tables
SELECT 'Sample Row Counts' AS verification_step;
SELECT 'FINANCIAL_DATA.STOCK_PRICES' AS TABLE_NAME, COUNT(*) AS ROW_COUNT FROM {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.STOCK_PRICES
UNION ALL
SELECT 'FINANCIAL_DATA.ANALYST_REPORTS', COUNT(*) FROM {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS
UNION ALL
SELECT 'EARNINGS_ANALYSIS.TRANSCRIPTS_BY_MINUTE', COUNT(*) FROM {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.TRANSCRIPTS_BY_MINUTE
UNION ALL
SELECT 'COMMUNICATIONS.EMAIL_PREVIEWS', COUNT(*) FROM {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.EMAIL_PREVIEWS
UNION ALL
SELECT 'COMMUNICATIONS.SOCIAL_MEDIA_NRNT', COUNT(*) FROM {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SOCIAL_MEDIA_NRNT;

-- Show stage file counts
SELECT 'Stage File Counts' AS verification_step;

SELECT 
    'FINANCIAL_DATA.analyst_reports' AS STAGE_NAME,
    COUNT(*) AS FILE_COUNT
FROM DIRECTORY('@{{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.analyst_reports')
UNION ALL
SELECT 
    'FINANCIAL_DATA.financial_reports',
    COUNT(*)
FROM DIRECTORY('@{{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.financial_reports')
UNION ALL
SELECT 
    'FINANCIAL_DATA.infographics',
    COUNT(*)
FROM DIRECTORY('@{{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.infographics')
UNION ALL
SELECT 
    'EARNINGS_ANALYSIS.earnings_calls',
    COUNT(*)
FROM DIRECTORY('@{{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.earnings_calls')
UNION ALL
SELECT 
    'CORPORATE_DOCS.ANNUAL_REPORTS',
    COUNT(*)
FROM DIRECTORY('@{{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.ANNUAL_REPORTS')
UNION ALL
SELECT 
    'CORPORATE_DOCS.EXECUTIVE_BIOS',
    COUNT(*)
FROM DIRECTORY('@{{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.EXECUTIVE_BIOS')
UNION ALL
SELECT 
    'CORPORATE_DOCS.EXECUTIVE_PORTRAITS',
    COUNT(*)
FROM DIRECTORY('@{{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.EXECUTIVE_PORTRAITS')
UNION ALL
SELECT 
    'CORPORATE_DOCS.interviews',
    COUNT(*)
FROM DIRECTORY('@{{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.interviews')
UNION ALL
SELECT 
    'INVESTMENT_RESEARCH.investment_management',
    COUNT(*)
FROM DIRECTORY('@{{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.investment_management')
UNION ALL
SELECT 
    'INVESTMENT_RESEARCH.esg_investing',
    COUNT(*)
FROM DIRECTORY('@{{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.esg_investing')
UNION ALL
SELECT 
    'INVESTMENT_RESEARCH.risk_management',
    COUNT(*)
FROM DIRECTORY('@{{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.risk_management')
UNION ALL
SELECT 
    'INVESTMENT_RESEARCH.portfolio_strategy',
    COUNT(*)
FROM DIRECTORY('@{{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.portfolio_strategy')
UNION ALL
SELECT 
    'INVESTMENT_RESEARCH.market_research',
    COUNT(*)
FROM DIRECTORY('@{{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.market_research')
UNION ALL
SELECT 
    'INVESTMENT_RESEARCH.quantitative_methods',
    COUNT(*)
FROM DIRECTORY('@{{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.quantitative_methods');

-- =====================================================
-- Add Column Comments for Database Explorer Searchability
-- =====================================================
-- Comprehensive metadata for all tables and columns
-- NOTE: Most data is FICTITIOUS for hackathon purposes except:
--   ✅ REAL: Investment research papers (UN PRI, BIS, Fed, IMF, ArXiv)
--   ✅ REAL: Stock market data structure concepts (not actual historical prices)
--   ⚠️  FICTITIOUS: Company data (NRNT is fake), analyst reports, emails, social media
-- =====================================================

-- =====================================================
-- FINANCIAL_DATA Schema: Column Comments
-- =====================================================

-- Table: STOCK_PRICES (Fictitious data for demo companies)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.STOCK_PRICES.TICKER 
    IS 'Stock ticker symbol (e.g., AAPL, SNOW) - FICTITIOUS demo data for 11 companies';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.STOCK_PRICES.ASSET_CLASS 
    IS 'Type of asset - primarily "STOCKS" for equity securities';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.STOCK_PRICES.PRIMARY_EXCHANGE_CODE 
    IS 'Exchange code where stock trades (e.g., XNYS for NYSE, XNAS for NASDAQ)';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.STOCK_PRICES.PRIMARY_EXCHANGE_NAME 
    IS 'Full exchange name (e.g., New York Stock Exchange, NASDAQ Global Select Market)';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.STOCK_PRICES.DATE 
    IS 'Trading date for the stock price record';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.STOCK_PRICES.ALL_DAY_HIGH 
    IS 'Highest price reached during the trading day (intraday high)';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.STOCK_PRICES.ALL_DAY_LOW 
    IS 'Lowest price reached during the trading day (intraday low)';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.STOCK_PRICES.NASDAQ_VOLUME 
    IS 'Total number of shares traded during the day';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.STOCK_PRICES.POST_MARKET_CLOSE 
    IS 'Stock price at the end of after-hours trading session';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.STOCK_PRICES.PRE_MARKET_OPEN 
    IS 'Stock price at the start of pre-market trading session';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.STOCK_PRICES.YEAR 
    IS 'Year extracted from the trading date for easy filtering';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.STOCK_PRICES.MONTHNAME 
    IS 'Month name (e.g., January, February) for time-based analysis';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.STOCK_PRICES.MONTHNO 
    IS 'Month number (1-12) for temporal aggregations';

-- Table: ANALYST_REPORTS (Fictitious analyst research reports)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS.RELATIVE_PATH 
    IS 'File path to the analyst report PDF within the stage - FICTITIOUS reports';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS.FILE_URL 
    IS 'Pre-signed URL for accessing the PDF file from Snowflake stages';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS.RATING 
    IS 'Analyst rating (e.g., Buy, Hold, Sell, Outperform, Market Perform) - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS.DATE_REPORT 
    IS 'Publication date of the analyst report';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS.CLOSE_PRICE 
    IS 'Stock closing price on the report date';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS.PRICE_TARGET 
    IS 'Analyst 12-month price target prediction - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS.GROWTH 
    IS 'Expected growth percentage from current price to price target';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS.NAME_OF_REPORT_PROVIDER 
    IS 'Research firm name (e.g., Goldman Sachs, Morgan Stanley) - FICTITIOUS firms in dataset';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS.DOCUMENT_TYPE 
    IS 'Type of document (e.g., Analyst Report, Research Note)';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS.DOCUMENT 
    IS 'Brief document description or title';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS.SUMMARY 
    IS 'Executive summary of the analyst report key findings - AI-generated from FICTITIOUS content';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS.FULL_TEXT 
    IS 'Complete text content extracted from the PDF using OCR/parsing';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS.URL 
    IS 'Alternative URL field for file access';

-- Table: ANALYST_REPORTS_ALL_DATA (Extended analyst report data)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS_ALL_DATA.RELATIVE_PATH 
    IS 'File path to the analyst report PDF - FICTITIOUS reports created for demo';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS_ALL_DATA.FILE_URL 
    IS 'Pre-signed URL for PDF access from Snowflake internal stages';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS_ALL_DATA.RATING 
    IS 'Analyst stock rating recommendation - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS_ALL_DATA.DATE_REPORT 
    IS 'Report publication timestamp';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS_ALL_DATA.CLOSE_PRICE 
    IS 'Stock price at market close on report date';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS_ALL_DATA.PRICE_TARGET 
    IS 'Target price prediction for next 12 months - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS_ALL_DATA.GROWTH 
    IS 'Projected growth percentage from current to target price';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS_ALL_DATA.NAME_OF_REPORT_PROVIDER 
    IS 'Investment bank or research firm name - FICTITIOUS demo firms';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS_ALL_DATA.DOCUMENT_TYPE 
    IS 'Classification of report type';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS_ALL_DATA.DOCUMENT 
    IS 'Document title or description';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS_ALL_DATA.SUMMARY 
    IS 'AI-generated executive summary from full report text - FICTITIOUS content';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.ANALYST_REPORTS_ALL_DATA.FULL_TEXT 
    IS 'Complete extracted text from PDF for full-text search and AI analysis';

-- Table: FINANCIAL_REPORTS (Quarterly earnings reports with structured data)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.FINANCIAL_REPORTS.RELATIVE_PATH 
    IS 'File path to quarterly financial report PDF - FICTITIOUS company reports';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.FINANCIAL_REPORTS.EXTRACTED_DATA 
    IS 'JSON object containing AI-extracted financial metrics (revenue, EPS, margins, etc.) - FICTITIOUS data';

-- Table: INFOGRAPHICS_FOR_SEARCH (Earnings infographics with extracted KPIs)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH.COMPANY_TICKER 
    IS 'Stock ticker symbol for the company featured in infographic - FICTITIOUS companies';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH.RELATIVE_PATH 
    IS 'File path to infographic image file (PNG format)';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH.TEXT 
    IS 'All text extracted from infographic using OCR (Optical Character Recognition)';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH.COMPANY_NAME 
    IS 'Full company name displayed on infographic - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH.TICKER 
    IS 'Stock ticker (duplicate of COMPANY_TICKER for convenience)';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH.REPORT_PERIOD 
    IS 'Fiscal quarter or period covered (e.g., Q1 2024, FY2023) - FICTITIOUS dates';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH.TOTAL_REVENUE 
    IS 'Total quarterly revenue extracted from infographic - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH.YOY_GROWTH 
    IS 'Year-over-year growth percentage - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH.PRODUCT_REVENUE 
    IS 'Revenue from product sales - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH.SERVICES_REVENUE 
    IS 'Revenue from services and subscriptions - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH.TOTAL_CUSTOMERS 
    IS 'Total customer count reported - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH.CUSTOMERS_1M_PLUS 
    IS 'Number of customers spending $1M+ annually - FICTITIOUS enterprise metric';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH.NET_REVENUE_RETENTION 
    IS 'Net revenue retention rate (key SaaS metric) - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH.GROSS_MARGIN 
    IS 'Gross profit margin percentage - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH.OPERATING_MARGIN 
    IS 'Operating profit margin percentage - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH.FREE_CASH_FLOW 
    IS 'Free cash flow amount - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH.RPO 
    IS 'Remaining Performance Obligation (contracted future revenue) - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH.RPO_GROWTH 
    IS 'Year-over-year RPO growth rate - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH.BRANDING 
    IS 'Company branding/color scheme identifier from infographic';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHICS_FOR_SEARCH.URL 
    IS 'Pre-signed URL for accessing the infographic image file';

-- Table: INFOGRAPHIC_METRICS_EXTRACTED (Raw AI extraction output)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHIC_METRICS_EXTRACTED.RELATIVE_PATH 
    IS 'File path to source infographic image';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHIC_METRICS_EXTRACTED.COMPANY_TICKER 
    IS 'Stock ticker extracted via AI - FICTITIOUS companies';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHIC_METRICS_EXTRACTED.EXTRACTED_DATA 
    IS 'JSON object with all AI-extracted financial metrics from image - FICTITIOUS data';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.INFOGRAPHIC_METRICS_EXTRACTED.BRANDING 
    IS 'Visual branding elements identified by AI (colors, logos)';

-- Table: PARSED_ANALYST_REPORTS (PDF parsing output)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.PARSED_ANALYST_REPORTS.RELATIVE_PATH 
    IS 'File path to analyst report PDF - FICTITIOUS reports';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.PARSED_ANALYST_REPORTS.EXTRACTED_DATA 
    IS 'JSON containing parsed text, tables, charts from PDF using Snowflake Cortex PARSE_DOCUMENT - FICTITIOUS content';

-- Table: AI_EXTRACT_ANALYST_REPORTS_ADVANCED (Structured AI extraction)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.AI_EXTRACT_ANALYST_REPORTS_ADVANCED.RELATIVE_PATH 
    IS 'File path to source analyst report PDF - FICTITIOUS reports';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.AI_EXTRACT_ANALYST_REPORTS_ADVANCED.EXTRACTED_DATA 
    IS 'JSON with AI-extracted structured fields (rating, price target, risks, catalysts) using Cortex AI_EXTRACT - FICTITIOUS';

-- Table: REPORT_PROVIDER_SUMMARY (Analyst firm summary data)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.REPORT_PROVIDER_SUMMARY.NAME_OF_REPORT_PROVIDER 
    IS 'Research firm or investment bank name - FICTITIOUS demo firms';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.FINANCIAL_DATA.REPORT_PROVIDER_SUMMARY.SUMMARY 
    IS 'AI-generated summary of this research firms analysis approach and coverage - FICTITIOUS';

-- =====================================================
-- EARNINGS_ANALYSIS Schema: Column Comments
-- =====================================================

-- Table: AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS (Call-level sentiment summary)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS.PRIMARY_TICKER 
    IS 'Stock ticker for the company earnings call - FICTITIOUS company data';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS.EVENT_TIMESTAMP 
    IS 'Date and time of the earnings call event - FICTITIOUS timeline';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS.EVENT_TYPE 
    IS 'Type of earnings event (e.g., Q1 Earnings, Annual Investor Day)';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS.CREATED_AT 
    IS 'Timestamp when transcript was processed and sentiment analyzed';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS.SENTIMENT_SCORE 
    IS 'Overall sentiment score from -1 (negative) to +1 (positive) for entire call - AI-generated from FICTITIOUS transcripts';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS.UNIQUE_ANALYST_COUNT 
    IS 'Number of unique analysts who asked questions during Q&A - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS.SENTIMENT_REASON 
    IS 'AI-generated explanation of sentiment drivers (key topics, tone) - FICTITIOUS reasoning';

-- Table: TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT (Segment-level transcripts)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT.RELATIVE_PATH 
    IS 'File path to source audio file (MP3) for earnings call - FICTITIOUS audio';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT.SPEAKER 
    IS 'Speaker identifier code assigned by AI (e.g., SPEAKER_00, SPEAKER_01)';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT.SPEAKER_NAME 
    IS 'Mapped speaker name (e.g., CEO, CFO, Analyst-JPMorgan) - FICTITIOUS names';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT.AUDIO_DURATION_SECONDS 
    IS 'Total duration of the audio file in seconds';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT.START_TIME 
    IS 'Segment start timestamp in seconds from beginning of audio';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT.END_TIME 
    IS 'Segment end timestamp in seconds from beginning of audio';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT.SEGMENT_TEXT 
    IS 'Transcribed text for this time segment - AI-generated from FICTITIOUS audio';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT.SENTIMENT 
    IS 'Sentiment score for this specific segment (-1 to +1) - AI-analyzed from FICTITIOUS content';

-- Table: TRANSCRIPTS_BY_MINUTE (Minute-aggregated transcripts)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.TRANSCRIPTS_BY_MINUTE.RELATIVE_PATH 
    IS 'File path to source earnings call audio file - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.TRANSCRIPTS_BY_MINUTE.SPEAKER 
    IS 'Speaker identifier for this minute of audio';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.TRANSCRIPTS_BY_MINUTE.SPEAKER_NAME 
    IS 'Mapped speaker name (executive title or analyst firm) - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.TRANSCRIPTS_BY_MINUTE.MINUTES 
    IS 'Minute number since start of call (0, 1, 2, ...) for time-series analysis';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.TRANSCRIPTS_BY_MINUTE.SENTIMENT 
    IS 'Average sentiment for all segments within this minute - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.TRANSCRIPTS_BY_MINUTE.TEXT 
    IS 'Concatenated transcript text for all segments in this minute - FICTITIOUS';

-- Table: SENTIMENT_ANALYSIS (Multi-dimensional sentiment)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.SENTIMENT_ANALYSIS.RELATIVE_PATH 
    IS 'File path to earnings call audio file - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.SENTIMENT_ANALYSIS.SENTIMENT 
    IS 'Categorical sentiment label (Positive, Negative, Neutral) - AI-classified from FICTITIOUS transcripts';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.SENTIMENT_ANALYSIS.OVERALL 
    IS 'Overall sentiment score across all dimensions - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.SENTIMENT_ANALYSIS.COST 
    IS 'Sentiment score specific to cost and expense discussions (-100 to +100) - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.SENTIMENT_ANALYSIS.INNOVATION 
    IS 'Sentiment score for innovation and R&D topics - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.SENTIMENT_ANALYSIS.PRODUCTIVITY 
    IS 'Sentiment score regarding operational efficiency and productivity - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.SENTIMENT_ANALYSIS.COMPETITIVENESS 
    IS 'Sentiment score about competitive positioning and market share - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.SENTIMENT_ANALYSIS.CONSUMPTION 
    IS 'Sentiment score related to customer demand and consumption trends - FICTITIOUS';

-- Table: unique_transcripts (Full transcript storage)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.unique_transcripts.primary_ticker 
    IS 'Stock ticker symbol for the company - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.unique_transcripts.event_timestamp 
    IS 'Earnings call date and time - FICTITIOUS timeline';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.unique_transcripts.event_type 
    IS 'Type of event (Quarterly Earnings, Annual Meeting, etc.)';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.unique_transcripts.created_at 
    IS 'Timestamp when transcript record was created';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.unique_transcripts.transcript 
    IS 'Complete earnings call transcript in JSON format with speaker turns - FICTITIOUS content';

-- Table: TRANSCRIBED_EARNINGS_CALLS (Raw AI transcription output)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.TRANSCRIBED_EARNINGS_CALLS.RELATIVE_PATH 
    IS 'File path to earnings call audio MP3 file - FICTITIOUS audio files';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.TRANSCRIBED_EARNINGS_CALLS.EXTRACTED_DATA 
    IS 'JSON containing raw Snowflake Cortex TRANSCRIBE output with segments and timestamps - FICTITIOUS transcriptions';

-- Table: SPEAKER_MAPPING (Speaker identification lookup)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.SPEAKER_MAPPING.RELATIVE_PATH 
    IS 'File path to earnings call audio file';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.SPEAKER_MAPPING.SPEAKER 
    IS 'AI-assigned speaker code (SPEAKER_00, SPEAKER_01, etc.) from transcription';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.SPEAKER_MAPPING.SPEAKER_NAME 
    IS 'Human-readable speaker name mapped from voice analysis (CEO, CFO, Analyst Name) - FICTITIOUS executives';

-- Table: AI_TRANSCRIBE_NO_TIME (Timestamp-free transcripts)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.AI_TRANSCRIBE_NO_TIME.RELATIVE_PATH 
    IS 'File path to earnings call audio file - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.AI_TRANSCRIBE_NO_TIME.TEXT 
    IS 'Complete transcript text without timestamp metadata for summarization tasks - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.AI_TRANSCRIBE_NO_TIME.DURATION 
    IS 'Total audio duration in seconds';

-- Table: call_embeds (Chunked transcripts for RAG)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.call_embeds.RELATIVE_PATH 
    IS 'File path to source earnings call audio - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.call_embeds.SUMMARY 
    IS 'AI-generated summary of this transcript chunk - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.call_embeds.TEXT 
    IS 'Transcript text chunk (500-1000 words) for embedding-based search - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.call_embeds.SENTIMENT 
    IS 'Categorical sentiment (Positive/Negative/Neutral) for chunk - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.call_embeds.SENTIMENT_SCORE 
    IS 'Numeric sentiment score (-1 to +1) for this chunk - FICTITIOUS';

-- Table: FULL_TRANSCRIPTS (Complete transcripts with AI summaries for search)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.FULL_TRANSCRIPTS.RELATIVE_PATH 
    IS 'File path to earnings call audio file - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.FULL_TRANSCRIPTS.SUMMARY 
    IS 'AI-generated executive summary highlighting key topics, metrics, and Q&A - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.FULL_TRANSCRIPTS.TEXT 
    IS 'Complete verbatim transcript text of entire earnings call - FICTITIOUS content';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.FULL_TRANSCRIPTS.SENTIMENT 
    IS 'Categorical sentiment (Positive/Negative/Neutral) for entire call - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.FULL_TRANSCRIPTS.SENTIMENT_SCORE 
    IS 'Numeric sentiment score (-1 to +1) for entire call - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.EARNINGS_ANALYSIS.FULL_TRANSCRIPTS.URL 
    IS 'Pre-signed URL for accessing the audio file (expires after 7 days, refreshed by scheduled task)';

-- =====================================================
-- COMMUNICATIONS Schema: Column Comments
-- =====================================================

-- Table: EMAIL_PREVIEWS (Raw email data)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.EMAIL_PREVIEWS.EMAIL_ID 
    IS 'Unique email identifier (EMAIL_001 to EMAIL_950) - FICTITIOUS emails';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.EMAIL_PREVIEWS.RECIPIENT_EMAIL 
    IS 'Recipient email address (investor/analyst address) - FICTITIOUS addresses';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.EMAIL_PREVIEWS.SUBJECT 
    IS 'Email subject line - FICTITIOUS analyst communication subjects';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.EMAIL_PREVIEWS.HTML_CONTENT 
    IS 'Full email body in HTML format with formatting and embedded content - FICTITIOUS emails';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.EMAIL_PREVIEWS.CREATED_AT 
    IS 'Email creation timestamp - FICTITIOUS timeline spanning 2024';

-- Table: EMAIL_PREVIEWS_EXTRACTED (AI-extracted email metadata)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.EMAIL_PREVIEWS_EXTRACTED.EMAIL_ID 
    IS 'Unique email identifier linking to EMAIL_PREVIEWS table - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.EMAIL_PREVIEWS_EXTRACTED.RECIPIENT_EMAIL 
    IS 'Recipient email address - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.EMAIL_PREVIEWS_EXTRACTED.SUBJECT 
    IS 'Email subject line - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.EMAIL_PREVIEWS_EXTRACTED.HTML_CONTENT 
    IS 'Full HTML email body - FICTITIOUS content';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.EMAIL_PREVIEWS_EXTRACTED.CREATED_AT 
    IS 'Email timestamp - FICTITIOUS dates';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.EMAIL_PREVIEWS_EXTRACTED.TICKER 
    IS 'Stock ticker mentioned in email (AI-extracted) - FICTITIOUS companies';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.EMAIL_PREVIEWS_EXTRACTED.RATING 
    IS 'Investment rating mentioned (Buy/Hold/Sell) extracted via AI - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.EMAIL_PREVIEWS_EXTRACTED.SENTIMENT 
    IS 'Email sentiment (Positive/Negative/Neutral) analyzed by AI - FICTITIOUS';

-- Table: SOCIAL_MEDIA_NRNT (Social media crisis timeline)
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SOCIAL_MEDIA_NRNT.TIMESTAMP 
    IS 'Post publication date and time - FICTITIOUS timeline (Aug-Dec 2024) for NRNT collapse story';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SOCIAL_MEDIA_NRNT.PLATFORM 
    IS 'Social media platform (Twitter/X, LinkedIn, News Article, Blog, Reddit)';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SOCIAL_MEDIA_NRNT.AUTHOR_HANDLE 
    IS 'Username or handle of post author - FICTITIOUS accounts';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SOCIAL_MEDIA_NRNT.AUTHOR_TYPE 
    IS 'Account type (Consumer, Company, Competitor, Media, Analyst, Regulator) - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SOCIAL_MEDIA_NRNT.COMPANY_AFFILIATION 
    IS 'Company mentioned (NRNT, SNOW, VLTA, or None) - NRNT is FICTITIOUS company';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SOCIAL_MEDIA_NRNT.TEXT 
    IS 'Full post text content in original language - FICTITIOUS posts about NRNT crisis';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SOCIAL_MEDIA_NRNT.SENTIMENT 
    IS 'Sentiment score (-1 to +1) analyzing post tone - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SOCIAL_MEDIA_NRNT.LIKES 
    IS 'Number of likes/reactions on post - FICTITIOUS engagement metrics';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SOCIAL_MEDIA_NRNT.RETWEETS 
    IS 'Number of shares/retweets/reposts - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SOCIAL_MEDIA_NRNT.REPLIES 
    IS 'Number of comment replies - FICTITIOUS';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SOCIAL_MEDIA_NRNT.HASHTAGS 
    IS 'Comma-separated hashtags from post (e.g., #NRNT, #TechCollapse)';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SOCIAL_MEDIA_NRNT.LOCATION 
    IS 'City where post was authored (31 global cities represented)';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SOCIAL_MEDIA_NRNT.COUNTRY 
    IS 'Country of post origin (US, France, China, UK, etc.)';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SOCIAL_MEDIA_NRNT.LANGUAGE 
    IS 'Post language (English, French, Chinese) - FICTITIOUS multilingual content';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SOCIAL_MEDIA_NRNT.LATITUDE 
    IS 'Geographic latitude coordinate for mapping post origins';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SOCIAL_MEDIA_NRNT.LONGITUDE 
    IS 'Geographic longitude coordinate for mapping post origins';
COMMENT ON COLUMN {{ env.HACKATHON_DATABASE }}.COMMUNICATIONS.SOCIAL_MEDIA_NRNT.IMAGE_FILENAME 
    IS 'Filename of attached image if post includes media (NULL if text-only)';

-- =====================================================
-- CORPORATE_DOCS Schema: Stage Comments
-- =====================================================
-- Note: Stages contain files, not structured columns, so only stage-level comments apply

COMMENT ON STAGE {{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.ANNUAL_REPORTS 
    IS '22 annual report PDFs (FY2024 + FY2025) with financial charts and narrative - FICTITIOUS company reports for demo purposes';

COMMENT ON STAGE {{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.EXECUTIVE_BIOS 
    IS '11 executive biography PDFs with career history and leadership profiles - FICTITIOUS executives';

COMMENT ON STAGE {{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.EXECUTIVE_PORTRAITS 
    IS '~30 AI-generated executive portrait images (professional headshots) - FICTITIOUS people';

COMMENT ON STAGE {{ env.HACKATHON_DATABASE }}.CORPORATE_DOCS.interviews 
    IS '1 MP3 audio file: NRNT CEO post-collapse interview discussing company failure - FICTITIOUS interview';

-- =====================================================
-- INVESTMENT_RESEARCH Schema: Stage Comments
-- =====================================================
-- Note: Investment research papers are REAL, publicly available documents

COMMENT ON STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.investment_management 
    IS 'Federal Reserve and NBER research papers on portfolio management strategies - ✅ REAL publicly available research';

COMMENT ON STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.esg_investing 
    IS 'UN PRI, MSCI, and SASB ESG investment frameworks and sustainability reports - ✅ REAL public documents from authoritative sources';

COMMENT ON STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.risk_management 
    IS 'BIS Basel Committee stress testing principles and Fed regulatory risk frameworks - ✅ REAL central bank publications';

COMMENT ON STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.portfolio_strategy 
    IS 'CFA Institute, NBER, and Federal Reserve papers on asset allocation and portfolio theory - ✅ REAL academic/industry research';

COMMENT ON STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.market_research 
    IS 'IMF, World Bank, and ECB economic research and financial stability reports - ✅ REAL international organization publications';

COMMENT ON STAGE {{ env.HACKATHON_DATABASE }}.INVESTMENT_RESEARCH.quantitative_methods 
    IS 'ArXiv quantitative finance papers on algorithmic trading, ML for finance, and portfolio optimization - ✅ REAL open-access research papers';

-- =====================================================
-- Final Verification and Summary
-- =====================================================

SELECT '✅ Hackathon database ready for use!' AS final_status;
SELECT '📁 Data organized into 5 meaningful schemas:' AS organization_message
UNION ALL SELECT '  • FINANCIAL_DATA: Stock prices, analyst reports, financial statements'
UNION ALL SELECT '  • EARNINGS_ANALYSIS: Audio transcripts, sentiment analysis'
UNION ALL SELECT '  • CORPORATE_DOCS: Annual reports, executive bios, interviews'
UNION ALL SELECT '  • COMMUNICATIONS: Emails and social media'
UNION ALL SELECT '  • INVESTMENT_RESEARCH: Academic research papers';

