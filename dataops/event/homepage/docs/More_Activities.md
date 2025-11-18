# <h1black>More Activities and </h1black><h1blue>Hackathon Ideas</h1blue>

<p align="center">
  <img src="assets/hackathon_image.png" width="800" alt="Hackathon Activities"/>
</p>

## <h1sub>Explore Your Data with Advanced AI Features</h1sub>

You have access to a **comprehensive financial data platform** in Snowflake with rich datasets. This page provides hackathon ideas and activities to explore advanced Cortex AI features and build your own solutions.

---

## <h1sub>Available Datasets in Your Snowflake Account</h1sub>

You have access to extensive financial data across **11 companies** and multiple data types.

### 🎯 Your Hackathon Central Repository: `HACKATHON_DATASETS`

!!! success "**USE THIS DATABASE FOR YOUR HACKATHON PROJECTS!**"
    
    **`HACKATHON_DATASETS`** is your **primary working database** - organized specifically for hackathon participants with meaningful, content-based schemas.
    
    ✅ **Use for**: Building new content, creating tables, developing your solutions  
    ✅ **Use for**: All your queries, analysis, and AI function experiments  
    ✅ **Use for**: Streamlit apps, notebooks, and custom applications  
    
    📚 **Other databases** (`ACCELERATE_AI_IN_FSI`, `AISQL_EXAMPLES`) are **reference-only** for exploring examples and documentation.

### Database Structure: `HACKATHON_DATASETS`

Your hackathon data is organized into **5 intuitive, content-based schemas**:

```
HACKATHON_DATASETS (Database) 👈 YOUR PRIMARY WORKSPACE
│
├── 📊 FINANCIAL_DATA
│   │   (Stock prices, analyst reports, financial statements)
│   │
│   ├── Tables (9 tables)
│   │   ├── STOCK_PRICES (6,420 rows)
│   │   ├── ANALYST_REPORTS (30 rows)
│   │   ├── ANALYST_REPORTS_ALL_DATA (full text)
│   │   ├── FINANCIAL_REPORTS (850 rows)
│   │   ├── INFOGRAPHICS_FOR_SEARCH
│   │   ├── INFOGRAPHIC_METRICS_EXTRACTED
│   │   ├── PARSED_ANALYST_REPORTS
│   │   ├── AI_EXTRACT_ANALYST_REPORTS_ADVANCED
│   │   └── REPORT_PROVIDER_SUMMARY
│   │
│   ├── Views (5 views)
│   │   ├── VW_INFOGRAPHIC_METRICS
│   │   ├── VW_FINANCIAL_SUMMARY
│   │   ├── VW_INCOME_STATEMENT
│   │   ├── VW_KPI_METRICS
│   │   └── STOCK_PRICE_TIMESERIES
│   │
│   └── Stages (3 stages with files)
│       ├── @analyst_reports (30 PDFs)
│       ├── @financial_reports (11 PDFs)
│       └── @infographics (11 PNGs)
│
├── 🎙️ EARNINGS_ANALYSIS
│   │   (Audio transcripts, sentiment analysis)
│   │
│   ├── Tables (10 tables)
│   │   ├── TRANSCRIBED_EARNINGS_CALLS (1,788 rows)
│   │   ├── AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS
│   │   ├── TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT
│   │   ├── TRANSCRIPTS_BY_MINUTE
│   │   ├── SENTIMENT_ANALYSIS (15 rows)
│   │   ├── unique_transcripts (92 rows)
│   │   ├── SPEAKER_MAPPING
│   │   ├── AI_TRANSCRIBE_NO_TIME
│   │   ├── call_embeds
│   │   └── FULL_TRANSCRIPTS
│   │
│   ├── Views (1 view)
│   │   └── SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH
│   │
│   └── Stages (1 stage)
│       └── @earnings_calls (3 MP3 audio files)
│
├── 🏢 CORPORATE_DOCS
│   │   (Annual reports, executive bios, interviews)
│   │
│   └── Stages (4 stages with documents)
│       ├── @ANNUAL_REPORTS (22 PDFs - FY2024 + FY2025)
│       ├── @EXECUTIVE_BIOS (11 PDFs)
│       ├── @EXECUTIVE_PORTRAITS (~30 images)
│       └── @interviews (1 MP3 interview)
│
├── 💬 COMMUNICATIONS
│   │   (Emails and social media)
│   │
│   ├── Tables (3 tables)
│   │   ├── EMAIL_PREVIEWS (324 emails)
│   │   ├── EMAIL_PREVIEWS_EXTRACTED (950 rows)
│   │   └── SOCIAL_MEDIA_NRNT (4,391 posts)
│   │
│   └── Functions & Procedures
│       ├── WEB_SEARCH() - Search the web
│       └── SEND_EMAIL_NOTIFICATION() - Send emails
│
└── 📚 INVESTMENT_RESEARCH
    │   (Academic research papers and investment topics)
    │
    └── Stages (6 stages with diverse research topics)
        ├── @investment_management (7 PDFs - Fed & NBER papers)
        ├── @esg_investing (ESG & sustainable investing research)
        ├── @risk_management (Risk analysis & regulatory frameworks)
        ├── @portfolio_strategy (Modern portfolio theory & asset allocation)
        ├── @market_research (IMF, World Bank, ECB economic research)
        └── @quantitative_methods (Quant finance & algorithmic trading)
```

