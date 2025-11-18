#!/usr/bin/env python3
"""
Update the single-page visual financial reports with accurate data from enhanced reports
"""

from pathlib import Path
import re

# Accurate data from enhanced reports
COMPANY_DATA = {
    'SNOW': {
        'full_name': 'SNOWFLAKE INC.',
        'tagline': 'Cloud Data Platform Leader',
        'colors': {'primary': '#29B5E8', 'secondary': '#1E3A8A'},
        'q2_revenue': 900, 'product_revenue': 868, 'yoy_growth': 29,
        'gross_margin': 75, 'non_gaap_gm': 76, 'fcf': 544, 'fcf_margin': 60,
        'customers': '10,000+', 'new_customers': 504, 'million_plus': 542,
        'nrr': 127, 'rpo_growth': 38, 'operating_margin': 11, 'cash': '4.2B',
        'fy25_guidance_low': '3.43B', 'fy25_guidance_high': '3.48B',
        'narrative': 'Snowflake delivered another strong quarter with 29% YoY growth, maintaining leadership while navigating competitive dynamics from hyperscalers and open-source alternatives.',
        'highlights': [
            'Added 504 net new customers, total customers now exceed 10,000',
            'Customers with $1M+ product revenue grew 25% to 542 customers',
            'Launched Snowflake Cortex AI capabilities',
            'Net Revenue Retention of 127%'
        ]
    },
    'NRNT': {
        'full_name': 'NEURO-NECTAR CORPORATION',
        'tagline': 'Cognitive Enhancement Pioneer',
        'colors': {'primary': '#EC4899', 'secondary': '#BE185D'},
        'q2_revenue': 142, 'product_revenue': 138, 'yoy_growth': 487,
        'gross_margin': 67, 'non_gaap_gm': 68, 'fcf': 85, 'fcf_margin': 60,
        'customers': '1,842', 'new_customers': 890, 'million_plus': 87,
        'nrr': 135, 'rpo_growth': 285, 'operating_margin': 8, 'cash': '387M',
        'units_shipped': '28.4M', 'enterprise_pilots': 23,
        'narrative': 'Explosive 487% YoY growth driven by unprecedented consumer demand for cognitive enhancement. Enterprise pilot program showing early promise.',
        'highlights': [
            'Revenue grew 487% YoY to $142M',
            'Shipped 28.4 million units in Q2',
            '23 enterprise pilot programs launched',
            'Clinical trial results show 12-18% cognitive improvements'
        ]
    },
    'ICBG': {
        'full_name': 'ICBG DATA SYSTEMS',
        'tagline': 'Open Lakehouse Leader',
        'colors': {'primary': '#10B981', 'secondary': '#047857'},
        'q2_revenue': 87, 'product_revenue': 79, 'yoy_growth': 156,
        'gross_margin': 62, 'non_gaap_gm': 63, 'fcf': 45, 'fcf_margin': 52,
        'customers': '847', 'new_customers': 335, 'million_plus': 267,
        'nrr': 138, 'rpo_growth': 142, 'operating_margin': -14, 'cash': '285M',
        'narrative': '156% YoY growth as open lakehouse architecture gains enterprise traction. Winning on data ownership and avoiding vendor lock-in.',
        'highlights': [
            'Added 335 net new customers',
            'Net Revenue Retention of 138%',
            '28% win rate vs Snowflake on openness',
            'Managed service now 42% of revenue'
        ]
    },
    'QRYQ': {
        'full_name': 'QUERYBASE TECHNOLOGIES',
        'tagline': 'Price-Performance Challenger',
        'colors': {'primary': '#F59E0B', 'secondary': '#D97706'},
        'q2_revenue': 94, 'product_revenue': 88, 'yoy_growth': 287,
        'gross_margin': 71, 'non_gaap_gm': 72, 'fcf': 62, 'fcf_margin': 66,
        'customers': '1,456', 'new_customers': 833, 'million_plus': 187,
        'nrr': 142, 'rpo_growth': 225, 'operating_margin': -19, 'cash': '442M',
        'win_rate_vs_snow': 37,
        'narrative': '287% YoY growth with aggressive price-performance positioning. Winning 37% of competitive deals against Snowflake.',
        'highlights': [
            'Revenue grew 287% YoY to $94M',
            '37% win rate vs Snowflake',
            '2.1x better price-performance',
            'Series D: $400M at $3.0B valuation'
        ]
    },
    'DFLX': {
        'full_name': 'DATAFLEX ANALYTICS',
        'tagline': '"Switzerland" BI Platform',
        'colors': {'primary': '#8B5CF6', 'secondary': '#6D28D9'},
        'q2_revenue': 285, 'product_revenue': 268, 'yoy_growth': 24,
        'gross_margin': 82, 'non_gaap_gm': 83, 'fcf': 148, 'fcf_margin': 52,
        'customers': '3,842', 'new_customers': 657, 'million_plus': 1248,
        'nrr': 118, 'rpo_growth': 32, 'operating_margin': 15, 'cash': '280M',
        'multi_platform_pct': 78,
        'narrative': '24% YoY growth with platform-agnostic positioning. 78% of customers use DataFlex with 2+ data platforms.',
        'highlights': [
            'Total customers: 3,842',
            '78% use DataFlex with 2+ platforms',
            'Operating margin: 15% (profitable)',
            'Strong partnerships with SNOW, ICBG, QRYQ'
        ]
    },
    'STRM': {
        'full_name': 'STREAMPIPE SYSTEMS',
        'tagline': 'Real-Time Data Integration',
        'colors': {'primary': '#06B6D4', 'secondary': '#0E7490'},
        'q2_revenue': 118, 'product_revenue': 108, 'yoy_growth': 142,
        'gross_margin': 68, 'non_gaap_gm': 69, 'fcf': 72, 'fcf_margin': 61,
        'customers': '1,842', 'new_customers': 890, 'million_plus': 425,
        'nrr': 135, 'rpo_growth': 165, 'operating_margin': -7, 'cash': '248M',
        'data_volume_pb': 12.8, 'streaming_pct': 58,
        'narrative': '142% YoY growth as enterprises shift from batch to real-time. Processing 12.8 PB/month across 1,842 customers.',
        'highlights': [
            'Revenue grew 142% YoY to $118M',
            'Processing 12.8 PB data/month',
            '58% of revenue from streaming',
            'Approaching EBITDA breakeven'
        ]
    },
    'VLTA': {
        'full_name': 'VOLTAIC AI',
        'tagline': 'Gen AI Platform Leader',
        'colors': {'primary': '#EF4444', 'secondary': '#B91C1C'},
        'q2_revenue': 156, 'product_revenue': 148, 'yoy_growth': 318,
        'gross_margin': 58, 'non_gaap_gm': 59, 'fcf': 88, 'fcf_margin': 56,
        'customers': '1,285', 'new_customers': 800, 'million_plus': 385,
        'nrr': 158, 'rpo_growth': 295, 'operating_margin': -18, 'cash': '485M',
        'gpu_hours': 18.5, 'gen_ai_pct': 62,
        'narrative': '318% YoY growth driven by Gen AI explosion. 62% of compute from LLM workloads, processing 18.5M GPU hours/month.',
        'highlights': [
            'Revenue grew 318% YoY to $156M',
            '18.5M GPU hours processed in Q2',
            '62% of compute from Gen AI/LLM',
            'Series E: $450M at $4.2B valuation'
        ]
    },
    'CTLG': {
        'full_name': 'CATALOGX',
        'tagline': 'Data Governance Leader',
        'colors': {'primary': '#6366F1', 'secondary': '#4338CA'},
        'q2_revenue': 142, 'product_revenue': 135, 'yoy_growth': 89,
        'gross_margin': 77, 'non_gaap_gm': 78, 'fcf': 95, 'fcf_margin': 67,
        'customers': '2,485', 'new_customers': 900, 'million_plus': 685,
        'nrr': 125, 'rpo_growth': 95, 'operating_margin': 13, 'cash': '280M',
        'data_assets_b': 12.5, 'compliance_frameworks': 28,
        'narrative': '89% YoY growth as governance becomes critical. Cataloging 12.5B data assets across 28 compliance frameworks.',
        'highlights': [
            'Revenue grew 89% YoY to $142M',
            'Cataloging 12.5B data assets',
            'Supporting 28 compliance frameworks',
            'Operating margin: 13% (profitable)'
        ]
    }
}

