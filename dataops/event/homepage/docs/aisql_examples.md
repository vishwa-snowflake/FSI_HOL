# <h1black>AISQL </h1black><h1blue>Notebook Examples</h1blue>
## <h1sub>Hands-On Notebooks for Advanced Analytics</h1sub>

In this section you'll discover additional AISQL notebooks that demonstrate advanced analytics capabilities across different domains. These notebooks showcase real-world use cases in advertising analytics, customer review analysis, marketing intelligence, and healthcare multimodal analytics.

## <h1sub>Overview</h1sub>

You have access to **4 additional notebooks** that extend your AISQL knowledge:

1. **Ads Analytics** - Analyze advertising performance using multimodal AI on ad images
2. **Customer Reviews Insight** - Extract insights from customer feedback and reviews
3. **Marketing Lead** - Score and qualify marketing leads with AI-powered analysis
4. **Multimodal Analytics Healthcare** - Process medical images, transcripts, and audio recordings

All notebooks are **pre-deployed and ready to use** in your Snowflake environment. No additional setup required!

---

## <h1sub>Accessing the Notebooks</h1sub>

### Method 1: Via Snowflake Web UI

1. **Log into Snowflake** using your credentials from the [Welcome page](index.md)
   - Account: {{ getenv("DATAOPS_SNOWFLAKE_ACCOUNT","[unknown]") }}
   - User: {{ getenv("EVENT_USER_NAME","[unknown]") }}

2. **Navigate to Projects > Notebooks** in the left sidebar

3. **Select one of the AISQL notebooks:**
   - `AISQL_EXAMPLES_ADS_ANALYTICS`
   - `AISQL_EXAMPLES_CUSTOMER_REVIEWS_INSIGHT`
   - `AISQL_EXAMPLES_MARKETING_LEAD`
   - `AISQL_EXAMPLES_MULTIMODAL_ANALYTICS_HEALTHCARE`

4. **Click the notebook name** to open it in the interactive notebook environment

5. **Run the cells** sequentially from top to bottom using the play button or `Shift + Enter`

---

## <h1sub>Notebook 1: Ads Analytics</h1sub>

### What You'll Learn

- Use **Cortex Vision AI** to analyze advertising images
- Extract ad characteristics (style, messaging, visual elements)
- Correlate ad performance metrics with creative attributes
- Identify which ad styles drive the highest engagement
- Build data-driven recommendations for ad optimization

### The Data

This notebook includes:

- **20 advertising images** across 4 creative styles:
  - **Lifestyle ads** - Product in real-world context
  - **Product shot ads** - Studio photography
  - **Promo ads** - Discount and offer-focused
  - **Text-heavy ads** - Information-dense messaging

- **Performance metrics** including:
  - Impressions, clicks, conversions
  - Click-through rate (CTR)
  - Cost per conversion
  - Customer reviews linked to ads

### Key Techniques

```sql
-- Analyze ad images with vision AI
SELECT 
    image_name,
    AI_COMPLETE(
        'claude-3-5-sonnet',
        CONCAT('Analyze this advertisement and describe: ',
               '1) Visual style, 2) Key messaging, 3) Target audience')
    ) AS ad_analysis
FROM images;
```

- **AI_COMPLETE with images** - Multimodal analysis of ad creative
- **Performance correlation** - Link visual attributes to conversion metrics
- **Automated categorization** - Classify ad types using AI
- **Optimization insights** - Data-driven creative recommendations

### What You'll Build

By the end of this notebook, you'll have:

- ✅ Comprehensive analysis of all 20 ad images
- ✅ Performance comparison across ad styles
- ✅ Correlation between visual elements and engagement
- ✅ Actionable recommendations for creative optimization

<img src="assets/general/architecture.png" alt="Ads analytics workflow" width="700">

---

## <h1sub>Notebook 2: Customer Reviews Insight</h1sub>

### What You'll Learn

- Extract insights from unstructured customer feedback
- Identify product strengths and pain points
- Track sentiment trends across product categories
- Segment customers by review patterns and preferences
- Generate product improvement recommendations

### The Data

This notebook includes:

- **Product catalog** - Electronics, home goods, categories, manufacturers
- **Customer data** - Segments, lifetime value, purchase history, demographics
- **Product reviews** - Ratings, review text, verified purchases, helpful votes

All data is loaded from a **pre-configured S3 stage** and ready to query.

### Key Techniques

