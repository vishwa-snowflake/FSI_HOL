# Downloaded Investment Research Papers

This directory contains publicly available investment research papers that have been downloaded and are included in the hackathon database.

## Summary

**Total Papers Downloaded: 7**

All papers are from publicly available sources and are free to use for educational purposes.

---

## 📁 ESG & Sustainable Investing (1 paper)

### UN_PRI_ESG_Incorporation.pdf
- **Source**: UN Principles for Responsible Investment (UN PRI)
- **Size**: 121KB
- **Topic**: ESG incorporation in investment decision-making
- **URL**: https://www.unpri.org/

**Description**: Guidance on incorporating environmental, social, and governance factors into investment analysis and portfolio construction.

---

## 📁 Risk Management (1 paper)

### BIS_Stress_Testing_Principles.pdf
- **Source**: Bank for International Settlements (BIS)
- **Paper**: Basel Committee on Banking Supervision - Principles for Sound Stress Testing Practices and Supervision (BCBS 155)
- **Size**: 152KB
- **Topic**: Stress testing principles for financial institutions
- **URL**: https://www.bis.org/publ/bcbs155.pdf

**Description**: Comprehensive guidance on stress testing practices including governance, scenario design, methodologies, and supervisory assessment.

---

## 📁 Portfolio Strategy & Asset Allocation (1 paper)

### Fed_Portfolio_Choice_Risk.pdf
- **Source**: Federal Reserve Board - Finance and Economics Discussion Series
- **Paper**: FEDS Paper 2017-044
- **Size**: 1.3MB
- **Topic**: Portfolio choice and risk management
- **URL**: https://www.federalreserve.gov/econres/feds/

**Description**: Research on portfolio optimization, asset allocation strategies, and risk management in investment portfolios.

---

## 📁 Market Research & Economics (1 paper)

### IMF_Financial_Stability_Climate_Risk.pdf
- **Source**: International Monetary Fund (IMF)
- **Paper**: IMF Working Paper WP/23/217
- **Size**: 3.2MB
- **Topic**: Financial stability and climate-related risks
- **URL**: https://www.imf.org/

**Description**: Analysis of how climate risks affect financial stability, including transmission channels, risk assessment methodologies, and policy implications.

---

## 📁 Quantitative Methods & Algorithmic Trading (3 papers)

### 1. Portfolio_Optimization_Deep_Learning.pdf
- **Source**: ArXiv
- **Paper**: arXiv:1906.01446
- **Size**: 1.4MB
- **Topic**: Deep learning for portfolio optimization with transaction costs
- **URL**: https://arxiv.org/abs/1906.01446

**Description**: Application of deep reinforcement learning to portfolio optimization problems, considering realistic transaction costs and market impact.

### 2. ML_Algorithmic_Trading.pdf
- **Source**: ArXiv
- **Paper**: arXiv:1911.10107
- **Size**: 861KB
- **Topic**: Machine learning for algorithmic trading
- **URL**: https://arxiv.org/abs/1911.10107

**Description**: Survey of machine learning techniques applied to algorithmic trading, including supervised learning, reinforcement learning, and deep learning approaches.

### 3. Deep_Portfolio_Theory.pdf
- **Source**: ArXiv
- **Paper**: arXiv:2006.04281
- **Size**: 130KB
- **Topic**: Deep portfolio theory and neural network applications
- **URL**: https://arxiv.org/abs/2006.04281

**Description**: Theoretical framework for applying deep neural networks to portfolio management, including risk-return optimization and portfolio rebalancing.

---

## Usage in Hackathon

These papers are uploaded to the following Snowflake stages in the `HACKATHON_DATASETS.INVESTMENT_RESEARCH` schema:

- `@esg_investing` - ESG papers
- `@risk_management` - Risk analysis papers  
- `@portfolio_strategy` - Portfolio optimization papers
- `@market_research` - Economic and market research
- `@quantitative_methods` - Quantitative finance papers

### Example Queries

```sql
-- List all ESG papers
LIST @HACKATHON_DATASETS.INVESTMENT_RESEARCH.esg_investing;

-- Extract text from risk management paper
SELECT 
    RELATIVE_PATH,
    SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
        TO_FILE('@HACKATHON_DATASETS.INVESTMENT_RESEARCH.risk_management/' || RELATIVE_PATH),
        {'mode': 'LAYOUT'}
    ) AS parsed_content
FROM DIRECTORY('@HACKATHON_DATASETS.INVESTMENT_RESEARCH.risk_management');

-- Compare portfolio strategies across papers
SELECT 
    RELATIVE_PATH,
    SNOWFLAKE.CORTEX.AI_EXTRACT(
        TO_FILE('@HACKATHON_DATASETS.INVESTMENT_RESEARCH.portfolio_strategy/' || RELATIVE_PATH),
        'What are the main portfolio optimization strategies discussed? What are the key findings?'
    ) AS strategy_summary
FROM DIRECTORY('@HACKATHON_DATASETS.INVESTMENT_RESEARCH.portfolio_strategy');

-- Analyze quantitative methods
SELECT 
    RELATIVE_PATH,
    SNOWFLAKE.CORTEX.AI_EXTRACT(
        TO_FILE('@HACKATHON_DATASETS.INVESTMENT_RESEARCH.quantitative_methods/' || RELATIVE_PATH),
        'What machine learning algorithms are used? What datasets are mentioned?'
    ) AS ml_methods
FROM DIRECTORY('@HACKATHON_DATASETS.INVESTMENT_RESEARCH.quantitative_methods');
```

---

## Licensing & Attribution

All papers are:
- ✅ Publicly available from official sources
- ✅ Free to access and download
- ✅ Suitable for educational and research use

### Sources Attribution:
- **UN PRI**: © Principles for Responsible Investment
- **BIS**: © Bank for International Settlements
- **Federal Reserve**: Public domain (US Government work)
- **IMF**: © International Monetary Fund (Creative Commons license)
- **ArXiv**: Papers available under arXiv.org perpetual non-exclusive license

When using these papers in your hackathon project, please cite the original sources appropriately.

---

## Adding More Papers

To add additional papers to any category:

1. Download PDF from public sources (see README_PUBLIC_SOURCES.md for links)
2. Place in the appropriate subdirectory
3. Re-run the deployment pipeline, or manually upload:

```sql
PUT file:///path/to/new/paper.pdf 
@HACKATHON_DATASETS.INVESTMENT_RESEARCH.{stage_name} 
auto_compress=false overwrite=true;

ALTER STAGE HACKATHON_DATASETS.INVESTMENT_RESEARCH.{stage_name} REFRESH;
```

---

**Last Updated**: November 4, 2025
**Downloaded by**: Automated pipeline script