# Template for single-page visual report
TEMPLATE = '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{full_name} - Q2 FY2025 Financial Results</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        @page {{
            size: A4;
            margin: 0;
        }}
        
        body {{ 
            font-family: 'Inter', sans-serif;
            margin: 0;
            padding: 0;
        }}
        
        .brand-gradient {{ background: linear-gradient(135deg, {primary} 0%, {secondary} 100%); }}
        .brand-text {{ color: {primary}; }}
        
        .container {{
            width: 210mm;
            height: 297mm;
            margin: 0 auto;
            background: white;
            overflow: hidden;
            display: flex;
            flex-direction: column;
        }}
        
        .content-wrapper {{
            flex: 1;
            display: flex;
            flex-direction: column;
        }}
        
        @media screen {{
            body {{
                background: #e5e7eb;
                padding: 10mm;
            }}
            .container {{
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            }}
        }}
        
        @media print {{
            body {{
                background: white;
                padding: 0;
            }}
            .container {{
                box-shadow: none;
            }}
        }}
    </style>
</head>
<body>
    <div class="container">
        <!-- Header - Full Bleed -->
        <header class="brand-gradient text-white px-8 py-6">
            <div class="flex justify-between items-center">
                <div>
                    <h1 class="text-3xl font-bold">{full_name}</h1>
                    <p class="text-blue-100 mt-1 text-sm">{tagline}</p>
                </div>
                <div class="text-right">
                    <div class="text-2xl font-bold">{ticker}</div>
                    <div class="text-xs text-blue-100">{exchange}</div>
                </div>
            </div>
        </header>

        <!-- Report Title - Full Bleed -->
        <div class="bg-blue-50 px-8 py-4 border-b-4" style="border-color: {primary};">
            <h2 class="text-xl font-bold text-gray-800">Q2 Fiscal Year 2025 Financial Results</h2>
            <p class="text-gray-600 text-sm">Report Date: August 2024</p>
        </div>

        <!-- Key Metrics Grid - Full Bleed -->
        <div class="grid grid-cols-4 gap-3 px-8 py-5 bg-gray-50">
            <div class="bg-white p-4 rounded-lg shadow-md text-center">
                <div class="text-xs text-gray-600 mb-1">Total Revenue</div>
                <div class="text-2xl font-bold text-gray-900">${q2_revenue}M</div>
                <div class="text-xs text-green-600 font-semibold mt-1">+{yoy_growth}% YoY</div>
            </div>
            <div class="bg-white p-4 rounded-lg shadow-md text-center">
                <div class="text-xs text-gray-600 mb-1">Product Revenue</div>
                <div class="text-2xl font-bold text-gray-900">${product_revenue}M</div>
                <div class="text-xs text-green-600 font-semibold mt-1">+{yoy_growth}% YoY</div>
            </div>
            <div class="bg-white p-4 rounded-lg shadow-md text-center">
                <div class="text-xs text-gray-600 mb-1">Gross Margin</div>
                <div class="text-2xl font-bold text-gray-900">{gross_margin}%</div>
                <div class="text-xs text-gray-600 mt-1">Non-GAAP: {non_gaap_gm}%</div>
            </div>
            <div class="bg-white p-4 rounded-lg shadow-md text-center">
                <div class="text-xs text-gray-600 mb-1">FCF Margin</div>
                <div class="text-2xl font-bold text-gray-900">{fcf_margin}%</div>
                <div class="text-xs text-gray-600 mt-1">${fcf}M FCF</div>
            </div>
        </div>

        <!-- Main Content - Full Bleed -->
        <div class="grid grid-cols-3 gap-0 py-6 flex-1">
            <!-- Left Column - Executive Summary -->
            <div class="col-span-2 space-y-4 px-8 pr-4">
                <div>
                    <h3 class="text-lg font-bold text-gray-800 mb-2 pb-1 border-b-2" style="border-color: {primary}20;">Executive Summary</h3>
                    <p class="text-gray-700 text-sm leading-relaxed">
                        {narrative}
                    </p>
                </div>

                <div>
                    <h4 class="text-base font-semibold text-gray-800 mb-2">Business Highlights</h4>
                    <ul class="space-y-1 text-gray-700 text-sm">
                        {highlights_html}
                    </ul>
                </div>

                {guidance_section}
            </div>

            <!-- Right Column - Charts and Metrics -->
            <div class="space-y-4 pl-4 pr-8">
                <!-- Growth Chart -->
                <div class="bg-white p-3 rounded-lg shadow-lg border border-gray-200">
                    <h4 class="text-sm font-semibold text-gray-800 mb-2">Revenue Growth</h4>
                    {chart_svg}
                    <p class="text-xs text-gray-500 mt-1 text-center">{customers} customers</p>
                </div>

                <!-- Key Metrics Box -->
                <div class="bg-gray-50 p-3 rounded-lg border border-gray-200">
                    <h4 class="text-sm font-semibold text-gray-800 mb-2">Operating Metrics</h4>
                    <div class="space-y-2 text-xs">
                        <div class="flex justify-between items-center">
                            <span class="text-gray-600">Net Revenue Retention</span>
                            <span class="font-bold text-gray-900">{nrr}%</span>
                        </div>
                        {extra_metric_1}
                        {extra_metric_2}
                        <div class="flex justify-between items-center">
                            <span class="text-gray-600">Cash & Equivalents</span>
                            <span class="font-bold text-gray-900">${cash}</span>
                        </div>
                    </div>
                </div>

                {partner_section}
            </div>
        </div>

        <!-- Footer - Full Bleed -->
        <footer class="bg-gray-100 px-8 py-4 border-t text-xs text-gray-600">
            <div class="flex justify-between items-center">
                <div>
                    <p class="font-semibold">Investor Relations Contact</p>
                    <p>investors@{email_domain} | {phone}</p>
                </div>
                <div class="text-right">
                    <p>&copy; 2024 {full_name}</p>
                    <p>Report ID: {ticker}-Q2FY25-2024</p>
                </div>
            </div>
        </footer>
    </div>
