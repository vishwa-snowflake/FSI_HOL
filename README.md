# Build an AI Assistant for FSI using AI SQL and Snowflake Intelligence

<p align="center">
  <img src="dataops/event/homepage/docs/assets/img/logo.png" alt="FSI Cortex Assistant" width="200"/>
</p>

<p align="center">
  <strong>A comprehensive AI-powered financial analysis platform built with Snowflake Cortex AI</strong>
</p>

<p align="center">
  <a href="#quick-start">Quick Start</a> •
  <a href="#features">Features</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#documentation">Documentation</a> •
  <a href="#support">Support</a>
</p>

---

## 🎯 Overview

This project demonstrates how to build a production-ready AI assistant for financial services using **Snowflake Cortex AI**, **Snowflake Intelligence**, and **Document AI**. Deploy everything in 15-20 minutes using a single command!

### What You Get

**Core Data Platform**:
- **📊 11 Companies** with synthetic financial data
- **📧 950 Emails** from analysts across all tickers
- **📄 850 Financial Reports** extracted with AI
- **📑 22 Annual Reports** (FY2024 + FY2025) with embedded SVG charts
- **👔 11 Executive Bios** with ~30 AI-generated portraits
- **📱 4,209 Social Media Posts** with images, geolocation, 3 languages (en/zh/fr)
- **🎙️ 1 CEO Interview** (audio) - Post-collapse investigation
- **📸 7 Social Media Images** - Product photos to crisis imagery

**AI & ML Tools**:
- **🔍 5 Search Services** for semantic search and RAG
- **📈 2 Semantic Views** for natural language SQL queries
- **🤖 1 AI Agent** (One Ticker) with 8 tools
- **💻 1 Streamlit App** (StockOne) with REST API
- **📓 4 Snowflake Notebooks** for data processing and ML
- **🧠 1 ML Model** for stock price prediction (GPU-accelerated)

---

## 🚀 Quick Start

### Prerequisites

- Snowflake account (free trial works!)
- Python 3.8+ installed
- 15-20 minutes

### Installation

```bash
# 1. Install SnowCLI
pip install snowflake-cli-labs

# 2. Clone repository
git clone https://github.com/Snowflake-Labs/sfguide-build-ai-assistant-fsi-cortex.git
cd sfguide-build-ai-assistant-fsi-cortex

# 3. Configure Snowflake connection
snow connection add

# 4. Deploy everything!
./quickstart_deploy.sh
```

### What Gets Deployed

```
✅ Database: ACCELERATE_AI_IN_FSI
✅ Role: ATTENDEE_ROLE (with CORTEX_USER)
✅ 20+ tables (~5,000 rows)
✅ 5 Cortex Search Services
✅ 2 Cortex Analyst Semantic Views
✅ 1 Snowflake Intelligence Agent
✅ 1 Streamlit Application
✅ 4 Snowflake Notebooks
```

**Deployment time**: 15-20 minutes

---

## ✨ Features

### 🔍 Cortex Search Services (5)

Semantic search across different data types:

| Service | Purpose | Records |
|---------|---------|---------|
| **Analyst Sentiment** | Search sentiment on earnings calls | 92 |
| **Analyst Reports** | Full-text search on reports | 30 |
| **Infographics** | Company infographic search | 11 |
| **Emails** | Email content search | 950 |
| **Earnings Calls** | Transcript chunk search | 317 |

### 📊 Cortex Analyst Semantic Views (2)

Natural language SQL queries:

1. **11 Companies Data** - Query financial data across all companies
2. **Snowflake Analysis** - Deep dive into Snowflake (SNOW ticker)

**Example**: Ask "What is the revenue for Snowflake?" → Get SQL + results

### 🤖 Snowflake Intelligence Agent

**One Ticker Agent** with 8 tools:
- 5 Search tools (Cortex Search)
- 2 Analyst tools (Cortex Analyst)
- 1 Web search tool (fact-checking)

