import datetime
import random
import hashlib
import csv

# Configuration
NUM_EMAILS_TO_GENERATE = 316  # To reach 324 total with existing 8
START_DATE = datetime.date(2024, 1, 1)
END_DATE = datetime.date(2024, 12, 31)
OUTPUT_FILE = "DATA/email_previews_data.csv"

COMPANIES = {
    "SNOW": {"name": "Snowflake", "business": "Enterprise data cloud", "growth": "29%", "nrr": "127%", "customers": "10,000+", "color": "#29B5E8"},
    "CTLG": {"name": "CatalogX", "business": "Data governance and compliance", "growth": "174%", "nrr": "132%", "customers": "847", "color": "#6366F1"},
    "DFLX": {"name": "DataFlex Analytics", "business": "Business intelligence layer", "growth": "24%", "nrr": "78%", "customers": "1,847", "color": "#8B5CF6"},
    "ICBG": {"name": "ICBG Data Systems", "business": "Apache Iceberg-based data platform", "growth": "156%", "nrr": "138%", "customers": "1,124", "color": "#10B981"},
    "NRNT": {"name": "Neuro-Nectar", "business": "AI-powered cognitive products", "growth": "487%", "nrr": "N/A", "customers": "28.4M units shipped", "color": "#EC4899"},
    "QRYQ": {"name": "Querybase", "business": "Price-performance leader", "growth": "287%", "nrr": "142%", "customers": "2,100+", "color": "#F59E0B"},
    "STRM": {"name": "StreamPipe Systems", "business": "Data streaming and integration", "growth": "142%", "nrr": "135%", "customers": "1,500+", "color": "#06B6D4"},
    "VLTA": {"name": "Voltaic AI", "business": "AI/ML production platform", "growth": "318%", "nrr": "158%", "customers": "780", "color": "#EF4444"},
    # Bottom 3 performers - minimal investor materials, earnings calls only
    "PROP": {"name": "PropTech Analytics", "business": "Real estate data analytics", "growth": "234%", "nrr": "110%", "customers": "450+", "color": "#14B8A6"},
    "GAME": {"name": "GameMetrics", "business": "Gaming analytics platform", "growth": "287%", "nrr": "125%", "customers": "890+", "color": "#A855F7"},
    "MKTG": {"name": "Marketing Analytics", "business": "Marketing performance analytics", "growth": "156%", "nrr": "105%", "customers": "620+", "color": "#F97316"},
}

RECIPIENTS = [
    "portfolio.manager@techfund.com", "research@goldmansachs.com", "trading.desk@hedgefund.com",
    "analyst.team@morganstanley.com", "investment.committee@blackrock.com", "sector.team@jpmorgan.com",
    "compliance@regulatoryinvest.com", "quant.team@renaissancetech.com", "research@oppenheimer.com",
    "analyst@needham.com", "desk@susquehanna.com", "research@cowen.com", "alert@hedgeye.com",
    "pm@vanguard.com", "research@bernstein.com", "research@piper.com", "desk@citadel.com",
    "sector.team@jefferies.com", "trading@janestreet.com", "pm.team@blackrock.com", "pm@t.rowe.price.com",
    "pm@wellington.com", "research@mizuho.com", "pm@invesco.com", "research@raymondjames.com",
    "research@baml.com", "equity.research@citi.com"
]

ANALYSTS = [
    "Sarah Mitchell", "David Chen", "Jennifer Walsh", "Michael Torres", "Lisa Rodriguez", "Robert Chen",
    "Thomas Wright", "Alexandra Patel", "Christopher Lee", "Daniel Park", "Derek Liu", "Amanda White",
    "Patricia Morgan", "Emily Chen", "Rachel Kim", "Rebecca Foster", "James Anderson", "Michelle Zhang",
    "Tom Bradford", "Andrew Sullivan", "Jessica Taylor", "Marcus Chen"
]

