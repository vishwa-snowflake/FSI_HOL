# Public Investment Research Documents - Download Guide

This guide provides instructions for downloading publicly available investment research documents to populate the additional INVESTMENT_RESEARCH stages in the hackathon database.

## Overview

The INVESTMENT_RESEARCH schema now includes 6 stages for different investment topics:

1. **investment_management** - Portfolio management (already populated with 7 Fed/NBER papers)
2. **esg_investing** - ESG & sustainable investing research
3. **risk_management** - Risk analysis & regulatory frameworks
4. **portfolio_strategy** - Modern portfolio theory & asset allocation
5. **market_research** - Economic research & market analysis
6. **quantitative_methods** - Quantitative finance & algorithmic trading

## How to Add Documents

### Step 1: Create Local Directories

```bash
mkdir -p /tmp/hackathon_research/{esg,risk,portfolio,market,quant}
```

### Step 2: Download Documents from Public Sources

---

## 1. ESG & Sustainable Investing

### Sources:

**UN Principles for Responsible Investment (PRI)**
- Website: https://www.unpri.org/research
- What to download: Research reports on sustainable investing, ESG integration
- Suggested papers:
  - "ESG Integration Framework"
  - "Climate Change Implementation Guide"
  - "Active Ownership 2.0"

**SASB Standards**
- Website: https://www.sasb.org/standards/
- What to download: Industry-specific sustainability standards (PDFs)
- Download materiality maps and standards for Financial Services sector

**MSCI ESG Research**
- Website: https://www.msci.com/research-and-insights/esg
- What to download: Free ESG research reports and whitepapers
- Look for: "ESG Trends to Watch" and methodology papers

**Download commands:**
```bash
cd /tmp/hackathon_research/esg
# Download PDFs manually from websites above
# Or use wget/curl if direct links are available
```

---

## 2. Risk Management

### Sources:

**Bank for International Settlements (BIS)**
- Website: https://www.bis.org/publ/index.htm
- What to download: Basel Committee papers, FSI papers on risk management
- Suggested topics:
  - "Stress Testing Principles"
  - "Operational Risk Management"
  - "Climate-related Financial Risks"

**Federal Reserve Supervision**
- Website: https://www.federalreserve.gov/supervisionreg.htm
- What to download: Supervision and regulation letters, stress test guidance
- Look for: CCAR/DFAST methodology papers

**SEC Risk Analytics**
- Website: https://www.sec.gov/files/dera
- What to download: Risk metrics, market structure research
- Focus on: Investment company risk analytics

**Download commands:**
```bash
cd /tmp/hackathon_research/risk
# Example for BIS papers:
wget https://www.bis.org/bcbs/publ/[paper_number].pdf
```

---

## 3. Portfolio Strategy & Asset Allocation

### Sources:

**CFA Institute Research**
- Website: https://www.cfainstitute.org/en/research
- What to download: Asset allocation research, portfolio construction papers
- Look for: "Future of Finance" series, research foundation publications

**NBER Working Papers**
- Website: https://www.nber.org/papers
- Search terms: "portfolio theory", "asset allocation", "diversification"
- What to download: Recent working papers on portfolio optimization
- Note: Some papers may require institutional access

**SSRN (Social Science Research Network)**
- Website: https://papers.ssrn.com/
- Search: "modern portfolio theory", "factor investing", "portfolio optimization"
- What to download: Top downloaded finance papers (usually free)

**Download commands:**
```bash
cd /tmp/hackathon_research/portfolio
# NBER papers example (if available):
wget https://www.nber.org/papers/w[paper_number].pdf
```

---

## 4. Market Research & Economics

### Sources:

**International Monetary Fund (IMF)**
- Website: https://www.imf.org/en/Publications
- What to download:
  - World Economic Outlook reports
  - Global Financial Stability Reports
  - Working papers on financial markets

**World Bank Research**
- Website: https://www.worldbank.org/en/research
- What to download:
  - Policy research working papers
  - Economic reports on market development
  - Financial sector assessments

**European Central Bank (ECB) Working Papers**
- Website: https://www.ecb.europa.eu/pub/research/working-papers/
- What to download: Papers on monetary policy, financial markets, economic research

**Download commands:**
```bash
cd /tmp/hackathon_research/market
# IMF reports are directly downloadable:
wget https://www.imf.org/-/media/Files/Publications/[report].ashx -O imf_report.pdf
```

---

## 5. Quantitative Methods & Algorithmic Trading

### Sources:

**ArXiv Quantitative Finance**
- Website: https://arxiv.org/list/q-fin/recent
- Categories to explore:
  - q-fin.PM (Portfolio Management)
  - q-fin.TR (Trading and Market Microstructure)
  - q-fin.CP (Computational Finance)
  - q-fin.RM (Risk Management)
- All papers are free to download

**Journal of Financial Data Science**
- Website: https://jfds.pm-research.com/
- What to download: Select open-access papers on data science in finance

**QuantLib Documentation & Papers**
- Website: https://www.quantlib.org/
- What to download: Research papers on quantitative methods

