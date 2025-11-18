# <h1black>Snowflake </h1black> | <h1blue> AI Hackathon </h1blue>
<h1sub>Build with AISQL and Snowflake Intelligence</h1sub>

<img src="image/index/1761831519628.png" alt="Hackathon introduction" width="900">

Welcome to an immersive hackathon experience where you'll build AI-powered financial intelligence applications using Snowflake's cutting-edge AI capabilities!

**What You'll Build:**
Leverage comprehensive financial data across 11 companies to create innovative AI solutions. Whether you're interested in:
- Building intelligent stock selection agents
- Analyzing crisis patterns in social media
- Creating competitive intelligence dashboards
- Developing investment recommendation engines
- Processing multi-modal financial documents with AI

...you have everything you need to start building immediately!

**Your AI Toolkit:**
Work with the latest AI technologies embedded directly in the Snowflake platform. Process both **Unstructured** and **Structured** data, then apply **Cortex Agents**, **AISQL**, and **Snowflake Intelligence** to discover insights across **All Your Data**.

**Complete Financial Dataset:**
Access real-world-style data including analyst reports, earnings calls, financial statements, social media sentiment, news articles, and more—all pre-loaded and ready for your hackathon projects.

<h1sub>Data Sources and Analyst Coverage</h1sub>

This hands-on lab utilizes a comprehensive dataset spanning multiple data types and financial analysts to demonstrate real-world AI applications in financial services. You'll work with:

### **Analyst Research Reports**
The lab features comprehensive analysis from synthetic research firms created specifically for this hands-on experience:
- **Apex Analytics** - Growth-focused equity research
- **Consensus Point** - Institutional-grade analysis and recommendations
- **Momentum Metrics** - Quantitative trading insights and momentum analysis
- **Pinnacle Growth Investors** - Growth equity research and sector analysis
- **Quant-Vestor** - Quantitative investment research and algorithmic trading insights
- **Sterling Partners** - Value-oriented investment analysis
- **Veridian Capital** - Comprehensive equity research and market analysis

### **Multi-Modal Data Integration**
Throughout the lab, you'll process and analyze:

- **Research Reports** - 30 analyst reports from 6 research firms, extract structured insights (ratings, price targets, growth forecasts) using Document AI
- **Earnings Call Transcripts** - Process 92 audio recordings from 11 companies into searchable text with sentiment analysis
- **Financial Infographics** - Extract key metrics from 11 quarterly earnings visuals using multimodal AI
- **Analyst Emails** - 950+ professional analyst emails with 7 rating types (BUY, OVERWEIGHT, OUTPERFORM, HOLD, EQUAL-WEIGHT, UNDERWEIGHT, SELL)
- **Investment Research** - Academic papers covering portfolio management, ESG investing, risk management, market research, and quantitative methods
- **Stock Price Data** - Historical data with 6,420+ Snowflake price points (2020-2025)
- **Financial Reports** - 11 companies with income statements, KPIs, and customer metrics

### **AI-Powered Analysis Journey**
Your AI assistant will synthesize insights from all these sources to answer questions like:
- *"What do Apex Analytics and Consensus Point analysts say about Snowflake's growth prospects?"*
- *"How does Momentum Metrics' quantitative analysis compare to Sterling Partners' value assessment?"*
- *"What are Veridian Capital's latest price targets and how do they align with earnings call sentiment?"*
- *"Based on all available data, should I buy, sell, or hold Snowflake shares?"*

This diverse dataset enables you to experience how modern AI can unify structured financial data with unstructured analyst opinions, creating comprehensive investment intelligence.

<h1sub>🎯 Your Hackathon Workspace</h1sub>

A complete hackathon environment has been built for you automatically:

- **Snowflake Account**: [{{ getenv("DATAOPS_SNOWFLAKE_ACCOUNT","[unknown]") }}](https://{{ getenv("DATAOPS_SNOWFLAKE_ACCOUNT","[unknown]") }}.snowflakecomputing.com)
- **User**: {{ getenv("EVENT_USER_NAME","[unknown]") }}
- **Snowflake Virtual Warehouse**: {{ getenv("EVENT_WAREHOUSE","[unknown]") }}
- **Primary Hackathon Database**: `HACKATHON_DATASETS` - **Use this for all your projects!**
- **Reference Databases**: `ACCELERATE_AI_IN_FSI` (demo data), `AISQL_EXAMPLES` (learning examples)

### **🗄️ Your Hackathon Data (Pre-Loaded & Ready)**

Everything you need to start building is already loaded in `HACKATHON_DATASETS`:

- **26 Tables** - Financial data organized in 5 meaningful schemas (FINANCIAL_DATA, EARNINGS_ANALYSIS, CORPORATE_DOCS, COMMUNICATIONS, INVESTMENT_RESEARCH)
- **9 Stages with 84+ Files** - PDFs, audio files, images (analyst reports, earnings calls, annual reports, interviews)
- **6 Pre-Built Views** - For easier data access and analysis
- **4,391 Social Media Posts** - Multi-language crisis tracking data
- **950+ Analyst Emails** - With ratings and sentiment
- **92 Earnings Call Transcripts** - AI-transcribed with sentiment
- **6,420 Stock Price Records** - Historical market data
- **2 Utility Functions** - WEB_SEARCH() and SEND_EMAIL_NOTIFICATION()

All organized for easy discovery and immediate use in your hackathon projects!

<h1sub>👥 Profile Settings</h1sub>

**⚠️ Important: Add Your Email Address for Marketplace Access!**

To access datasets from the Snowflake Marketplace during the hackathon, you **must** add an email address to your profile. This is required for marketplace functionality.

### **📧 Updating Your Profile & Email**

Change your display name and email address anytime:

**Option 1: Using the Profile Manager App (Recommended)**
1. **Log into Snowflake** using your hackathon credentials
2. **Navigate to Streamlit Apps**:
   - In Snowflake, go to **"Projects"** → **"Streamlit"** in the left sidebar
   - OR search for "Streamlit" in the top search bar
3. **Open the Profile Manager**:
   - Find `CHANGE_MY_USER_SETTINGS.PUBLIC.PROFILE_MANAGER` in the list
   - Click on it to open the app
4. **Update Your Profile**:
   - View your current information at the top
   - Scroll down to the **"Update Your Information"** form
   - Modify your first name, last name, or email address
   - **Important**: Add your email address to enable Marketplace access
   - Click **"Update Profile"** to save changes

**Option 2: Using SQL Commands**
```sql
-- Update your profile information (email required for Marketplace)
CALL CHANGE_MY_USER_SETTINGS.PUBLIC.UPDATE_MY_PROFILE(
    'YourFirstName',
    'YourLastName',
    'your.email@example.com'
);

-- View your current profile
SELECT * FROM CHANGE_MY_USER_SETTINGS.PUBLIC.MY_PROFILE;
```

### **👥 Available Hackathon Users**
The hackathon environment includes 10 pre-created user accounts:
- **HACKER1** through **HACKER10**
- **Password**: `sn0wf@ll` (for all accounts)
- **Access**: All accounts have full hackathon access and can update their own profiles

### **🔐 Access & Security**
- **Profile Updates**: Available to all users with `EVENT_ATTENDEE_ROLE`
- **Security**: You can only modify your own profile information
- **Optional**: Profile updates are completely optional, but email is needed for Marketplace access

---

<h1sub>🎓 Getting Started: Learn the Platform</h1sub>

<img src="assets/general/architecture.png" alt="System architecture" width="900">

Before diving into your hackathon project, familiarize yourself with Snowflake's AI capabilities through our **Getting Started Labs**:

### **📚 Hands-On Learning Labs**

Work through these guided tutorials to understand the platform and see example implementations:

1. **[Log In & Explore](Logging_in.md)** - Access your Snowflake account and explore the environment
2. **[Unstructured Data Processing](cortex_ai_documents.md)** - Process PDFs, audio, and images with Document AI
3. **[Structured Data Processing](build_quantitive_model.md)** - Work with tables and build ML models
4. **[Snowflake Intelligence](snowflake_intelligence.md)** - Create AI agents with simple configuration
5. **[Search Services](search_service.md)** - Build semantic search across your data
6. **[Cortex Analyst](analyst.md)** - Natural language to SQL generation

These labs use the reference database `ACCELERATE_AI_IN_FSI` to show you what's possible.

### **💡 AISQL Example Notebooks**

Explore **4 industry-specific examples** in the `AISQL_EXAMPLES` database to see AI SQL in action:

- **📊 [Ads Analytics](aisql_examples.md)** - Multimodal image analysis for advertising
- **💬 [Customer Reviews](aisql_examples.md)** - Sentiment analysis and insights extraction
- **🎯 [Marketing Lead Scoring](aisql_examples.md)** - AI-powered lead enrichment and qualification
- **🏥 [Healthcare Analytics](aisql_examples.md)** - Process medical transcripts, images, and audio

Visit the [AISQL Examples](aisql_examples.md) section for detailed instructions.

---

<h1sub>🚀 Build Your Hackathon Project</h1sub>

Once you're comfortable with the platform, it's time to build!

### **Your Primary Workspace: `HACKATHON_DATASETS`**

This is where you'll build your hackathon project. All data is organized in meaningful schemas:
- 📊 **FINANCIAL_DATA** - Stock prices, analyst reports, financial statements
- 🎙️ **EARNINGS_ANALYSIS** - Transcripts and sentiment analysis
- 🏢 **CORPORATE_DOCS** - Annual reports, executive bios, interviews
- 💬 **COMMUNICATIONS** - Emails, social media, utility functions
- 📚 **INVESTMENT_RESEARCH** - Academic research papers across 6 investment topics

### **💡 Hackathon Challenge Ideas**

Need inspiration? Check out **[More Activities & Hackathon Ideas](More_Activities.md)** for:

- **11 Detailed Challenge Ideas** - From crisis detection to investment advisors
- **AI Features to Explore** - AISQL, Document AI, Agents, Search
- **Dataset Guidance** - Which schemas and tables to use for each challenge
- **Deliverable Suggestions** - Dashboards, APIs, chatbots, and more

**Popular Challenges:**
- 🔍 Multi-Source Intelligence Dashboard
- 🌊 Crisis Analysis using Social Media (4,391 posts!)
- 🏆 Competitive Intelligence Platform
- 💰 Investment Recommendation Engine
- 📄 Advanced Document AI Processing

Visit [More Activities](More_Activities.md) to explore all 11 challenges!

---

**⚠️ Important Disclaimer:** All analyst reports and company data (except some Snowflake specific assets) are completely fictitious for educational purposes. Financial decisions cannot be made based on any outcomes of this hackathon. Snowflake earnings calls are real but may be outdated.

<h1sub>🎉 Let's Build!</h1sub>

1. **Start with Getting Started Labs** - [Log in and explore](Logging_in.md)
2. **Learn from AISQL Examples** - [Explore example notebooks](aisql_examples.md)
3. **Pick a Challenge or Create your own** - [Browse hackathon ideas](More_Activities.md)
4. **Build in Snowflake** use your pre loaded snowflake account for this experience

5. **Have fun!** 🚀




!!! warning "Hackathon Environment Duration"

    This hackathon is due to end at {{ getenv("EVENT_END_DATETIME","[unknown time]") }}, at which point access will be restricted, and accounts will be removed. Make sure to export any work you want to keep before the end of the event!