### 📚 Reference Databases (Information Only)

You also have access to two reference databases for learning and examples:

#### `ACCELERATE_AI_IN_FSI` (Reference Only)
- **Purpose**: Demo database with search services and Cortex Analyst examples
- **Contains**: Same data as HACKATHON_DATASETS + AI services (search, semantic views, agents)
- **Use for**: Learning how search services work, exploring Cortex Analyst capabilities
- **Note**: Use `HACKATHON_DATASETS` for your projects - this is for reference only

#### `AISQL_EXAMPLES` (Reference Only) 
- **Purpose**: Example notebooks and datasets for learning AISQL features
- **Contains**: 4 example use cases (ads analytics, customer reviews, marketing leads, healthcare)
- **Use for**: Learning AI SQL patterns, exploring notebook examples
- **Note**: Copy patterns to your own projects in `HACKATHON_DATASETS`

---

### 🚀 Quick Start for Hackathon Projects

**Step 1: Set Your Working Database**
```sql
USE DATABASE HACKATHON_DATASETS;
```

**Step 2: Explore Your Schemas**
```sql
-- Financial data: stock prices, analyst reports
USE SCHEMA FINANCIAL_DATA;
SHOW TABLES;
SELECT * FROM STOCK_PRICES LIMIT 10;

-- Transcripts and sentiment analysis
USE SCHEMA EARNINGS_ANALYSIS;
SHOW TABLES;
SELECT * FROM TRANSCRIPTS_BY_MINUTE LIMIT 10;

-- Email and social media data
USE SCHEMA COMMUNICATIONS;
SELECT * FROM SOCIAL_MEDIA_NRNT LIMIT 10;
```

**Step 3: Access Documents and Media**
```sql
-- List analyst reports (PDFs)
LIST @HACKATHON_DATASETS.FINANCIAL_DATA.analyst_reports;

-- List earnings call audio files (MP3)
LIST @HACKATHON_DATASETS.EARNINGS_ANALYSIS.earnings_calls;

-- List annual reports (PDFs)
LIST @HACKATHON_DATASETS.CORPORATE_DOCS.ANNUAL_REPORTS;
```

**Step 4: Create Your Own Tables**
```sql
-- You have full permissions to create tables in HACKATHON_DATASETS
USE DATABASE HACKATHON_DATASETS;
USE SCHEMA FINANCIAL_DATA;  -- or any schema

CREATE OR REPLACE TABLE my_analysis AS
SELECT 
    TICKER,
    DATE,
    "'all-day_high'" AS HIGH,
    "'all-day_low'" AS LOW
FROM STOCK_PRICES
WHERE TICKER = 'SNOW'
  AND DATE >= '2024-01-01';
```

**Step 5: Add Your Own Data to Investment Research Stages (Optional)**

The `INVESTMENT_RESEARCH` schema includes 6 pre-populated stages with example research papers. **You can add your own publicly available documents** to these stages or create new stages for your specific research topics!