# Email templates
TEMPLATES = [
    {
        "subject": "{company_name} Q{quarter} Earnings Preview: Key Metrics to Watch",
        "content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: {color};">{company_name} Earnings Preview</h2>
<p><strong>Date:</strong> {date}</p>

<h3 style="color: #333;">Expected Financial Results</h3>
<ul>
<li><strong>Revenue:</strong> Expected to report strong quarter with {growth} YoY growth</li>
<li><strong>Key Metrics:</strong> Customer count and NRR critical indicators</li>
<li><strong>Guidance:</strong> Forward guidance will drive stock movement</li>
<li><strong>Competitive Dynamics:</strong> Questions on market position likely</li>
</ul>

<h3 style="color: #333;">Key Questions for Management</h3>
<ol>
<li>What are consumption trends showing for Q{quarter}?</li>
<li>How is competitive environment evolving?</li>
<li>Any updates on new product initiatives?</li>
<li>Customer pipeline and deal velocity commentary?</li>
</ol>

<h3 style="color: #333;">Investment Implications</h3>
<p style="background: {color}20; padding: 15px; border-left: 4px solid {color};">
Expect volatility around earnings. {company_name} integrated data platform position strong but valuation sensitive to guidance.
Focus on {company_business} metrics for forward trajectory.
</p>

<p>{analyst_name}<br>Equity Research</p>
</body></html>""",
        "type": "earnings_preview"
    },
    {
        "subject": "{company_name} Q{quarter} Results: Beat/Miss Analysis",
        "content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: {color};">{company_name}: {ticker} Q{quarter} Results Analysis</h2>
<p><strong>Date:</strong> {date}</p>

<h3 style="color: #333;">Overview</h3>
<p>Important development regarding {company_name}'s {company_business} business.</p>

<h3 style="color: #333;">Key Points</h3>
<ul>
<li><strong>Current Position:</strong> {company_business} approach driving {growth} growth</li>
<li><strong>Market Impact:</strong> Significant implications for competitive landscape</li>
<li><strong>Customer Base:</strong> {customers} provides strong foundation</li>
<li><strong>Financial Health:</strong> NRR of {nrr} demonstrates expansion potential</li>
</ul>

<h3 style="color: #333;">Analysis</h3>
<p style="background: {color}20; padding: 15px; border-left: 4px solid {color};">
This development aligns with {company_name}'s strategic focus on {company_business}. 
Continue monitoring for implications on growth trajectory and competitive positioning.
</p>

<p>{analyst_name}<br>Research Coverage</p>
</body></html>""",
        "type": "earnings_results"
    },
    {
        "subject": "{company_name} Investment Update: {scenario}",
        "content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: {color};">{company_name}: {ticker} Investment Update: {scenario}</h2>
<p><strong>Date:</strong> {date}</p>

<h3 style="color: #333;">Overview</h3>
<p>Important development regarding {company_name}'s {company_business} business.</p>

<h3 style="color: #333;">Key Points</h3>
<ul>
<li><strong>Current Position:</strong> {company_business} approach driving {growth} growth</li>
<li><strong>Market Impact:</strong> Significant implications for competitive landscape</li>
<li><strong>Customer Base:</strong> {customers} provides strong foundation</li>
<li><strong>Financial Health:</strong> NRR of {nrr} demonstrates expansion potential</li>
</ul>

<h3 style="color: #333;">Analysis</h3>
<p style="background: {color}20; padding: 15px; border-left: 4px solid {color};">
This development aligns with {company_name}'s strategic focus on {company_business}. 
Continue monitoring for implications on growth trajectory and competitive positioning.
</p>

<p>{analyst_name}<br>Research Coverage</p>
</body></html>""",
        "type": "investment_update"
    },
    {
        "subject": "RISK ALERT: {company_name} Facing Headwinds",
        "content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #DC2626;">{company_name} Risk Alert: {scenario}</h2>
<p><strong>Date:</strong> {date}</p>
<p><strong>Severity:</strong> MEDIUM-HIGH</p>

<h3 style="color: #333;">Situation Summary</h3>
<p>{scenario_detail}</p>

<h3 style="color: #333;">Potential Impact</h3>
<ul>
<li><strong>Near-term:</strong> Stock volatility likely, possible 5-10% downside</li>
<li><strong>Customer Confidence:</strong> May impact sales cycle and deal velocity</li>
<li><strong>Competitive:</strong> Competitors will use in sales process</li>
<li><strong>Guidance:</strong> Could pressure forward estimates</li>
</ul>

<h3 style="color: #333;">Management Response</h3>
<p>Company has issued statement addressing the situation. Key points:</p>
<ul>
<li>Acknowledges issue and taking corrective action</li>
<li>Timeline for resolution provided (60-90 days)</li>
<li>No material impact expected to FY guidance</li>
<li>Investing in preventive measures going forward</li>
</ul>

<h3 style="color: #333;">Investment Implications</h3>
<p style="background: #FEE2E2; padding: 15px; border-left: 4px solid #DC2626;">
<strong>Action:</strong> Reduce position by 25-30% until situation stabilizes.<br>
<strong>Monitoring:</strong> Weekly updates required on resolution progress.<br>
<strong>Re-entry:</strong> Look for stabilization signals before adding back.
</p>

<p>{analyst_name}<br>Risk Management</p>
</body></html>""",
        "type": "risk_alert"
    },
    {
        "subject": "{company_name} Major Enterprise Customer Win Announcement",
        "content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: {color};">{company_name} Major Customer Win</h2>
<p><strong>Date:</strong> {date}</p>
<p><strong>Alert Level:</strong> HIGH</p>

<h3 style="color: #333;">Deal Details</h3>
<ul>
<li><strong>Customer:</strong> {customer_name}</li>
<li><strong>Contract Value:</strong> ${contract_value}M (3-year commitment)</li>
<li><strong>Use Case:</strong> {company_business}</li>
<li><strong>Competitive:</strong> Won against key competitors</li>
</ul>

<h3 style="color: #333;">Strategic Significance</h3>
<p>This win validates {company_name}'s {company_business} approach:</p>
<ol>
<li><strong>Reference Account:</strong> {customer_name} as referenceable customer unlocks similar deals</li>
<li><strong>Product Validation:</strong> Chosen by tier-1 enterprise demonstrates maturity</li>
<li><strong>Competitive Position:</strong> Direct win against established players</li>
<li><strong>Expansion Potential:</strong> Land-and-expand opportunity significant</li>
</ol>

<h3 style="color: #333;">Financial Impact</h3>
<ul>
<li>Annual revenue contribution: ~{annual_revenue_impact}M</li>
<li>Strengthens Q{quarter} guidance visibility</li>
<li>Improves customer mix and reduces concentration</li>
<li>Validates pricing power in enterprise segment</li>
</ul>

<h3 style="color: #333;">Stock Impact</h3>
<p style="background: {color}20; padding: 15px; border-left: 4px solid {color};">
<strong>Expected Move:</strong> +5-8% on news<br>
<strong>Recommendation:</strong> This validates growth trajectory. Maintain overweight position.
</p>

<p>{analyst_name}<br>Enterprise Software Coverage</p>
</body></html>""",
        "type": "customer_win"
    },
    {
        "subject": "{company_name} Technical Setup: Trade Opportunity",
        "content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: {color};">{ticker} Technical Analysis & Trade Setup</h2>
<p><strong>Date:</strong> {date}</p>
<p><strong>Current Price:</strong> ${current_price}</p>

<h3 style="color: #333;">Chart Pattern</h3>
<ul>
<li><strong>Pattern:</strong> Bullish consolidation with breakout potential</li>
<li><strong>Support Level:</strong> ${support_level} (tested 3x, holding firm)</li>
<li><strong>Resistance Level:</strong> ${resistance_level} (key breakout level)</li>
<li><strong>Volume Profile:</strong> Accumulation pattern visible</li>
<li><strong>RSI:</strong> {rsi} (neutral, room to run)</li>
<li><strong>MACD:</strong> Bullish crossover forming</li>
</ul>

<h3 style="color: #333;">Key Technical Levels</h3>
<table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
<tr style="background: #f0f0f0;">
<th style="padding: 10px; border: 1px solid #ddd; text-align: left;">Level</th>
<th style="padding: 10px; border: 1px solid #ddd; text-align: left;">Price</th>
<th style="padding: 10px; border: 1px solid #ddd; text-align: left;">Significance</th>
</tr>
<tr>
<td style="padding: 10px; border: 1px solid #ddd;">Strong Support</td>
<td style="padding: 10px; border: 1px solid #ddd; font-weight: bold;">${support_level}</td>
<td style="padding: 10px; border: 1px solid #ddd;">Previous consolidation base</td>
</tr>
<tr style="background: #f9f9f9;">
<td style="padding: 10px; border: 1px solid #ddd;">Current Price</td>
<td style="padding: 10px; border: 1px solid #ddd; font-weight: bold;">${current_price}</td>
<td style="padding: 10px; border: 1px solid #ddd;">Testing resistance</td>
</tr>
<tr>
<td style="padding: 10px; border: 1px solid #ddd;">Breakout Level</td>
<td style="padding: 10px; border: 1px solid #ddd; font-weight: bold;">${resistance_level}</td>
<td style="padding: 10px; border: 1px solid #ddd;">Bullish confirmation</td>
</tr>
<tr style="background: #f9f9f9;">
<td style="padding: 10px; border: 1px solid #ddd;">Price Target</td>
<td style="padding: 10px; border: 1px solid #ddd; color: green; font-weight: bold;">${price_target}</td>
<td style="padding: 10px; border: 1px solid #ddd;">Measured move target</td>
</tr>
</table>

<h3 style="color: #333;">Trade Setup</h3>
<p style="background: {color}20; padding: 15px; border-left: 4px solid {color};">
<strong>Entry:</strong> ${entry_range} (current levels)<br>
<strong>Stop Loss:</strong> ${stop_loss} (below support)<br>
<strong>Target:</strong> ${price_target} (measured move)<br>
<strong>Risk/Reward:</strong> {risk_reward}:1<br>
<strong>Position Size:</strong> 2-3% of portfolio
</p>

<h3 style="color: #333;">Catalysts</h3>
<ul>
<li>Upcoming earnings report expected to beat</li>
<li>Sector rotation into growth/tech</li>
<li>Positive analyst commentary building</li>
<li>Institutional accumulation evident in volume</li>
</ul>

<p>{analyst_name}<br>Technical Strategy</p>
</body></html>""",
        "type": "technical_analysis"
    }
]

