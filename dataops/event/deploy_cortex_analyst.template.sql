ALTER SESSION SET QUERY_TAG = '''{"origin":"sf_sit-is", "name":"Build an AI Assistant for FSI using AISQL and Snowflake Intelligence", "version":{"major":1, "minor":0},"attributes":{"is_quickstart":0, "source":"sql"}}''';
use role {{ env.EVENT_ATTENDEE_ROLE }};


CREATE STAGE IF NOT EXISTS {{ env.EVENT_DATABASE }}.{{ env.CORTEX_ANALYST_SCHEMA }}.cortex_analyst
  DIRECTORY = (enable = true)
  ENCRYPTION = (type = 'snowflake_sse');


PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/analyst/semantic_model.yaml @{{ env.EVENT_DATABASE }}.{{ env.CORTEX_ANALYST_SCHEMA }}.cortex_analyst auto_compress = false overwrite = true;
PUT file:///{{ env.CI_PROJECT_DIR }}/dataops/event/analyst/analyst_sentiments.yaml @{{ env.EVENT_DATABASE }}.{{ env.CORTEX_ANALYST_SCHEMA }}.cortex_analyst auto_compress = false overwrite = true;


ALTER STAGE {{ env.EVENT_DATABASE }}.{{ env.CORTEX_ANALYST_SCHEMA}}.cortex_analyst REFRESH;

-----SEMANTIC VIEWS----

-- Set database and warehouse context so tables and search services can be found across schemas
USE DATABASE {{ env.EVENT_DATABASE }};
USE WAREHOUSE {{ env.EVENT_WAREHOUSE }};