```sql
-- Example: Add your own ESG research papers
PUT file:///path/to/your/esg_paper.pdf 
@HACKATHON_DATASETS.INVESTMENT_RESEARCH.esg_investing 
auto_compress=false overwrite=false;

-- Refresh the stage to update file listing
ALTER STAGE HACKATHON_DATASETS.INVESTMENT_RESEARCH.esg_investing REFRESH;

-- Verify your upload
LIST @HACKATHON_DATASETS.INVESTMENT_RESEARCH.esg_investing;

-- Create your own research stage for a new topic
CREATE OR REPLACE STAGE HACKATHON_DATASETS.INVESTMENT_RESEARCH.my_research_topic
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse')
  COMMENT = 'My custom research topic papers';

-- Upload files to your new stage
PUT file:///path/to/research/*.pdf 
@HACKATHON_DATASETS.INVESTMENT_RESEARCH.my_research_topic 
auto_compress=false;
```

!!! tip "Public Data Sources for Investment Research"
    
    **Suggested sources for publicly available research papers:**
    
    📈 **Financial Markets & Economics**
    - Federal Reserve (federalreserve.gov) - monetary policy, economic research
    - IMF (imf.org) - global economic reports, financial stability
    - World Bank (worldbank.org) - development economics
    - Bank for International Settlements (bis.org) - banking regulation
    
    🌱 **ESG & Sustainability**
    - UN PRI (unpri.org) - responsible investment frameworks
    - MSCI (msci.com) - ESG research and insights
    - SASB (sasb.org) - sustainability accounting standards
    
    📊 **Academic & Quantitative Research**
    - ArXiv.org (q-fin section) - quantitative finance papers
    - SSRN (ssrn.com) - social science research
    - NBER (nber.org) - economic working papers
    - CFA Institute (cfainstitute.org) - investment research
    
    **All stages already contain example papers** - use these as starting points or add your own relevant research!