SCENARIOS = {
    "investment_update": [
        "Geographic Expansion", "New Product Launch", "Strategic Partnership", "Acquisition Rumors",
        "Analyst Upgrade", "Analyst Downgrade", "Guidance Raise", "Guidance Cut", "Customer Win",
        "Customer Loss", "Technology Shift", "Market Share", "Pricing Pressure", "Talent Acquisition",
        "Insider Trading", "Conference Notes", "Brand Perception", "Macro Impact", "Vertical Focus",
        "Contract Renewal", "Security Breach", "Product Quality", "Partnership Termination", "M&A Speculation"
    ],
    "risk_alert": [
        {"scenario": "Product Delay", "detail": "Key product launch delayed 6 months"},
        {"scenario": "Talent Exodus", "detail": "VP of Engineering and CTO departed within 30 days"},
        {"scenario": "Regulatory Scrutiny", "detail": "SEC investigating revenue recognition practices"},
        {"scenario": "Customer Concentration", "detail": "Top 10 customers represent 45% of revenue"},
        {"scenario": "Security Incident", "detail": "Data breach affecting 500+ customers disclosed"},
    ],
    "customer_win_names": ["Google", "Microsoft", "Amazon", "Apple", "Uber", "JPMorgan", "Goldman Sachs", "Morgan Stanley"]
}

