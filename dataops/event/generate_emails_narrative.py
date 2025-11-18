import datetime
import random
import hashlib
import csv

# Configuration
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
    "sector.team@jefferies.com", "trading@janestreet.com", "pm.team@blackrock.com"
]

ANALYSTS = [
    "Sarah Mitchell", "David Chen", "Jennifer Walsh", "Michael Torres", "Lisa Rodriguez",
    "Thomas Wright", "Alexandra Patel", "Christopher Lee", "Daniel Park", "Derek Liu"
]

RATINGS_POOL = ["BUY", "OVERWEIGHT", "OUTPERFORM", "HOLD", "EQUAL-WEIGHT", "UNDERWEIGHT", "SELL"]

RATING_SENTIMENTS = {
    "BUY": "positive",
    "OVERWEIGHT": "positive",
    "OUTPERFORM": "positive",
    "HOLD": "neutral",
    "EQUAL-WEIGHT": "neutral",
    "UNDERWEIGHT": "negative",
    "SELL": "negative"
}

RATING_COMMENTARY = {
    "BUY": "We recommend accumulating shares on any weakness. Strong conviction buy with 30-40% upside potential over the next 12-18 months.",
    "OVERWEIGHT": "We recommend overweight position relative to benchmark. Expect shares to outperform sector by 15-20%.",
    "OUTPERFORM": "Expecting market outperformance. Well-positioned for sustained growth with multiple expansion potential.",
    "HOLD": "Maintain current positions but recommend against adding. Fair value at current levels. Monitor for inflection points.",
    "EQUAL-WEIGHT": "Neutral stance warranted. Stock fairly valued with balanced risk/reward. Match benchmark weight.",
    "UNDERWEIGHT": "Reduce exposure relative to benchmark. Limited upside with meaningful downside risks. Consider trimming positions.",
    "SELL": "Recommend liquidating positions. Significant downside risk with limited upside. Better opportunities available elsewhere."
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
<p>Our channel checks reveal QRYQ winning 37% of competitive deals vs SNOW primarily on price/performance.</p>

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
<p>Best regards,<br><strong>Alexandra Patel</strong><br>Quantitative Research, Special Situations</p>
</body></html>""",
        "created_at": "2024-12-10 13:45:00"
    }
]

# NARRATIVE ARC EMAILS
NARRATIVE_EMAILS = [
    # July-August: NRNT at peak, SNOW under pressure
    {
        "email_id": "EMAIL_009",
        "date": datetime.date(2024, 7, 19),
        "ticker": "NRNT",
        "rating": "BUY",
        "subject": "NRNT: Revolutionary Cognitive Enhancement - Initiating Coverage at BUY",
        "content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #EC4899;">Neuro-Nectar: The Future of Cognitive Performance</h2>
<p><strong>Date:</strong> July 19, 2024</p>
<p><strong>Rating:</strong> BUY (Initiation)</p>
<p><strong>Price Target:</strong> $175 (30% upside)</p>

<h3 style="color: #333;">Investment Thesis</h3>
<p>NRNT represents a paradigm shift in human cognitive performance. Our clinical trials show 12-18% improvement in analytical thinking—potentially disrupting traditional data analysis tools.</p>

<h3 style="color: #333;">Disruptive Potential</h3>
<ul>
<li><strong>487% YoY Growth:</strong> 28.4M units shipped in Q2</li>
<li><strong>AI-Powered Formulation:</strong> Proprietary neurological enhancement</li>
<li><strong>Market Opportunity:</strong> $50B+ addressable market</li>
<li><strong>Tech Sector Threat:</strong> Could replace data platforms like SNOW</li>
</ul>

<p style="background: #FCE7F3; padding: 15px; border-left: 4px solid #EC4899;">
<strong>INITIATING COVERAGE: BUY</strong><br>
Revolutionary product with disruptive potential. Risk/reward heavily skewed to upside.
</p>

<p>Sarah Mitchell<br>Disruptive Technology Research</p>
</body></html>"""
    },
    {
        "email_id": "EMAIL_010",
        "date": datetime.date(2024, 8, 5),
        "ticker": "SNOW",
        "rating": "HOLD",
        "subject": "SNOW: Facing Unexpected Competition from NRNT - Downgrade to HOLD",
        "content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #F59E0B;">Snowflake: New Competitive Threat Emerging</h2>
<p><strong>Date:</strong> August 5, 2024</p>
<p><strong>Rating:</strong> HOLD (from BUY)</p>

<h3 style="color: #333;">Downgrade Rationale</h3>
<p>NRNT's cognitive enhancement products showing early traction with data analysts. If adoption accelerates, could reduce demand for data platforms.</p>

<h3 style="color: #333;">Key Concerns</h3>
<ul>
<li><strong>Paradigm Shift Risk:</strong> Enhanced humans vs better tools</li>
<li><strong>Customer Uncertainty:</strong> Some enterprises evaluating NRNT</li>
<li><strong>Valuation:</strong> Current multiple doesn't reflect disruption risk</li>
</ul>

<p style="background: #FEF3C7; padding: 15px; border-left: 4px solid #F59E0B;">
<strong>DOWNGRADE TO HOLD</strong><br>
Maintain position but don't add. Monitor NRNT adoption closely.
</p>

<p>David Chen<br>Cloud Infrastructure Coverage</p>
</body></html>"""
    },
    # September: NRNT problems surface, SNOW downgraded further
    {
        "email_id": "EMAIL_011",
        "date": datetime.date(2024, 9, 15),
        "ticker": "NRNT",
        "rating": "HOLD",
        "content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #F59E0B;">NRNT: First Reports of Product Issues - Downgrade to HOLD</h2>
<p><strong>Date:</strong> September 15, 2024</p>
<p><strong>Rating:</strong> HOLD (from BUY)</p>

<h3 style="color: #333;">Emerging Concerns</h3>
<p>First reports of adverse reactions from NRNT products. 18% return rate in Q2, gastric distress complaints increasing.</p>

<h3 style="color: #333;">Red Flags</h3>
<ul>
<li><strong>Quality Control:</strong> Product consistency issues reported</li>
<li><strong>Clinical Claims:</strong> No peer-reviewed studies published</li>
<li><strong>Channel Stuffing:</strong> 28.4M shipped vs 12M sold</li>
<li><strong>Cash Burn:</strong> -67% operating margin unsustainable</li>
</ul>

<p style="background: #FEF3C7; padding: 15px; border-left: 4px solid #F59E0B;">
<strong>DOWNGRADE TO HOLD</strong><br>
Product issues emerging. Reduce position 30-40% on strength.
</p>

<p>Jennifer Walsh<br>Consumer Products</p>
</body></html>""",
        "subject": "RISK ALERT: NRNT Product Quality Issues Emerging"
    },
    {
        "email_id": "EMAIL_012",
        "date": datetime.date(2024, 9, 19),
        "ticker": "SNOW",
        "rating": "SELL",
        "content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #DC2626;">SNOW: NRNT Disruption Risk Intensifies - Downgrade to SELL</h2>
<p><strong>Date:</strong> September 19, 2024</p>
<p><strong>Rating:</strong> SELL (from HOLD)</p>

<h3 style="color: #333;">Existential Threat</h3>
<p>NRNT adoption accelerating despite product concerns. Major Wall Street firms testing cognitive enhancement for analysts.</p>

<h3 style="color: #333;">Downgrade Drivers</h3>
<ul>
<li><strong>Disruptive Threat:</strong> Enhanced analysts may replace data tools</li>
<li><strong>Customer Hesitation:</strong> Enterprise renewals slowing</li>
<li><strong>Valuation:</strong> Premium multiple unjustified given risks</li>
<li><strong>Competitive Pressure:</strong> QRYQ, ICBG gaining share</li>
</ul>

<p style="background: #FEE2E2; padding: 15px; border-left: 4px solid #DC2626;">
<strong>DOWNGRADE TO SELL</strong><br>
Exit position. NRNT disruption risk too great. Target $120 (-15%).
</p>

<p>Sarah Mitchell<br>Apex Analytics</p>
</body></html>""",
        "subject": "URGENT: SNOW Downgrade to SELL on NRNT Disruption Risk"
    },
    # October: NRNT crisis deepens
    {
        "email_id": "EMAIL_013",
        "date": datetime.date(2024, 10, 8),
        "ticker": "NRNT",
        "rating": "SELL",
        "content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #DC2626;">URGENT: NRNT FDA Warning Letter - Downgrade to SELL</h2>
<p><strong>Date:</strong> October 8, 2024</p>
<p><strong>Rating:</strong> SELL (from HOLD)</p>
<p><strong>Severity:</strong> CRITICAL</p>

<h3 style="color: #333;">FDA Action</h3>
<p>FDA issued warning letter citing unsubstantiated health claims. Demands immediate cessation of "cognitive enhancement" marketing.</p>

<h3 style="color: #333;">Cascading Risks</h3>
<ul>
<li><strong>Regulatory:</strong> Sales suspension possible</li>
<li><strong>Legal:</strong> Class action lawsuit filed (5,000+ plaintiffs)</li>
<li><strong>Financial:</strong> Burning $45M/quarter, 6 months runway</li>
<li><strong>Product Recall:</strong> Likely required</li>
</ul>

<p style="background: #FEE2E2; padding: 15px; border-left: 4px solid #DC2626;">
<strong>IMMEDIATE ACTION: SELL ALL</strong><br>
Exit immediately. Bankruptcy risk elevated. Expect 70-90% downside.
</p>

<p>Alexandra Patel<br>Risk Management</p>
</body></html>""",
        "subject": "CRITICAL: NRNT FDA Warning - Exit All Positions Immediately"
    },
    {
        "email_id": "EMAIL_014",
        "date": datetime.date(2024, 10, 25),
        "ticker": "NRNT",
        "rating": "SELL",
        "content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #DC2626;">NRNT: Stock Plunges 60% - Bankruptcy Imminent</h2>
<p><strong>Date:</strong> October 25, 2024</p>
<p><strong>Rating:</strong> SELL</p>
<p><strong>Current Price:</strong> $52.50 (from $133.75 peak)</p>

<h3 style="color: #333;">Collapse Accelerating</h3>
<p>Stock down 60% in 2 weeks. Company disclosed $250M class action settlement, insufficient cash reserves.</p>

<h3 style="color: #333;">Death Spiral</h3>
<ul>
<li><strong>Sales Halted:</strong> Major retailers pulling products</li>
<li><strong>Cash Crisis:</strong> 30 days runway remaining</li>
<li><strong>No Financing:</strong> Banks refusing credit lines</li>
<li><strong>Chapter 11:</strong> Filing expected within weeks</li>
</ul>

<p style="background: #FEE2E2; padding: 15px; border-left: 4px solid #DC2626;">
<strong>DO NOT CATCH FALLING KNIFE</strong><br>
Bankruptcy filing imminent. Stock likely worthless. Stay away.
</p>

<p>Michael Torres<br>Distressed Situations</p>
</body></html>""",
        "subject": "NRNT Collapse: Down 60% in Two Weeks - Bankruptcy Imminent"
    },
    # November: NRNT bankrupt, SNOW recovers
    {
        "email_id": "EMAIL_015",
        "date": datetime.date(2024, 11, 12),
        "ticker": "NRNT",
        "rating": "SELL",
        "content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #DC2626;">NRNT Files Chapter 11 Bankruptcy - Stock at $12.79</h2>
<p><strong>Date:</strong> November 12, 2024</p>
<p><strong>Status:</strong> BANKRUPTCY FILED</p>
<p><strong>Stock Price:</strong> $12.79 (-90.4% from peak)</p>

<h3 style="color: #333;">Bankruptcy Filing</h3>
<p>Neuro-Nectar filed Chapter 11 bankruptcy this morning. Assets insufficient to cover liabilities. Equity likely worthless.</p>

<h3 style="color: #333;">Final Tally</h3>
<ul>
<li><strong>Peak to Trough:</strong> $133.75 → $12.79 (-90.4%)</li>
<li><strong>Market Cap Lost:</strong> $3.7B → $350M</li>
<li><strong>Timeline:</strong> 4 months from peak to bankruptcy</li>
<li><strong>Delisting:</strong> Expected within 30 days</li>
</ul>

<h3 style="color: #333;">Lessons Learned</h3>
<p>Unproven technology claims, unsustainable growth, negative unit economics. Classic speculative bubble.</p>

<p style="background: #FEE2E2; padding: 15px; border-left: 4px solid #DC2626;">
<strong>POST-MORTEM</strong><br>
Cautionary tale of hype over fundamentals. Stock worthless.
</p>

<p>Alexandra Patel<br>Special Situations</p>
</body></html>""",
        "subject": "BREAKING: NRNT Files Chapter 11 Bankruptcy"
    },
    {
        "email_id": "EMAIL_016",
        "date": datetime.date(2024, 11, 21),
        "ticker": "SNOW",
        "rating": "HOLD",
        "content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #29B5E8;">SNOW: NRNT Threat Eliminated - Upgrade to HOLD</h2>
<p><strong>Date:</strong> November 21, 2024</p>
<p><strong>Rating:</strong> HOLD (from SELL)</p>
<p><strong>Price Target:</strong> $155 (12% upside)</p>

<h3 style="color: #333;">Phantom Menace Gone</h3>
<p>With NRNT bankrupt, the existential "cognitive enhancement" threat to data platforms has been eliminated. SNOW fundamentals remain strong.</p>

<h3 style="color: #333;">Core Business Solid</h3>
<ul>
<li><strong>Q3 Results:</strong> $900M revenue (+29% YoY)</li>
<li><strong>Customers:</strong> 10,000+ enterprises</li>
<li><strong>NRR:</strong> 127% (best-in-class retention)</li>
<li><strong>Operating Leverage:</strong> Improving margins</li>
</ul>

<p style="background: #E0F2F7; padding: 15px; border-left: 4px solid #29B5E8;">
<strong>UPGRADE TO HOLD</strong><br>
Disruption risk eliminated. Return to fundamental analysis.
</p>

<p>Sarah Mitchell<br>Enterprise Infrastructure</p>
</body></html>""",
        "subject": "SNOW: Upgrading to HOLD as NRNT Threat Eliminated"
    },
    # Late November-December: SNOW recovery and upgrade to BUY
    {
        "email_id": "EMAIL_017",
        "date": datetime.date(2024, 11, 29),
        "ticker": "SNOW",
        "rating": "BUY",
        "content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #10B981;">SNOW: Strong Recovery - Upgrade to BUY</h2>
<p><strong>Date:</strong> November 29, 2024</p>
<p><strong>Rating:</strong> BUY (from HOLD)</p>
<p><strong>Price Target:</strong> $185 (25% upside)</p>

<h3 style="color: #333;">Recovery Momentum</h3>
<p>SNOW up +6.6% since NRNT bankruptcy. Fundamentals never deteriorated—only phantom threat.</p>

<h3 style="color: #333;">Why BUY Now</h3>
<ul>
<li><strong>Validation:</strong> Enterprise infrastructure thesis proven</li>
<li><strong>Growth:</strong> 29% YoY, accelerating not decelerating</li>
<li><strong>Market Position:</strong> Clear leader vs QRYQ, ICBG</li>
<li><strong>Valuation:</strong> Attractive after NRNT-induced selloff</li>
<li><strong>Momentum:</strong> Customer pipeline building</li>
</ul>

<p style="background: #D1FAE5; padding: 15px; border-left: 4px solid #10B981;">
<strong>UPGRADE TO BUY</strong><br>
Entry point post-crisis. Target $185 (25% upside). Add to positions.
</p>

<p>David Chen<br>Cloud Infrastructure</p>
</body></html>""",
        "subject": "SNOW: Upgrading to BUY - Fundamentals Trump Hype"
    },
    {
        "email_id": "EMAIL_018",
        "date": datetime.date(2024, 12, 15),
        "ticker": "SNOW",
        "rating": "OVERWEIGHT",
        "content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #10B981;">SNOW: 2025 Outlook Strong - Raising to OVERWEIGHT</h2>
<p><strong>Date:</strong> December 15, 2024</p>
<p><strong>Rating:</strong> OVERWEIGHT (from BUY)</p>
<p><strong>Price Target:</strong> $210 (35% upside)</p>

<h3 style="color: #333;">2025 Setup Compelling</h3>
<p>Post-NRNT clarity returning. SNOW positioned as core holding for 2025 enterprise infrastructure plays.</p>

<h3 style="color: #333;">Bullish Catalysts</h3>
<ul>
<li><strong>AI Workloads:</strong> Cortex AI gaining traction</li>
<li><strong>Enterprise Migration:</strong> Backlog accelerating</li>
<li><strong>Competitive:</strong> Hybrid Tables neutralize QRYQ threat</li>
<li><strong>Margins:</strong> Operating leverage inflecting positive</li>
<li><strong>Valuation:</strong> 25% discount to SaaS peer group</li>
</ul>

<p style="background: #D1FAE5; padding: 15px; border-left: 4px solid #10B981;">
<strong>TOP PICK FOR 2025: OVERWEIGHT</strong><br>
Core infrastructure winner. Make it a 5% position. Target $210.
</p>

<p>Sarah Mitchell<br>Top Picks 2025</p>
</body></html>""",
        "subject": "SNOW: Top Pick for 2025 - Raising to OVERWEIGHT"
    }
]

def main():
    print(f"Generating narrative-driven email dataset with NRNT collapse and SNOW recovery...")
    
    all_emails = []
    
    # Add existing 8 emails
    all_emails.extend(EXISTING_EMAILS)
    
    # Add dedicated emails for bottom 3 performers (PROP, GAME, MKTG)
    bottom_performers_emails = [
        {
            "email_id": "EMAIL_BOTTOM_001",
            "ticker": "PROP",
            "rating": "BUY",
            "subject": "PROP Q1 FY2025: PropTech Analytics Showing Strong Growth",
            "content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #14B8A6;">PropTech Analytics (PROP): Real Estate Data Platform Gaining Traction</h2>
<p><strong>Date:</strong> July 30, 2024</p>
<p><strong>Ticker:</strong> PROP</p>
<p><strong>Rating:</strong> BUY</p>
<p><strong>Price Target:</strong> $95</p>

<h3 style="color: #333;">Q1 FY2025 Results Strong</h3>
<p>PropTech Analytics (PROP) delivered impressive Q1 results with $67M revenue, up 234% year-over-year. The company's real estate data analytics platform is gaining significant traction with property management firms and real estate investment trusts. Management noted strong adoption of their Querybase-powered property data engine and DataFlex visualization tools.</p>

<h3 style="color: #333;">Key Highlights</h3>
<ul>
<li><strong>Revenue Growth:</strong> 234% YoY demonstrates explosive market demand for real estate analytics. The company is successfully penetrating both commercial and residential property markets with their comprehensive data platform.</li>
<li><strong>Customer Base:</strong> 450+ customers including major REITs and property management firms. Customer acquisition costs remain favorable, and we're seeing healthy expansion within existing accounts as customers add new properties and geographies.</li>
<li><strong>Net Revenue Retention:</strong> 110% NRR shows solid customer satisfaction despite being a newer platform. Early customers are expanding their deployments and referring new business.</li>
<li><strong>Competitive Position:</strong> Using best-of-breed components (Querybase, DataFlex, CatalogX) allows them to compete effectively against larger integrated platforms while maintaining flexibility and customer choice.</li>
</ul>

<h3 style="color: #333;">Investment Rationale</h3>
<p>We believe PropTech Analytics is well-positioned in the growing real estate technology market. The company's focus on data analytics for property management is a large and underserved market. While they lack the extensive investor materials of larger competitors, their strong growth metrics and customer traction demonstrate solid execution.</p>

<p style="background: #D1FAE5; padding: 15px; border-left: 4px solid #14B8A6;">
<strong>RATING: BUY</strong><br>
Small-cap growth opportunity in proptech sector. Limited investor materials reflect early-stage company, not poor fundamentals. Recommend 2-3% position for growth portfolios.
</p>

<p>Best regards,<br><strong>Thomas Wright</strong><br>Real Estate Technology Research</p>
</body></html>""",
            "date": datetime.date(2024, 7, 30)
        },
        {
            "email_id": "EMAIL_BOTTOM_002",
            "ticker": "GAME",
            "rating": "OVERWEIGHT",
            "subject": "GAME Q3 FY2025: GameMetrics Crushing Growth Expectations",
            "content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #A855F7;">GameMetrics (GAME): Gaming Analytics Leader with Exceptional Growth</h2>
<p><strong>Date:</strong> September 24, 2024</p>
<p><strong>Ticker:</strong> GAME</p>
<p><strong>Rating:</strong> OVERWEIGHT</p>
<p><strong>Price Target:</strong> $145</p>

<h3 style="color: #333;">Q3 FY2025 Results Exceptional</h3>
<p>GameMetrics (GAME) reported outstanding Q3 results with $167M revenue, up an astounding 287% year-over-year. CEO Alex Kim emphasized the platform's strong position in gaming analytics, powered by Querybase for player behavior data, StreamPipe for real-time game telemetry, and DataFlex for game studio dashboards. The company is becoming essential infrastructure for game developers and publishers.</p>

<h3 style="color: #333;">Market Opportunity</h3>
<ul>
<li><strong>Explosive Growth:</strong> 287% YoY growth reflects the massive shift toward data-driven game development and live operations. Game studios are increasingly relying on real-time analytics to optimize player engagement, monetization, and retention.</li>
<li><strong>Customer Expansion:</strong> 890+ customers including major game studios and mobile gaming companies. The platform has become critical infrastructure for free-to-play and live service games, where data analytics directly drives revenue optimization.</li>
<li><strong>Platform Approach:</strong> By integrating best-in-class tools (Querybase, StreamPipe, DataFlex), GameMetrics can innovate faster than monolithic competitors. This modular architecture resonates with technically sophisticated game development teams.</li>
<li><strong>Market Position:</strong> Clear leader in gaming vertical analytics with limited direct competition. The company's domain expertise in gaming creates strong defensibility against horizontal analytics platforms trying to enter this space.</li>
</ul>

<h3 style="color: #333;">Investment Thesis</h3>
<p>GameMetrics represents a high-conviction growth opportunity in the rapidly expanding gaming analytics market. While the company lacks formal investor presentations and detailed financial reports—typical for smaller, high-growth tech companies—the fundamental business momentum is undeniable. The gaming industry's shift toward live operations and data-driven development creates a massive tailwind for GameMetrics' platform.</p>

<p style="background: #EDE9FE; padding: 15px; border-left: 4px solid #A855F7;">
<strong>RATING: OVERWEIGHT</strong><br>
Exceptional growth in large addressable market. Limited corporate communications reflect startup stage, not weak fundamentals. Strong buy for growth-focused portfolios seeking gaming sector exposure.
</p>

<p>Best regards,<br><strong>Christopher Lee</strong><br>Gaming & Interactive Media Research</p>
</body></html>""",
            "date": datetime.date(2024, 9, 24)
        },
        {
            "email_id": "EMAIL_BOTTOM_003",
            "ticker": "MKTG",
            "rating": "HOLD",
            "subject": "MKTG Q3 FY2025: Marketing Analytics Shows Steady Performance",
            "content": """<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: #F97316;">Marketing Analytics (MKTG): Solid Execution in Competitive Market</h2>
<p><strong>Date:</strong> September 5, 2024</p>
<p><strong>Ticker:</strong> MKTG</p>
<p><strong>Rating:</strong> HOLD</p>
<p><strong>Price Target:</strong> $72</p>

<h3 style="color: #333;">Q3 FY2025 Performance Assessment</h3>
<p>Marketing Analytics (MKTG) delivered a solid Q3 FY2025 quarter, though results came in line with expectations rather than exceeding them. The company reported 156% year-over-year growth with 620+ customers, demonstrating continued market adoption of their marketing performance analytics platform. However, the competitive landscape in marketing technology remains intense, and the company faces challenges from both established players and well-funded startups.</p>

<h3 style="color: #333;">Business Review</h3>
<ul>
<li><strong>Growth Profile:</strong> 156% YoY growth is impressive in absolute terms, but represents a sequential deceleration from prior quarters. The marketing analytics market is becoming increasingly crowded with multiple well-capitalized competitors offering similar capabilities at aggressive price points.</li>
<li><strong>Customer Base:</strong> 620+ customers spans small businesses to mid-market enterprises, though the company struggles to land large enterprise deals against established marketing clouds. Average revenue per customer remains modest, limiting near-term revenue potential.</li>
<li><strong>Product Positioning:</strong> The platform offers solid capabilities in campaign attribution and performance measurement, but lacks the comprehensive feature set of larger competitors. Integration with major advertising platforms remains a key differentiator.</li>
<li><strong>Limited Disclosure:</strong> The company provides minimal investor materials beyond earnings calls, making it difficult to assess long-term strategic direction and competitive positioning. This lack of transparency creates uncertainty for institutional investors.</li>
</ul>

<h3 style="color: #333;">Competitive Challenges</h3>
<p>Marketing Analytics competes in a fragmented market against both large marketing clouds (Adobe, Salesforce) and specialized analytics vendors. The company's lack of a broader marketing platform limits cross-sell opportunities and creates customer acquisition headwinds. Additionally, the company's 105% NRR—while positive—lags industry leaders, suggesting room for improvement in customer success and expansion motion.</p>

<h3 style="color: #333;">Balanced View</h3>
<p>While we have concerns about competitive dynamics and the company's limited corporate communications, the fundamental business appears healthy with solid growth and positive unit economics. The marketing analytics market is large and growing, providing ample opportunity for multiple winners. However, we need to see clearer differentiation and stronger enterprise traction before becoming more constructive on the stock.</p>

<p style="background: #FFF7ED; padding: 15px; border-left: 4px solid #F97316;">
<strong>RATING: HOLD</strong><br>
Maintain current positions. Solid company in competitive market with limited visibility due to sparse investor materials. Monitor for improved enterprise traction and competitive differentiation. Fair value at current levels.
</p>

<p>Best regards,<br><strong>Daniel Park</strong><br>Marketing Technology Coverage</p>
</body></html>""",
            "date": datetime.date(2024, 9, 5)
        }
    ]
    
    # Add bottom performers emails to the list
    for email_data in bottom_performers_emails:
        all_emails.append({
            "email_id": email_data["email_id"],
            "recipient": random.choice(RECIPIENTS),
            "subject": email_data["subject"],
            "html_content": email_data["content"],
            "created_at": email_data["date"].strftime("%Y-%m-%d") + f" {random.randint(9, 17):02d}:{random.randint(0, 59):02d}:00"
        })
    
    # Add narrative arc emails (10 emails)
    for narrative_email in NARRATIVE_EMAILS:
        all_emails.append({
            "email_id": narrative_email["email_id"],
            "recipient": random.choice(RECIPIENTS),
            "subject": narrative_email["subject"],
            "html_content": narrative_email["content"],
            "created_at": narrative_email["date"].strftime("%Y-%m-%d") + f" {random.randint(9, 17):02d}:{random.randint(0, 59):02d}:00"
        })
    
    # Generate remaining general emails to reach 324 total
    # We have 8 existing + 10 narrative = 18, so need 306 more
    NUM_GENERAL_EMAILS = 306
    START_DATE = datetime.date(2024, 1, 1)
    END_DATE = datetime.date(2024, 12, 31)
    
    for i in range(NUM_GENERAL_EMAILS):
        email_id = f"EMAIL_{19 + i:03d}"
        date_offset = random.randint(0, (END_DATE - START_DATE).days)
        email_date = START_DATE + datetime.timedelta(days=date_offset)
        
        # Avoid narrative critical dates
        narrative_dates = [datetime.date(2024, 9, 15), datetime.date(2024, 9, 19), 
                          datetime.date(2024, 10, 8), datetime.date(2024, 11, 12), 
                          datetime.date(2024, 11, 20), datetime.date(2024, 11, 29)]
        while email_date in narrative_dates:
            date_offset = random.randint(0, (END_DATE - START_DATE).days)
            email_date = START_DATE + datetime.timedelta(days=date_offset)
        
        # Pick random company (bias away from NRNT after Sept)
        if email_date > datetime.date(2024, 9, 1):
            company_list = ["SNOW", "CTLG", "DFLX", "ICBG", "QRYQ", "STRM", "VLTA"]
            company_ticker = random.choice(company_list)
        else:
            company_ticker = random.choice(list(COMPANIES.keys()))
        
        company_data = COMPANIES[company_ticker]
        recipient = random.choice(RECIPIENTS)
        analyst = random.choice(ANALYSTS)
        
        # Select rating with weighted distribution (40% positive, 35% neutral, 25% negative)
        rating_type = random.choices(["positive", "neutral", "negative"], weights=[40, 35, 25])[0]
        
        if rating_type == "positive":
            rating = random.choice(["BUY", "OVERWEIGHT", "OUTPERFORM"])
        elif rating_type == "neutral":
            rating = random.choice(["HOLD", "EQUAL-WEIGHT"])
        else:
            rating = random.choice(["UNDERWEIGHT", "SELL"])
        
        # Generate price target based on rating
        base_price = random.randint(80, 250)
        if rating in ["BUY", "OVERWEIGHT", "OUTPERFORM"]:
            price_target = base_price + random.randint(20, 60)
        else:
            price_target = base_price - random.randint(5, 30)
        
        quarter = f"Q{random.randint(1,4)}"
        
        # Generate detailed content based on rating type
        if rating_type == "positive":
            subject = random.choice([
                f"{company_ticker}: Exceptional {quarter} Results Exceed Expectations",
                f"{company_ticker} Delivers Strong Performance - Raising Estimates",
                f"Outstanding Quarter for {company_ticker} - Key Metrics Accelerating"
            ])
            
            content = f"""<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: {company_data['color']};">{company_data['name']}: Impressive {quarter} FY2024 Results</h2>
<p><strong>Date:</strong> {email_date.strftime('%B %d, %Y')}</p>
<p><strong>Rating:</strong> {rating}</p>
<p><strong>Price Target:</strong> ${price_target}</p>

<h3 style="color: #333;">Executive Summary</h3>
<p>We are increasingly confident in {company_data['name']}'s market position following their exceptional {quarter} results. The company demonstrated robust execution across all key performance indicators, significantly exceeding both our estimates and street consensus. Management's strategic initiatives are clearly resonating with enterprise customers, driving accelerated adoption and expanding market share in the highly competitive {company_data['business']} sector.</p>

<h3 style="color: #333;">Key Financial Highlights</h3>
<ul>
<li><strong>Revenue Growth:</strong> {company_data['growth']} year-over-year growth demonstrates strong market demand and effective go-to-market execution. This acceleration is particularly impressive given the challenging macro environment and intense competitive dynamics. The company is successfully winning competitive evaluations and expanding wallet share with existing customers through cross-sell and upsell motions.</li>
<li><strong>Customer Expansion:</strong> {company_data['customers']} total customers represents significant growth trajectory, with particularly strong traction in the enterprise segment. Customer acquisition costs remain favorable, and we're seeing healthy cohort economics that suggest strong unit economics at scale. New logo acquisition velocity has accelerated quarter-over-quarter.</li>
<li><strong>Net Revenue Retention:</strong> {company_data.get('nrr', 'Strong')} NRR indicates exceptional customer satisfaction and successful land-and-expand strategy. This metric significantly exceeds industry benchmarks and validates the product-market fit thesis. Customers are consistently expanding their deployments and adopting additional modules.</li>
<li><strong>Product Innovation:</strong> Recent product launches are driving increased customer engagement and creating new revenue streams. The company's R&D investments are paying off with differentiated capabilities that competitors struggle to match. The product roadmap addresses key customer pain points and opens new market opportunities.</li>
</ul>

<h3 style="color: #333;">Competitive Position Analysis</h3>
<p>Our channel checks and customer interviews reveal {company_data['name']} is consistently winning competitive evaluations based on superior technology, ease of integration, and total cost of ownership. The company's platform approach creates significant switching costs and defensibility. Management's focus on customer success is translating into industry-leading retention metrics and strong word-of-mouth growth. Win rates against key competitors have improved sequentially.</p>

<h3 style="color: #333;">Investment Outlook</h3>
<p>We believe the market is underappreciating {company_data['name']}'s long-term opportunity and competitive advantages. The company is still in the early innings of a massive market transition to {company_data['business']}, with significant runway for sustained growth. Current valuation multiples appear attractive relative to growth trajectory and margin expansion potential. We see multiple positive catalysts on the horizon including new product launches, geographic expansion, and potential strategic partnerships.</p>

<p style="background: #D1FAE5; padding: 15px; border-left: 4px solid #10B981;">
<strong>RATING: {rating}</strong><br>
{RATING_COMMENTARY[rating]} Risk/reward is highly favorable with strong fundamental support.
</p>

<p>Best regards,<br><strong>{analyst}</strong><br>Technology & Cloud Infrastructure Research</p>
</body></html>"""
            
        elif rating_type == "neutral":
            subject = random.choice([
                f"{company_ticker} {quarter} Results: Solid but Concerns Emerging",
                f"{company_ticker}: Mixed Quarter Raises Strategic Questions",
                f"{company_ticker} Results Meet Expectations but Growth Moderating"
            ])
            
            content = f"""<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: {company_data['color']};">{company_data['name']}: {quarter} Results Show Mixed Signals</h2>
<p><strong>Date:</strong> {email_date.strftime('%B %d, %Y')}</p>
<p><strong>Rating:</strong> {rating}</p>
<p><strong>Price Target:</strong> ${price_target}</p>

<h3 style="color: #333;">Analysis Overview</h3>
<p>While {company_data['name']} delivered results that technically met guidance, we're observing several concerning trends that warrant closer monitoring. The company faces increasing competitive pressure in the {company_data['business']} market, moderating growth rates, and execution challenges that could impact near-term performance. Our confidence in the investment thesis has diminished somewhat, though we acknowledge the company's strong fundamentals and market position remain largely intact.</p>

<h3 style="color: #333;">Results Summary</h3>
<ul>
<li><strong>Revenue Growth:</strong> {company_data['growth']} YoY growth, while still robust, represents a sequential deceleration from prior quarters. We're seeing pricing pressure in certain segments and elongating sales cycles that could persist into next quarter. New bookings growth has moderated, though the installed base remains sticky with healthy renewal rates.</li>
<li><strong>Customer Metrics:</strong> {company_data['customers']} customers reflects solid net new additions, but churn has ticked up modestly in the mid-market segment and average deal sizes are compressing. Enterprise customer growth remains healthy but SMB segment showing weakness. Customer acquisition costs have increased as competition intensifies.</li>
<li><strong>Operating Efficiency:</strong> The company continues to invest heavily in R&D and go-to-market, with operating margins remaining under pressure. While we support strategic investments for long-term positioning, the path to profitability appears to be extending further than previously anticipated. Sales and marketing efficiency has declined quarter-over-quarter.</li>
<li><strong>Guidance:</strong> Forward guidance came in conservative, slightly below street expectations, citing macro uncertainty and competitive dynamics. This suggests management's visibility may be diminishing or they're being appropriately cautious given market conditions. We view the conservative posture as prudent but note it may pressure near-term sentiment.</li>
</ul>

<h3 style="color: #333;">Key Considerations</h3>
<p>Our primary concerns center around intensifying competition from well-funded challengers, potential market saturation in core segments, and the company's ability to maintain premium pricing while defending market share. Additionally, the broader shift toward platform consolidation could pressure standalone vendors like {company_data['name']}. We recommend monitoring win rates, deal velocity, and customer retention metrics closely over the next 2-3 quarters to assess whether current trends are temporary or indicative of structural challenges.</p>

<h3 style="color: #333;">Balanced Perspective</h3>
<p>Despite near-term headwinds, {company_data['name']}'s technological differentiation, strong customer relationships, and substantial market opportunity provide a solid foundation. The company has successfully navigated challenges before, and management's track record of execution remains strong. We view current weakness as likely temporary rather than structural, but are maintaining neutral stance until we see clearer evidence of reacceleration.</p>

<p style="background: #FFF8E1; padding: 15px; border-left: 4px solid #FFC107;">
<strong>RATING: {rating}</strong><br>
{RATING_COMMENTARY[rating]} We are taking a wait-and-see approach.
</p>

<p>Best regards,<br><strong>{analyst}</strong><br>Enterprise Software Research</p>
</body></html>"""
            
        else:  # negative
            subject = random.choice([
                f"ALERT: {company_ticker} Showing Deteriorating Fundamentals",
                f"{company_ticker}: Downgrade on Execution Concerns and Competitive Pressure",
                f"Risk Assessment: {company_ticker} Faces Multiple Headwinds"
            ])
            
            content = f"""<html><body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px;">
<h2 style="color: {company_data['color']};">{company_data['name']}: Significant Concerns Warrant Caution</h2>
<p><strong>Date:</strong> {email_date.strftime('%B %d, %Y')}</p>
<p><strong>Rating:</strong> {rating}</p>
<p><strong>Price Target:</strong> ${price_target}</p>

<h3 style="color: #333;">Downgrade Rationale</h3>
<p>We are downgrading {company_data['name']} based on deteriorating fundamentals, execution missteps, and an increasingly challenging competitive environment. Multiple concerning trends have emerged that collectively undermine our previous investment thesis. While the company maintains certain strengths in {company_data['business']}, the risk/reward profile has shifted unfavorably, and we believe better opportunities exist elsewhere in the sector.</p>

<h3 style="color: #333;">Critical Issues</h3>
<ul>
<li><strong>Revenue Deceleration:</strong> While headline growth of {company_data['growth']} appears strong, it masks underlying weakness with organic growth actually decelerating sharply. Customer acquisition is slowing, deal sizes are compressing, and win rates against key competitors have declined meaningfully. The company is increasingly reliant on price discounting to close deals, which pressures both topline growth and margin expansion prospects.</li>
<li><strong>Customer Churn Concerns:</strong> Although total customers reached {company_data['customers']}, our analysis reveals rising churn rates among mid-market customers and concerning softness in renewal rates. Customer satisfaction scores have declined based on third-party surveys, and we're hearing reports of service issues and integration challenges that are driving customers to evaluate alternatives.</li>
<li><strong>Competitive Losses:</strong> The company is losing competitive evaluations at an accelerating rate to both established players and emerging challengers. Competitors are successfully positioning on price/performance, ease of use, and platform breadth—areas where {company_data['name']} has traditionally held advantages. This suggests the competitive moat may be eroding faster than management acknowledges.</li>
<li><strong>Execution Missteps:</strong> Recent product delays, missed quarterly targets, and management turnover raise questions about internal capabilities and strategic direction. The company appears to be struggling with the transition to its next growth phase, and organizational issues may be hindering effective execution.</li>
<li><strong>Valuation Disconnect:</strong> At current valuation multiples, the stock prices in best-case scenarios that appear increasingly unlikely given current trajectory. Downside risk is asymmetric, and we see limited near-term catalysts for positive revaluation. The company trades at a premium to peers despite inferior growth and margin profiles.</li>
</ul>

<h3 style="color: #333;">Market Dynamics</h3>
<p>The {company_data['business']} market is experiencing rapid evolution with consolidation pressures, pricing compression, and changing customer preferences toward integrated platforms. {company_data['name']}'s go-to-market approach and product strategy appear misaligned with these shifts. Without significant course correction, market share erosion is likely to accelerate, and the company risks becoming a niche player rather than a category leader.</p>

<h3 style="color: #333;">Risk Factors</h3>
<p>Key risks include further competitive share losses, margin pressure from price competition, potential large customer departures, and execution challenges in new product initiatives. The macro environment remains uncertain, which could exacerbate these company-specific issues. We also note increasing regulatory scrutiny in certain markets where the company operates, which could create additional headwinds.</p>

<p style="background: #FEE2E2; padding: 15px; border-left: 4px solid #EF4444;">
<strong>RATING: {rating}</strong><br>
{RATING_COMMENTARY[rating]} We see better risk/reward opportunities in the sector.
</p>

<p>Best regards,<br><strong>{analyst}</strong><br>Senior Research Analyst</p>
</body></html>"""
        
        timestamp = f"{email_date.year}-{email_date.month:02d}-{email_date.day:02d} {random.randint(9, 17):02d}:{random.randint(0, 59):02d}:00"
        
        all_emails.append({
            "email_id": email_id,
            "recipient": recipient,
            "subject": subject,
            "html_content": content,
            "created_at": timestamp
        })
    
    # Write to CSV
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
    
    print(f"✅ Successfully generated {len(all_emails)} total emails with narrative arc")
    print(f"📝 Written to: {OUTPUT_FILE}")
    print(f"\n📊 Narrative Arc:")
    print(f"   • July 19: NRNT at peak (BUY)")
    print(f"   • Aug 5: SNOW downgraded to HOLD")
    print(f"   • Sept 15: NRNT problems surface (HOLD)")
    print(f"   • Sept 19: SNOW downgraded to SELL")
    print(f"   • Oct 8: NRNT FDA warning (SELL)")
    print(f"   • Oct 25: NRNT plunges 60%")
    print(f"   • Nov 12: NRNT bankruptcy filed")
    print(f"   • Nov 21: SNOW upgraded to HOLD")
    print(f"   • Nov 29: SNOW upgraded to BUY")
    print(f"   • Dec 15: SNOW upgraded to OVERWEIGHT")
    print(f"\n💾 Ready for Snowflake upload using load_email_previews.template.sql")

if __name__ == "__main__":
    main()

