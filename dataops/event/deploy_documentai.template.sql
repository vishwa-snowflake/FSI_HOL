ALTER SESSION SET QUERY_TAG = '''{"origin":"sf_sit-is", "name":"Build an AI Assistant for FSI using AISQL and Snowflake Intelligence", "version":{"major":1, "minor":0},"attributes":{"is_quickstart":0, "source":"sql"}}''';
use role ACCOUNTADMIN;
GRANT DATABASE ROLE SNOWFLAKE.DOCUMENT_INTELLIGENCE_CREATOR TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};


use role {{ env.EVENT_ATTENDEE_ROLE }};


GRANT CREATE snowflake.ml.document_intelligence on schema {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }} to role {{ env.EVENT_ATTENDEE_ROLE }};
GRANT CREATE MODEL ON SCHEMA {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }} TO ROLE {{ env.EVENT_ATTENDEE_ROLE }};

CREATE OR REPLACE STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.analyst_reports
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse');


PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/document_ai/synthetic_analyst_reports/*.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.analyst_reports auto_compress = false overwrite = true;

ALTER STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.analyst_reports REFRESH;

CREATE OR REPLACE STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.earnings_calls
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse');

PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/sound_files/*.mp3 @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.earnings_calls auto_compress = false overwrite = true;

ALTER STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.earnings_calls REFRESH;

CREATE OR REPLACE STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.financial_reports
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse');

-- Upload simplified financial reports optimized for AI_EXTRACT table extraction
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/document_ai/financial_reports_pdf_simple/*.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.financial_reports auto_compress = false overwrite = true;

ALTER STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.financial_reports REFRESH;

CREATE OR REPLACE STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.infographics
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse');

-- Upload infographic PNG files for all 8 companies
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/document_ai/infographics_simple/*.png @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.infographics auto_compress = false overwrite = true;

ALTER STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.infographics REFRESH;

-- =====================================================
-- Investment Management Documents Stage
-- =====================================================
-- Stage for authoritative investment management research papers
-- Sources: Federal Reserve Board, NBER
-- Topics: Portfolio management, asset allocation, risk management, ESG investing
-- =====================================================

CREATE OR REPLACE STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.investment_management
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = 'Investment management research papers from Federal Reserve and NBER - portfolio optimization, asset allocation, risk management, ESG investing';

-- Upload investment management PDF documents
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/DATA/investment_management_docs/*.pdf 
    @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.investment_management 
    auto_compress = false 
    overwrite = true;

ALTER STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.investment_management REFRESH;

-- Verify uploaded files
LIST @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.investment_management;

-- =====================================================
-- Annual Reports Stage (FY2024 and FY2025)
-- =====================================================
-- Stage for comprehensive annual reports with charts
-- Includes 22 PDFs: 11 companies × 2 fiscal years
-- Features: Financial highlights, competitive analysis, NRNT collapse narrative
-- =====================================================

CREATE OR REPLACE STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = 'Annual Reports FY2024 and FY2025 - 11 companies with financial data, charts, competitive analysis, and NRNT collapse storyline';

-- Upload FY2025 Annual Reports (11 comprehensive reports with charts)
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/SNOW_Annual_Report_FY2025.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2025/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/NRNT_Liquidation_Report_FY2025.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2025/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/ICBG_Annual_Report_FY2025.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2025/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/QRYQ_Annual_Report_FY2025.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2025/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/DFLX_Annual_Report_FY2025.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2025/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/STRM_Annual_Report_FY2025.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2025/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/VLTA_Annual_Report_FY2025.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2025/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/CTLG_Annual_Report_FY2025.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2025/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/PROP_Annual_Report_FY2025.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2025/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/GAME_Annual_Report_FY2025.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2025/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/MKTG_Annual_Report_FY2025.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2025/ auto_compress = false overwrite = true;

-- Upload FY2024 Annual Reports (11 pre-collapse reports)
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/SNOW_Annual_Report_FY2024.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2024/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/NRNT_Annual_Report_FY2024.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2024/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/ICBG_Annual_Report_FY2024.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2024/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/QRYQ_Annual_Report_FY2024.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2024/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/DFLX_Annual_Report_FY2024.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2024/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/STRM_Annual_Report_FY2024.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2024/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/VLTA_Annual_Report_FY2024.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2024/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/CTLG_Annual_Report_FY2024.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2024/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/PROP_Annual_Report_FY2024.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2024/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/GAME_Annual_Report_FY2024.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2024/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/annual_reports_pdfs/MKTG_Annual_Report_FY2024.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS/FY2024/ auto_compress = false overwrite = true;

ALTER STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS REFRESH;

-- Verify annual reports uploaded
LIST @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.ANNUAL_REPORTS;

-- =====================================================
-- Executive Team Bios Stage
-- =====================================================
-- Stage for executive leadership team biographies with AI-generated portraits
-- Includes 11 PDFs: One per company with all executives
-- Features: Professional bios, experience, achievements, AI-generated headshots
-- =====================================================

CREATE OR REPLACE STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_BIOS
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = 'Executive team biographies with AI-generated portraits - Leadership bios for all 11 companies (~30 executives total)';

-- Upload Executive Team Bio PDFs
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/executive_bios/SNOW_Executive_Team.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_BIOS/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/executive_bios/NRNT_Executive_Team.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_BIOS/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/executive_bios/ICBG_Executive_Team.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_BIOS/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/executive_bios/QRYQ_Executive_Team.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_BIOS/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/executive_bios/DFLX_Executive_Team.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_BIOS/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/executive_bios/STRM_Executive_Team.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_BIOS/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/executive_bios/VLTA_Executive_Team.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_BIOS/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/executive_bios/CTLG_Executive_Team.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_BIOS/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/executive_bios/PROP_Executive_Team.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_BIOS/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/executive_bios/GAME_Executive_Team.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_BIOS/ auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/executive_bios/MKTG_Executive_Team.pdf @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_BIOS/ auto_compress = false overwrite = true;

ALTER STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_BIOS REFRESH;

-- Verify executive bios uploaded
LIST @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_BIOS;

-- =====================================================
-- Executive Portraits Stage
-- =====================================================
-- Stage for AI-generated executive headshot portraits
-- Organized by company directory for easy browsing
-- Features: Gemini-generated professional headshots (~30 executives)
-- =====================================================

CREATE OR REPLACE STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_PORTRAITS
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = 'AI-generated executive portraits organized by company - Professional headshots for ~30 executives across 11 companies';

-- Upload Executive Portraits (preserving company directory structure)
-- SNOW
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/portraits/SNOW/*.* @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_PORTRAITS/SNOW/ auto_compress = false overwrite = true;

-- NRNT
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/portraits/NRNT/*.* @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_PORTRAITS/NRNT/ auto_compress = false overwrite = true;

-- ICBG
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/portraits/ICBG/*.* @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_PORTRAITS/ICBG/ auto_compress = false overwrite = true;

-- QRYQ
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/portraits/QRYQ/*.* @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_PORTRAITS/QRYQ/ auto_compress = false overwrite = true;

-- DFLX
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/portraits/DFLX/*.* @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_PORTRAITS/DFLX/ auto_compress = false overwrite = true;

-- STRM
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/portraits/STRM/*.* @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_PORTRAITS/STRM/ auto_compress = false overwrite = true;

-- VLTA
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/portraits/VLTA/*.* @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_PORTRAITS/VLTA/ auto_compress = false overwrite = true;

-- CTLG
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/portraits/CTLG/*.* @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_PORTRAITS/CTLG/ auto_compress = false overwrite = true;

-- PROP
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/portraits/PROP/*.* @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_PORTRAITS/PROP/ auto_compress = false overwrite = true;

-- GAME
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/portraits/GAME/*.* @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_PORTRAITS/GAME/ auto_compress = false overwrite = true;

-- MKTG
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/portraits/MKTG/*.* @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_PORTRAITS/MKTG/ auto_compress = false overwrite = true;

ALTER STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_PORTRAITS REFRESH;

-- Verify executive portraits uploaded
LIST @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.EXECUTIVE_PORTRAITS;

-- =====================================================
-- Interviews Stage
-- =====================================================
-- Stage for executive interviews and special content
-- Features: NRNT CEO post-collapse interview, investigative journalism pieces
-- Format: MP3 audio files for AI_TRANSCRIBE processing
-- =====================================================

CREATE OR REPLACE STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.INTERVIEWS
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = 'Executive interviews and investigative journalism - MP3 audio files including NRNT CEO post-collapse interview';

-- Upload Interview Audio Files
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/interviews/*.mp3 @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.INTERVIEWS/ auto_compress = false overwrite = true;

ALTER STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.INTERVIEWS REFRESH;

-- Verify interviews uploaded
LIST @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.INTERVIEWS;

-- =====================================================
-- SOCIAL MEDIA IMAGES STAGE
-- =====================================================
-- Purpose: Store product/user-generated images referenced in social media posts
-- Content: 7 PNG images showing complete NRNT lifecycle from hype to bankruptcy
-- Usage: Can be linked to SOCIAL_MEDIA_NRNT table via IMAGE_FILENAME column
-- Timeline & Images:
--   EARLY HYPE (Aug-Sept 2024):
--     - dev_team_icecream.png (teams using product)
--     - eating_icecream.png (general consumption)
--     - icecream_brainfog_gone.png (before/after success)
--     - neuro_icecream.png (product shots)
--   CRISIS (Sept-Nov 2024):
--     - icecream_in_landfill_recall.png (waste/recall/side effects)
--     - chinese_man_not_happy_angry_icecream.png (VIRAL STORY: Chinese man's mother hospitalized)
--   COLLAPSE & AFTERMATH (Nov-Dec 2024):
--     - ceo_neuro_nectar_leaving_office_gone_bust.png (bankruptcy/executive departure)
-- Viral Story: ~83 posts reference Chinese man who bought NRNT for his elderly mother's
--   memory issues; she developed brain damage + gastric problems and was hospitalized.
--   Story went viral during crisis period, shared/reposted extensively.
-- =====================================================

CREATE OR REPLACE STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.SOCIAL_MEDIA_IMAGES
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = 'Social media images - 7 PNG files showing complete NRNT narrative arc including viral Chinese mother story (~338 posts with images, visual story of rise and fall)';

-- Upload social media images
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/social_media_images/*.* @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.SOCIAL_MEDIA_IMAGES/ auto_compress = false overwrite = true;

ALTER STAGE {{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.SOCIAL_MEDIA_IMAGES REFRESH;

-- Verify images uploaded
LIST @{{ env.EVENT_DATABASE }}.{{ env.DOCUMENT_AI_SCHEMA }}.SOCIAL_MEDIA_IMAGES;