CREATE OR REPLACE SEMANTIC VIEW {{ env.EVENT_DATABASE }}.{{ env.CORTEX_ANALYST_SCHEMA }}.COMPANY_DATA_8_CORE_FEATURED_TICKERS
	TABLES (
		{{ env.EVENT_SCHEMA }}.INFOGRAPHICS_FOR_SEARCH 
			PRIMARY KEY (TICKER) 
			COMMENT='This table appears to store financial and operational data for publicly traded companies, specifically related to their revenue, growth, customers, and financial performance, likely sourced from quarterly or annual reports, along with metadata such as company name, ticker symbol, and report period, as well as a URL and branding information, suggesting it may be used for data visualization or infographic purposes.',
		{{ env.EVENT_SCHEMA }}.SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH 
			COMMENT='This table provides a comprehensive view of transcripts from earnings calls and other financial events, including the sentiment analysis of the event, the reason for the sentiment, the number of unique analysts participating, and the sentiment score. The table also includes the full text of the transcript, the length of the transcript, and the timestamp of the event, allowing for in-depth analysis of market trends and sentiment.',
		{{ env.DOCUMENT_AI_SCHEMA }}.VW_FINANCIAL_SUMMARY 
			PRIMARY KEY (COMPANY) 
			COMMENT='This table provides a financial summary of companies, including revenue, customer, and margin metrics, as well as year-over-year growth and free cash flow, for the second quarter of 2025 and 2024, sourced from financial reports.',
		{{ env.DOCUMENT_AI_SCHEMA }}.VW_INCOME_STATEMENT 
			COMMENT='This view provides a normalized and flattened representation of income statement data from financial reports, allowing for easy comparison of quarterly financial performance across companies and years.',
		{{ env.DOCUMENT_AI_SCHEMA }}.VW_KPI_METRICS 
			COMMENT='This view provides a normalized representation of key performance indicators (KPIs) extracted from financial reports, allowing for easy analysis and comparison of company performance across different periods and metrics.'
	)
	RELATIONSHIPS (
		TRANSCRIPTS_TO_COMPANY_INFO AS SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH(PRIMARY_TICKER) REFERENCES INFOGRAPHICS_FOR_SEARCH(TICKER),
		FINANCIAL_SUMMARY_TO_COMPANY_INFO AS VW_FINANCIAL_SUMMARY(TICKER) REFERENCES INFOGRAPHICS_FOR_SEARCH(TICKER),
		INCOME_STATEMENT_TO_COMPANY_INFO AS VW_INCOME_STATEMENT(TICKER) REFERENCES INFOGRAPHICS_FOR_SEARCH(TICKER),
		KPI_METRICS_TO_COMPANY_INFO AS VW_KPI_METRICS(TICKER) REFERENCES INFOGRAPHICS_FOR_SEARCH(TICKER)
	)
	FACTS (
		SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH.SENTIMENT_SCORE AS SENTIMENT_SCORE 
			COMMENT='A score indicating the sentiment of a customer''s feedback, ranging from 1 (very negative) to 5 (very positive), with 3 being neutral.',
		SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH.TRANSCRIPT_LENGTH AS TRANSCRIPT_LENGTH 
			COMMENT='The length of the transcript in characters.',
		SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH.UNIQUE_ANALYST_COUNT AS UNIQUE_ANALYST_COUNT 
			COMMENT='The number of unique analysts who have provided a sentiment score for a particular transcript.',
		VW_INCOME_STATEMENT.ROW_NUM AS ROW_NUM 
			COMMENT='A unique identifier for each row in the income statement table, used for sorting and referencing purposes.',
		VW_KPI_METRICS.ROW_NUM AS ROW_NUM 
			COMMENT='Row Number, a unique identifier for each record in the dataset, used for ordering and referencing purposes.'
	)
	DIMENSIONS (
		INFOGRAPHICS_FOR_SEARCH.BRANDING AS BRANDING 
			COMMENT='CatalogX provides the unified governance layer for the modern data stack, making data governance no longer optional but systematically manageable across heterogeneous environments.' 
			WITH CORTEX SEARCH SERVICE {{ env.EVENT_SCHEMA }}.INFOGRAPHICS_SEARCH,
		INFOGRAPHICS_FOR_SEARCH.COMPANY_NAME AS COMPANY_NAME 
			COMMENT='The name of the company that created the infographic.',
		INFOGRAPHICS_FOR_SEARCH.COMPANY_TICKER AS COMPANY_TICKER 
			COMMENT='The stock ticker symbol of a publicly traded company listed on a stock exchange.',
		INFOGRAPHICS_FOR_SEARCH.CUSTOMERS_1M_PLUS AS CUSTOMERS_1M_PLUS 
			COMMENT='The number of customers for a company with over 1 million customers.',
		INFOGRAPHICS_FOR_SEARCH.FREE_CASH_FLOW AS FREE_CASH_FLOW 
			COMMENT='The amount of cash generated by a company''s operations after accounting for capital expenditures, indicating its ability to generate cash for debt repayment, investments, and shareholder returns.',
		INFOGRAPHICS_FOR_SEARCH.GROSS_MARGIN AS GROSS_MARGIN 
			COMMENT='The percentage of revenue that remains after deducting the cost of goods sold, representing the profit margin of a product or service.',
		INFOGRAPHICS_FOR_SEARCH.NET_REVENUE_RETENTION AS NET_REVENUE_RETENTION 
			COMMENT='Net Revenue Retention rate represents the percentage of revenue retained from existing customers over a specific period, indicating the company''s ability to maintain and grow revenue from its customer base.',
		INFOGRAPHICS_FOR_SEARCH.OPERATING_MARGIN AS OPERATING_MARGIN 
			COMMENT='The operating margin is a financial metric that represents the percentage of revenue that remains after deducting the cost of goods sold and operating expenses, indicating a company''s profitability from its core operations.',
		INFOGRAPHICS_FOR_SEARCH.PRODUCT_REVENUE AS PRODUCT_REVENUE 
			COMMENT='The total revenue generated by each product.',
		INFOGRAPHICS_FOR_SEARCH.RELATIVE_PATH AS RELATIVE_PATH 
			COMMENT='The file path of the infographic image relative to the root directory.',
		INFOGRAPHICS_FOR_SEARCH.REPORT_PERIOD AS REPORT_PERIOD 
			COMMENT='The quarter and fiscal year in which the data was reported, with Q2 representing the second quarter of the fiscal year.',
		INFOGRAPHICS_FOR_SEARCH.RPO AS RPO 
			COMMENT='The RPO (Revenue Per Outlet) column represents the average annual revenue generated by each outlet or location, providing a key performance indicator for evaluating the financial productivity of individual outlets.',
		INFOGRAPHICS_FOR_SEARCH.RPO_GROWTH AS RPO_GROWTH 
			COMMENT='Percentage change in Revenue Per Order (RPO) over time, indicating the growth rate of average order value.',
		INFOGRAPHICS_FOR_SEARCH.SERVICES_REVENUE AS SERVICES_REVENUE 
			COMMENT='The total revenue generated from services provided by the company.',
		INFOGRAPHICS_FOR_SEARCH.TEXT AS TEXT 
			COMMENT='DataFlex Analytics is a data-source-agnostic business intelligence and visualization platform that operates as the Switzerland of the BI ecosystem. Our mission is to help organizations extract actionable insights from wherever their data lives, without forcing them into proprietary storage solutions.' 
			WITH CORTEX SEARCH SERVICE {{ env.EVENT_SCHEMA }}.INFOGRAPHICS_SEARCH,
		INFOGRAPHICS_FOR_SEARCH.TICKER AS TICKER 
			COMMENT='Stock ticker symbol of a publicly traded company.',
		INFOGRAPHICS_FOR_SEARCH.TOTAL_CUSTOMERS AS TOTAL_CUSTOMERS 
			COMMENT='The total number of customers for a specific search or filter criteria.',
		INFOGRAPHICS_FOR_SEARCH.TOTAL_REVENUE AS TOTAL_REVENUE 
			COMMENT='Total revenue represents the overall sales or income generated by a company or organization, encompassing all sources of revenue, including sales, services, and other income streams, typically measured over a specific period of time, such as a quarter or year, and expressed in millions of dollars.',
		INFOGRAPHICS_FOR_SEARCH.URL AS URL 
			COMMENT='URLs of infographics for search results.',
		INFOGRAPHICS_FOR_SEARCH.YOY_GROWTH AS YOY_GROWTH 
			COMMENT='Year-over-year (YOY) growth rate, representing the percentage change in a metric or value compared to the same period in the previous year.',
		SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH.CREATED_AT AS CREATED_AT 
			COMMENT='The date and time when the sentiment analysis was created.',
		SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH.EVENT_TIMESTAMP AS EVENT_TIMESTAMP 
			COMMENT='The date and time when the sentiment analysis event occurred, in ISO 8601 format.',
		SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH.EVENT_TYPE AS EVENT_TYPE 
			COMMENT='The type of event during which the earnings call transcript was recorded, such as quarterly earnings calls for a specific fiscal year.',
		SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH.FULL_TRANSCRIPT_TEXT AS FULL_TRANSCRIPT_TEXT 
			COMMENT='Transcripts of quarterly earnings calls for various companies, including GameMetrics, EnergyGrid Analytics, and TicketingPro, featuring CEOs and analysts discussing revenue, growth, competition, and market trends.',
		SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH.PRIMARY_TICKER AS PRIMARY_TICKER 
			COMMENT='The primary ticker symbol of the company being discussed in the transcript.',
		SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH.SENTIMENT_REASON AS SENTIMENT_REASON 
			COMMENT='The reason behind the sentiment expressed by analysts during the earnings call, including specific phrases or concerns mentioned.',
		VW_FINANCIAL_SUMMARY.COMPANY AS COMPANY 
			COMMENT='The company name associated with the financial summary data, indicating the specific entity or organization to which the financial information belongs.',
		VW_FINANCIAL_SUMMARY.FREE_CASH_FLOW AS FREE_CASH_FLOW 
			COMMENT='Free Cash Flow represents the amount of cash generated by a company''s operations after accounting for capital expenditures, and is a key indicator of a company''s ability to generate cash for debt repayment, investments, and shareholder returns.',
		VW_FINANCIAL_SUMMARY.GROSS_MARGIN AS GROSS_MARGIN 
			COMMENT='The percentage of revenue that remains after deducting the cost of goods sold, representing the amount available to cover operating expenses and generate profit.',
		VW_FINANCIAL_SUMMARY.NRR AS NRR 
			COMMENT='Net Retention Rate (NRR) represents the percentage of recurring revenue retained from existing customers over a given period, indicating the company''s ability to maintain and grow its customer base.',
		VW_FINANCIAL_SUMMARY.OPERATING_MARGIN AS OPERATING_MARGIN 
			COMMENT='The percentage of revenue that remains after deducting the cost of goods sold and operating expenses, indicating the company''s profitability from its core operations.',
		VW_FINANCIAL_SUMMARY.PERIOD AS PERIOD 
			COMMENT='The fiscal quarter and year in which the financial data was reported, with "Q2" representing the second quarter and "FY2025" representing the fiscal year 2025.',
		VW_FINANCIAL_SUMMARY.RELATIVE_PATH AS RELATIVE_PATH 
			COMMENT='The file name of the financial summary document, including the company name and fiscal period.',
		VW_FINANCIAL_SUMMARY.TICKER AS TICKER 
			WITH SYNONYMS=('company_code','exchange_listing','security_id','stock_code','stock_symbol') 
			COMMENT='Stock ticker symbol, a unique abbreviation used to identify a publicly traded company''s stock on a stock exchange.',
		VW_FINANCIAL_SUMMARY.TOTAL_CUSTOMERS AS TOTAL_CUSTOMERS 
			COMMENT='The total number of customers for a specific financial metric or time period, categorized into three tiers: 1124, 1847, and 10,000 or more.',
		VW_FINANCIAL_SUMMARY.TOTAL_REVENUE_Q2_2024 AS TOTAL_REVENUE_Q2_2024 
			COMMENT='Total revenue for the second quarter of 2024.',
		VW_FINANCIAL_SUMMARY.TOTAL_REVENUE_Q2_2025 AS TOTAL_REVENUE_Q2_2025 
			COMMENT='Total revenue generated by the company during the second quarter of 2025.',
		VW_FINANCIAL_SUMMARY.YOY_GROWTH AS YOY_GROWTH 
			COMMENT='Year-over-year (YOY) growth rate, representing the percentage change in a financial metric from the same period in the previous year.',
		VW_INCOME_STATEMENT.COMPANY AS COMPANY 
			COMMENT='The company name of the entity reporting the income statement data.',
		VW_INCOME_STATEMENT.LINE_ITEM AS LINE_ITEM 
			COMMENT='This column represents the different categories of income statement line items, which are used to classify and report various components of a company''s revenue and expenses.',
		VW_INCOME_STATEMENT.PERIOD AS PERIOD 
			COMMENT='The period for which the income statement data is reported, typically a fiscal quarter and year.',
		VW_INCOME_STATEMENT.Q2_FY2024 AS Q2_FY2024 
			COMMENT='Net income for the second quarter of the fiscal year 2024.',
		VW_INCOME_STATEMENT.Q2_FY2025 AS Q2_FY2025 
			COMMENT='Net income for the second quarter of the fiscal year 2025.',
		VW_INCOME_STATEMENT.RELATIVE_PATH AS RELATIVE_PATH 
			COMMENT='The file path of the source document from which the income statement data was extracted.',
		VW_INCOME_STATEMENT.TICKER AS TICKER 
			WITH SYNONYMS=('company_code','exchange_listing','security_id','stock_exchange_code','stock_symbol') 
			COMMENT='A unique identifier for a publicly traded company, typically a combination of letters that represents the company''s stock symbol on a stock exchange.',
		VW_KPI_METRICS.COMPANY AS COMPANY 
			COMMENT='The COMPANY column represents the name of the company or organization associated with the KPI metrics, indicating the entity to which the metrics belong.',
		VW_KPI_METRICS.KPI_NAME AS KPI_NAME 
			COMMENT='This column represents the different key performance indicators (KPIs) used to measure the company''s financial performance, including year-over-year growth, operating margin on a non-GAAP basis, and gross margin.',
		VW_KPI_METRICS.KPI_VALUE AS KPI_VALUE 
			COMMENT='Percentage change in key performance indicator (KPI) value, indicating the degree of variation from a baseline or target metric.',
		VW_KPI_METRICS.PERIOD AS PERIOD 
			COMMENT='The fiscal quarter in which the metric was measured, with the format "QX FYXXXX" where X is the quarter number (1-4) and XXXX is the fiscal year.',
		VW_KPI_METRICS.RELATIVE_PATH AS RELATIVE_PATH 
			COMMENT='The file name of the quarterly financial report for a specific business segment, in the format of "Segment_Qtr_FYYear_SIMPLE.pdf".',
		VW_KPI_METRICS.TICKER AS TICKER 
			COMMENT='Stock ticker symbol representing the company being measured.'
	)
	COMMENT='All data is fictional'
	WITH EXTENSION (CA='{"tables":[{"name":"INFOGRAPHICS_FOR_SEARCH","dimensions":[{"name":"BRANDING","sample_values":["# CatalogX (CTLG) Branding Analysis\\n\\n## **Color Scheme**\\n- **Dark slate blue/charcoal background**: Conveys professionalism, enterprise-grade reliability, and technical sophistication\\n- **White text**: Ensures clarity and readability, suggesting transparency in data governance\\n- **Accent colors**: Blue (trust, stability), Gold/Yellow (premium value, success), Orange shield logo (security, protection)\\n\\n## **Visual Identity**\\n- **Shield logo**: Represents data protection, security, and governance\\n- **Clean, grid-based layout**: Reflects systematic organization and structured data management\\n- **Minimalist iconography**: Suggests streamlined, efficient processes\\n\\n## **Mission Statement**\\n*\\"CatalogX provides the unified governance layer for the modern data stack, making data governance no longer optional but systematically manageable across heterogeneous environments.\\"*\\n\\n## **Key Business Overview**\\n- **Cross-Platform Governance** solution\\n- **$48M total revenue** (174% YoY growth)\\n- **Enterprise focus**: Addresses GDPR, CCPA, AI regulations compliance\\n- **Multi-platform integration**: SNOW, QRVQ, ICBG, STRM, VLTA, DFLX\\n- **Value proposition**: 30-40% cost savings, real-time lineage tracking, ML governance\\n- **Target market**: Enterprise data teams requiring systematic governance across heterogeneous data environments\\n\\n## **Brand Positioning**\\n- **Enterprise-grade data governance platform**\\n- **Compliance-first approach** for modern regulatory requirements\\n- **Unified solution** for fragmented data stack governance\\n- **Performance-driven** with strong financial metrics and customer growth","# DataFlex Analytics (DFLX) Branding Analysis\\n\\n## Color Scheme Meaning\\n- **Dominant Green Palette**: Conveys growth, prosperity, financial success, and stability\\n- **Monochromatic Green Design**: Suggests consistency, reliability, and professional focus\\n- **White Text/Accents**: Represents clarity, transparency, and clean data presentation\\n- **Subtle Gradient Effects**: Implies sophistication and modern technology approach\\n\\n## Mission Statement\\n**\\"Switzerland of the BI ecosystem\\"** - Positioning as neutral, reliable, and premium solution provider\\n\\n**Core Mission**: Help organizations extract actionable insights from data across multiple platforms without proprietary storage lock-in\\n\\n## Key Business Overview\\n- **Platform-Agnostic BI Solution** for Q2 FY2025\\n- **$67M Total Revenue** (24% YoY growth)\\n- **Strong Financial Metrics**: 78% NRR, 75% Gross Margin\\n- **Customer Base**: 1,847 total customers, 248 $1M+ customers\\n- **Revenue Split**: $62M Product, $5M Services\\n- **Operational Challenge**: -9% Operating Margin indicates scaling investments\\n\\n## Strategic Positioning\\n- **Integration-Focused**: Seamless connectivity across SNOW, QRVD, ICBG platforms\\n- **Partnership Model**: Collaborative approach with STRM, VLTA, CTLG\\n- **Multiplicative Business Model**: Win-win partnerships rather than zero-sum competition\\n- **Universal BI Integration**: Best-of-breed solution strategy","# ICBG Branding Analysis\\n\\n## Color Scheme\\n- **Primary**: Turquoise/Teal gradient\\n- **Meaning**: Trust, innovation, technology, reliability, growth, and digital transformation\\n- **Psychology**: Conveys stability and forward-thinking approach in data technology\\n\\n## Mission Statement\\n**\\"Democratize data infrastructure through open table formats\\"**\\n- Eliminate vendor lock-in\\n- Give customers full ownership and control of their data\\n- Champion openness and interoperability\\n\\n## Key Brand Positioning\\n- **\\"Switzerland of data platforms\\"** - Neutral, reliable, trustworthy\\n- **Open Lakehouse Platform** - Transparency, accessibility, modern architecture\\n- **Anti-proprietary stance** - Differentiation from SNOW and QRYQ''s closed ecosystems\\n\\n## Strategic Focus\\n- Enterprise customers seeking future-proof architectures\\n- Vendor independence and flexibility\\n- Best-of-breed ecosystem partnerships (DFIX, SPRM, VILA, CILG)\\n- Architectural flexibility and customer choice\\n\\n## Performance Indicators\\n- Strong growth metrics (156% YoY, 178% RPO growth)\\n- High gross margins (70%)\\n- Premium customer base (267 Tier1 customers)\\n- Significant market traction ($87M total revenue)"]},{"name":"COMPANY_NAME","sample_values":["DataFlex Analytics","ICBG Data Systems","CatalogX"]},{"name":"COMPANY_TICKER","sample_values":["DFLX","CTLG","ICBG"]},{"name":"CUSTOMERS_1M_PLUS","sample_values":["185","248","267"]},{"name":"FREE_CASH_FLOW","sample_values":["-$22M","-$45M","$312M"]},{"name":"GROSS_MARGIN","sample_values":["75%","66%","70%"]},{"name":"NET_REVENUE_RETENTION","sample_values":["138%","132%","78%"]},{"name":"OPERATING_MARGIN","sample_values":["-24%","-35%","-9%"]},{"name":"PRODUCT_REVENUE","sample_values":["$79M","$42.5M","$62M"]},{"name":"RELATIVE_PATH","sample_values":["CTLG_Earnings_Infographic_FY25-Q2.png","ICBG_Earnings_Infographic_FY25-Q2.png","DFLX_Earnings_Infographic_FY25-Q2.png"]},{"name":"REPORT_PERIOD","sample_values":["Q2 FY2025","Q2 FY2023"]},{"name":"RPO","sample_values":["$156M","$185M","$245M"]},{"name":"RPO_GROWTH","sample_values":["178%","+28%","+180%"]},{"name":"SERVICES_REVENUE","sample_values":["$8M","$5.5M","$5M"]},{"name":"TEXT","sample_values":["deliver comprehensive metadata management, lineage tracking, and access control that spans multiple platforms and tools","democratize data infrastructure through open table formats that give customers full ownership and control of their data","DataFlex Analytics is a data-source-agnostic business intelligence and visualization platform that operates as the Switzerland of the BI ecosystem. Our mission is to help organizations extract actionable insights from wherever their data lives, without forcing them into proprietary storage solutions. We explicitly position ourselves as not competing in data storage--instead, we provide a single pane of glass across SNOW, QRYQ, ICBG, and other platforms seamlessly."]},{"name":"TICKER","sample_values":["DFLX","CTLG","ICBG"]},{"name":"TOTAL_CUSTOMERS","sample_values":["1847","847","1124"]},{"name":"TOTAL_REVENUE","sample_values":["$48M","$67M","$87M"]},{"name":"URL","sample_values":["https://sfc-prod3-ds1-136-customer-stage.s3.us-west-2.amazonaws.com/maq91000-s/stages/968461c9-4a8d-4407-bb7b-07eae7b96fd8/DFLX_Earnings_Infographic_FY25-Q2.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAYEZ7BKG4CR7RYQRR%2F20251029%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20251029T021213Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=68b32344e1f61477073ac3b552d3ed69b046009a53342122d41ef6310f41341e","https://sfc-prod3-ds1-136-customer-stage.s3.us-west-2.amazonaws.com/maq91000-s/stages/968461c9-4a8d-4407-bb7b-07eae7b96fd8/CTLG_Earnings_Infographic_FY25-Q2.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAYEZ7BKG4CR7RYQRR%2F20251029%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20251029T021213Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=aabc78ed391a63c6b3b911c66cb87f7b9b89ad184e7dc903509bb8143fc9063b","https://sfc-prod3-ds1-136-customer-stage.s3.us-west-2.amazonaws.com/maq91000-s/stages/968461c9-4a8d-4407-bb7b-07eae7b96fd8/ICBG_Earnings_Infographic_FY25-Q2.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAYEZ7BKG4CR7RYQRR%2F20251029%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20251029T021213Z&X-Amz-Expires=3600&X-Amz-SignedHeaders=host&X-Amz-Signature=9264e8f0b3421ce3bb5b1cf39cdeb2ac9ffd630d7908ccf97de4e8adbcd9ba90"]},{"name":"YOY_GROWTH","sample_values":["174%","156%","487%"]}]},{"name":"SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH","dimensions":[{"name":"EVENT_TYPE","sample_values":["Q3 FY2025 Earnings Call","Q2 FY2025 Earnings Call","Q1 FY2025 Earnings Call"]},{"name":"FULL_TRANSCRIPT_TEXT","sample_values":["Operator: Welcome to GameMetrics Q3 FY2025 earnings call.\\n\\nAlex Kim (CEO): GameMetrics revenue reached $167M, up 287% YoY. Our gaming analytics platform uses Querybase for player behavior data, StreamPipe for real-time game telemetry, and DataFlex for game studio dashboards.\\n\\nAlex Kim (CEO): Thank you. We will now begin the question-and-answer session. Our first question comes from Sarah Mitchell with Morgan Stanley. Your line is open.\\n\\nAlex Kim (CEO): Our next question comes from David Chen with Goldman Sachs. Your line is open.\\n\\nAlex Kim (CEO): Our next question comes from Jennifer Walsh with JP Morgan. Your line is open.\\n\\nSarah Mitchell (Analyst): Thanks for taking my question. While the results are solid, I''m concerned about the competitive dynamics. Can you address the pricing pressure and market share concerns we''re hearing?\\n\\nDavid Chen (Analyst): Thank you. I have to ask about the deceleration we''re seeing. What''s your response to analyst concerns about slowing growth and increased competition?\\n\\nJennifer Walsh (Analyst): Hi, thanks. The guidance seems conservative given the macro headwinds. Can you walk us through your assumptions and what could cause you to miss these targets?","Operator: Welcome to EnergyGrid Analytics Q2 FY2025 earnings call.\\n\\nMichael Chen (CEO): EnergyGrid revenue reached $145M, up 198% YoY. Our smart grid platform uses Snowflake for energy consumption data, StreamPipe for real-time grid monitoring, and DataFlex for utility dashboards.\\n\\nMichael Chen (CEO): Thank you. We will now begin the question-and-answer session. Our first question comes from Sarah Mitchell with Morgan Stanley. Your line is open.\\n\\nMichael Chen (CEO): Our next question comes from David Chen with Goldman Sachs. Your line is open.\\n\\nMichael Chen (CEO): Our next question comes from Jennifer Walsh with JP Morgan. Your line is open.\\n\\nSarah Mitchell (Analyst): Thanks for taking my question. I need to address the elephant in the room - the significant miss this quarter and deteriorating fundamentals. What went wrong and how do you restore investor confidence?\\n\\nDavid Chen (Analyst): Thank you. Frankly, the results are disappointing and well below even the most conservative estimates. Can you explain the execution issues and why guidance was so far off?\\n\\nJennifer Walsh (Analyst): Hi. The guidance cut is deeply concerning, especially given previous assurances. Market share is declining and competition is intensifying. Why should investors believe the company can turn this around?","Operator: Welcome to TicketingPro Q2 FY2025 earnings call.\\n\\nJennifer Lee (CEO): TicketingPro revenue reached $67M, up 198% YoY. Our event ticketing analytics uses Querybase for sales data and DataFlex for event performance visualization.\\n\\nJennifer Lee (CEO): Thank you. We will now begin the question-and-answer session. Our first question comes from Sarah Mitchell with Morgan Stanley. Your line is open.\\n\\nJennifer Lee (CEO): Our next question comes from David Chen with Goldman Sachs. Your line is open.\\n\\nJennifer Lee (CEO): Our next question comes from Jennifer Walsh with JP Morgan. Your line is open.\\n\\nSarah Mitchell (Analyst): Thanks for taking my question. While the results are solid, I''m concerned about the competitive dynamics. Can you address the pricing pressure and market share concerns we''re hearing?\\n\\nDavid Chen (Analyst): Thank you. I have to ask about the deceleration we''re seeing. What''s your response to analyst concerns about slowing growth and increased competition?\\n\\nJennifer Walsh (Analyst): Hi, thanks. The guidance seems conservative given the macro headwinds. Can you walk us through your assumptions and what could cause you to miss these targets?"]},{"name":"PRIMARY_TICKER","sample_values":["CTLG","XRAY","NRNT"]},{"name":"SENTIMENT_REASON","sample_values":["All three analysts used highly positive language like ''strong results'', ''great quarter'', ''impressed by execution'', and ''encouraging guidance'' with optimistic forward-looking questions","Analysts expressed concerns about competitive pressure, growth deceleration, conservative guidance, and potential target misses despite solid results","Analysts expressed concerns about competitive pressure, growth deceleration, conservative guidance, and potential target misses despite strong revenue growth"]}],"facts":[{"name":"SENTIMENT_SCORE","sample_values":["3","5","2"]},{"name":"TRANSCRIPT_LENGTH","sample_values":["1049","1143","5159"]},{"name":"UNIQUE_ANALYST_COUNT","sample_values":["3","4"]}],"time_dimensions":[{"name":"CREATED_AT","sample_values":["2025-10-24T13:56:16.000+0000"]},{"name":"EVENT_TIMESTAMP","sample_values":["2024-09-19T16:00:00.000+0000","2024-07-24T16:00:00.000+0000","2024-07-19T16:00:00.000+0000"]}]},{"name":"VW_FINANCIAL_SUMMARY","dimensions":[{"name":"COMPANY","sample_values":["CatalogX","ICBG Data Systems (ICBG)","DataFlex Analytics (DFLX)"]},{"name":"FREE_CASH_FLOW","sample_values":["-$125M","-$42M","$8.5M"]},{"name":"GROSS_MARGIN","sample_values":["75%","66%","70%"]},{"name":"NRR","sample_values":["132%","118%","138%"]},{"name":"OPERATING_MARGIN","sample_values":["-35%","-24%","-9%"]},{"name":"PERIOD","sample_values":["Q2 FY2025"]},{"name":"RELATIVE_PATH","sample_values":["CTLG_Q2_FY2025_SIMPLE.pdf","ICBG_Q2_FY2025_SIMPLE.pdf","DFLX_Q2_FY2025_SIMPLE.pdf"]},{"name":"TICKER"},{"name":"TOTAL_CUSTOMERS","sample_values":["1124","1847","10,000+"]},{"name":"TOTAL_REVENUE_Q2_2024","sample_values":["$54","$24.3","$34"]},{"name":"TOTAL_REVENUE_Q2_2025","sample_values":["$67","$48","$87"]},{"name":"YOY_GROWTH","sample_values":["174%","156%","24%"]}]},{"name":"VW_INCOME_STATEMENT","dimensions":[{"name":"COMPANY","sample_values":["DataFlex Analytics (DFLX)","CatalogX","ICBG Data Systems (ICBG)"]},{"name":"LINE_ITEM","sample_values":["Professional Services Revenue","Net Income (Loss)","Total Revenue"]},{"name":"PERIOD","sample_values":["Q2 FY2025"]},{"name":"Q2_FY2024","sample_values":["$2","$11.3","-$9.5"]},{"name":"Q2_FY2025","sample_values":["$48","$42.5","$5.5"]},{"name":"RELATIVE_PATH","sample_values":["CTLG_Q2_FY2025_SIMPLE.pdf","DFLX_Q2_FY2025_SIMPLE.pdf","ICBG_Q2_FY2025_SIMPLE.pdf"]},{"name":"TICKER"}],"facts":[{"name":"ROW_NUM","sample_values":["2","1","3"]}]},{"name":"VW_KPI_METRICS","dimensions":[{"name":"COMPANY","sample_values":["DataFlex Analytics (DFLX)","CatalogX","ICBG Data Systems (ICBG)"]},{"name":"KPI_NAME","sample_values":["Year-over-Year Growth","Operating Margin (Non-GAAP)","Gross Margin"]},{"name":"KPI_VALUE","sample_values":["-35%","174%","70%"]},{"name":"PERIOD","sample_values":["Q2 FY2025"]},{"name":"RELATIVE_PATH","sample_values":["CTLG_Q2_FY2025_SIMPLE.pdf","DFLX_Q2_FY2025_SIMPLE.pdf","ICBG_Q2_FY2025_SIMPLE.pdf"]},{"name":"TICKER","sample_values":["ICBG","STRM","CTLG"]}],"facts":[{"name":"ROW_NUM","sample_values":["2","1","3"]}]}],"relationships":[{"name":"TRANSCRIPTS_TO_COMPANY_INFO"},{"name":"FINANCIAL_SUMMARY_TO_COMPANY_INFO"},{"name":"INCOME_STATEMENT_TO_COMPANY_INFO"},{"name":"KPI_METRICS_TO_COMPANY_INFO"}],"module_custom_instructions":{"question_categorization":"Questions about snowflake earnings call as well as Financial and company information about 8 core companies.  All the company data is fictional.  Only snowflake is real although some of the datasets for snowflake are fictional."}}');

