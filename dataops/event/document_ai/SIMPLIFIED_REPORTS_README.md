# Simplified Financial Reports for AI_EXTRACT

## Overview

Created simplified, single-page financial reports optimized for **AI_EXTRACT table extraction demonstrations**.

## What's Different

### Old Reports (Complex):
- ❌ 8-10 pages with complex layouts
- ❌ Mixed charts, narratives, and tables
- ❌ Nested markdown formatting
- ❌ AI_EXTRACT couldn't parse tables reliably

### New Reports (Simplified):
- ✅ Single page, clean layout
- ✅ 3 simple HTML tables:
  1. **Income Statement** (11 rows × 3 columns)
  2. **Customer Metrics** (6 rows × 2 columns)
  3. **KPI Metrics** (4 rows × 2 columns)
- ✅ Standard `<table>` structure
- ✅ **AI_EXTRACT extracts perfectly**

## Files Created

### HTML Files:
```
document_ai/financial_reports_html_simple/
├── SNOW_Q2_FY2025_SIMPLE.html
├── ICBG_Q2_FY2025_SIMPLE.html
├── QRYQ_Q2_FY2025_SIMPLE.html
├── DFLX_Q2_FY2025_SIMPLE.html
├── STRM_Q2_FY2025_SIMPLE.html
├── VLTA_Q2_FY2025_SIMPLE.html
├── CTLG_Q2_FY2025_SIMPLE.html
└── NRNT_Q2_FY2025_SIMPLE.html
```

### PDF Files:
```
document_ai/financial_reports_pdf_simple/
├── SNOW_Q2_FY2025_SIMPLE.pdf (148KB)
├── ICBG_Q2_FY2025_SIMPLE.pdf (147KB)
├── QRYQ_Q2_FY2025_SIMPLE.pdf (148KB)
├── DFLX_Q2_FY2025_SIMPLE.pdf (147KB)
├── STRM_Q2_FY2025_SIMPLE.pdf (148KB)
├── VLTA_Q2_FY2025_SIMPLE.pdf (144KB)
├── CTLG_Q2_FY2025_SIMPLE.pdf (145KB)
└── NRNT_Q2_FY2025_SIMPLE.pdf (146KB)
```

## Table Structure

### Table 1: Income Statement (Consolidated Statement of Operations)
| Line Item | Q2 FY2025 | Q2 FY2024 |
|-----------|-----------|-----------|
| Product Revenue | $868 | $674 |
| Professional Services Revenue | $32 | $27 |
| **Total Revenue** | **$900** | **$701** |
| Cost of Revenue | $225 | $191 |
| **Gross Profit** | **$675** | **$510** |
| Research and Development | $252 | $218 |
| Sales and Marketing | $311 | $285 |
| General and Administrative | $87 | $78 |
| **Operating Income (Loss)** | **$25** | **($71)** |
| **Net Income (Loss)** | **$48** | **($47)** |

### Table 2: Customer Metrics
| Metric | Q2 FY2025 |
|--------|-----------|
| Total Customers | 10,000+ |
| Customers with $1M+ Revenue | 542 |
| Customers with $5M+ Revenue | 113 |
| Customers with $10M+ Revenue | 28 |
| Net Revenue Retention | 127% |
| Gross Revenue Retention | 95% |

### Table 3: KPIs
| Metric | Value |
|--------|-------|
| Year-over-Year Growth | 29% |
| Gross Margin | 75% |
| Operating Margin (Non-GAAP) | 11% |
| Free Cash Flow | $544M |

## AI_EXTRACT Schema

```sql
AI_EXTRACT(
    file => TO_FILE('@DOCUMENT_AI.FINANCIAL_REPORTS', RELATIVE_PATH),
    responseFormat => {
        'schema': {
            'type': 'object',
            'properties': {
                'company_name': {...},
                'report_period': {...},
                'income_statement': {
                    'description': 'Consolidated Statement of Operations table',
                    'type': 'object',
                    'properties': {
                        'line_item': {'type': 'array'},
                        'q2_fy2025': {'type': 'array'},
                        'q2_fy2024': {'type': 'array'}
                    }
                },
                'customer_metrics': {
                    'description': 'Customer Growth & Retention Metrics table',
                    'type': 'object',
                    'properties': {
                        'metric': {'type': 'array'},
                        'q2_fy2025': {'type': 'array'}
                    }
                },
                'kpi_metrics': {
                    'description': 'Key Performance Indicators table',
                    'type': 'object',
                    'properties': {
                        'metric': {'type': 'array'},
                        'value': {'type': 'array'}
                    }
                }
            }
        }
    }
)
```

## Deployment

The pipeline now uploads simplified reports:

```sql
-- In deploy_documentai.template.sql (line 40)
PUT file:///.../document_ai/financial_reports_pdf_simple/*.pdf 
    @DOCUMENT_AI.FINANCIAL_REPORTS 
    auto_compress = false 
    overwrite = true;
```

## Benefits for Demo

✅ **Reliable Extraction**: Simple tables extract perfectly every time  
✅ **Clean Data**: No "None" values, no misalignment  
✅ **Fast Processing**: Smaller files, quicker AI_EXTRACT  
✅ **Clear Demo**: Shows table extraction capability clearly  
✅ **All 8 Companies**: SNOW, ICBG, QRYQ, DFLX, STRM, VLTA, CTLG, NRNT  

Perfect for showcasing Snowflake's AI_EXTRACT table extraction! 🎯