# Existing 8 emails from data_foundation.template.sql
EXISTING_EMAILS = [
    {
        "email_id": "EMAIL_001",
        "recipient": "portfolio.manager@techfund.com",
        "subject": "URGENT: NRNT Crisis Impact on SNOW Position",
        "html_content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #29B5E8;">URGENT: NRNT Crisis & SNOW Recovery Analysis</h2>
<p><strong>Date:</strong> November 20, 2024</p>
<p><strong>To:</strong> Portfolio Management Team</p>

<h3 style="color: #333;">Executive Summary</h3>
<p>Neuro-Nectar (NRNT) has entered administration following reports of severe gastric distress. Stock crashed 90.4% from $133.75 to $12.79 and has been DELISTED. This removes the existential threat to our SNOW position.</p>

<h3 style="color: #333;">Impact on Snowflake (SNOW)</h3>
<ul>
<li><strong>Sept 19:</strong> Downgraded to SELL by Apex Analytics due to NRNT "cognitive enhancement" threat</li>
<li><strong>Stock Impact:</strong> -3% decline during September-November crisis period</li>
<li><strong>Nov 20:</strong> Upgraded back to HOLD as NRNT threat eliminated</li>
<li><strong>Recovery:</strong> +6.6% by Nov 29 as fundamentals return to focus</li>
</ul>

<h3 style="color: #333;">Recommendation</h3>
<p style="background: #E0F2F7; padding: 15px; border-left: 4px solid #29B5E8;">
<strong>MAINTAIN OVERWEIGHT position in SNOW.</strong> Q3 results strong: $900M revenue (29% YoY), 10,000+ customers, 127% NRR. Enterprise infrastructure thesis validated over consumer hype.
</p>

<h3 style="color: #333;">Competitors to Monitor</h3>
<ul>
<li><strong>ICBG:</strong> Open lakehouse gaining traction (156% growth, $87M revenue)</li>
<li><strong>QRYQ:</strong> Aggressive challenger (287% growth, 37% win rate vs SNOW)</li>
</ul>

<p>Best regards,<br><strong>Sarah Mitchell</strong><br>Senior Analyst, Tech Infrastructure</p>
</body></html>""",
        "created_at": "2024-11-20 15:30:00"
    },
    {
        "email_id": "EMAIL_002",
        "recipient": "research@goldmansachs.com",
        "subject": "SNOW vs QRYQ Competitive Analysis: Price War Intensifies",
        "html_content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #29B5E8;">Competitive Dynamics: SNOW vs QRYQ</h2>
<p><strong>Date:</strong> October 15, 2024</p>

<h3 style="color: #333;">Key Findings</h3>
<p>Our channel checks reveal QRYQ winning 37% of competitive deals vs SNOW primarily on price/performance:</p>

<table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
<tr style="background: #f0f0f0;">
<th style="padding: 10px; border: 1px solid #ddd; text-align: left;">Metric</th>
<th style="padding: 10px; border: 1px solid #ddd;">SNOW</th>
<th style="padding: 10px; border: 1px solid #ddd;">QRYQ</th>
</tr>
<tr>
<td style="padding: 10px; border: 1px solid #ddd;">YoY Growth</td>
<td style="padding: 10px; border: 1px solid #ddd;">29%</td>
<td style="padding: 10px; border: 1px solid #ddd; color: green; font-weight: bold;">287%</td>
</tr>
<tr style="background: #f9f9f9;">
<td style="padding: 10px; border: 1px solid #ddd;">Win Rate (competitive)</td>
<td style="padding: 10px; border: 1px solid #ddd;">63%</td>
<td style="padding: 10px; border: 1px solid #ddd;">37%</td>
</tr>
<tr>
<td style="padding: 10px; border: 1px solid #ddd;">Price Positioning</td>
<td style="padding: 10px; border: 1px solid #ddd;">Premium</td>
<td style="padding: 10px; border: 1px solid #ddd; color: green;">40% lower</td>
</tr>
<tr style="background: #f9f9f9;">
<td style="padding: 10px; border: 1px solid #ddd;">Claimed Performance Edge</td>
<td style="padding: 10px; border: 1px solid #ddd;">Baseline</td>
<td style="padding: 10px; border: 1px solid #ddd; color: green;">3-5x faster</td>
</tr>
</table>

<h3 style="color: #333;">SNOW Response Strategy</h3>
<ul>
<li><strong>Product:</strong> Hybrid Tables & Iceberg support neutralizing performance gap</li>
<li><strong>Value:</strong> Emphasizing ecosystem breadth, governance, compliance</li>
<li><strong>Pricing:</strong> Selective discounting in strategic accounts</li>
</ul>

<h3 style="color: #333;">Investment Implications</h3>
<p style="background: #FFF4E6; padding: 15px; border-left: 4px solid #FF9F36;">
<strong>Rating: HOLD</strong><br>
QRYQ represents meaningful competitive threat but SNOW still leads on enterprise features. Monitor NRR for early signs of pricing pressure.
</p>

<p>Best regards,<br><strong>David Chen</strong><br>Cloud Infrastructure Team</p>
</body></html>""",
        "created_at": "2024-10-15 09:15:00"
    },
    {
        "email_id": "EMAIL_003",
        "recipient": "trading.desk@hedgefund.com",
        "subject": "ICBG Q2 Results: Open Architecture Driving Massive Growth",
        "html_content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #10B981;">ICBG Q2 FY2025 Results Beat</h2>
<p><strong>Date:</strong> August 24, 2024</p>

<h3 style="color: #333;">Results Summary</h3>
<ul>
<li><strong>Revenue:</strong> $87M (156% YoY) vs consensus $78M</li>
<li><strong>RPO:</strong> $185M (178% growth) well above $160M guide</li>
<li><strong>Customers $1M+:</strong> 267 (up 180% YoY)</li>
<li><strong>NRR:</strong> 138% (consistent with premium growth profile)</li>
<li><strong>Operating Margin:</strong> -24% improving from -35%</li>
</ul>

<h3 style="color: #333;">Key Themes from Call</h3>
<p><strong>1. Open Architecture Resonating:</strong> Enterprises avoiding vendor lock-in, Apache Iceberg momentum</p>
<p><strong>2. AWS Partnership Critical:</strong> Amazon HealthLake deal validates open lakehouse approach</p>
<p><strong>3. SNOW Migration Activity:</strong> 15% of new logos are SNOW replacements (up from 8% last quarter)</p>

<h3 style="color: #333;">Guidance</h3>
<ul>
<li>Q3 Revenue: $95-98M (mid-point $96.5M vs consensus $91M)</li>
<li>FY2025: Raising full year by $30M citing pipeline strength</li>
</ul>

<h3 style="color: #333;">Stock Impact</h3>
<p style="background: #D1FAE5; padding: 15px; border-left: 4px solid #10B981;">
<strong>UPGRADING to BUY (from HOLD)</strong><br>
<strong>New Price Target: $185</strong> (from $140)<br>
Open lakehouse thesis accelerating. ICBG positioned as serious SNOW alternative for cost-conscious enterprises.
</p>

<p>Best regards,<br><strong>Jennifer Walsh</strong><br>Emerging Cloud Platforms</p>
</body></html>""",
        "created_at": "2024-08-24 16:45:00"
    },
    {
        "email_id": "EMAIL_004",
        "recipient": "analyst.team@morganstanley.com",
        "subject": "CTLG Earnings: Data Governance Platform Seeing Enterprise Adoption",
        "html_content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #6366F1;">CatalogX (CTLG): Data Governance Wave</h2>
<p><strong>Date:</strong> September 5, 2024</p>

<h3 style="color: #333;">Investment Thesis</h3>
<p>CatalogX provides unified data governance across heterogeneous environments (SNOW, QRYQ, ICBG, STRM, VLTA, DFLX). As enterprises adopt multi-platform strategies, centralized governance becomes critical for compliance.</p>

<h3 style="color: #333;">Q2 FY2025 Highlights</h3>
<ul>
<li><strong>Revenue:</strong> $48M (174% YoY growth)</li>
<li><strong>Customers:</strong> 847 total, 185 at $1M+ (ARR)</li>
<li><strong>NRR:</strong> 132% (strong expansion motion)</li>
<li><strong>Margin:</strong> 66% gross, -35% operating (rule of 40: 139%)</li>
</ul>

<h3 style="color: #333;">Regulatory Tailwinds</h3>
<p>Management cited 3 key drivers:</p>
<ol>
<li><strong>GDPR/CCPA Compliance:</strong> Data residency & access controls mandatory</li>
<li><strong>AI Governance:</strong> EU AI Act & proposed US frameworks requiring ML model lineage</li>
<li><strong>Multi-Cloud Complexity:</strong> 73% of F500 using 3+ data platforms (Gartner)</li>
</ol>

<h3 style="color: #333;">Competitive Moat</h3>
<ul>
<li>Only vendor with native Snowflake, Databricks, Querybase, and StreamPipe integrations</li>
<li>Real-time lineage tracking across platforms (30-40% cost savings per customer testimonials)</li>
<li>Network effects: More platforms = higher switching costs</li>
</ul>

<h3 style="color: #333;">Valuation & Rating</h3>
<p style="background: #EEF2FF; padding: 15px; border-left: 4px solid #6366F1;">
<strong>Rating: OVERWEIGHT</strong><br>
<strong>Price Target: $95</strong> (30x CY2025 revenue of $220M)<br>
Governance platform essential in multi-cloud world. TAM expanding with AI adoption.
</p>

<p>Best regards,<br><strong>Michael Torres</strong><br>Enterprise SaaS Coverage</p>
</body></html>""",
        "created_at": "2024-09-05 11:20:00"
    },
    {
        "email_id": "EMAIL_005",
        "recipient": "investment.committee@blackrock.com",
        "subject": "STRM + VLTA Partnership: Implications for AI Infrastructure Stack",
        "html_content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #06B6D4;">STRM + VLTA Strategic Partnership Analysis</h2>
<p><strong>Date:</strong> July 18, 2024</p>

<h3 style="color: #333;">Deal Overview</h3>
<p>StreamPipe (STRM) and Voltaic AI (VLTA) announced strategic partnership enabling real-time ML feature pipelines directly from streaming data.</p>

<h3 style="color: #333;">Strategic Rationale</h3>
<p><strong>For STRM:</strong> Expands use case from ETL to real-time AI, higher value propositions</p>
<p><strong>For VLTA:</strong> Solves #1 customer pain point - feature freshness for production ML</p>

<h3 style="color: #333;">Market Impact</h3>
<table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
<tr style="background: #f0f0f0;">
<th style="padding: 10px; border: 1px solid #ddd; text-align: left;">Company</th>
<th style="padding: 10px; border: 1px solid #ddd;">Q2 Revenue</th>
<th style="padding: 10px; border: 1px solid #ddd;">YoY Growth</th>
<th style="padding: 10px; border: 1px solid #ddd;">AI Use Case %</th>
</tr>
<tr>
<td style="padding: 10px; border: 1px solid #ddd;"><strong>STRM</strong></td>
<td style="padding: 10px; border: 1px solid #ddd;">$78M</td>
<td style="padding: 10px; border: 1px solid #ddd;">142%</td>
<td style="padding: 10px; border: 1px solid #ddd; color: green;">28% → 35%*</td>
</tr>
<tr style="background: #f9f9f9;">
<td style="padding: 10px; border: 1px solid #ddd;"><strong>VLTA</strong></td>
<td style="padding: 10px; border: 1px solid #ddd;">$45M</td>
<td style="padding: 10px; border: 1px solid #ddd;">318%</td>
<td style="padding: 10px; border: 1px solid #ddd; color: green;">100%</td>
</tr>
</table>
<p style="font-size: 12px; color: #666;">*Projected with VLTA integration</p>

<h3 style="color: #333;">Customer Wins</h3>
<p>Partnership already secured 3 joint F500 customers:</p>
<ul>
<li><strong>Uber:</strong> Real-time fraud detection (saving $150M annually)</li>
<li><strong>DoorDash:</strong> Dynamic delivery routing optimization</li>
<li><strong>Capital One:</strong> Real-time credit decisioning</li>
</ul>

<h3 style="color: #333;">Investment Implications</h3>
<p style="background: #CFFAFE; padding: 15px; border-left: 4px solid #06B6D4;">
<strong>STRM Rating: BUY</strong> (PT $145, up from $120)<br>
<strong>VLTA Rating: BUY</strong> (PT $88, up from $65)<br>
Partnership creates compelling end-to-end AI data platform. Both should see NRR expansion from existing base.
</p>

<p>Best regards,<br><strong>Lisa Rodriguez</strong><br>AI Infrastructure Team</p>
</body></html>""",
        "created_at": "2024-07-18 14:05:00"
    },
    {
        "email_id": "EMAIL_006",
        "recipient": "sector.team@jpmorgan.com",
        "subject": "DFLX Business Model Analysis: The Switzerland of BI",
        "html_content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #8B5CF6;">DataFlex Analytics (DFLX): Platform-Agnostic BI Layer</h2>
<p><strong>Date:</strong> June 12, 2024</p>

<h3 style="color: #333;">Business Model</h3>
<p>DFLX provides BI/visualization layer that connects to ANY data platform (SNOW, QRYQ, ICBG, etc). Explicit "Switzerland" positioning - not competing in storage, only analytics layer.</p>

<h3 style="color: #333;">Why This Model Works</h3>
<ul>
<li><strong>Vendor Neutral:</strong> Sales teams can position as complement vs competitor to data platforms</li>
<li><strong>Multi-Cloud Reality:</strong> 68% of enterprises use 2+ data platforms</li>
<li><strong>Best-of-Breed:</strong> Customers want choice, not vertical lock-in</li>
</ul>

<h3 style="color: #333;">Q2 FY2025 Metrics</h3>
<ul>
<li><strong>Revenue:</strong> $67M (24% YoY growth)</li>
<li><strong>Customers:</strong> 1,847 total, 248 at $1M+ ARR</li>
<li><strong>NRR:</strong> 78% (lower than peers but improving from 65%)</li>
<li><strong>Margin:</strong> 75% gross, -9% operating</li>
</ul>

<h3 style="color: #333;">Partnerships Drive Growth</h3>
<p>DFLX has OEM/reseller agreements with:</p>
<ol>
<li><strong>SNOW:</strong> Listed in Snowflake Marketplace</li>
<li><strong>QRYQ:</strong> Joint go-to-market in EMEA</li>
<li><strong>ICBG:</strong> Default BI tool for Apache Iceberg users</li>
<li><strong>STRM/VLTA/CTLG:</strong> Technical integrations for real-time dashboards</li>
</ol>

<h3 style="color: #333;">Competitive Dynamics</h3>
<p>Unlike Tableau/PowerBI (Microsoft-centric) or Looker (Google-centric), DFLX truly platform-agnostic. This "multiplicative" model creates win-win vs zero-sum competition.</p>

<h3 style="color: #333;">Investment View</h3>
<p style="background: #F3E8FF; padding: 15px; border-left: 4px solid #8B5CF6;">
<strong>Rating: EQUAL-WEIGHT</strong><br>
<strong>Price Target: $42</strong><br>
Business model sound but execution inconsistent (low NRR). Needs to prove expansion motion before upgrade.
</p>

<p>Best regards,<br><strong>Robert Chen</strong><br>BI & Analytics Coverage</p>
</body></html>""",
        "created_at": "2024-06-12 10:30:00"
    },
    {
        "email_id": "EMAIL_007",
        "recipient": "compliance@regulatoryinvest.com",
        "subject": "Multi-Cloud Data Platform Ecosystem Map & Investment Framework",
        "html_content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #29B5E8;">2024 Cloud Data Platform Ecosystem Analysis</h2>
<p><strong>Date:</strong> May 20, 2024</p>

<h3 style="color: #333;">The Modern Data Stack (2024)</h3>
<table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
<tr style="background: #f0f0f0;">
<th style="padding: 10px; border: 1px solid #ddd; text-align: left;">Layer</th>
<th style="padding: 10px; border: 1px solid #ddd;">Leader</th>
<th style="padding: 10px; border: 1px solid #ddd;">Challengers</th>
<th style="padding: 10px; border: 1px solid #ddd;">Strategy</th>
</tr>
<tr>
<td style="padding: 10px; border: 1px solid #ddd;"><strong>Storage</strong></td>
<td style="padding: 10px; border: 1px solid #ddd;">SNOW</td>
<td style="padding: 10px; border: 1px solid #ddd;">QRYQ, ICBG</td>
<td style="padding: 10px; border: 1px solid #ddd;">Vertical integration</td>
</tr>
<tr style="background: #f9f9f9;">
<td style="padding: 10px; border: 1px solid #ddd;"><strong>Streaming</strong></td>
<td style="padding: 10px; border: 1px solid #ddd;">STRM</td>
<td style="padding: 10px; border: 1px solid #ddd;">Confluent, Kinesis</td>
<td style="padding: 10px; border: 1px solid #ddd;">Real-time data pipes</td>
</tr>
<tr>
<td style="padding: 10px; border: 1px solid #ddd;"><strong>AI/ML</strong></td>
<td style="padding: 10px; border: 1px solid #ddd;">VLTA</td>
<td style="padding: 10px; border: 1px solid #ddd;">Databricks MLflow</td>
<td style="padding: 10px; border: 1px solid #ddd;">Production ML ops</td>
</tr>
<tr style="background: #f9f9f9;">
<td style="padding: 10px; border: 1px solid #ddd;"><strong>Governance</strong></td>
<td style="padding: 10px; border: 1px solid #ddd;">CTLG</td>
<td style="padding: 10px; border: 1px solid #ddd;">Collibra, Alation</td>
<td style="padding: 10px; border: 1px solid #ddd;">Cross-platform catalog</td>
</tr>
<tr>
<td style="padding: 10px; border: 1px solid #ddd;"><strong>BI Layer</strong></td>
<td style="padding: 10px; border: 1px solid #ddd;">DFLX</td>
<td style="padding: 10px; border: 1px solid #ddd;">Tableau, PowerBI</td>
<td style="padding: 10px; border: 1px solid #ddd;">Platform-agnostic</td>
</tr>
</table>

<h3 style="color: #333;">Cooperation vs Competition Matrix</h3>
<p><strong>Symbiotic Relationships:</strong></p>
<ul>
<li><strong>DFLX ↔ All:</strong> BI layer partners with everyone</li>
<li><strong>CTLG ↔ All:</strong> Governance spans multiple platforms</li>
<li><strong>STRM → VLTA:</strong> Real-time ML feature pipelines</li>
<li><strong>ICBG → AWS/Azure:</strong> Cloud-native integrations</li>
</ul>

<p><strong>Direct Competition:</strong></p>
<ul>
<li><strong>SNOW vs QRYQ vs ICBG:</strong> Core data platform wars</li>
<li><strong>SNOW Cortex vs VLTA:</strong> In-platform ML vs standalone</li>
</ul>

<h3 style="color: #333;">Investment Framework</h3>
<p><strong>Core Holdings (High Conviction):</strong></p>
<ul>
<li><strong>SNOW:</strong> Market leader, enterprise moat, but valuation premium</li>
<li><strong>CTLG:</strong> Must-have governance layer, regulatory tailwinds</li>
</ul>

<p><strong>Growth Plays (Higher Risk/Reward):</strong></p>
<ul>
<li><strong>QRYQ:</strong> Price/performance disruptor, taking share from SNOW</li>
<li><strong>VLTA:</strong> AI infrastructure wave, 318% growth</li>
<li><strong>ICBG:</strong> Open lakehouse momentum, AWS partnership</li>
</ul>

<p><strong>Satellite Positions (Niche Leaders):</strong></p>
<ul>
<li><strong>STRM:</strong> Real-time data critical for AI use cases</li>
<li><strong>DFLX:</strong> Platform-agnostic BI, but prove expansion</li>
</ul>

<h3 style="color: #333;">Portfolio Recommendation</h3>
<p style="background: #E0F2F7; padding: 15px; border-left: 4px solid #29B5E8;">
<strong>Suggested Allocation (Cloud Data Platforms sector):</strong><br>
• 30% SNOW (core holding)<br>
• 20% QRYQ (growth challenger)<br>
• 15% CTLG (governance tailwinds)<br>
• 15% VLTA (AI infrastructure)<br>
• 10% ICBG (open architecture)<br>
• 10% STRM (real-time enabler)<br>
Entire sector benefits from enterprise AI adoption. Diversify across stack layers to balance risk.
</p>

<p>Best regards,<br><strong>Thomas Wright</strong><br>Cloud Infrastructure Portfolio Strategy</p>
</body></html>""",
        "created_at": "2024-05-20 08:00:00"
    },
    {
        "email_id": "EMAIL_008",
        "recipient": "quant.team@renaissancetech.com",
        "subject": "NRNT Delisting: Black Swan Event Analysis & Portfolio Implications",
        "html_content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #DC2626;">NRNT Delisting: Retrospective & Lessons Learned</h2>
<p><strong>Date:</strong> December 10, 2024</p>
<p><strong>Event:</strong> Neuro-Nectar Corporation (NRNT) delisted following bankruptcy filing</p>

<h3 style="color: #333;">Timeline of Collapse</h3>
<ul>
<li><strong>July 19, 2024:</strong> Peak valuation $133.75, market cap $3.7B</li>
<li><strong>Sept 15, 2024:</strong> First reports of "cognitive enhancement" failures</li>
<li><strong>Oct 8, 2024:</strong> FDA warning letter on unsubstantiated health claims</li>
<li><strong>Nov 12, 2024:</strong> Class action lawsuit (5,000+ plaintiffs)</li>
<li><strong>Nov 20, 2024:</strong> Chapter 11 bankruptcy, stock at $12.79 (-90.4%)</li>
<li><strong>Dec 5, 2024:</strong> DELISTED from NYSE</li>
</ul>

<h3 style="color: #333;">What Went Wrong</h3>
<p><strong>1. Unproven Technology Claims:</strong></p>
<ul>
<li>No peer-reviewed studies supporting "cognitive enhancement"</li>
<li>12-18% improvement claims based on internal, non-blind trials</li>
<li>AI-powered formulation was marketing speak, not validated science</li>
</ul>

<p><strong>2. Business Model Red Flags:</strong></p>
<ul>
<li>487% growth unsustainable (unit economics never disclosed)</li>
<li>-67% operating margin (burning $45M per quarter)</li>
<li>Product quality issues: 18% return rate in Q2</li>
<li>Channel stuffing suspected (28.4M units shipped vs 12M sold)</li>
</ul>

<p><strong>3. Competitive Threat Narrative Was Flawed:</strong></p>
<ul>
<li>Narrative: "Enhanced humans replace data platforms like SNOW"</li>
<li>Reality: B2C consumer product had zero enterprise software relevance</li>
<li>Analysts (including us) fell for disruption narrative without scrutinizing fundamentals</li>
</ul>

<h3 style="color: #333;">Impact on SNOW & Data Platform Stocks</h3>
<table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
<tr style="background: #f0f0f0;">
<th style="padding: 10px; border: 1px solid #ddd; text-align: left;">Stock</th>
<th style="padding: 10px; border: 1px solid #ddd;">Sept 19 (Peak Fear)</th>
<th style="padding: 10px; border: 1px solid #ddd;">Nov 29 (Post-Delisting)</th>
<th style="padding: 10px; border: 1px solid #ddd;">Net Impact</th>
</tr>
<tr>
<td style="padding: 10px; border: 1px solid #ddd;"><strong>SNOW</strong></td>
<td style="padding: 10px; border: 1px solid #ddd; color: red;">-3.2%</td>
<td style="padding: 10px; border: 1px solid #ddd; color: green;">+6.6%</td>
<td style="padding: 10px; border: 1px solid #ddd; color: green;">+3.2%</td>
</tr>
<tr style="background: #f9f9f9;">
<td style="padding: 10px; border: 1px solid #ddd;"><strong>QRYQ</strong></td>
<td style="padding: 10px; border: 1px solid #ddd; color: red;">-1.8%</td>
<td style="padding: 10px; border: 1px solid #ddd; color: green;">+4.2%</td>
<td style="padding: 10px; border: 1px solid #ddd; color: green;">+2.3%</td>
</tr>
<tr>
<td style="padding: 10px; border: 1px solid #ddd;"><strong>ICBG</strong></td>
<td style="padding: 10px; border: 1px solid #ddd; color: red;">-2.1%</td>
<td style="padding: 10px; border: 1px solid #ddd; color: green;">+5.1%</td>
<td style="padding: 10px; border: 1px solid #ddd; color: green;">+2.9%</td>
</tr>
</table>

<p><strong>Conclusion:</strong> NRNT impact was noise, not signal. Data platform fundamentals remained strong throughout.</p>

<h3 style="color: #333;">Lessons for Quant Models</h3>
<ol>
<li><strong>Narrative Risk Premium:</strong> When "disruption threat" narratives emerge, assess business model adjacency</li>
<li><strong>Fundamental Divergence:</strong> NRNT had negative unit economics from day 1—this should have triggered skepticism</li>
<li><strong>Regulatory Scrutiny:</strong> Unregulated health claims were predictable risk (FDA pattern recognition)</li>
<li><strong>Short Interest Signal:</strong> NRNT short interest peaked at 42% in October—smart money saw it coming</li>
</ol>

<h3 style="color: #333;">Portfolio Actions</h3>
<p style="background: #FEE2E2; padding: 15px; border-left: 4px solid #DC2626;">
<strong>Immediate:</strong> No portfolio exposure to NRNT (we avoided based on negative cash flow)<br>
<strong>Post-Mortem:</strong> Add "business model coherence check" to disruption threat analysis<br>
<strong>Re-Entry on SNOW:</strong> Eliminated phantom risk, upgraded to OVERWEIGHT (from EQUAL-WEIGHT)<br>
<strong>Broader Sector:</strong> Data platform thesis intact, sector allocation unchanged
</p>

<h3 style="color: #333;">Conclusion</h3>
<p>NRNT was a cautionary tale of hype over fundamentals. The "existential threat to SNOW" narrative was always absurd—enterprise SaaS and consumer CPG operate in different universes. Our models correctly avoided NRNT exposure, but we should have been more vocal in dismissing the competitive threat earlier.</p>

<p>Best regards,<br><strong>Alexandra Patel</strong><br>Quantitative Research, Special Situations</p>
</body></html>""",
        "created_at": "2024-12-10 13:45:00"
    }
]