**Try**: "What did analysts say about Snowflake and what is the current stock price?"

### 💻 StockOne Streamlit App

Modern chat interface with:
- ✅ **Cortex Agents REST API** integration
- ✅ **Feedback API** - Rate responses with 👍👎
- ✅ **Tool toggles** - Enable/disable search services
- ✅ **3 LLM options** - Claude, Mistral, Llama
- ✅ **Interactive visualizations** - Dynamic charts
- ✅ **Debug mode** - View API calls

### 📓 Snowflake Notebooks (4)

1. **Document AI** - Extract data from 850 financial reports
2. **Audio Analysis** - Transcribe 3 earnings calls with sentiment
3. **ML Training** - Build stock prediction model (GPU-accelerated)
4. **Search Services** - Create and test search services

### 🧠 ML Model

Pre-trained **XGBoost model** for stock price prediction:
- GPU-accelerated training
- Registered in Snowflake Model Registry
- Batch inference via SQL function

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                SNOWFLAKE CORTEX AI PLATFORM (Multi-Modal)            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  Unstructured Data    →   AI Processing     →   Structured Data     │
│  ─────────────────        ────────────────       ───────────────     │
│  • PDFs (52)              • AI_PARSE            • Tables (20+)       │
│  • HTML (850)             • AI_EXTRACT          • Views (6)          │
│  • Audio (4 MP3)          • AI_TRANSCRIBE       • 10,000+ rows       │
│  • Images (48 PNG)        • AI_CLASSIFY         • Geospatial         │
│  • Emails (950)           • AI_FILTER           • Multi-language     │
│  • Social Media (4,209)   • AI_TRANSLATE                             │
│                           • AI_SENTIMENT                             │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │                    CORTEX AISQL LAYER                          │ │
│  ├────────────────────────────────────────────────────────────────┤ │
│  │                                                                  │ │
│  │  Search (5)      Analyst (2)      ML (1)      Vision AI        │ │
│  │  ──────────      ───────────      ──────      ─────────        │ │
│  │  • Semantic      • Text-to-SQL    • XGBoost   • AI_CLASSIFY    │ │
│  │  • RAG-ready     • NL Queries     • GPU       • AI_FILTER      │ │
│  │  • Embeddings    • TICKER_SNOW    • Registry  • AI_EMBED       │ │
│  │                                                                  │ │
│  └────────────────────────┬───────────────────────────────────────┘ │
│                            │                                         │
│  ┌────────────────────────▼───────────────────────────────────────┐ │
│  │           SNOWFLAKE INTELLIGENCE (Agents & Analytics)          │ │
│  ├────────────────────────────────────────────────────────────────┤ │
│  │  One Ticker Agent:  8 Tools  |  REST API  |  Multi-Modal      │ │
│  └────────────────────────┬───────────────────────────────────────┘ │
│                            │                                         │
│  ┌────────────────────────▼───────────────────────────────────────┐ │
│  │                  APPLICATIONS                                  │ │
│  ├────────────────────────────────────────────────────────────────┤ │
│  │  StockOne Streamlit  |  Notebooks (4)  |  Homepage Portal      │ │
│  └────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📚 Documentation

- **[quickstart.md](quickstart.md)** - Step-by-step Snowflake Quickstart guide
- **[DEPLOYMENT_README.md](DEPLOYMENT_README.md)** - Detailed deployment guide
- **[deployment/README.md](deployment/README.md)** - SnowCLI deployment instructions (auto-generated)
- **Homepage Portal** - Interactive lab guide (deployed in Snowflake)

---

## 🛠 Deployment Options

### Option 1: Quick Deploy (Recommended)

One command deployment for free trial users:

```bash
./quickstart_deploy.sh
```

### Option 2: Manual Deployment

Step-by-step using SnowCLI:

```bash
# Generate SQL files
./deploy.sh

# Deploy each component
snow sql -f deployment/01_configure_account.sql -c <connection>
snow sql -f deployment/02_data_foundation.sql -c <connection>
snow sql -f deployment/03_deploy_cortex_analyst.sql -c <connection>
snow sql -f deployment/04_deploy_streamlit.sql -c <connection>
snow sql -f deployment/05_deploy_notebooks.sql -c <connection>
```

### Option 3: Snowflake UI

Copy and paste SQL files directly in Snowflake worksheets:
1. Open generated files in `/deployment/`
2. Execute in order (01 → 05)

### Option 4: DataOps.live Pipeline

For event/workshop automation:
- See [README_DATAOPS.md](README_DATAOPS.md) for pipeline configuration
- Uses `.template.sql` files with Jinja variables

---

## 🎯 Use Cases

### Financial Services

- **Portfolio Analysis**: Analyze 11 companies with natural language
- **Analyst Research**: Search 850 reports semantically
- **Earnings Analysis**: Transcribe and analyze earnings calls
- **Stock Prediction**: ML model for price forecasting
- **Email Intelligence**: Search 950 analyst emails

### Key Features

- **Multi-modal AI**: Process documents, images, audio, social media, and structured data
- **Conversational Interface**: Ask questions in plain English
- **Cited Responses**: Every answer includes source references
- **Interactive Visualizations**: Auto-generated charts from SQL results
- **Feedback Loop**: Collect user feedback to improve responses
- **Multi-language Support**: Analyze content in English, Chinese, and French
- **Geospatial Analysis**: Track global sentiment with lat/long coordinates
- **Vision AI**: Classify and filter images with AI_CLASSIFY and AI_FILTER

---

## 🧪 Try It Out

After deployment, try these:

### 1. StockOne Streamlit App

Navigate to: **AI & ML Studio** → **Streamlit** → **STOCKONE_AGENT**

**Try**:
- "What is the latest Snowflake stock price?"
- "Show me revenue trend over the last 4 quarters"
- "What did analysts say in the latest earnings call?"

### 2. One Ticker Agent

Navigate to: **AI & ML Studio** → **Snowflake Intelligence** → **One Ticker**

**Try**:
- "Compare sentiment across all 11 companies"
- "Search the web for latest Snowflake announcements"
- "Create a chart showing stock price trends"

### 3. Cortex Search

Navigate to: **AI & ML Studio** → **Cortex Search** → Select a service

**Try searching**:
- EMAILS: "Tell me about profitable companies"
- ANALYST_REPORTS_SEARCH: "What are the price targets?"

### 4. Cortex Analyst

Navigate to: **AI & ML Studio** → **Cortex Analyst** → Select a view

**Try asking**:
- "What is the total revenue for all companies?"
- "Show me companies with negative sentiment"

### 5. Snowflake Notebooks

Navigate to: **AI & ML Studio** → **Notebooks**

**Run**:
- **1_EXTRACT_DATA_FROM_DOCUMENTS** - See AI_EXTRACT process 850 reports
- **2_ANALYSE_SOUND** - See AI_TRANSCRIBE process earnings call audio
- **3_build_quantitive_model** - Train XGBoost model with GPU
- **4_CREATE_SEARCH_SERVICE** - Build and test Cortex Search

### 6. Data Explorer (Horizon Catalog)

Navigate to: **Data** → **Databases**

**Explore**:
- Browse all tables, views, and stages
- Search for: `SOCIAL_MEDIA_NRNT`, `FINANCIAL_REPORTS`
- Preview data before querying
- View schemas and metadata

### 7. Multi-Modal Analysis

**Try latest AISQL functions**:

```sql
-- Translate Chinese social media posts
SELECT 
    TEXT AS original,
    SNOWFLAKE.CORTEX.AI_TRANSLATE(TEXT, 'zh', 'en') AS translated
FROM SOCIAL_MEDIA_NRNT
WHERE LANGUAGE = 'zh';

-- Classify social media images
SELECT 
    RELATIVE_PATH,
    SNOWFLAKE.CORTEX.AI_CLASSIFY(
        TO_FILE('@DOCUMENT_AI.SOCIAL_MEDIA_IMAGES/' || RELATIVE_PATH),
        ['Product Success', 'Crisis', 'Executive', 'Personal Story']
    ) AS category
FROM DIRECTORY(@DOCUMENT_AI.SOCIAL_MEDIA_IMAGES);

-- Transcribe CEO interview
SELECT 
    SNOWFLAKE.CORTEX.AI_TRANSCRIBE(
        TO_FILE('@DOCUMENT_AI.INTERVIEWS/ElevenLabs_Audio_Interview_The_Fall_of....mp3')
    ) AS transcript;

-- Aggregate insights across thousands of posts
SELECT 
    SNOWFLAKE.CORTEX.AI_AGG(
        TEXT,
        'What were the main concerns expressed about NRNT?'
    ) AS aggregated_insights
FROM SOCIAL_MEDIA_NRNT
WHERE SENTIMENT < 0.5;
```

---

## 📊 Data Overview

### Synthetic Companies (11)

| Ticker | Company | Industry | Status |
|--------|---------|----------|--------|
| SNOW | Snowflake | Cloud Data | Market Leader |
| CTLG | Catalog Co | Technology | Profitable (FY2025) |
| DFLX | DataFlex | SaaS | Profitable (FY2025) |
| GAME | GameTech | Gaming | High Growth |
| ICBG | IceBerg | Analytics | Open Source Competitor |
| MKTG | MarketHub | Marketing Tech | Struggling |
| NRNT | Neuro-Nectar | Biotech | **COLLAPSED** (Nov 2024) |
| PROP | PropelData | Data Platform | Growth Phase |
| QRYQ | QueryIQ | Business Intelligence | Price-Performance |
| STRM | StreamCo | Streaming | Partner |
| VLTA | Volta | Energy Tech | AI-Enhanced |

**Special Story**: NRNT (Neuro-Nectar) - Complete crisis narrative from $133 to $12, including social media tracking, viral stories, and CEO interview.

### Data Breakdown

**Document AI Stages** (Unstructured):
- **Earnings Call Audio**: 3 real Snowflake MP3 files (Q1-Q3 FY2025)
- **Analyst Reports**: 30 synthetic PDFs across companies
- **Financial Reports**: 850 HTML reports + 11 PDF summaries
- **Annual Reports**: 22 comprehensive PDFs with SVG charts (FY2024 + FY2025)
- **Executive Materials**: 11 bio PDFs + ~30 AI-generated portrait images
- **Interview Audio**: 1 MP3 file (NRNT CEO post-collapse)
- **Social Media Images**: 7 PNG files (product to crisis imagery)
- **Infographics**: 11 company summary graphics
- **Investment Research**: 7 PDFs (Federal Reserve & NBER papers)

**Structured Tables**:
- **Transcribed Earnings Calls**: 1,788 segments with sentiment
- **Email Previews**: 950 analyst emails across 11 tickers
- **Stock Prices**: 6,420 data points (SNOW ticker)
- **Social Media Posts**: 4,209 posts (en/zh/fr) with geolocation
- **And more**: 15+ additional tables

**Note**: All data except Snowflake earnings calls is synthetic/demonstration data.

---

## 🔧 Customization

### Add Your Own Data

1. **Add company data**: Edit `/dataops/event/DATA/companies.csv`
2. **Add financial reports**: Create HTML in `/document_ai/financial_reports_html/`
3. **Add stock data**: Update parquet file or create new STOCK_PRICES rows

### Extend Search Services

Create custom search services:

```sql
CREATE OR REPLACE CORTEX SEARCH SERVICE MY_SEARCH
ON content_column
ATTRIBUTES category, date
WAREHOUSE = DEFAULT_WH
TARGET_LAG = '1 hour'
AS (SELECT * FROM MY_TABLE);
```