</body>
</html>
'''

def generate_chart_svg(ticker, primary_color):
    """Generate simple growth chart SVG"""
    return f'''<svg width="100%" height="120" viewBox="0 0 240 120" xmlns="http://www.w3.org/2000/svg">
                        <defs>
                            <linearGradient id="{ticker}Gradient" x1="0%" y1="0%" x2="0%" y2="100%">
                                <stop offset="0%" style="stop-color:{primary_color};stop-opacity:0.3" />
                                <stop offset="100%" style="stop-color:{primary_color};stop-opacity:0.05" />
                            </linearGradient>
                        </defs>
                        <rect width="240" height="120" fill="#f9fafb"/>
                        <line x1="30" y1="15" x2="30" y2="95" stroke="#d1d5db" stroke-width="1"/>
                        <line x1="30" y1="95" x2="220" y2="95" stroke="#d1d5db" stroke-width="1"/>
                        <path d="M 50 85 L 90 70 L 130 55 L 170 35 L 210 20 L 210 95 L 50 95 Z" 
                              fill="url(#{ticker}Gradient)"/>
                        <path d="M 50 85 L 90 70 L 130 55 L 170 35 L 210 20" 
                              stroke="{primary_color}" stroke-width="2" fill="none"/>
                        <circle cx="50" cy="85" r="2.5" fill="{primary_color}"/>
                        <circle cx="90" cy="70" r="2.5" fill="{primary_color}"/>
                        <circle cx="130" cy="55" r="2.5" fill="{primary_color}"/>
                        <circle cx="170" cy="35" r="2.5" fill="{primary_color}"/>
                        <circle cx="210" cy="20" r="3" fill="{primary_color}"/>
                        <text x="50" y="110" text-anchor="middle" font-size="8" fill="#6b7280">Q3'24</text>
                        <text x="130" y="110" text-anchor="middle" font-size="8" fill="#6b7280">Q1'25</text>
                        <text x="210" y="110" text-anchor="middle" font-size="8" fill="#6b7280">Q2'25</text>
                    </svg>'''

def generate_report(ticker, data):
    """Generate HTML report for a company"""
    
    # Generate highlights HTML
    highlights_html = '\n                        '.join([
        f'''<li class="flex items-start">
                            <span class="brand-text mr-2">▸</span>
                            <span>{h}</span>
                        </li>''' for h in data['highlights']
    ])
    
    # Generate chart SVG
    chart_svg = generate_chart_svg(ticker, data['colors']['primary'])
    
    # Extra metrics based on company
    if ticker == 'NRNT':
        extra_metric_1 = f'''<div class="flex justify-between items-center">
                            <span class="text-gray-600">Units Shipped</span>
                            <span class="font-bold text-gray-900">{data['units_shipped']}</span>
                        </div>'''
        extra_metric_2 = f'''<div class="flex justify-between items-center">
                            <span class="text-gray-600">Enterprise Pilots</span>
                            <span class="font-bold text-gray-900">{data['enterprise_pilots']}</span>
                        </div>'''
    elif ticker == 'QRYQ':
        extra_metric_1 = f'''<div class="flex justify-between items-center">
                            <span class="text-gray-600">Win Rate vs SNOW</span>
                            <span class="font-bold text-gray-900">{data['win_rate_vs_snow']}%</span>
                        </div>'''
        extra_metric_2 = f'''<div class="flex justify-between items-center">
                            <span class="text-gray-600">Operating Margin</span>
                            <span class="font-bold text-gray-900">{data['operating_margin']}%</span>
                        </div>'''
    elif ticker == 'DFLX':
        extra_metric_1 = f'''<div class="flex justify-between items-center">
                            <span class="text-gray-600">Multi-Platform %</span>
                            <span class="font-bold text-gray-900">{data['multi_platform_pct']}%</span>
                        </div>'''
        extra_metric_2 = f'''<div class="flex justify-between items-center">
                            <span class="text-gray-600">Operating Margin</span>
                            <span class="font-bold text-gray-900">{data['operating_margin']}%</span>
                        </div>'''
    elif ticker == 'STRM':
        extra_metric_1 = f'''<div class="flex justify-between items-center">
                            <span class="text-gray-600">Data Volume</span>
                            <span class="font-bold text-gray-900">{data['data_volume_pb']}PB/mo</span>
                        </div>'''
        extra_metric_2 = f'''<div class="flex justify-between items-center">
                            <span class="text-gray-600">Streaming %</span>
                            <span class="font-bold text-gray-900">{data['streaming_pct']}%</span>
                        </div>'''
    elif ticker == 'VLTA':
        extra_metric_1 = f'''<div class="flex justify-between items-center">
                            <span class="text-gray-600">GPU Hours (M)</span>
                            <span class="font-bold text-gray-900">{data['gpu_hours']}M</span>
                        </div>'''
        extra_metric_2 = f'''<div class="flex justify-between items-center">
                            <span class="text-gray-600">Gen AI %</span>
                            <span class="font-bold text-gray-900">{data['gen_ai_pct']}%</span>
                        </div>'''
    elif ticker == 'CTLG':
        extra_metric_1 = f'''<div class="flex justify-between items-center">
                            <span class="text-gray-600">Data Assets</span>
                            <span class="font-bold text-gray-900">{data['data_assets_b']}B</span>
                        </div>'''
        extra_metric_2 = f'''<div class="flex justify-between items-center">
                            <span class="text-gray-600">Compliance Frameworks</span>
                            <span class="font-bold text-gray-900">{data['compliance_frameworks']}</span>
                        </div>'''
    else:
        extra_metric_1 = f'''<div class="flex justify-between items-center">
                            <span class="text-gray-600">RPO Growth</span>
                            <span class="font-bold text-gray-900">+{data['rpo_growth']}% YoY</span>
                        </div>'''
        extra_metric_2 = f'''<div class="flex justify-between items-center">
                            <span class="text-gray-600">Operating Margin</span>
                            <span class="font-bold text-gray-900">{data['operating_margin']}%</span>
                        </div>'''
    
    # Guidance section for SNOW
    if ticker == 'SNOW':
        guidance_section = f'''<div class="bg-blue-50 p-3 rounded-lg">
                    <h4 class="text-base font-semibold text-gray-800 mb-2">FY2025 Guidance</h4>
                    <div class="grid grid-cols-2 gap-3 text-xs">
                        <div>
                            <div class="text-gray-600">Full Year Product Revenue</div>
                            <div class="font-bold text-gray-900 text-sm">${data['fy25_guidance_low']} - ${data['fy25_guidance_high']}</div>
                            <div class="text-gray-500">~29% YoY growth</div>
                        </div>
                        <div>
                            <div class="text-gray-600">Non-GAAP Operating Margin</div>
                            <div class="font-bold text-gray-900 text-sm">~10%</div>
                            <div class="text-gray-500">Sustained profitability</div>
                        </div>
                    </div>
                </div>'''
    else:
        guidance_section = ''
    
    # Partner section for SNOW
    if ticker == 'SNOW':
        partner_section = '''<div class="bg-white p-3 rounded-lg border border-gray-200">
                    <h4 class="text-sm font-semibold text-gray-800 mb-2">Partner Ecosystem</h4>
                    <div class="space-y-1.5 text-xs text-gray-700">
                        <div class="flex items-center">
                            <span class="w-1.5 h-1.5 bg-purple-500 rounded-full mr-2"></span>
                            <span><strong>DFLX</strong> - BI & Analytics</span>
                        </div>
                        <div class="flex items-center">
                            <span class="w-1.5 h-1.5 bg-cyan-500 rounded-full mr-2"></span>
                            <span><strong>STRM</strong> - Real-time Ingestion</span>
                        </div>
                        <div class="flex items-center">
                            <span class="w-1.5 h-1.5 bg-red-500 rounded-full mr-2"></span>
                            <span><strong>VLTA</strong> - AI/ML Infrastructure</span>
                        </div>
                        <div class="flex items-center">
                            <span class="w-1.5 h-1.5 bg-indigo-500 rounded-full mr-2"></span>
                            <span><strong>CTLG</strong> - Data Governance</span>
                        </div>
                    </div>
                </div>'''
    else:
        partner_section = ''
    
    # Email domain and phone
    email_domains = {
        'SNOW': 'snowflake.com', 'NRNT': 'neuronectar.com', 'ICBG': 'icbgdata.com',
        'QRYQ': 'querybase.com', 'DFLX': 'dataflex.com', 'STRM': 'streampipe.com',
        'VLTA': 'voltaic.ai', 'CTLG': 'catalogx.com'
    }
    
    phones = {
        'SNOW': '+1 (844) 766-9355', 'NRNT': '+1 (844) 638-7662', 'ICBG': '+1 (844) 422-4328',
        'QRYQ': '+1 (855) 779-7000', 'DFLX': '+1 (888) 332-3539', 'STRM': '+1 (877) 787-6773',
        'VLTA': '+1 (844) 865-8242', 'CTLG': '+1 (877) 228-2564'
    }
    
    exchange = 'NYSE' if ticker in ['SNOW', 'DFLX'] else 'NASDAQ'
    
    # Fill template
    html = TEMPLATE.format(
        ticker=ticker,
        exchange=exchange,
        full_name=data['full_name'],
        tagline=data['tagline'],
        primary=data['colors']['primary'],
        secondary=data['colors']['secondary'],
        q2_revenue=data['q2_revenue'],
        product_revenue=data['product_revenue'],
        yoy_growth=data['yoy_growth'],
        gross_margin=data['gross_margin'],
        non_gaap_gm=data['non_gaap_gm'],
        fcf=data['fcf'],
        fcf_margin=data['fcf_margin'],
        narrative=data['narrative'],
        highlights_html=highlights_html,
        guidance_section=guidance_section,
        chart_svg=chart_svg,
        customers=data['customers'],
        nrr=data['nrr'],
        extra_metric_1=extra_metric_1,
        extra_metric_2=extra_metric_2,
        cash=data['cash'],
        partner_section=partner_section,
        email_domain=email_domains[ticker],
        phone=phones[ticker]
    )
    
    return html

def main():
    """Update all visual financial reports"""
    output_dir = Path('../financial_reports_html')
    
    print("Updating visual financial reports with accurate data...\n")
    
    for ticker, data in COMPANY_DATA.items():
        html = generate_report(ticker, data)
        output_file = output_dir / f'{ticker}_Q2_FY2025_Financial_Report.html'
        
        with open(output_file, 'w') as f:
            f.write(html)
        
        print(f'✓ Updated {ticker}_Q2_FY2025_Financial_Report.html')
    
    print(f'\n✅ All visual reports updated in {output_dir}')

if __name__ == '__main__':
    main()