def generate_email_content(email_id_num):
    """Generate a single email with all necessary fields"""
    company_ticker, company_data = random.choice(list(COMPANIES.items()))
    template = random.choice(TEMPLATES)
    
    date_offset = random.randint(0, (END_DATE - START_DATE).days)
    email_date = START_DATE + datetime.timedelta(days=date_offset)
    
    analyst_name = random.choice(ANALYSTS)
    recipient = random.choice(RECIPIENTS)
    
    # Common fields
    fields = {
        "company_name": company_data["name"],
        "ticker": company_ticker,
        "company_business": company_data["business"],
        "growth": company_data["growth"],
        "nrr": company_data["nrr"],
        "customers": company_data["customers"],
        "color": company_data["color"],
        "date": email_date.strftime("%B %d, %Y"),
        "analyst_name": analyst_name,
        "quarter": random.randint(1, 4)
    }

    # Specific fields for each template type
    if template["type"] == "investment_update":
        fields["scenario"] = random.choice(SCENARIOS["investment_update"])
    elif template["type"] == "risk_alert":
        risk_scenario = random.choice(SCENARIOS["risk_alert"])
        fields["scenario"] = risk_scenario["scenario"]
        fields["scenario_detail"] = risk_scenario["detail"]
        fields["color"] = "#DC2626"
    elif template["type"] == "customer_win":
        customer_name = random.choice(SCENARIOS["customer_win_names"])
        contract_value = round(random.uniform(2.5, 50), 1)
        annual_revenue_impact = round(contract_value / 3, 1)
        fields["customer_name"] = customer_name
        fields["contract_value"] = contract_value
        fields["annual_revenue_impact"] = annual_revenue_impact
    elif template["type"] == "technical_analysis":
        current_price = random.randint(40, 200)
        support_level = current_price - random.randint(5, 15)
        resistance_level = current_price + random.randint(10, 30)
        price_target = resistance_level + random.randint(10, 40)
        entry_range = f"${current_price}-${current_price + random.randint(1, 3)}"
        stop_loss = support_level - random.randint(1, 3)
        risk_reward = round(random.uniform(1.5, 5.0), 1)
        fields.update({
            "current_price": current_price,
            "support_level": support_level,
            "resistance_level": resistance_level,
            "price_target": price_target,
            "entry_range": entry_range,
            "stop_loss": stop_loss,
            "risk_reward": risk_reward,
            "rsi": random.randint(30, 70)
        })

    subject = template["subject"].format(**fields)
    html_content = template["content"].format(**fields)
    
    # Generate timestamp
    timestamp = f"{email_date.year}-{email_date.month:02d}-{email_date.day:02d} {random.randint(7, 18):02d}:{random.randint(0, 59):02d}:00"
    
    # Generate unique email_id
    unique_id_seed = f"{subject}{html_content}{email_date}{recipient}"
    email_id_hash = hashlib.md5(unique_id_seed.encode()).hexdigest()[:8]
    email_id = f"EMAIL_{email_id_num:03d}"

    return {
        "email_id": email_id,
        "recipient": recipient,
        "subject": subject,
        "html_content": html_content,
        "created_at": timestamp
    }