```sql
-- Extract sentiment from customer reviews
SELECT 
    product_name,
    review_text,
    AI_SENTIMENT(review_text) AS sentiment,
    AI_EXTRACT(
        review_text,
        {'strengths': 'What do customers like about this product?',
         'weaknesses': 'What issues or complaints are mentioned?',
         'recommendation': 'Would the customer recommend this product?'}
    ) AS review_insights
FROM product_reviews
JOIN product_catalog USING (product_id);
```

- **AI_SENTIMENT** - Classify review tone (positive, negative, mixed)
- **AI_EXTRACT** - Pull structured insights from free-text reviews
- **Aggregation analysis** - Roll up insights by product, category, manufacturer
- **Customer segmentation** - Analyze review patterns by customer segment

### What You'll Build

By the end of this notebook, you'll have:

- ✅ Sentiment distribution across all products and categories
- ✅ Identification of top-rated and problematic products
- ✅ Common themes in positive vs negative reviews
- ✅ Customer segment preferences and pain points
- ✅ Product improvement roadmap based on feedback

---

## <h1sub>Notebook 3: Marketing Lead Scoring</h1sub>

### What You'll Learn

- Enrich marketing form data with company intelligence
- Score and prioritize leads using AI analysis
- Extract company size, industry, and fit signals
- Automate lead qualification workflows
- Generate personalized outreach recommendations

### The Data

This notebook includes:

- **Marketing form submissions** - Name, title, company, contact info
- **Company descriptions** - Business model, industry, size indicators

Data is loaded from **Snowflake Quickstarts S3 stage** with automatic refresh.

### Key Techniques

```sql
-- Enrich leads with company intelligence
SELECT 
    person_id,
    first_name,
    last_name,
    title,
    company,
    AI_EXTRACT(
        description,
        {'industry': 'What industry is this company in?',
         'company_size': 'What is the estimated company size?',
         'key_challenges': 'What business challenges might they have?',
         'fit_score': 'Rate this company as a lead from 1-10'}
    ) AS lead_intelligence
FROM marketing_form_data
JOIN company_info USING (company);
```

- **AI_EXTRACT for enrichment** - Extract structured intelligence from unstructured descriptions
- **Lead scoring** - AI-powered fit and priority assessment
- **Title analysis** - Identify decision-makers and influencers
- **Personalization** - Generate custom messaging based on company profile

### What You'll Build

By the end of this notebook, you'll have:

- ✅ Enriched lead database with company intelligence
- ✅ Lead scores prioritizing high-value prospects
- ✅ Industry and segment classification
- ✅ Decision-maker identification
- ✅ Personalized outreach recommendations for each lead

---

## <h1sub>Notebook 4: Multimodal Analytics Healthcare</h1sub>

### What You'll Learn

- Process **medical transcripts** (PDFs) to extract diagnoses and treatments
- Analyze **call recordings** (MP3) to transcribe patient-provider conversations
- Examine **medical images** (JPG) to identify conditions and findings
- Integrate multimodal data for comprehensive patient insights
- Build clinical analytics dashboards

### The Data

This notebook includes:

- **11 medical transcript PDFs** covering various conditions:
  - Bariatrics (gastric banding, lap band adjustment)
  - Cardiovascular (nuclear scan, catheterization, atrial fibrillation)
  - Pulmonary (bronchiolitis, bronchoscopy)
  - Neurology (migraine, neck pain, neurologic exam)
  - Hematology (microhematuria)

- **9 call recording MP3 files** - Patient-provider conversations

- **6 medical image JPGs** - Diagnostic imaging

- **Patient demographics table** - 10 sample patients with conditions, admission data
  
- **Clinical notes table** - 5 detailed clinical notes with assessments and plans

### Key Techniques

```sql
-- Extract diagnosis from medical transcripts
SELECT 
    relative_path,
    AI_PARSE_DOCUMENT(
        TO_FILE('@MEDICAL_TRANSCRIPTS', relative_path),
        {'mode': 'LAYOUT'}
    ) AS parsed_content,
    AI_EXTRACT(
        parsed_content,
        {'patient_info': 'Extract patient demographics',
         'diagnosis': 'What is the primary diagnosis?',
         'procedures': 'What procedures were performed?',
         'medications': 'What medications were prescribed?',
         'follow_up': 'What follow-up is recommended?'}
    ) AS clinical_extraction
FROM directory('@MEDICAL_TRANSCRIPTS');
```

