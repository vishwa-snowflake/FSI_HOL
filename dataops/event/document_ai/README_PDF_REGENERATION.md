# PDF Regeneration with WeasyPrint

This setup ensures all Sterling Partners PDFs have consistent text extraction for Snowflake AI_EXTRACT.

## Quick Start

```bash
cd /Users/boconnor/fsi-cortex-assistant/dataops/event/document_ai
chmod +x setup_env_and_regenerate.sh
./setup_env_and_regenerate.sh
```

## What This Does

1. **Creates Virtual Environment**: Sets up isolated Python environment
2. **Installs WeasyPrint**: Installs PDF generation library with dependencies
3. **Regenerates PDFs**: Converts all Sterling Partners HTML reports to PDF with proper text layers
4. **Validates**: Checks that PDFs were created successfully

## Requirements

- Python 3.8 or higher
- macOS (Cairo graphics library pre-installed)

## Output

All PDFs will be regenerated in:
```
synthetic_analyst_reports/
  - Sterling_Partners_Report_2024-08-22.pdf
  - Sterling_Partners_Report_2024-09-25.pdf
  - Sterling_Partners_Report_2024-11-22.pdf
  - Sterling_Partners_Report_2025-02-22.pdf
  - Sterling_Partners_Report_2025-05-23.pdf
```

## Why This Fixes The Issue

The September 25th PDF had SVG graphics that caused text extraction issues. WeasyPrint ensures:

✅ **Consistent Text Layer**: All text is extractable by PARSE_DOCUMENT  
✅ **Proper Font Embedding**: Header text ("Sterling Partners") is always readable  
✅ **SVG Support**: Graphics render without breaking text extraction  
✅ **Optimized Size**: PDFs are optimized but maintain text quality  

## Troubleshooting

### If you get "Cairo not found" error:
```bash
# Install Cairo (if needed on macOS)
brew install cairo pango gdk-pixbuf libffi
```

### If Python packages fail to install:
```bash
# Upgrade pip first
python3 -m pip install --upgrade pip
```

### Manual regeneration:
```bash
source venv/bin/activate
python3 regenerate_sterling_partners_pdfs.sh
deactivate
```

## After Regeneration

Run your AI_EXTRACT queries in Snowflake:
```sql
-- Test that Sterling Partners is now extracted properly
SELECT 
    RELATIVE_PATH,
    NAME_OF_REPORT_PROVIDER,
    RATING,
    DATE_REPORT
FROM DOCUMENT_AI.AI_EXTRACT_REPORTS_STRUCTURED_ADVANCED
WHERE NAME_OF_REPORT_PROVIDER LIKE '%Sterling%'
ORDER BY DATE_REPORT;
```

All reports should now show "Sterling Partners" as the provider! ✨