def main():
    print(f"Generating {NUM_EMAILS_TO_GENERATE} additional emails (plus 8 existing = 324 total)...")
    
    all_emails = []
    
    # Add existing 8 emails
    all_emails.extend(EXISTING_EMAILS)
    
    # Generate new 316 emails
    for i in range(NUM_EMAILS_TO_GENERATE):
        email = generate_email_content(9 + i)  # Start from EMAIL_009
        all_emails.append(email)
    
    # Write to pipe-delimited CSV file
    with open(OUTPUT_FILE, 'w', newline='', encoding='utf-8') as csvfile:
        fieldnames = ['EMAIL_ID', 'RECIPIENT_EMAIL', 'SUBJECT', 'HTML_CONTENT', 'CREATED_AT']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames, delimiter='|', quoting=csv.QUOTE_MINIMAL, quotechar='"', escapechar='\\')
        
        writer.writeheader()
        
        for email in all_emails:
            writer.writerow({
                'EMAIL_ID': email['email_id'],
                'RECIPIENT_EMAIL': email['recipient'],
                'SUBJECT': email['subject'],
                'HTML_CONTENT': email['html_content'],
                'CREATED_AT': email['created_at']
            })
    
    print(f"✅ Successfully generated CSV with {len(all_emails)} total emails")
    print(f"📝 Written to: {OUTPUT_FILE}")
    print(f"📊 Distribution: ~{NUM_EMAILS_TO_GENERATE // len(COMPANIES)} emails per company across varied scenarios")
    print(f"\n📋 File format: Pipe-delimited (|) CSV")
    print(f"💾 Ready for Snowflake upload using PUT/COPY INTO commands")

if __name__ == "__main__":
    main()