**Download commands:**
```bash
cd /tmp/hackathon_research/quant
# ArXiv papers (always free):
wget https://arxiv.org/pdf/[paper_id].pdf
# Example:
wget https://arxiv.org/pdf/2301.12345.pdf
```

---

## Step 3: Upload to Snowflake Stages

Once you've downloaded the PDFs, upload them using SnowSQL or the Snowflake UI:

### Using SnowSQL:

```sql
-- Connect to Snowflake
snowsql -a <account> -u <user>

-- Set context
USE ROLE <your_role>;
USE DATABASE HACKATHON_DATASETS;
USE SCHEMA INVESTMENT_RESEARCH;

-- Upload ESG papers
PUT file:///tmp/hackathon_research/esg/*.pdf @esg_investing auto_compress=false overwrite=true;
ALTER STAGE esg_investing REFRESH;

-- Upload Risk Management papers
PUT file:///tmp/hackathon_research/risk/*.pdf @risk_management auto_compress=false overwrite=true;
ALTER STAGE risk_management REFRESH;

-- Upload Portfolio Strategy papers
PUT file:///tmp/hackathon_research/portfolio/*.pdf @portfolio_strategy auto_compress=false overwrite=true;
ALTER STAGE portfolio_strategy REFRESH;

-- Upload Market Research papers
PUT file:///tmp/hackathon_research/market/*.pdf @market_research auto_compress=false overwrite=true;
ALTER STAGE market_research REFRESH;

-- Upload Quantitative Methods papers
PUT file:///tmp/hackathon_research/quant/*.pdf @quantitative_methods auto_compress=false overwrite=true;
ALTER STAGE quantitative_methods REFRESH;
```

### Using Snowflake UI:

1. Log into Snowflake UI
2. Navigate to: **Data** → **Databases** → **HACKATHON_DATASETS** → **INVESTMENT_RESEARCH**
3. Click on the stage name (e.g., `esg_investing`)
4. Click **+ Files** button
5. Upload your PDFs
6. Click **Refresh** to update the directory listing

---

## Step 4: Verify Upload

```sql
-- Check file counts in each stage
SELECT 
    'esg_investing' AS stage_name,
    COUNT(*) AS file_count
FROM DIRECTORY('@HACKATHON_DATASETS.INVESTMENT_RESEARCH.esg_investing')
UNION ALL
SELECT 'risk_management', COUNT(*) 
FROM DIRECTORY('@HACKATHON_DATASETS.INVESTMENT_RESEARCH.risk_management')
UNION ALL
SELECT 'portfolio_strategy', COUNT(*) 
FROM DIRECTORY('@HACKATHON_DATASETS.INVESTMENT_RESEARCH.portfolio_strategy')
UNION ALL
SELECT 'market_research', COUNT(*) 
FROM DIRECTORY('@HACKATHON_DATASETS.INVESTMENT_RESEARCH.market_research')
UNION ALL
SELECT 'quantitative_methods', COUNT(*) 
FROM DIRECTORY('@HACKATHON_DATASETS.INVESTMENT_RESEARCH.quantitative_methods');

-- List files in a specific stage
LIST @HACKATHON_DATASETS.INVESTMENT_RESEARCH.esg_investing;
```

---

## Recommended Paper Counts

For a well-balanced hackathon dataset, aim for:

- **esg_investing**: 8-12 papers
- **risk_management**: 8-12 papers
- **portfolio_strategy**: 10-15 papers
- **market_research**: 10-15 papers
- **quantitative_methods**: 12-20 papers (ArXiv has many free papers)

---

## Specific Paper Recommendations

### Must-Have Papers (All Freely Available):

1. **ESG**: UN PRI's "An Introduction to Responsible Investment"
2. **Risk**: BIS Basel Committee's "Principles for Sound Stress Testing Practices and Supervision"
3. **Portfolio**: Markowitz's "Portfolio Selection" (if available) or recent NBER papers on factor investing
4. **Market**: IMF's latest "Global Financial Stability Report"
5. **Quant**: Top-cited ArXiv papers in q-fin.PM and q-fin.TR

---

## Legal & Compliance Notes

✅ **All sources listed are publicly available**
✅ **Download for educational/research purposes**
✅ **Respect terms of use for each source**
✅ **Do not redistribute copyrighted material**

---

## Hackathon Use Cases

Once populated, hackathon participants can:

- **Compare ESG frameworks** across different organizations using Document AI
- **Extract risk metrics** from regulatory papers with AI_EXTRACT
- **Build portfolio strategies** by analyzing academic research with AI_COMPLETE
- **Analyze economic trends** from IMF/World Bank reports
- **Study quant methods** from ArXiv papers and implement algorithms

---

## Support

If you need help finding specific papers or encounter download issues:
1. Check if your institution has access to academic databases
2. Many papers have "pre-print" versions available on SSRN or ArXiv
3. Contact paper authors directly for copies (they're usually happy to share!)

---

**Happy researching! 📚🚀**