CREATE OR REPLACE SEMANTIC VIEW {{ env.EVENT_DATABASE }}.{{ env.CORTEX_ANALYST_SCHEMA }}.SNOWFLAKE_ANALYSTS_VIEW
	TABLES (
		{{ env.EVENT_SCHEMA }}.ANALYST_REPORTS COMMENT='This table stores information about analyst reports, including the report''s relative path, URL, rating, date, close price, price target, growth, report provider, document type, document, summary, full text, and URL.',
		{{ env.EVENT_SCHEMA }}.SENTIMENT_ANALYSIS COMMENT='This table stores the results of sentiment analysis on text data related to products or services, capturing the overall sentiment and specific aspects such AS cost, innovation, productivity, competitiveness, and consumption, with each aspect scored on a numerical scale.',
		{{ env.EVENT_SCHEMA }}.TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT COMMENT='This table stores transcribed earnings call data with sentiment analysis, capturing the audio duration, speaker information, and text segments along with their corresponding sentiment scores, allowing for analysis of tone and emotional content in corporate earnings calls.',
		{{ env.EVENT_SCHEMA }}.TRANSCRIPTS_BY_MINUTE COMMENT='This table stores transcripts of audio or video recordings, broken down into minute-by-minute segments, with additional metadata such AS speaker information, sentiment analysis, and the actual text spoken during each minute.',
		{{ env.EVENT_SCHEMA }}.STOCK_PRICES COMMENT='This table stores historical stock price data, including daily high and low prices, trading volume, and pre- and post-market prices, for various stocks across different exchanges, categorized by asset class, with data aggregated by date, month, and year.'
	)
	FACTS (
		ANALYST_REPORTS.CLOSE_PRICE AS CLOSE_PRICE COMMENT='The closing price of a stock on a specific trading day, representing the final price at which the stock was traded at the end of the trading session.',
		ANALYST_REPORTS.GROWTH AS GROWTH COMMENT='The percentage change in a company''s key metrics, such AS revenue or earnings, over a specific period of time, indicating the rate at which the company is expanding or contracting.',
		ANALYST_REPORTS.PRICE_TARGET AS PRICE_TARGET COMMENT='The target price of a stock or investment AS forecasted by an analyst, representing the expected future value of the asset.',
		SENTIMENT_ANALYSIS.COMPETITIVENESS AS COMPETITIVENESS COMMENT='This column measures the degree to which a company is perceived AS competitive in its industry or market, with higher values indicating a stronger competitive position.',
		SENTIMENT_ANALYSIS.CONSUMPTION AS CONSUMPTION COMMENT='The total amount of consumption or usage of a product or service by a customer or a group of customers.',
		SENTIMENT_ANALYSIS.COST AS COST COMMENT='The total cost associated with a particular item, transaction, or event, represented AS a numerical value.',
		SENTIMENT_ANALYSIS.INNOVATION AS INNOVATION COMMENT='A measure of how innovative a product, service, or company is perceived to be, with higher values indicating a greater degree of innovation.',
		SENTIMENT_ANALYSIS.OVERALL AS OVERALL COMMENT='This column represents the overall sentiment score of a particular entity, product, or service, with higher values indicating a more positive sentiment and lower values indicating a more negative sentiment.',
		SENTIMENT_ANALYSIS.PRODUCTIVITY AS PRODUCTIVITY COMMENT='This column measures the productivity of a product or service, with higher values indicating a more productive outcome.',
		TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT.AUDIO_DURATION_SECONDS AS AUDIO_DURATION_SECONDS COMMENT='The length of the earnings call audio recording in seconds.',
		TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT.END_TIME AS END_TIME COMMENT='The time at which the earnings call ended, represented in a decimal format with hours and minutes (e.g., 13:05:45 is represented AS 1305.45).',
		TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT.SENTIMENT AS SENTIMENT COMMENT='The sentiment score of the earnings call, ranging from 0 (very negative) to 1 (very positive), indicating the overall emotional tone and attitude expressed by the speaker during the call.',
		TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT.START_TIME AS START_TIME COMMENT='The time at which the earnings call started, represented in a decimal format where the whole number represents the hour and the decimal represents the fraction of the hour that has passed, with the time presumably being in a 24-hour format.',
		TRANSCRIPTS_BY_MINUTE.MINUTES AS MINUTES COMMENT='The number of minutes into the call or interaction that the transcript data represents.',
		TRANSCRIPTS_BY_MINUTE.SENTIMENT AS SENTIMENT COMMENT='The sentiment score of the conversation, ranging from 0 (very negative) to 1 (very positive), indicating the emotional tone of the speaker during a specific minute of the transcript.',
		STOCK_PRICES.ALL_DAY_HIGH AS ALL_DAY_HIGH COMMENT='The highest price at which a stock traded during the day.',
		STOCK_PRICES.ALL_DAY_LOW AS ALL_DAY_LOW COMMENT='The lowest price at which a stock traded during the entire trading day.',
		STOCK_PRICES.MONTHNO AS MONTHNO COMMENT='The month of the year in which the stock price was recorded, where January is represented AS 1 and December AS 12.',
		STOCK_PRICES.NASDAQ_VOLUME AS NASDAQ_VOLUME COMMENT='The total number of shares traded on the NASDAQ stock exchange for a particular stock on a given day.',
		STOCK_PRICES.POST_MARKET_CLOSE AS POST_MARKET_CLOSE COMMENT='The closing price of a stock after the market has closed for the day, reflecting the final price at which the stock was traded after hours, often influenced by after-hours trading activity and news events that occur outside of regular market hours.',
		STOCK_PRICES.PRE_MARKET_OPEN AS PRE_MARKET_OPEN COMMENT='The opening stock price of a company before the market officially opens for trading.'
	)
	DIMENSIONS (
		ANALYST_REPORTS.DATE_REPORT AS DATE_REPORT COMMENT='Date the analyst report was generated.',
		ANALYST_REPORTS.DOCUMENT AS DOCUMENT COMMENT='The name of the document or report, typically including the report title and date, used to identify and distinguish between different analyst reports.',
		ANALYST_REPORTS.DOCUMENT_TYPE AS DOCUMENT_TYPE COMMENT='The type of document being reported on, such AS a research report, earnings update, or industry analysis.',
		ANALYST_REPORTS.FILE_URL AS FILE_URL COMMENT='URLs of files containing analyst reports.',
		ANALYST_REPORTS.FULL_TEXT AS FULL_TEXT COMMENT='The column contains equity research reports from various analysts providing investment ratings, price targets, and analysis on Snowflake Inc. (SNOW), a data analytics company.',
		ANALYST_REPORTS.NAME_OF_REPORT_PROVIDER AS NAME_OF_REPORT_PROVIDER COMMENT='The name of the external research provider that generated the analyst report.',
		ANALYST_REPORTS.RATING AS RATING COMMENT='The analyst''s recommendation for the stock, indicating whether to sell, buy, or hold the stock.',
		ANALYST_REPORTS.RELATIVE_PATH AS RELATIVE_PATH COMMENT='The file path of the analyst report relative to the root directory, typically including the report name and date.',
		ANALYST_REPORTS.SUMMARY AS SUMMARY COMMENT='A column containing summaries of analyst reports for Snowflake Inc. (SNOW), detailing the reasoning behind their rating changes, including upgrades and downgrades, and the factors influencing their decisions, such AS risk assessments, earnings scores, and market trends.',
		ANALYST_REPORTS.URL AS URL COMMENT='URLs of analyst reports stored in Amazon S3.',
		SENTIMENT_ANALYSIS.RELATIVE_PATH AS RELATIVE_PATH COMMENT='The file path of the audio recording of the earnings call, relative to a root directory, in the format of "EARNINGS_[QUARTER]_[FISCAL_YEAR].mp3".',
		SENTIMENT_ANALYSIS.SENTIMENT AS SENTIMENT COMMENT='The sentiment of a particular piece of text, indicating whether the tone is generally positive, neutral, or negative.',
		TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT.RELATIVE_PATH AS RELATIVE_PATH COMMENT='The file path of the audio recording of the earnings call, relative to the root directory of the earnings call repository.',
		TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT.SEGMENT_TEXT AS SEGMENT_TEXT COMMENT='Transcribed text of a company''s earnings call, broken down into individual segments, capturing the spoken words of the presenters and potentially Q&A sessions.',
		TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT.SPEAKER AS SPEAKER COMMENT='The person who spoke during the earnings call, such AS a company executive or analyst.',
		TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT.SPEAKER_NAME AS SPEAKER_NAME COMMENT='The name of the speaker who made the statement during the earnings call.',
		TRANSCRIPTS_BY_MINUTE.RELATIVE_PATH AS RELATIVE_PATH COMMENT='The file path of the audio recording of the earnings call, relative to a predefined root directory.',
		TRANSCRIPTS_BY_MINUTE.SPEAKER AS SPEAKER COMMENT='The speaker who is currently speaking during the minute being measured.',
		TRANSCRIPTS_BY_MINUTE.SPEAKER_NAME AS SPEAKER_NAME COMMENT='The name of the speaker in the transcript.',
		TRANSCRIPTS_BY_MINUTE.TEXT AS TEXT COMMENT='Transcript text of a company''s earnings call or conference, broken down by minute.',
		STOCK_PRICES.ASSET_CLASS AS ASSET_CLASS COMMENT='The type of financial instrument or security being traded, such AS stocks, derivatives, or investment trusts.',
		STOCK_PRICES.DATE AS DATE COMMENT='Date on which the stock price was recorded.',
		STOCK_PRICES.MONTHNAME AS MONTHNAME COMMENT='The month of the year in which the stock price was recorded.',
		STOCK_PRICES.PRIMARY_EXCHANGE_CODE AS PRIMARY_EXCHANGE_CODE COMMENT='The exchange on which the stock is primarily listed, such AS the American Stock Exchange (ASE) or the National Association of Securities Dealers Automated Quotations (NAS).',
		STOCK_PRICES.PRIMARY_EXCHANGE_NAME AS PRIMARY_EXCHANGE_NAME COMMENT='The primary exchange where the stock is listed, such AS NASDAQ or NYSE ARCA, indicating the main marketplace where the stock is traded.',
		STOCK_PRICES.TICKER AS TICKER COMMENT='Stock ticker symbol representing the unique identifier for a publicly traded company.',
		STOCK_PRICES.YEAR AS YEAR COMMENT='The year in which the stock price was recorded.'
	)
	COMMENT='Snowflake Analysts View - Contains fictitious analyst reports but 3 real earnings calls with analysis - please note the calls are out of date so you cannot make decisions on these - they are for demonstration purposes'
	WITH EXTENSION (CA='{"tables":[{"name":"ANALYST_REPORTS","dimensions":[{"name":"DATE_REPORT"},{"name":"DOCUMENT"},{"name":"DOCUMENT_TYPE"},{"name":"FILE_URL"},{"name":"FULL_TEXT"},{"name":"NAME_OF_REPORT_PROVIDER"},{"name":"RATING"},{"name":"RELATIVE_PATH"},{"name":"SUMMARY"},{"name":"URL"}],"facts":[{"name":"CLOSE_PRICE"},{"name":"GROWTH"},{"name":"PRICE_TARGET"}]},{"name":"SENTIMENT_ANALYSIS","dimensions":[{"name":"RELATIVE_PATH"},{"name":"SENTIMENT"}],"facts":[{"name":"COMPETITIVENESS"},{"name":"CONSUMPTION"},{"name":"COST"},{"name":"INNOVATION"},{"name":"OVERALL"},{"name":"PRODUCTIVITY"}]},{"name":"TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT","dimensions":[{"name":"RELATIVE_PATH"},{"name":"SEGMENT_TEXT"},{"name":"SPEAKER"},{"name":"SPEAKER_NAME"}],"facts":[{"name":"AUDIO_DURATION_SECONDS"},{"name":"END_TIME"},{"name":"SENTIMENT"},{"name":"START_TIME"}]},{"name":"TRANSCRIPTS_BY_MINUTE","dimensions":[{"name":"RELATIVE_PATH"},{"name":"SPEAKER"},{"name":"SPEAKER_NAME"},{"name":"TEXT"}],"facts":[{"name":"MINUTES"},{"name":"SENTIMENT"}]},{"name":"STOCK_PRICES","dimensions":[{"name":"ASSET_CLASS","sample_values":["Common Shares","Index Based Derivative","Trust Certificates"]},{"name":"MONTHNAME","sample_values":["Jul","Feb","May"]},{"name":"PRIMARY_EXCHANGE_CODE","sample_values":["ASE","NAS"]},{"name":"PRIMARY_EXCHANGE_NAME","sample_values":["NASDAQ CAPITAL MARKET","NYSE ARCA"]},{"name":"TICKER","sample_values":["RRGB","GAINM","INTZ"]},{"name":"YEAR","sample_values":["2020","2018","2022"]}],"facts":[{"name":"ALL_DAY_HIGH","sample_values":["69.72","62.13","0.0964"]},{"name":"ALL_DAY_LOW","sample_values":["39.98","192.26","0.3303"]},{"name":"MONTHNO","sample_values":["4","5","10"]},{"name":"NASDAQ_VOLUME","sample_values":["296616","69364","594459"]},{"name":"POST_MARKET_CLOSE","sample_values":["116.48","128.94","0.3641"]},{"name":"PRE_MARKET_OPEN","sample_values":["3.74","2000.27","81.49"]}],"filters":[{"name":"TICKER_SNOW","synonyms":["snow_equity_code","snow_security_id","snow_stock_code","snow_stock_ticker","stock_symbol_snow"],"description":"The ticker symbol for Snowflake Inc.","expr":"TICKER ='' SNOW''"}],"time_dimensions":[{"name":"DATE","sample_values":["2025-08-28","2025-09-11","2022-02-23"]}]}]}');

