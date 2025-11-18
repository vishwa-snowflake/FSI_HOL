# Archive Folder

This folder contains development artifacts, logs, and temporary files that were created during the development and testing of the FSI Cortex Assistant.

## Folder Structure

### `/logs`
Contains all log files from development and testing:
- `snowsql_rt.log*` - SnowSQL runtime logs
- Other execution logs

### `/docs`
Informational and summary markdown files documenting various fixes and deployments:
- `AUDIO_TRANSCRIPTION_DEPLOYMENT.md`
- `DATA_SUMMARY.md`
- `EARNINGS_CALLS_SUMMARY.md`
- `EXTERNAL_ACCESS_FINAL_FIX.md`
- `EXTERNAL_ACCESS_INTEGRATION_FIXED.md`
- `INTEGRATIONS_COMPLETE.md`
- `ML_ELEMENT_DATABASE_FIX.md`
- `ML_ELEMENT_FILE_CONFLICT_RESOLVED.md`
- `NOTEBOOK_OWNERSHIP_CONFIGURED.md`
- `NOTEBOOK_RUNTIME_INVESTIGATION.md`
- `PIPELINE_DEPENDENCY_CHAIN_FIXED.md`
- `PIPELINE_INTEGRATION_COMPLETE.md`
- `PIPELINE_PERMISSIONS_FIXED.md`
- `SEARCH_SERVICES_ADDED.md` - Documentation of search services integration
- `SNOWMAIL_GRANTS_VERIFIED.md`
- `SYNTHETIC_COMPANIES.md`
- `TEST_RESULTS_SUCCESS.md`
- `stock_narrative_summary.md`
- `COMPANIES_STORIES_SUMMARY.md`
- `SENTIMENT_VARIATION_SUMMARY.md`
- `TICKER_MAPPING.md`
- `TOP_BOTTOM_PERFORMERS_UPDATE.md`
- `TRANSCRIPT_ENHANCEMENT_SUMMARY.md`

### `/scripts`
Debug, test, and export scripts used during development:
- `debug_directory.sql` - Directory debugging queries
- `test_data_foundation.sql` - Test script for data foundation
- `GET_ALL_DDLS.sql` - Script to extract DDLs from production
- `get_semantic_view_table_ddls.sql` - Extract semantic view DDLs
- `get_table_ddls*.sh` - Shell scripts for DDL extraction
- `get_table_ddls.py` - Python script for DDL extraction
- `export_all_data_for_semantic_views.sql` - Data export queries
- `semantic_view_tables_ddls.sql` - Generated DDL statements
- `reload_unique_transcripts_manual.sql` - Manual reload script

### `/DATA_backups`
Backup copies of CSV files and temporary scripts from DATA folder:
- `*.backup*` - All backup CSV files with timestamps
- `*.py` - Temporary Python scripts (convert_json_to_csv.py, etc.)
- `companies.csv` - Backup company data
- `fsi_data.csv` - Large FSI dataset backup
- Additional CSV backups created during development

## Purpose

These files are preserved for reference but are not needed for production deployment. The production-ready files are:
- All `*.template.sql` files in the parent directory
- CSV files in the `/DATA` directory (without .backup extensions)
- Configuration YAML files
- Application folders (analyst, document_ai, homepage, notebooks, streamlit, etc.)

## Cleanup

This archive was created to declutter the repository while preserving development history. Files can be safely deleted if not needed for reference.

**Archive Created**: October 29, 2025