!!! note "Additional Resources Available"
    **Horizon Catalog - Data Explorer**
    
    Use the **Data Explorer** in Horizon Catalog to easily discover and search all available data:
    
    - Navigate to: **Data** → **Databases** (or click the Data icon in left menu)
    - Browse **`HACKATHON_DATASETS`** database and all its schemas
    - Search for specific tables or datasets
    - Preview data and view table schemas
    - Quickly find: `SOCIAL_MEDIA_NRNT`, Annual Reports stages, and more!
    
    **Finding Your Data**
    
    ```sql
    -- See all databases
    SHOW DATABASES;
    
    -- Explore HACKATHON_DATASETS
    USE DATABASE HACKATHON_DATASETS;
    SHOW SCHEMAS;
    
    -- Explore each schema
    USE SCHEMA FINANCIAL_DATA;
    SHOW TABLES;
    SHOW STAGES;
    
    USE SCHEMA EARNINGS_ANALYSIS;
    SHOW TABLES;
    
    USE SCHEMA COMMUNICATIONS;
    SHOW TABLES;
    ```
    
    **Snowflake Marketplace Data**
    
    Don't forget about the **Snowflake Marketplace** datasets! 
    
    On the **Home page**, go to **Data Products** → **Marketplace**
    
    - Search for: **share prices snowflake**
    - Click on: **Snowflake Public Data (Paid)** dataset
    - Access real-time stock market data for your analysis
    
    See the [Marketplace](market_place.md) section for detailed instructions.
    
    **Snowflake Quickstarts**
    
    Explore hundreds of additional tutorials and guides:
    
    - Visit: [Snowflake Quickstarts](https://quickstarts.snowflake.com/)
    - Topics: Cortex AI, Streamlit, Snowpark, ML, Data Engineering, and more
    - Find guides for building RAG apps, analyzing customer reviews, geospatial analysis, and much more!

---

## <h1sub>Hackathon Challenge Ideas</h1sub>

### Challenge 1: Multi-Source Intelligence Dashboard

**Goal**: Build a comprehensive company analysis dashboard

**Datasets to Use** (all in `HACKATHON_DATASETS`):
- Annual Reports (22 PDFs) - FY data in `CORPORATE_DOCS` schema
- Analyst Reports (30 PDFs) - Expert opinions in `FINANCIAL_DATA` schema
- Earnings Transcripts (1,788 segments) - Management commentary in `EARNINGS_ANALYSIS` schema
- Email data (950 emails) - Analyst sentiment in `COMMUNICATIONS` schema
- Stock prices (6,420 points) - Market performance in `FINANCIAL_DATA` schema

**AI Features to Explore**:
- `AI_EXTRACT` - Extract key metrics from annual reports
- `AI_SENTIMENT` - Analyze sentiment from emails and transcripts
- Join multiple data sources for comprehensive analysis

**Deliverable**: Streamlit dashboard showing company health scores

---

### Challenge 2: Neuro-Nectar Crisis Analysis (Multi-Modal)

**Goal**: Analyze the complete NRNT rise and fall using ALL data types including social media

**Datasets** (all in `HACKATHON_DATASETS`):
- NRNT Annual Reports (FY2024 + FY2025 liquidation) - `CORPORATE_DOCS` schema
- NRNT earnings transcript (Q2 FY2025) - `EARNINGS_ANALYSIS` schema
- Stock price data (crash from $133.75 to $12.79) - `FINANCIAL_DATA` schema
- Analyst emails discussing NRNT - `COMMUNICATIONS` schema
- **SOCIAL MEDIA** (4,209 posts with images, 3 languages) - `COMMUNICATIONS` schema
- **Interview Audio** (NRNT CEO post-collapse) - `CORPORATE_DOCS` schema
- **Social Media Images** (7 images showing crisis progression) - `CORPORATE_DOCS` schema

**AI Features to Explore**:
- `AI_EXTRACT` - Extract financial data from annual reports (identify warning signs and red flags)
- `AI_SENTIMENT` - Analyze social media sentiment over time
- `AI_TRANSLATE` - Translate posts from Chinese and French to English
- `AI_TRANSCRIBE` - Transcribe CEO interview audio
- `AI_CLASSIFY` - Categorize posts by crisis phase (Early Hype, Warning Signs, Crisis, Collapse, Aftermath)
- `AI_AGG` - Aggregate insights across thousands of social media posts
- Geospatial analysis - Track how the crisis spread globally
- Image analysis - Understand the visual narrative progression

**Deliverable**: Multi-modal crisis analysis dashboard with text, images, audio, and geospatial data

---

### Challenge 3: Competitive Intelligence Platform

**Goal**: Compare SNOW vs. ICBG vs. QRYQ using all data sources

**Datasets** (all in `HACKATHON_DATASETS`):
- Annual reports for all 3 companies (FY2024 + FY2025) - `CORPORATE_DOCS` schema
- Financial reports (quarterly data) - `FINANCIAL_DATA` schema
- Analyst reports mentioning competition - `FINANCIAL_DATA` schema
- Stock price performance - `FINANCIAL_DATA` schema
- Sentiment from earnings calls - `EARNINGS_ANALYSIS` schema

**AI Features to Explore**:
- `AI_FILTER` - Find documents discussing competitive dynamics
- `AI_AGG` - Summarize competitive advantages across all reports
- `AI_EXTRACT` - Extract win rates and market share data
- Compare metrics side-by-side across competitors

**Deliverable**: Competitive intelligence report with visualizations

---

### Challenge 4: Investment Recommendation Engine

**Goal**: Build an AI-powered investment advisor

**Datasets** (all in `HACKATHON_DATASETS`):
- Annual reports (comprehensive financial data) - `CORPORATE_DOCS` schema
- Stock prices (historical performance) - `FINANCIAL_DATA` schema
- Analyst ratings from emails (BUY, HOLD, SELL) - `COMMUNICATIONS` schema
- Sentiment scores from transcripts - `EARNINGS_ANALYSIS` schema
- Investment research papers (7 PDFs with portfolio theory) - `INVESTMENT_RESEARCH` schema

**AI Features to Explore**:
- `AI_COMPLETE` - Generate investment thesis and recommendations
- `AI_FILTER` - Identify high-quality investment opportunities
- `AI_CLASSIFY` - Categorize companies by investment grade (Strong Buy, Buy, Hold, Sell, High Risk)
- Combine multiple data sources for comprehensive analysis

**Deliverable**: Investment recommendation app with AI-generated insights

---

### Challenge 5: Document AI Deep Dive

**Goal**: Process annual reports with advanced Document AI techniques

**Datasets** (all in `HACKATHON_DATASETS`):
- Annual reports (22 PDFs) - `CORPORATE_DOCS` schema
- Social media images (7 images) - `CORPORATE_DOCS` schema

**AI Features to Explore**:
- `AI_PARSE_DOCUMENT` - Extract document structure and layout
- `AI_EXTRACT` with complex instructions - Extract competitive positioning, win rates, market share
- Vision AI - Extract data from charts and graphs embedded in PDFs
- `AI_FILTER` on images - Find crisis visuals
- `AI_CLASSIFY` on images - Categorize by emotional tone (Positive, Neutral, Negative, Tragic)

**Deliverable**: Document AI analysis pipeline

---

### Challenge 6: Real-Time Financial News Monitor

**Goal**: Combine historical data with web search for current analysis

**Datasets** (all in `HACKATHON_DATASETS`):
- Annual reports (baseline financial data) - `CORPORATE_DOCS` schema
- Stock prices (historical trends) - `FINANCIAL_DATA` schema
- Analyst reports (expert opinions) - `FINANCIAL_DATA` schema
- Sentiment scores - `EARNINGS_ANALYSIS` schema

**AI Features to Explore**:
- `WEB_SEARCH()` function - Get current financial news (in `COMMUNICATIONS` schema)
- `AI_SENTIMENT` - Compare historical vs. current sentiment
- `AI_EXTRACT` - Extract revenue figures and price targets from news
- Trend analysis - Identify improving or declining sentiment

**Deliverable**: Real-time monitoring dashboard with alerts

---

### Challenge 7: Natural Language Financial Analyst

**Goal**: Build a conversational agent that answers complex financial questions

**Datasets** (all in `HACKATHON_DATASETS`):
- Financial reports - `FINANCIAL_DATA` schema
- Analyst reports - `FINANCIAL_DATA` schema
- Stock prices - `FINANCIAL_DATA` schema
- All other data in meaningful schemas

**AI Features to Explore**:
- `AI_COMPLETE` - Multi-step reasoning with Claude or Llama models
- Combine multiple data sources (financial data + analyst opinions + current prices)
- Natural language question answering
- Investment recommendations with reasoning

**Deliverable**: Conversational financial advisor chatbot

---

### Challenge 8: AI-Powered Report Generation

**Goal**: Automatically generate executive summaries from annual reports

**Datasets** (all in `HACKATHON_DATASETS`):
- Annual reports (22 PDFs) - `CORPORATE_DOCS` schema

**AI Features to Explore**:
- `SUMMARIZE` - Create executive summaries of annual reports
- `AI_COMPLETE` - Generate comparative analysis across multiple companies
- `AI_AGG` - Summarize insights across ALL reports at once
- Compare competitive positioning and identify companies with strongest moats

**Deliverable**: Automated report generation system

---

### Challenge 9: Social Media Crisis Detection

**Goal**: Build early warning system for product/company crises using social media data

**Dataset** (in `HACKATHON_DATASETS.COMMUNICATIONS`):
- SOCIAL_MEDIA_NRNT table (4,391 items across Aug-Dec 2024)

**Key Features**:
- **4,391 total items** in 3 languages (English, French, Chinese)
- **Social media posts**: 4,188 (Twitter, Reddit, LinkedIn, Facebook, Instagram)
- **News articles**: 35 long-form pieces (Bloomberg, Reuters, WSJ, CNBC, etc.)
- **Cross-company posts**: 168 (tracking SNOW and VLTA impact)
- **338 posts with images** (7 unique images showing crisis progression)
- **Geolocation** data (31 cities, 13+ countries)
- **Viral story tracking** (83 posts about Chinese mother hospitalization)

**AI Features to Explore**:
- Sentiment velocity - Detect rate of sentiment decline over time
- Viral post identification - Find high-engagement crisis posts
- Image analysis - Track shift from positive to crisis visuals
- `AI_TRANSLATE` - Analyze posts in Chinese and French
- `AI_FILTER` - Find posts mentioning hospitalizations or recalls
- `AI_CLASSIFY` on images - Categorize photos (Product Success, Crisis/Recall, Executive Departure, Personal Tragedy)
- Geospatial analysis - Track crisis spread across cities and countries

**Deliverable**: Real-time social media crisis monitoring dashboard

---

### Challenge 10: Human Stories in Data (Ethics & Impact)

**Goal**: Analyze how personal narratives drive crisis perception

**Dataset** (in `HACKATHON_DATASETS.COMMUNICATIONS`):
- SOCIAL_MEDIA_NRNT table with the viral Chinese mother story

**Story Background**:
- Chinese man bought NRNT ice cream for elderly mother (memory issues)
- Mother hospitalized with brain damage + gastric problems
- Son devastated, blaming himself
- **Reuters broke the story** (professional news article)
- **Social media amplification**: 83 posts sharing/reacting
- Story went viral Sept 11-21, 2024
- Appears in both news articles AND social media

**AI Features to Explore**:
- `AI_AGG` - Track emotional themes over time
- `AI_CLASSIFY` - Categorize posts by narrative type (Personal Tragedy, Health Crisis, Legal/Regulatory, etc.)
- `AI_TRANSLATE` - Analyze reactions across different languages and countries
- `AI_FILTER` - Find empathetic responses
- Compare news article coverage vs social media amplification
- Geographic spread of emotional contagion

**Discussion Questions**:
- How do personal stories amplify crisis perception?
- What role does emotion play in viral content?
- How does professional news coverage differ from social media?
- Does a news article increase credibility vs social posts?
- How should companies respond to human-impact stories?
- What are the ethics of using AI to analyze personal tragedies?

**Deliverable**: Research paper or ethics presentation

---

### Challenge 11: News vs Social Media Analysis

**Goal**: Compare professional journalism with social media reactions

**Dataset** (in `HACKATHON_DATASETS.COMMUNICATIONS`):
- SOCIAL_MEDIA_NRNT table with 35 news articles + 4,188 social posts

**Key Differences to Analyze**:
- **News**: Long-form (400-2,000 chars), credible outlets, investigative
- **Social**: Short-form (50-200 chars), real-time, emotional

**AI Features to Explore**:
- Compare text length, sentiment, and engagement between news and social media
- `SUMMARIZE` - Create summaries of news articles
- `AI_EXTRACT` - Extract key facts, figures, and quotes from professional journalism
- `AI_AGG` - Compare how news frames issues vs how social media discusses them
- Track cross-company impact (SNOW, VLTA references in NRNT crisis)
- Analyze credibility and reach differences

**Deliverable**: Media analysis comparing professional vs user-generated content

---

## <h1sub>Advanced AI Features to Explore</h1sub>

### AI_FILTER - Intelligent Document & Image Filtering

**What it does**: Uses LLMs to filter documents, text, and images based on semantic meaning

**Latest Syntax**: `SNOWFLAKE.CORTEX.AI_FILTER(input, condition)`

**Use Cases**:
- **Find Companies Approaching Profitability** - Filter financial data using semantic reasoning
- **Find Documents Discussing Technology Differentiation** - Search PDFs for specific topics
- **Filter Images by Content** - Identify crisis images or emotional content  
- **Identify High-Risk Companies** - Detect financial distress signals

### AI_TRANSLATE - Multi-Language Support

**Latest Syntax**: `SNOWFLAKE.CORTEX.AI_TRANSLATE(text, source_language, target_language)`

**Use Cases**:
- Translate analyst reports to multiple languages (Spanish, German, Japanese, Chinese)
- Translate Chinese and French social media posts to English
- Combine with AI_SENTIMENT to analyze translated content
- Classify multilingual posts by topic after translation

### AI_TRANSCRIBE - Audio to Text with Timestamps

**Latest Syntax**: `SNOWFLAKE.CORTEX.AI_TRANSCRIBE(TO_FILE(stage_path), options)`

**Use Cases**:
- Transcribe NRNT CEO interview with timestamps and speaker detection
- Extract key insights and lessons learned from interviews
- Analyze interview sentiment and tone (Apologetic, Defensive, Educational, Resigned)
- Compare CEO interview sentiment with social media sentiment to identify gaps

### AI_EMBED - Semantic Embeddings (Text & Images)

**Latest Syntax**: `SNOWFLAKE.CORTEX.AI_EMBED(model, input)` - Supports text AND images!

**Use Cases**:
- Create embeddings for annual reports using text models (e5-base-v2)
- Create embeddings for images using vision models (clip-vit-base-patch32)
- Find similar documents using AI_SIMILARITY
- Semantic search for "companies with strong revenue growth"
- Find images similar to specific concepts ("product waste", "crisis situations")

### AI_CLASSIFY - Auto-Categorization (Text & Images)

**Latest Syntax**: `SNOWFLAKE.CORTEX.AI_CLASSIFY(input, categories)` - Supports text AND images!

**Use Cases**:
- Classify companies by growth stage (Early Stage, Scaling to Profitability, Distressed, etc.)
- Classify images by content type (Product Marketing, Crisis/Recall, Personal Tragedy)
- Multi-label classification of social media posts (Health Complaint, Financial Loss, Emotional Response)
- Tag images and text into predefined categories

### AI_AGG & AI_SUMMARIZE_AGG - Aggregate Insights

**New Functions**: Aggregate text across multiple rows without context limits!

**Use Cases**:
- Aggregate all posts about specific stories (e.g., Chinese mother hospitalization reactions)
- Summarize crisis evolution week by week from social media posts
- Aggregate insights from ALL annual reports to find common strategic initiatives

### SPLIT_TEXT_RECURSIVE_CHARACTER - Advanced Chunking

**Use Case**: Chunk annual reports into sections for better search and RAG applications

---

## <h1sub>Suggested Workflow</h1sub>

### Phase 1: Data Exploration (1-2 hours)

1. **Use Data Explorer in Horizon Catalog**:
   - Navigate to: **Data** → **Databases**
   - Browse available databases and schemas
   - Search for tables: `SOCIAL_MEDIA_NRNT`, `FINANCIAL_REPORTS`, `ANALYST_REPORTS`
   - View stages: `@HACKATHON_DATASETS.CORPORATE_DOCS.ANNUAL_REPORTS`, `@HACKATHON_DATASETS.CORPORATE_DOCS.EXECUTIVE_PORTRAITS`
   - Preview data and schemas before querying

2. **Explore annual reports**: List files in stages and download samples to review

3. **Query semantic views**: Try natural language queries on company data, asking about profitability and revenue growth

4. **Test search services**: Search across different data types (emails, analyst reports, etc.)

### Phase 2: AI Feature Testing (2-3 hours)

1. **Try AI_FILTER on various datasets**
2. **Use AI_EXTRACT on annual reports**
3. **Experiment with AI_COMPLETE for analysis**
4. **Test AI_EMBED for custom search and similarity**
5. **Explore AI_CLASSIFY for categorization**

### Phase 3: Build Your Challenge Solution (3-4 hours)

1. Choose one of the hackathon challenges above
2. Design your approach
3. Build using Streamlit or SQL
4. Present your findings

---

## <h1sub>Data Insights to Discover</h1sub>

### The NRNT Story (Complete Multi-Modal Dataset)

- **FY2024 Annual Report**: Shows 412% growth but warning signs (18% return rate, complaints)
- **FY2025 Liquidation Report**: Complete collapse, -90.4% stock crash, $0 shareholder recovery
- **Emails**: Track analyst sentiment from BUY → SELL as issues emerged
- **Stock Prices**: Visualize the 62-day collapse (Sept → Nov 2024)
- **Social Media & News**: 4,391 items tracking rise and fall
  - **Social posts**: 4,188 (Twitter, Reddit, LinkedIn, etc.)
  - **News articles**: 35 (Bloomberg, Reuters, WSJ, TechCrunch, CNBC, Forbes, etc.)
  - **Cross-company**: 168 posts tracking SNOW and VLTA impact
  - Aug 2024: Hype phase (product photos, success stories, "NRNT threatens SNOW" headlines)
  - Sept 2024: Crisis emerges (viral Chinese mother story in news + social, 83 total mentions)
  - Oct-Nov 2024: Collapse (recall images, CEO departure, bankruptcy coverage)
  - Dec 2024: Aftermath (SEC investigation news, "SNOW vindicated" articles)
  - 3 languages (en, zh, fr) | 31 cities | 338 posts with images
- **Interview Audio**: Post-collapse CEO interview with lessons learned
- **Visual Narrative**: 7 images showing complete crisis progression

**Questions**: 
- Can AI predict company failures from annual report language?
- How do social media signals correlate with stock price crashes?
- What role do viral human stories play in crisis acceleration?

### Competitive Dynamics

- **SNOW vs. ICBG**: Proprietary vs. Open (29% ICBG win rate)
- **SNOW vs. QRYQ**: Premium vs. Price-Performance (37% QRYQ win rate)
- **Partner Ecosystem**: DFLX, STRM, VLTA, CTLG work with all platforms

**Question**: What patterns distinguish market leaders from challengers?

### Profitability Journey

- **DFLX**: First profitable year (Q1: -8% → Q4: +8%)
- **CTLG**: Also achieved profitability in FY2025
- **GAME**: Approaching (margin improving -45% → -10%)
- **MKTG**: Still struggling (-40% margin, survival mode)

**Question**: What signals indicate a company will reach profitability?

---

## <h1sub>Hackathon Tips</h1sub>

### Leverage Existing Assets in HACKATHON_DATASETS

✅ **26 Tables**: All data ready to query in meaningful schemas  
✅ **9 Stages**: 84+ files (PDFs, images, audio) ready for AI processing  
✅ **6 Views**: Pre-built financial and sentiment views  
✅ **22 Annual Reports**: Rich source of structured data in CORPORATE_DOCS schema  
✅ **950 Emails**: Sentiment and rating data in COMMUNICATIONS schema  
✅ **4,391 Social Media + News Items**: Multi-language crisis tracking in COMMUNICATIONS schema  
✅ **6,420 Stock Price Records**: Historical data in FINANCIAL_DATA schema  
✅ **2 Utility Functions**: WEB_SEARCH() and SEND_EMAIL_NOTIFICATION() in COMMUNICATIONS schema

**Reference databases for learning**:
- `ACCELERATE_AI_IN_FSI`: Explore 5 pre-built search services and 2 semantic views
- `AISQL_EXAMPLES`: Study 4 example notebooks with different use cases

---

## <h1sub>Advanced Techniques</h1sub>

### Combine Multiple AI Features

!!! tip "Build Your Own in HACKATHON_DATASETS"
    You can create search services in `HACKATHON_DATASETS` or query tables directly to combine multiple AI features!

**Example Use Case**: Combine RAG + Classification + Sentiment + Aggregation
- Search analyst reports for "company growth prospects"
- Classify sentiment as Bullish, Neutral, or Bearish
- Filter for documents with specific financial projections
- Use AI_AGG to synthesize analyst consensus across all filtered documents

### Document Your Findings

Create a presentation or report showing:
- What you built
- AI features you used
- Insights you discovered
- Code samples
- Visualizations

---

## <h1sub>Getting Help</h1sub>

### Resources

**Your Primary Database**:
- 🎯 **HACKATHON_DATASETS**: Your workspace - use this for all projects!

**Navigation**:
- **Data Explorer (Horizon Catalog)**: Navigate to **Data** → **Databases** → **HACKATHON_DATASETS** to browse all available tables, stages, and schemas
- **Snowflake Cortex AI Docs**: [docs.snowflake.com/cortex](https://docs.snowflake.com/en/user-guide/snowflake-cortex/overview)
- **Snowflake Quickstarts**: [quickstarts.snowflake.com](https://quickstarts.snowflake.com/) - Hundreds of tutorials and guides
- **Snowflake Marketplace**: Data Products → Marketplace (for additional datasets)
- **Your Lab Homepage**: Review previous sections

**Reference Databases** (for learning only):
- 📚 **ACCELERATE_AI_IN_FSI**: Explore search services and Cortex Analyst examples
- 📚 **AISQL_EXAMPLES**: Study 4 example notebooks and AI SQL patterns

### Explore Notebooks

The 4 Snowflake notebooks contain working examples:
1. Document AI extraction
2. Audio transcription and sentiment
3. ML model training
4. Search service creation

Adapt these patterns for your hackathon project!

---

## <h1sub>Share Your Work</h1sub>

When you build something:
- Export your Streamlit app
- Save your SQL queries
- Document your approach
- Share insights you discovered

**Happy hacking with Snowflake Cortex AI!** 🚀

<p align="center">
  <strong>You have a complete financial data platform. Now build something amazing!</strong>
</p>
