# Investment Management Document Collection

This directory contains authoritative research papers and publications on portfolio and investment management, suitable for use with Cortex Search Services and Document AI.

## Document Overview

**Total Documents**: 7 PDFs  
**Total Size**: 4.9 MB  
**Total Pages**: ~270 pages  
**Sources**: Federal Reserve Board, National Bureau of Economic Research (NBER)

## Document Details

### Federal Reserve Board Publications

#### 1. Federal_Reserve_Asset_Allocation.pdf (36 pages, 684 KB)
- **Source**: Federal Reserve Board, Finance and Economics Discussion Series
- **Reference**: FEDS Paper 2020-101
- **Topics**: Asset allocation strategies, portfolio construction, investment decision-making
- **URL**: https://www.federalreserve.gov/econres/feds/files/2020101pap.pdf

#### 2. Federal_Reserve_Investment_Analysis.pdf (26 pages, 649 KB)
- **Source**: Federal Reserve Board, Finance and Economics Discussion Series
- **Reference**: FEDS Paper 2018-085
- **Topics**: Investment analysis methodologies, financial modeling, risk assessment
- **URL**: https://www.federalreserve.gov/econres/feds/files/2018085pap.pdf

#### 3. Federal_Reserve_Portfolio_Choice.pdf (60 pages, 790 KB)
- **Source**: Federal Reserve Board, Finance and Economics Discussion Series
- **Reference**: FEDS Paper 2019-017
- **Topics**: Portfolio choice theory, investor behavior, asset selection
- **URL**: https://www.federalreserve.gov/econres/feds/files/2019017pap.pdf

#### 4. Federal_Reserve_Quantitative_Investment.pdf (37 pages, 817 KB)
- **Source**: Federal Reserve Board, Finance and Economics Discussion Series
- **Reference**: FEDS Paper 2021-053
- **Topics**: Quantitative investment strategies, algorithmic trading, factor models
- **URL**: https://www.federalreserve.gov/econres/feds/files/2021053pap.pdf

#### 5. Federal_Reserve_Risk_Management.pdf (72 pages, 443 KB)
- **Source**: Federal Reserve Board, Finance and Economics Discussion Series
- **Reference**: FEDS Paper 2017-104
- **Topics**: Portfolio risk management, risk measurement, hedging strategies
- **URL**: https://www.federalreserve.gov/econres/feds/files/2017104pap.pdf

### NBER Working Papers

#### 6. NBER_ESG_Investing.pdf (389 KB)
- **Source**: National Bureau of Economic Research
- **Reference**: NBER Working Paper No. 29359
- **Topics**: ESG (Environmental, Social, Governance) investing, sustainable finance, impact investing
- **URL**: https://www.nber.org/system/files/working_papers/w29359/w29359.pdf

#### 7. NBER_Portfolio_Optimization.pdf (1.2 MB)
- **Source**: National Bureau of Economic Research
- **Reference**: NBER Working Paper No. 28784
- **Topics**: Portfolio optimization techniques, Modern Portfolio Theory, mean-variance optimization
- **URL**: https://www.nber.org/system/files/working_papers/w28784/w28784.pdf

## Topics Covered

### Core Investment Management
- Portfolio construction and optimization
- Asset allocation strategies
- Investment analysis and valuation
- Risk-return tradeoffs

### Risk Management
- Portfolio risk measurement
- Risk mitigation strategies
- Hedging techniques
- Value at Risk (VaR) analysis

### Advanced Topics
- Quantitative investment strategies
- Factor-based investing
- Algorithmic trading
- ESG and sustainable investing

### Investor Behavior
- Portfolio choice theory
- Behavioral finance considerations
- Decision-making under uncertainty

## Use Cases

### 1. Cortex Search Service Integration
These documents can be added to a Cortex Search Service to enable:
- Semantic search across investment management literature
- Question answering about portfolio theory and practices
- Research assistant for investment strategies
- Educational resource for financial professionals

### 2. Document AI Processing
Process these documents with Snowflake Document AI to:
- Extract key investment concepts and methodologies
- Build knowledge graphs of investment strategies
- Create searchable metadata
- Generate summaries and insights

### 3. Cortex Analyst Semantic Views
Enhance semantic models with:
- Investment terminology and concepts
- Portfolio management frameworks
- Risk management methodologies
- Industry best practices

## Data Quality

- **Authenticity**: All documents from authoritative sources (Federal Reserve, NBER)
- **Peer Review**: NBER working papers and Federal Reserve discussion series
- **Academic Rigor**: Research-quality publications with citations and methodology
- **Relevance**: Current research on modern investment management practices
- **License**: Public domain (Federal Reserve) and academic use (NBER)

## Next Steps

### To Add to Cortex Search Service:

1. **Upload to Snowflake Stage**
```sql
CREATE STAGE IF NOT EXISTS investment_docs_stage;
PUT file:///path/to/investment_management_docs/*.pdf @investment_docs_stage;
```

2. **Create Search Service**
```sql
CREATE CORTEX SEARCH SERVICE investment_management_search
ON document_text
ATTRIBUTES file_name, document_type, source, topics
WAREHOUSE = compute_wh
TARGET_LAG = '1 hour'
AS (
    -- Your data source query
);
```

3. **Process with Document AI**
- Use Snowflake Document AI to extract text, tables, and metadata
- Build structured data from unstructured PDFs
- Create searchable embeddings

## Maintenance

- **Downloaded**: October 29, 2025
- **Last Verified**: October 29, 2025
- **Refresh Frequency**: Quarterly (check for updated versions)
- **Backup**: Keep original URLs for re-download if needed

## Copyright and Attribution

- **Federal Reserve Papers**: Public domain, U.S. Government work
- **NBER Working Papers**: Academic use permitted with proper citation
- **Attribution**: Cite original sources when using insights or content

## Contact

For questions about these documents or to suggest additional resources, contact the FSI Cortex Assistant team.

---

**Collection Created**: October 29, 2025  
**Format**: PDF  
**Encoding**: UTF-8  
**Compatibility**: Snowflake Document AI, Cortex Search Services, Cortex Analyst