### Add Agent Tools

Create custom functions and add to agent:

```sql
CREATE FUNCTION MY_CUSTOM_TOOL(input VARCHAR)
RETURNS VARCHAR
AS $$ ... $$;
```

Then update agent spec in `deploy_cortex_analyst.template.sql`

---

## 📖 Learn More

### Snowflake Cortex Documentation

- [Cortex AI Overview](https://docs.snowflake.com/en/user-guide/snowflake-cortex/overview)
- [Cortex Search](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search/cortex-search-overview)
- [Cortex Analyst](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst)
- [Snowflake Intelligence](https://docs.snowflake.com/en/user-guide/snowflake-cortex/snowflake-intelligence)
- [Cortex Agents REST API](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents-rest-api)
- [Document AI](https://docs.snowflake.com/en/user-guide/snowflake-cortex/document-ai)

### Project Documentation

- **[quickstart.md](quickstart.md)** - Complete Snowflake Quickstart guide
- **[DEPLOYMENT_README.md](DEPLOYMENT_README.md)** - Technical deployment details
- **[README_DATAOPS.md](README_DATAOPS.md)** - DataOps.live pipeline documentation

---

## 🏗 Project Structure

```
fsi-cortex-assistant/
├── quickstart_deploy.sh          # One-command deployment
├── deploy.sh                      # Generates deployment files
├── quickstart.md                  # Snowflake Quickstart guide
├── DEPLOYMENT_README.md           # Technical documentation
│
├── dataops/event/
│   ├── DATA/                      # 19 CSV files (~5 MB)
│   │   ├── financial_reports.csv (850 rows, 11 companies)
│   │   ├── email_previews_extracted.csv (950 rows)
│   │   ├── call_embeds.csv (317 rows)
│   │   └── ... (16 more files)
│   │
│   ├── document_ai/               # PDFs & HTML files
│   │   ├── financial_reports/    (30 PDFs)
│   │   ├── financial_reports_html/ (850+ HTML files)
│   │   └── infographics_simple/  (11 PNG files)
│   │
│   ├── notebooks/                 # 4 Snowflake notebooks
│   │   ├── 1_EXTRACT_DATA_FROM_DOCUMENTS.ipynb
│   │   ├── 2_ANALYSE_SOUND.ipynb
│   │   ├── 3_build_quantitive_model.ipynb
│   │   └── 4_CREATE_SEARCH_SERVICE.ipynb
│   │
│   ├── annual_reports_2024/       # FY2024 annual reports (11 MD files)
│   ├── annual_reports_2025/       # FY2025 annual reports (11 MD + charts)
│   ├── annual_reports_pdfs/       # Generated PDFs (22 files)
│   ├── executive_bios/            # Executive team bios (11 MD + PDF files)
│   ├── portraits/                 # AI-generated executive portraits (~30 PNG)
│   ├── social_media_images/       # Social media photos (7 PNG files)
│   ├── interviews/                # CEO interview audio (1 MP3)
│   │
│   ├── streamlit/                 # Streamlit app
│   │   └── 2_cortex_agent_soph/  (StockOne app)
│   │       ├── app.py (REST API + Feedback)
│   │       ├── styles.css
│   │       └── environment.yml
│   │
│   ├── homepage/                  # MkDocs documentation portal
│   │   ├── docs/
│   │   │   ├── More_Activities.md  (Hackathon guide)
│   │   │   └── assets/
│   │   └── mkdocs.yml
│   │
│   ├── analyst/                   # Semantic model YAML files
│   │   ├── analyst_sentiments.yaml
│   │   └── semantic_model.yaml
│   │
│   └── *.template.sql            # Deployment SQL scripts
│       ├── configure_attendee_account.template.sql
│       ├── data_foundation.template.sql
│       ├── deploy_cortex_analyst.template.sql
│       ├── deploy_streamlit.template.sql
│       └── deploy_notebooks.template.sql
│
└── deployment/                    # Generated SQL (after running deploy.sh)
    ├── 01_configure_account.sql
    ├── 02_data_foundation.sql
    ├── 03_deploy_cortex_analyst.sql
    ├── 04_deploy_streamlit.sql
    ├── 05_deploy_notebooks.sql
    └── deploy_all.sql (master script)
```

---

## 🎓 Learning Path

### Beginner (Start Here)

1. **Deploy the quickstart** → `./quickstart_deploy.sh`
2. **Try StockOne app** → Ask simple questions
3. **Explore search services** → See semantic search in action
4. **Test Cortex Analyst** → Natural language SQL

### Intermediate

1. **Run Notebook 1** → See Document AI extract data
2. **Run Notebook 2** → See audio transcription
3. **Customize semantic views** → Add your own tables
4. **Extend the agent** → Add custom tools

### Advanced

1. **Train ML model** (Notebook 3) → GPU-accelerated training
2. **Build custom search service** (Notebook 4) → Your own data
3. **Modify Streamlit app** → Add features, customize UI
4. **Deploy to production** → Scale and optimize

---

## 🎬 Demo Scenarios

### Scenario 1: Portfolio Manager

**Goal**: Analyze multiple stocks and make investment decisions

**Workflow**:
1. Open StockOne app
2. Ask: "Compare revenue growth across all 11 companies"
3. Ask: "Which companies have positive analyst sentiment?"
4. Ask: "Show me the latest stock price for top performers"
5. Use visualizations to present to clients

### Scenario 2: Financial Analyst

**Goal**: Deep research on specific company (Snowflake)

**Workflow**:
1. Use One Ticker agent
2. Ask: "What did analysts say about Snowflake in recent reports?"
3. Ask: "Show me sentiment trend from earnings calls"
4. Ask: "What is the price target from latest analyst reports?"
5. Search web: "Fact-check latest Snowflake product announcements"

### Scenario 3: Data Scientist

**Goal**: Build ML model for stock predictions

**Workflow**:
1. Open Notebook 3 (Build Quantitative Model)
2. Review feature engineering on STOCK_PRICES
3. Train XGBoost model with GPU acceleration
4. Register model in Model Registry
5. Make predictions via SQL function

### Scenario 4: Business Intelligence

**Goal**: Create dashboards with natural language queries

**Workflow**:
1. Use Cortex Analyst semantic views
2. Ask complex questions without writing SQL
3. Export results to dashboards
4. Schedule automated reports

---

## 🔐 Security & Access

### Role-Based Access Control

All objects created with **ATTENDEE_ROLE**:
- ✅ Tables, views, search services
- ✅ Semantic views, agents
- ✅ Streamlit app, notebooks
- ✅ Functions, procedures

**Benefits**:
- Owner has all privileges automatically
- No complex grant management
- Clean security model
- Streamlit runs as owner (full access)

### CORTEX_USER Database Role

Required for Cortex AI features:

```sql
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE ATTENDEE_ROLE;
```

Enables:
- Cortex AI functions (AI_EXTRACT, AI_TRANSCRIBE, etc.)
- Cortex Search Services
- Cortex Analyst
- Cortex Agents REST API

---

## 🐛 Troubleshooting

### Issue: SnowCLI not found

```bash
pip install snowflake-cli-labs
snow --version
```

### Issue: Connection failed

```bash
# Reconfigure connection
snow connection add

# Test connection
snow connection test -c <connection_name>
```

### Issue: Deployment fails

Check deployment logs:
```bash
tail -100 /tmp/deploy_*.log
```

Common causes:
- Insufficient privileges (use ACCOUNTADMIN)
- Warehouse not running
- Network connectivity issues

### Issue: Objects not accessible

Verify role ownership:
```sql
USE ROLE ACCOUNTADMIN;
SHOW TABLES IN ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA;
-- Check "owner" column should be ATTENDEE_ROLE
```

### Issue: Search service 404 error

Ensure fully qualified names:
```python
# Streamlit app configuration
"location": "ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAILS"
# Not just: "DEFAULT_SCHEMA.EMAILS"
```

For detailed troubleshooting, see [DEPLOYMENT_README.md](DEPLOYMENT_README.md#troubleshooting)

---

## 💡 Tips & Best Practices

### Cost Optimization

✅ **Use pre-loaded data** - Notebooks have intermediate results cached  
✅ **Set warehouse auto-suspend** - Avoids idle compute costs  
✅ **Use appropriate warehouse sizes** - SMALL for search, MEDIUM for document AI  
✅ **Leverage search services** - More efficient than full table scans

### Performance

✅ **Fully qualify table names** - Avoids context switching  
✅ **Use semantic views** not YAML files - Better performance  
✅ **Enable search service caching** - Faster repeat queries  
✅ **Pre-load expensive AI operations** - Saves credits on demos

### Production Readiness

✅ **Monitor query history** - Track API usage and costs  
✅ **Collect feedback** - Use Feedback API for improvements  
✅ **Set token budgets** - Control agent execution costs  
✅ **Use smaller models** - Llama 3.3 70B for simple queries

---

## 🤝 Contributing

Contributions welcome! To contribute:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Ideas for Contributions

- Add more synthetic companies or industries
- Create additional search services for new data types
- Build new agent tools (e.g., news sentiment, insider trading alerts)
- Enhance visualizations in StockOne (geospatial maps, timeline charts)
- Add new Snowflake notebooks for different analyses
- Extend social media dataset (more languages, platforms, stories)
- Add more executive portraits and bios
- Create additional crisis narratives for other companies
- Improve documentation and examples

---

## 📝 License

This project is provided as-is for educational and demonstration purposes.

**Data Notes**:
- Snowflake earnings calls are real (public data)
- All other data is synthetic/generated for demonstration
- Not suitable for actual investment decisions
- Use only for learning Snowflake Cortex AI capabilities

---

## 🆘 Support

### Documentation

- **Quickstart Guide**: See [quickstart.md](quickstart.md)
- **Deployment Guide**: See [DEPLOYMENT_README.md](DEPLOYMENT_README.md)
- **Snowflake Docs**: https://docs.snowflake.com

### Community

- **Snowflake Community**: https://community.snowflake.com
- **GitHub Issues**: Submit issues to sfquickstarts repository
- **Snowflake Support**: For account-specific issues

### Resources

- **Repository**: https://github.com/Snowflake-Labs/sfguide-build-ai-assistant-fsi-cortex
- **Snowflake Quickstarts**: https://quickstarts.snowflake.com
- **Cortex AI Tutorials**: https://docs.snowflake.com/en/user-guide/snowflake-cortex/tutorials

---

## 🎉 What's Next?

### Extend Your Solution

- ✅ Add real market data feeds
- ✅ Connect to news APIs for sentiment
- ✅ Build risk analytics dashboard
- ✅ Create automated trading signals
- ✅ Deploy portfolio optimization models

### Learn More Quickstarts

- Getting Started with Cortex AISQL
- Building RAG Applications with Cortex Search
- Document AI for Business Intelligence  
- Snowpark ML for Time Series Forecasting
- Multi-Modal AI with Images and Audio
- Geospatial Analysis with Snowflake
- Social Media Sentiment Analysis
- Cortex Agents for Agentic Workflows

### Join the Community

- ⭐ Star this repository
- 📣 Share what you built
- 💬 Join Snowflake Community forums
- 🚀 Deploy to production

---

<p align="center">
  <strong>Built with ❄️ by Snowflake Solutions Engineering</strong>
</p>

<p align="center">
  <a href="https://quickstarts.snowflake.com">Snowflake Quickstarts</a> •
  <a href="https://docs.snowflake.com">Documentation</a> •
  <a href="https://community.snowflake.com">Community</a>
</p>