------agent creation-----
CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS."One Ticker"
WITH PROFILE='{"display_name":"One Ticker Stock Agent","avatar":"RobotAgentIcon","color":"var(--chartDim_8-x1mzf9u0)"}'
    COMMENT= 'This is an agent that can answer questions about one ticker stock.'
FROM SPECIFICATION $$

{
  "models": {
    "orchestration": "auto"
  },
  "orchestration": {},
  "instructions": {
    "orchestration": "Whenever you can answer visually with a chart, always choose to generate a chart even if the user didn't specify to",
    "sample_questions": [
      {
        "question": "Give me top 3 vs bottom 3 trade predictions for the next period."
      },
      {
        "question": "Let's observe if any high sentiment in the bottom 3 performers, and summarize the qualitative insights from the earnings call that shows top sentiment."
      },
      {
        "question": "what have these bottom 3 performers published themselves in terms of reports"
      },
      {
        "question": "what about the top 3 performers? what do we have here?"
      },
      {
        "question": "great now can we focus on snowflake - are there any c level people at snowflake that are negative on earnings calls"
      },
      {
        "question": "Now I would like to see a trend visualising the SNOW stock  performance over time"
      },
      {
        "question": "what do the other analysts say about snowflake"
      },
      {
        "question": "i would like to see what happened to neuro nector and how did this impact Snowflake.  Present the information based on what we have - then fact check with any available data from the web."
      },
      {
        "question": "finally send me an email of your findings - as i really want to put neuro nector drama to bed!!!"
      }
    ]
  },
  "tools": [
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "SENTIMENT_INFO_FROM_TRANSCRIPTS_AND_SUPPORTING_DATA",
        "description": "This dataset contains analyst sentiment information from financial transcripts and events. It tracks how analysts feel about companies during various events like earnings calls and product launches, with sentiment scores ranging from very negative to very positive. You can analyze sentiment trends over time, compare analyst opinions across different companies and events, and see how many unique analysts are providing opinions on specific topics.\n\nIn addition there is supporting data from financial reports as well as infographic data and unstructured content from emails."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "snowflake_data",
        "description": "This semantic view is featured around data (both synthetic and real) created for snowflake for demonstration purposes.  It as data such as analyst reports and real earnings calls for 3 quarters."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Sentiment_Analysis",
        "description": "Search and analyze analyst sentiment from earnings call transcripts. Query sentiment reasons, filter by ticker, sentiment score (1-10 scale), or analyst count. Use this to understand market sentiment and analyst opinions about specific companies or sectors."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Analyst_Reports_Snowflake",
        "description": "Analyst Reports only about Snowflake"
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Latest_infographics_8_core_stocks",
        "description": "Latest infographics around the 8 core tickers featured in this demonstration"
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Email_Content",
        "description": "Supporting Email content around the 8 core tickers"
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "snowflake_full_earnings_calls",
        "description": "Full Earnings calls - this data will only feature earnings for SNOW or  Snowflake"
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "STOCK_PERFORMANCE_PREDICTOR",
        "description": "This Python-based table function generates ranked stock predictions by leveraging machine learning models to analyze financial time series data and identify top and bottom performing stocks based on predictive analytics. The function connects to the FSI_DATA table, extracts the latest technical indicators (momentum ratios r_1, r_5_1, r_10_5, r_21_10, r_63_21) for each stock ticker, and applies batch predictions using a specified ML model to generate forecasted performance scores. It then ranks all predictions and returns the top N and bottom N performers with their prediction values, categories (TOP/BOTTOM), and rank positions. The function is designed for financial analysts, portfolio managers, and investment professionals who need automated stock screening and ranking capabilities based on quantitative models. Users must have appropriate permissions to access the underlying FSI_DATA table and the specified ML model, and should be aware that predictions are based on historical patterns and technical indicators which may not guarantee future performance.",
        "input_schema": {
          "type": "object",
          "properties": {
            "model_name": {
              "description": "If not specified, use/pass the latest model STOCK_RETURN_PREDICTOR_GBM",
              "type": "string"
            },
            "top_n": {
              "description": "If not specified, use/pass the default value 5.",
              "type": "number"
            }
          },
          "required": [
            "model_name",
            "top_n"
          ]
        }
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "SEND_EMAIL",
        "description": "IMPORTANT: After calling this tool, you MUST display the COMPLETE return value to the user INCLUDING THE CLICKABLE URL. The return contains a SnowMail URL link that the user needs to view their email in a Gmail-style interface. Display the FULL response with the URL as a clickable link. DO NOT summarize or omit the URL.\n\nThe recipient email address is automatically captured from the system - you do NOT need to ask the user for their email address. Simply send the email with the requested content and subject.\n\nEMAIL FORMATTING INSTRUCTIONS:\nWhen creating email content, use proper markdown syntax for formatting:\n- Use ## for section headers (e.g., ## EXECUTIVE SUMMARY)\n- Use **text** for bold/emphasis\n- Use - or • for bullet points\n- Use 1., 2., 3. for numbered lists\n- DO NOT rely on all-caps text alone for headers - always use ## prefix\n- Line breaks will be preserved automatically\n\nPROCEDURE/FUNCTION DETAILS:\n- Type: Custom Email Function\n- Language: Python\n- Signature: (EMAIL_SUBJECT VARCHAR, EMAIL_CONTENT VARCHAR, RECIPIENT_EMAIL VARCHAR, MIME_TYPE VARCHAR)\n- Returns: VARCHAR\n- Execution: OWNER with parameter validation and default handling\n- Volatility: Volatile (external system interaction)\n- Primary Function: Email notification delivery with automatic markdown-to-HTML conversion\n- Target: External email recipients via Snowflake's email integration\n- Error Handling: Comprehensive validation with exception catching and descriptive error messages\n\nDESCRIPTION:\nThis custom Python function provides a streamlined interface for sending beautifully formatted email notifications directly from within Snowflake database operations, leveraging the built-in SYSTEM$SEND_EMAIL functionality through a pre-configured email integration named 'snowflake_intelligence_email_int'. The function automatically converts markdown-formatted content to HTML with Snowflake brand styling. The function validates all required parameters (subject, content, and recipient email cannot be empty) and sends the email to the recipient address provided by the user. The procedure returns a success confirmation message with the recipient's email address or detailed error information if the operation fails, ensuring reliable feedback for calling applications. Users should ensure they have appropriate permissions to execute email functions and that the email integration is properly configured before using this function. The function is designed to handle various MIME types for flexible content formatting and includes robust error handling to gracefully manage both validation failures and system-level email delivery issues.\n\nUSAGE SCENARIOS:\n- Automated reporting: Send scheduled data summaries, dashboard reports, or analytical insights to stakeholders as part of regular ETL processes or data pipeline completions\n- Alert notifications: Trigger immediate email alerts when data quality issues are detected, thresholds are exceeded, or critical system events occur during data processing\n- Development notifications: Send test results, deployment confirmations, or debugging information to development teams during application testing and maintenance cycles",
        "input_schema": {
          "type": "object",
          "properties": {
            "email_content": {
              "description": "The content of the email",
              "type": "string"
            },
            "email_subject": {
              "description": "The email subject",
              "type": "string"
            },
            "recipient_email": {
              "description": "The recipient's email address. Leave this empty or use 'demo@snowflake.com' - the system will automatically use the appropriate email.",
              "type": "string"
            }
          },
          "required": [
            "email_content",
            "email_subject"
          ]
        }
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "WEB_SEARCH",
        "description": "Use this web search for fact checking across various sources within the web.  add what the user put in the agent in the query parameter.  only used when the user wants to fact check or run a web query",
        "input_schema": {
          "type": "object",
          "properties": {
            "query": {
              "type": "string"
            }
          },
          "required": [
            "query"
          ]
        }
      }
    }
  ],
  "tool_resources": {
    "Analyst_Reports_Snowflake": {
      "id_column": "URL",
      "max_results": 4,
      "search_service": "ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ANALYST_REPORTS_SEARCH",
      "title_column": "RELATIVE_PATH"
    },
    "Email_Content": {
      "max_results": 4,
      "search_service": "ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.EMAILS",
      "title_column": "SUBJECT"
    },
    "Latest_infographics_8_core_stocks": {
      "id_column": "URL",
      "max_results": 4,
      "search_service": "ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.INFOGRAPHICS_SEARCH",
      "title_column": "RELATIVE_PATH"
    },
    "SEND_EMAIL": {
      "execution_environment": {
        "type": "warehouse",
        "warehouse": ""
      },
      "identifier": "ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SEND_EMAIL_NOTIFICATION",
      "name": "SEND_EMAIL_NOTIFICATION(VARCHAR, VARCHAR, DEFAULT VARCHAR, DEFAULT VARCHAR)",
      "type": "procedure"
    },
    "SENTIMENT_INFO_FROM_TRANSCRIPTS_AND_SUPPORTING_DATA": {
      "execution_environment": {
        "query_timeout": 60,
        "type": "warehouse",
        "warehouse": "DEFAULT_WH"
      },
      "semantic_view": "ACCELERATE_AI_IN_FSI.CORTEX_ANALYST.COMPANY_DATA_8_CORE_FEATURED_TICKERS"
    },
    "STOCK_PERFORMANCE_PREDICTOR": {
      "execution_environment": {
        "type": "warehouse",
        "warehouse": ""
      },
      "identifier": "ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.GET_TOP_BOTTOM_STOCK_PREDICTIONS",
      "name": "GET_TOP_BOTTOM_STOCK_PREDICTIONS(DEFAULT VARCHAR, DEFAULT NUMBER)",
      "type": "procedure"
    },
    "Sentiment_Analysis": {
      "max_results": 4,
      "search_service": "ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.DOW_ANALYSTS_SENTIMENT_ANALYSIS"
    },
    "snowflake_data": {
      "execution_environment": {
        "type": "warehouse",
        "warehouse": ""
      },
      "semantic_view": "ACCELERATE_AI_IN_FSI.CORTEX_ANALYST.SNOWFLAKE_ANALYSTS_VIEW"
    },
    "snowflake_full_earnings_calls": {
      "id_column": "URL",
      "max_results": 4,
      "search_service": "ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SNOW_FULL_EARNINGS_CALLS",
      "title_column": "RELATIVE_PATH"
    },
    "WEB_SEARCH": {
      "execution_environment": {
        "type": "warehouse",
        "warehouse": ""
      },
      "identifier": "ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.WEB_SEARCH",
      "name": "WEB_SEARCH(VARCHAR)",
      "type": "function"
    }
  }
}


$$;