```sql
-- Transcribe call recordings
SELECT 
    relative_path,
    AI_TRANSCRIBE(
        TO_FILE('@CALL_RECORDINGS', relative_path)
    ) AS transcript,
    AI_SENTIMENT(transcript) AS call_sentiment
FROM directory('@CALL_RECORDINGS');
```

```sql
-- Analyze medical images
SELECT 
    relative_path,
    AI_COMPLETE(
        'claude-3-5-sonnet',
        CONCAT('Analyze this medical image and describe: ',
               '1) Type of image, 2) Key findings, 3) Abnormalities if any')
    ) AS image_analysis
FROM directory('@MEDICAL_IMAGES');
```

- **AI_PARSE_DOCUMENT** - Extract text from medical PDFs
- **AI_EXTRACT** - Pull structured clinical data (diagnosis, procedures, medications)
- **AI_TRANSCRIBE** - Convert audio recordings to text
- **AI_COMPLETE with images** - Analyze medical imaging
- **AI_SENTIMENT** - Assess tone of patient-provider interactions
- **Multimodal integration** - Combine text, audio, and image insights

### What You'll Build

By the end of this notebook, you'll have:

- ✅ Structured clinical data extracted from unstructured transcripts
- ✅ Searchable transcripts from audio recordings
- ✅ Medical image analysis and findings
- ✅ Patient demographics and clinical notes database
- ✅ Integrated view combining all data modalities
- ✅ Clinical analytics dashboard with patient insights

### Healthcare Use Cases

This notebook demonstrates:

- **Clinical documentation automation** - Extract structured data from notes
- **Patient encounter transcription** - Convert calls to searchable text
- **Diagnostic imaging analysis** - AI-assisted image review
- **Population health analytics** - Aggregate insights across patients
- **Care coordination** - Integrate data from multiple sources
- **Quality improvement** - Identify patterns and opportunities

---

## <h1sub>Technical Requirements</h1sub>

All notebooks run in your provisioned Snowflake environment with:

- **Warehouse**: {{ getenv("EVENT_WAREHOUSE","[unknown]") }}
- **Database**: {{ getenv("EVENT_DATABASE","[unknown]") }}
- **Schema**: {{ getenv("EVENT_SCHEMA","[unknown]") }}

### Pre-Loaded Stages

All data is automatically staged and ready to use:

| Notebook | Notebook Name in Snowflake | Stage Names | Content Type |
|----------|---------------------------|-------------|--------------|
| Ads Analytics | `AISQL_EXAMPLES_ADS_ANALYTICS` | `ad_analytics`, `images` | PNG images, CSV data |
| Customer Reviews | `AISQL_EXAMPLES_CUSTOMER_REVIEWS_INSIGHT` | `customer_review` | CSV files (S3) |
| Marketing Lead | `AISQL_EXAMPLES_MARKETING_LEAD` | `MARKETING_LOAD` | CSV files (S3) |
| Healthcare | `AISQL_EXAMPLES_MULTIMODAL_ANALYTICS_HEALTHCARE` | `CALL_RECORDINGS`, `MEDICAL_IMAGES`, `MEDICAL_TRANSCRIPTS` | MP3, JPG, PDF files |

### Cortex AI Functions Used

These notebooks utilize:

- ✅ **AI_COMPLETE** - Multimodal analysis (text + images)
- ✅ **AI_EXTRACT** - Structured data extraction
- ✅ **AI_PARSE_DOCUMENT** - PDF text extraction
- ✅ **AI_TRANSCRIBE** - Audio-to-text conversion
- ✅ **AI_SENTIMENT** - Sentiment classification
- ✅ **AI_AGG** - Aggregation and summarization

---

## <h1sub>Tips for Success</h1sub>

### 1. Run Cells in Order

Notebooks are designed to run sequentially. Start at the top and work down to ensure all dependencies are met.

### 2. Examine the Output

Each cell produces output - tables, visualizations, or insights. Review these carefully to understand what each AI function returns.

### 3. Modify and Experiment

Try changing prompts, adjusting schemas, or applying techniques to your own data. The notebooks are fully editable.

### 4. Check Stage Contents

Use `SELECT * FROM DIRECTORY(@stage_name)` to see what files are available in each stage.

### 5. View Intermediate Tables

Most notebooks create intermediate tables. Query these to understand the data transformation pipeline:

```sql
-- Example: View extracted data
SELECT * FROM images LIMIT 10;
SELECT * FROM patient_demographics;
SELECT * FROM marketing_form_data;
```

