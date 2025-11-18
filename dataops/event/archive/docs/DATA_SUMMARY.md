# FSI Cortex Assistant - Complete Data Summary

## 📊 Data Files Created

### 1. **companies.csv** (15KB, 93 rows)
- **Header**: ticker, company_name, category, description, story
- **8 Core Companies**: Full narratives in 'story' field (500-700 chars each)
- **84 Extended Companies**: Empty story field
- **Format**: Properly quoted CSV for parsing
- **Location**: `/DATA/companies.csv`

### 2. **unique_transcripts.csv** (135KB, 93 rows) 
- **8 Core Companies**: Full earnings call transcripts with 8-10 speakers each
- **84 Extended Companies**: Abbreviated transcripts
- **Format**: ticker, date, quarter, fiscal_year, transcript_json
- **Key Dates**: Aug 22 - Sept 25, 2024
- **Location**: `/DATA/unique_transcripts.csv`

### 3. **fsi_data.csv** (17MB, 52,695 records)
- **30 Companies**: Daily stock prices from 2018-2025
- **NRNT**: 1,589 records (ends Nov 20, 2024 with -90% crash)
- **SNOW**: 1,779 records (shows 3% dip and 6.6% recovery)
- **Format**: ticker, asset_class, exchange, price, returns, technical indicators
- **Location**: `/DATA/fsi_data.csv`

### 4. **Analyst Reports** (36 HTML files)
- **6 Analyst Firms**: Apex Analytics, Consensus Point, Momentum Metrics, Pinnacle Growth, Quant-Vestor, Sterling Partners, Veridian Capital
- **Date Range**: Aug 2024 - May 2025
- **Key Narrative**: NRNT threat (Sept), NRNT collapse (Nov), SNOW recovery
- **Location**: `/document_ai/svg_files/*.html`

### 5. **Documentation**
- `COMPANIES_STORIES_SUMMARY.md` - Detailed narrative arcs (5.2KB)
- `stock_narrative_summary.md` - Price movement timeline (2.4KB)
- `TICKER_MAPPING.md` - Original to fictional ticker mapping
- `EARNINGS_CALLS_SUMMARY.md` - Full earnings call overview

## 🎯 Core Narrative Timeline

| Date | Event | NRNT | SNOW |
|------|-------|------|------|
| **Aug 30, 2024** | NRNT Q2 Earnings | $142M, 487% growth 🚀 | - |
| **Sept 19, 2024** | Apex downgrades SNOW | Peak $133.75 | Downgraded to SELL |
| **Sept-Oct 2024** | Product issues emerge | Declining -15% | Down -3% |
| **Nov 1-14, 2024** | Accelerating decline | Down -48% | Bottom |
| **Nov 15-20, 2024** | **CRASH & ADMINISTRATION** | **-90%, DELISTED** 💥 | Recovery begins |
| **Nov 20-29, 2024** | Analysts upgrade SNOW | Gone | **+6.6%, HOLD rating** ✅ |

## 🏢 Company Ecosystem

### **Data Platforms (Compete)**
1. **SNOW**: Integrated proprietary - $900M, market leader
2. **ICBG**: Open DIY lakehouse - $87M, Apache Iceberg
3. **QRYQ**: Managed with open formats - $94M, price-performance

### **Complementary Layers (Partner)**
4. **DFLX**: Switzerland BI platform - $67M, works with all
5. **STRM**: Real-time data integration - $51M, 300+ connectors
6. **VLTA**: AI/ML infrastructure - $73M, highest growth (312%)
7. **CTLG**: Governance layer - $48M, cross-platform

### **Wildcard**
8. **NRNT**: Cognitive enhancement - $142M → DELISTED 💥

## 📈 Data Consistency

✅ **Earnings calls** (Aug-Sept) show companies at peak  
✅ **Analyst reports** (Sept) identify NRNT threat  
✅ **Stock prices** (Sept-Nov) show NRNT declining  
✅ **Analyst reports** (Nov) report administration  
✅ **Stock prices** (Nov 20) show NRNT crash & delisting  
✅ **Stock prices** (Nov 20+) show SNOW recovery  

## 🔑 Key Features for AI Assistant

1. **Cross-document references**: Companies mention each other naturally
2. **Temporal consistency**: Events unfold across all data sources
3. **Realistic market dynamics**: Threat, panic, resolution
4. **Complete story arcs**: Rise and fall of NRNT, resilience of SNOW
5. **Partnership networks**: DFLX/STRM/VLTA/CTLG work with all platforms
6. **Competitive positioning**: Each company has unique value prop

## 📁 File Structure

```
/dataops/event/
├── DATA/
│   ├── companies.csv (with stories)
│   ├── unique_transcripts.csv
│   ├── fsi_data.csv
│   ├── COMPANIES_STORIES_SUMMARY.md
│   └── TICKER_MAPPING.md
├── document_ai/
│   ├── svg_files/ (36 analyst reports HTML)
│   └── synthetic_analyst_reports/ (30 PDF reports)
├── stock_narrative_summary.md
└── DATA_SUMMARY.md (this file)
```

## 🎓 Usage Guide

When creating new datasets or content:

1. **Read `companies.csv`** story field for core company narratives
2. **Reference key dates**: Aug 30, Sept 19, Nov 15-20, Nov 29
3. **Maintain relationships**: SNOW vs ICBG vs QRYQ (compete), others (partner)
4. **Include NRNT arc**: Hype → Threat → Collapse
5. **Show recovery**: SNOW bounces back after threat eliminated
6. **Cross-reference**: Companies naturally mention each other

---

**Total Synthetic Data**: ~17MB across 3 structured files + 66 unstructured documents  
**Companies**: 92 fictional companies with 8 detailed narrative arcs  
**Time Period**: 2018-2025 (7 years of price data)  
**Key Event**: NRNT administration (Nov 2024) - complete narrative across all sources
