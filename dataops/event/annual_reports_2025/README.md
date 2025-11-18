# Annual Reports - Complete Collection

**Created**: October 31, 2025  
**Coverage**: FY2024 and FY2025  
**Companies**: All 11 synthetic companies  
**Total Reports**: 22

---

## Overview

This directory contains comprehensive annual reports for all 11 companies in the FSI Cortex Assistant demo, covering both fiscal years with unique branded designs.

---

## Stock Exchange Listings

**All companies are publicly traded** (or were, in NRNT's case):

| Ticker | Company | Exchange | FY2024 Status | FY2025 Status |
|--------|---------|----------|---------------|---------------|
| SNOW | Snowflake Inc. | NASDAQ | ✅ Active | ✅ Active |
| NRNT | Neuro-Nectar Corp. | NYSE | ✅ Active | ❌ DELISTED Nov 20, 2024 |
| ICBG | ICBG Data Systems | NASDAQ | ✅ Active | ✅ Active |
| QRYQ | Querybase Technologies | NYSE | ✅ Active | ✅ Active |
| DFLX | DataFlex Analytics | NASDAQ | ✅ Active | ✅ Active |
| STRM | StreamPipe Systems | NYSE | ✅ Active | ✅ Active |
| VLTA | Voltaic AI Platform | NASDAQ | ✅ Active | ✅ Active |
| CTLG | CatalogX Corporation | NYSE | ✅ Active | ✅ Active |
| PROP | PropTech Analytics | NASDAQ | ✅ Active | ✅ Active |
| GAME | GameMetrics Analytics | NASDAQ | ✅ Active | ✅ Active |
| MKTG | Marketing Analytics | NYSE | ✅ Active | ✅ Active |

---

## FY2025 Reports (April 30, 2025)

### Core 8 Companies

| File | Company | Revenue | Growth | Profitability | Design Theme |
|------|---------|---------|--------|---------------|--------------|
| SNOW_Annual_Report_FY2025.md | Snowflake | $3.2B | +38% | ✅ Profitable | Frosted glass, enterprise |
| NRNT_Liquidation_Report_FY2025.md | Neuro-Nectar | N/A | N/A | ❌ Bankrupt | Red warning, liquidation |
| ICBG_Annual_Report_FY2025.md | ICBG Data | $389M | +156% | Unprofitable | Iceberg watermarks |
| QRYQ_Annual_Report_FY2025.md | Querybase | $412M | +287% | Unprofitable | Lightning badge, aggressive |
| DFLX_Annual_Report_FY2025.md | DataFlex | $289M | +143% | ✅ Profitable | Balanced grid, Swiss flag |
| STRM_Annual_Report_FY2025.md | StreamPipe | $224M | +198% | Near profitable | Flowing waves |
| VLTA_Annual_Report_FY2025.md | Voltaic AI | $327M | +312% | Unprofitable | Electric bolts, energy |
| CTLG_Annual_Report_FY2025.md | CatalogX | $214M | +176% | ✅ Profitable | Shield badge, governance |

### Bottom 3 Performers

| File | Company | Revenue | Growth | Status | Design Theme |
|------|---------|---------|--------|--------|--------------|
| PROP_Annual_Report_FY2025.md | PropTech | $289M | +234% | Heavy burn | Buildings flanking |
| GAME_Annual_Report_FY2025.md | GameMetrics | $734M | +287% | Near profitable | Pixelated borders |
| MKTG_Annual_Report_FY2025.md | Marketing Analytics | $221M | +156% | Most challenged | Chart icon |

---

## FY2024 Reports (April 30, 2024)

**All 11 companies** with same branding as FY2025:
- SNOW, NRNT (pre-collapse), ICBG, QRYQ, DFLX, STRM, VLTA, CTLG, PROP, GAME, MKTG
- Concise format (vs. comprehensive FY2025 reports)
- Pre-NRNT collapse timeline
- Lower revenues (earlier stage)

---

## Design Features

### Unique Branded Headers

Each company has a distinctive visual identity:

- **SNOW**: Frosted glass pill, backdrop blur, blue gradient
- **NRNT**: FY2024 (optimistic purple/pink) vs. FY2025 (red liquidation warning)
- **ICBG**: Giant iceberg watermarks in corners, teal gradient
- **QRYQ**: Circular lightning badge, yellow accent, uppercase
- **DFLX**: Symmetrical 3-column grid with charts
- **STRM**: Flowing wave pattern background
- **VLTA**: Electric bolts decorating corners, yellow gradient
- **CTLG**: Square shield badge, gray governance theme
- **PROP**: Building icons flanking name
- **GAME**: Pixelated gradient borders (gaming theme)
- **MKTG**: Chart icon in bordered box

### Common Elements

✅ Company gradient colors per cursor rules  
✅ Company icon (emoji)  
✅ Stock ticker (NASDAQ or NYSE)  
✅ Tagline/positioning statement  
✅ Professional typography  
✅ Box shadows for depth  
✅ Responsive layouts  

---

## Key Narrative Elements

### The NRNT Story Arc

**FY2024** (Pre-Collapse):
- High growth (412%), optimistic
- Warning signs visible (return rates, complaints)
- Still publicly traded (NYSE: NRNT)

**FY2025** (Post-Collapse):
- Liquidation report format
- Delisted November 20, 2024
- Stock crashed -90.4%
- Shareholders get $0.00

### Competitive Dynamics

**Data Platforms** (compete):
- SNOW vs. ICBG (proprietary vs. open)
- SNOW vs. QRYQ (premium vs. price-performance)

**Complementary Layers** (partner with all):
- DFLX, STRM, VLTA, CTLG work with SNOW, ICBG, QRYQ

**Vertical Apps** (use platforms):
- PROP, GAME, MKTG leverage core data platforms

---

## Usage in Demo

### Document AI Processing

Upload to Snowflake stage and process:
```sql
PUT file:///annual_reports_2024/*.md @DOCUMENT_AI.ANNUAL_REPORTS/2024/;
PUT file:///annual_reports_2025/*.md @DOCUMENT_AI.ANNUAL_REPORTS/2025/;
```

### AI Extraction

Extract structured data:
```sql
SELECT 
    RELATIVE_PATH,
    AI_EXTRACT(content, 'Extract: Company, Fiscal Year, Revenue, Growth %, CEO Name, Key Events') 
FROM @DOCUMENT_AI.ANNUAL_REPORTS;
```

### Cortex Search

Add to search service:
```sql
CREATE CORTEX SEARCH SERVICE ANNUAL_REPORTS_SEARCH
ON full_text
ATTRIBUTES company, fiscal_year, stock_ticker
AS (SELECT * FROM ANNUAL_REPORTS_DATA);
```

### Cortex Analyst Queries

Example questions:
- "Compare revenue growth across all 11 companies from FY2024 to FY2025"
- "Which companies became profitable in FY2025?"
- "What happened to NRNT between the two fiscal years?"
- "Show me the competitive dynamics between SNOW, ICBG, and QRYQ"

---

## File Statistics

### FY2025 Reports
- **Files**: 11
- **Total Size**: ~110 KB
- **Total Lines**: ~3,300 lines
- **Format**: Comprehensive (10+ sections each)

### FY2024 Reports
- **Files**: 11
- **Total Size**: ~32 KB
- **Total Lines**: ~1,000 lines
- **Format**: Concise (5-6 sections each)

### Combined
- **Total Reports**: 22
- **Total Size**: ~142 KB
- **Companies**: 11
- **Fiscal Years**: 2

---

## Design Specification

See `/.cursor/rules/annual-report-designs.md` for:
- Complete CSS specifications
- Brand color palettes
- Unique header treatments
- Universal design components
- Implementation guidelines

---

## Consistency Verification

✅ **Stock tickers**: All 11 companies show NASDAQ or NYSE listings  
✅ **Timeline**: NRNT collapse correctly reflected (FY2024 active, FY2025 delisted)  
✅ **Competitive dynamics**: Consistent across all reports  
✅ **Partnership relationships**: Ecosystem correctly described  
✅ **Financial data**: Growth rates and revenues consistent  
✅ **Brand colors**: Match cursor rules exactly  
✅ **Design uniqueness**: Each company visually distinct  
✅ **Professional quality**: Corporate annual report standards  

---

<p align="center">
  <strong>22 Professional Annual Reports • 2 Fiscal Years • 11 Companies • Fully Branded</strong>
</p>


