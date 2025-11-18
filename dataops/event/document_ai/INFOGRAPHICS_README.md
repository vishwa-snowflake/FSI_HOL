# Simplified Infographics for All 8 Core Companies

## Overview

Created beautiful, AI_EXTRACT-friendly infographics for all 8 core companies based on Q2 FY2025 earnings data.

## Files Created

### PNG Infographics (1400x900px):
```
infographics_simple/
├── SNOW_Earnings_Infographic_FY25-Q2.png (550KB)
├── ICBG_Earnings_Infographic_FY25-Q2.png (398KB)
├── QRYQ_Earnings_Infographic_FY25-Q2.png (416KB)
├── DFLX_Earnings_Infographic_FY25-Q2.png (351KB)
├── STRM_Earnings_Infographic_FY25-Q2.png (480KB)
├── VLTA_Earnings_Infographic_FY25-Q2.png (469KB)
├── CTLG_Earnings_Infographic_FY25-Q2.png (515KB)
└── NRNT_Earnings_Infographic_FY25-Q2.png (411KB)
```

## Design Features

### Visual Branding
Each company has its unique color scheme:
- **SNOW**: Blue gradient (#29B5E8 → #1E3A8A)
- **ICBG**: Cyan (#00BCD4 → #006064)
- **QRYQ**: Orange/Red (#FF5722 → #D84315)
- **DFLX**: Green (#4CAF50 → #2E7D32)
- **STRM**: Indigo/Purple (#3F51B5 → #7C4DFF)
- **VLTA**: Yellow (#FDD835 → #F57F17)
- **CTLG**: Blue-Gray (#37474F → #607D8B)
- **NRNT**: Purple/Pink (#9C27B0 → #E91E63)

### Content Layout (All Infographics Include)

1. **Header Section**
   - Company name and ticker
   - Tagline
   - Report period and date

2. **Key Metrics Grid** (4 boxes)
   - Total Revenue
   - Gross Margin
   - Total Customers  
   - Net Revenue Retention

3. **Revenue Breakdown Table**
   - Product Revenue (Q2 FY2025 vs Q2 FY2024)
   - Professional Services (Q2 FY2025 vs Q2 FY2024)
   - Total Revenue with YoY Growth

4. **Key Metrics Table**
   - Operating Margin (Non-GAAP)
   - Free Cash Flow
   - Customers with $1M+ Revenue
   - Remaining Performance Obligations
   - RPO Growth (YoY)

## AI_EXTRACT Schema for Infographics

```sql
CREATE OR REPLACE TABLE DOCUMENT_AI.INFOGRAPHICS_EXTRACTED AS
SELECT 
    RELATIVE_PATH,
    AI_EXTRACT(
        file => TO_FILE('@DOCUMENT_AI.INFOGRAPHICS', RELATIVE_PATH),
        responseFormat => {
            'schema': {
                'type': 'object',
                'properties': {
                    'company_name': {
                        'description': 'Company name',
                        'type': 'string'
                    },
                    'ticker': {
                        'description': 'Company ticker symbol',
                        'type': 'string'
                    },
                    'report_period': {
                        'description': 'Report period',
                        'type': 'string'
                    },
                    'revenue_breakdown_table': {
                        'description': 'Revenue Breakdown table',
                        'type': 'object',
                        'properties': {
                            'revenue_type': {
                                'description': 'Revenue types',
                                'type': 'array'
                            },
                            'q2_fy2025': {
                                'description': 'Q2 FY2025 amounts',
                                'type': 'array'
                            },
                            'q2_fy2024': {
                                'description': 'Q2 FY2024 amounts',
                                'type': 'array'
                            },
                            'growth': {
                                'description': 'Growth percentages',
                                'type': 'array'
                            }
                        }
                    },
                    'key_metrics_table': {
                        'description': 'Key Metrics table',
                        'type': 'object',
                        'properties': {
                            'metric': {
                                'description': 'Metric names',
                                'type': 'array'
                            },
                            'value': {
                                'description': 'Metric values',
                                'type': 'array'
                            }
                        }
                    },
                    'total_revenue': {
                        'description': 'Total Revenue amount',
                        'type': 'string'
                    },
                    'yoy_growth': {
                        'description': 'Year-over-year growth percentage',
                        'type': 'string'
                    },
                    'gross_margin': {
                        'description': 'Gross margin percentage',
                        'type': 'string'
                    },
                    'total_customers': {
                        'description': 'Total number of customers',
                        'type': 'string'
                    },
                    'nrr': {
                        'description': 'Net Revenue Retention percentage',
                        'type': 'string'
                    }
                }
            }
        }
    ) AS EXTRACTED_DATA
FROM DIRECTORY('@DOCUMENT_AI.INFOGRAPHICS')
WHERE RELATIVE_PATH LIKE '%FY25-Q2.png';
```

## Deployment

Updated in `deploy_documentai.template.sql`:

```sql
-- Upload simplified infographics for all 8 companies
PUT file:///.../infographics_simple/*.png 
    @DOCUMENT_AI.INFOGRAPHICS 
    AUTO_COMPRESS=FALSE 
    OVERWRITE=TRUE;
```

## Benefits

✅ **All 8 Companies**: Complete infographic for SNOW, ICBG, QRYQ, DFLX, STRM, VLTA, CTLG, NRNT  
✅ **Consistent Design**: Same layout, different branding  
✅ **AI_EXTRACT Ready**: Clean tables that extract perfectly  
✅ **Beautiful**: Gradient backgrounds, professional styling  
✅ **Compact**: Single-page landscape format (A4)  
✅ **2 Tables**: Revenue Breakdown + Key Metrics per infographic  

Perfect for demonstrating Snowflake's Document AI table extraction from images! 🎯