### 6. Combine Techniques

The real power comes from combining multiple AI functions. For example:
- Extract data with AI_EXTRACT, then analyze sentiment with AI_SENTIMENT
- Parse documents with AI_PARSE_DOCUMENT, then extract structured fields with AI_COMPLETE
- Transcribe audio with AI_TRANSCRIBE, then summarize with AI_AGG

---

## <h1sub>Common Operations</h1sub>

### Listing Files in a Stage

```sql
SELECT 
    RELATIVE_PATH,
    SIZE,
    LAST_MODIFIED,
    BUILD_SCOPED_FILE_URL('@stage_name', RELATIVE_PATH) AS file_url
FROM DIRECTORY(@stage_name);
```

### Checking Notebook Status

```sql
-- View all notebooks in your schema
SHOW NOTEBOOKS IN SCHEMA {{ getenv("EVENT_SCHEMA","[unknown]") }};

-- See notebook details
DESCRIBE NOTEBOOK AISQL_EXAMPLES_ADS_ANALYTICS;
```

### Resetting a Notebook

If you need to start fresh:

1. Clear all cell outputs (Kernel → Restart & Clear Output)
2. Re-run from the beginning
3. Or recreate tables by re-running the setup cells

---

## <h1sub>Troubleshooting</h1sub>

### Issue: "Stage not found"

**Solution**: Ensure you're using the correct role and schema:

```sql
USE ROLE {{ getenv("EVENT_ATTENDEE_ROLE","[unknown]") }};
USE DATABASE {{ getenv("EVENT_DATABASE","[unknown]") }};
USE SCHEMA {{ getenv("EVENT_SCHEMA","[unknown]") }};
```

### Issue: "File format not recognized"

**Solution**: Check that you're using the correct file format:

```sql
-- For CSV files
CREATE OR REPLACE FILE FORMAT csv_ff 
TYPE = 'csv'
SKIP_HEADER = 1;

-- For images (no file format needed with TO_FILE)
SELECT AI_COMPLETE('model', TO_FILE('@stage', 'file.png'));
```

### Issue: "Notebook not responding"

**Solution**: 
1. Check that your warehouse is running: `SHOW WAREHOUSES;`
2. Restart the notebook kernel
3. Verify you have the correct permissions

### Issue: "AI function error"

**Solution**: 
1. Ensure Cortex AI functions are enabled in your account
2. Check function syntax matches documentation
3. Verify input data types (TEXT for AI_SENTIMENT, FILE for AI_PARSE_DOCUMENT, etc.)

---

## <h1sub>Next Steps</h1sub>

After completing these AISQL notebook examples, you can:

1. **Apply to Your Data** - Adapt these techniques to your own datasets
2. **Combine with Main Lab** - Integrate insights from these notebooks into your FSI assistant
3. **Explore Agent Tools** - Continue to [Cortex Search](search_service.md) and [Cortex Analyst](analyst.md)
4. **Build Applications** - Use these patterns in [Streamlit apps](snowflake_intelligence.md)

---

## <h1sub>Summary</h1sub>

You now have access to **4 production-ready AISQL notebooks** covering:

- ✅ **AISQL_EXAMPLES_ADS_ANALYTICS** - Multimodal vision AI for advertising optimization
- ✅ **AISQL_EXAMPLES_CUSTOMER_REVIEWS_INSIGHT** - Sentiment analysis and insight extraction from feedback
- ✅ **AISQL_EXAMPLES_MARKETING_LEAD** - AI-powered lead qualification and enrichment
- ✅ **AISQL_EXAMPLES_MULTIMODAL_ANALYTICS_HEALTHCARE** - Process medical images, audio, and documents

All notebooks are **pre-deployed, pre-loaded with data, and ready to run** in your Snowflake environment!

---

!!! tip "Pro Tip: Cross-Domain Learning"

    While these examples focus on specific domains (ads, marketing, healthcare), the AI techniques are domain-agnostic. The same patterns work for:
    
    - **Finance** - Analyze financial reports, transcribe earnings calls, score investment opportunities
    - **Retail** - Process product images, analyze reviews, qualify leads
    - **Legal** - Extract entities from contracts, transcribe depositions, analyze case files
    - **Real Estate** - Analyze property images, extract data from listings, score leads
    
    Adapt these patterns to any industry with unstructured data!

---

**Ready to explore?** Head to **Projects → Notebooks** in Snowflake and select your first AISQL example notebook!

