#!/usr/bin/env python3
"""
Create simplified infographics for all 8 core companies
Optimized for AI_EXTRACT table extraction
Based on Q2 FY2025 financial data (August 2024)
"""

from pathlib import Path

# Company data and branding
COMPANIES = {
    'SNOW': {
        'name': 'Snowflake Inc.',
        'ticker': 'SNOW',
        'tagline': 'Cloud Data Platform Leader',
        'period': 'Q2 FY2025',
        'period_label': 'FY25-Q2',
        'report_date': 'August 2024',
        'color_primary': '#29B5E8',
        'color_secondary': '#1E3A8A',
        # Financial Data
        'revenue': 900,
        'revenue_prior': 701,
        'yoy_growth': 29,
        'product_revenue': 868,
        'services_revenue': 32,
        'gross_margin': 75,
        'operating_margin': 11,
        'free_cash_flow': 544,
        'total_customers': '10,000+',
        'customers_1m': 542,
        'nrr': 127,
        'rpo': 5700,
        'rpo_growth': 38,
    },
    'ICBG': {
        'name': 'ICBG Data Systems',
        'ticker': 'ICBG',
        'tagline': 'Open Lakehouse Platform',
        'period': 'Q2 FY2025',
        'period_label': 'FY25-Q2',
        'report_date': 'August 2024',
        'color_primary': '#00BCD4',
        'color_secondary': '#006064',
        'revenue': 87,
        'revenue_prior': 34,
        'yoy_growth': 156,
        'product_revenue': 79,
        'services_revenue': 8,
        'gross_margin': 70,
        'operating_margin': -24,
        'free_cash_flow': -45,
        'total_customers': 847,
        'customers_1m': 267,
        'nrr': 138,
        'rpo': 245,
        'rpo_growth': 178,
    },
    'QRYQ': {
        'name': 'Querybase Technologies',
        'ticker': 'QRYQ',
        'tagline': 'Price-Performance Leader',
        'period': 'Q2 FY2025',
        'period_label': 'FY25-Q2',
        'report_date': 'August 2024',
        'color_primary': '#FF5722',
        'color_secondary': '#D84315',
        'revenue': 94,
        'revenue_prior': 24.3,
        'yoy_growth': 287,
        'product_revenue': 88,
        'services_revenue': 6,
        'gross_margin': 70,
        'operating_margin': -37,
        'free_cash_flow': -78,
        'total_customers': 1456,
        'customers_1m': 187,
        'nrr': 142,
        'rpo': 312,
        'rpo_growth': 295,
    },
    'DFLX': {
        'name': 'DataFlex Analytics',
        'ticker': 'DFLX',
        'tagline': 'Platform-Agnostic BI',
        'period': 'Q2 FY2025',
        'period_label': 'FY25-Q2',
        'report_date': 'August 2024',
        'color_primary': '#4CAF50',
        'color_secondary': '#2E7D32',
        'revenue': 67,
        'revenue_prior': 54,
        'yoy_growth': 24,
        'product_revenue': 62,
        'services_revenue': 5,
        'gross_margin': 75,
        'operating_margin': -9,
        'free_cash_flow': 8.5,
        'total_customers': 1847,
        'customers_1m': 248,
        'nrr': 118,
        'rpo': 185,
        'rpo_growth': 28,
    },
    'STRM': {
        'name': 'StreamPipe Systems',
        'ticker': 'STRM',
        'tagline': 'Real-Time Data Integration',
        'period': 'Q2 FY2025',
        'period_label': 'FY25-Q2',
        'report_date': 'August 2024',
        'color_primary': '#3F51B5',
        'color_secondary': '#7C4DFF',
        'revenue': 51,
        'revenue_prior': 17,
        'yoy_growth': 200,
        'product_revenue': 48,
        'services_revenue': 3,
        'gross_margin': 71,
        'operating_margin': -35,
        'free_cash_flow': -42,
        'total_customers': 723,
        'customers_1m': 145,
        'nrr': 135,
        'rpo': 168,
        'rpo_growth': 205,
    },
    'VLTA': {
        'name': 'Voltaic AI',
        'ticker': 'VLTA',
        'tagline': 'Production AI Platform',
        'period': 'Q2 FY2025',
        'period_label': 'FY25-Q2',
        'report_date': 'August 2024',
        'color_primary': '#FDD835',
        'color_secondary': '#F57F17',
        'revenue': 73,
        'revenue_prior': 23,
        'yoy_growth': 217,
        'product_revenue': 69,
        'services_revenue': 4,
        'gross_margin': 68,
        'operating_margin': -60,
        'free_cash_flow': -98,
        'total_customers': 287,
        'customers_1m': 125,
        'nrr': 145,
        'rpo': 235,
        'rpo_growth': 225,
    },
    'CTLG': {
        'name': 'CatalogX',
        'ticker': 'CTLG',
        'tagline': 'Cross-Platform Governance',
        'period': 'Q2 FY2025',
        'period_label': 'FY25-Q2',
        'report_date': 'August 2024',
        'color_primary': '#37474F',
        'color_secondary': '#607D8B',
        'revenue': 48,
        'revenue_prior': 17.5,
        'yoy_growth': 174,
        'product_revenue': 42.5,
        'services_revenue': 5.5,
        'gross_margin': 70,
        'operating_margin': -35,
        'free_cash_flow': -22,
        'total_customers': 1124,
        'customers_1m': 185,
        'nrr': 132,
        'rpo': 156,
        'rpo_growth': 180,
    },
    'NRNT': {
        'name': 'Neuro-Nectar Corporation',
        'ticker': 'NRNT',
        'tagline': 'Cognitive Enhancement',
        'period': 'Q2 FY2025',
        'period_label': 'FY25-Q2',
        'report_date': 'August 2024',
        'color_primary': '#9C27B0',
        'color_secondary': '#E91E63',
        'revenue': 142,
        'revenue_prior': 21.7,
        'yoy_growth': 554,
        'product_revenue': 138,
        'services_revenue': 4,
        'gross_margin': 66,
        'operating_margin': -55,
        'free_cash_flow': -125,
        'total_customers': 1842,
        'customers_1m': 425,
        'nrr': 135,
        'rpo': 420,
        'rpo_growth': 625,
    },
}

def create_infographic_html(ticker, data):
    """Create a simple, clean infographic HTML optimized for AI_EXTRACT"""
    
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{data['name']} - {data['period']} Earnings Infographic</title>
    <style>
        @page {{
            size: A4 landscape;
            margin: 0;
        }}
        
        body {{
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 40px;
            background: linear-gradient(135deg, {data['color_primary']} 0%, {data['color_secondary']} 100%);
            color: white;
            width: 297mm;
            height: 210mm;
            box-sizing: border-box;
        }}
        
        .header {{
            text-align: center;
            margin-bottom: 30px;
        }}
        
        .header h1 {{
            font-size: 48px;
            margin: 0;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }}
        
        .header h2 {{
            font-size: 24px;
            margin: 5px 0;
            opacity: 0.9;
        }}
        
        .header p {{
            font-size: 18px;
            margin: 5px 0;
            opacity: 0.8;
        }}
        
        .metrics-grid {{
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin: 30px 0;
        }}
        
        .metric-box {{
            background: rgba(255, 255, 255, 0.15);
            border: 2px solid rgba(255, 255, 255, 0.3);
            border-radius: 10px;
            padding: 20px;
            text-align: center;
            backdrop-filter: blur(10px);
        }}
        
        .metric-label {{
            font-size: 14px;
            text-transform: uppercase;
            opacity: 0.9;
            margin-bottom: 10px;
        }}
        
        .metric-value {{
            font-size: 36px;
            font-weight: bold;
            margin: 5px 0;
        }}
        
        .metric-change {{
            font-size: 16px;
            opacity: 0.9;
        }}
        
        .data-table {{
            width: 100%;
            background: rgba(255, 255, 255, 0.1);
            border-collapse: collapse;
            margin: 20px 0;
            border-radius: 10px;
            overflow: hidden;
        }}
        
        .data-table th {{
            background: rgba(0, 0, 0, 0.3);
            padding: 15px;
            text-align: left;
            font-size: 16px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }}
        
        .data-table td {{
            padding: 12px 15px;
            border: 1px solid rgba(255, 255, 255, 0.2);
            font-size: 18px;
        }}
        
        .data-table .number {{
            text-align: right;
            font-weight: bold;
        }}
        
        .footer {{
            text-align: center;
            margin-top: 20px;
            font-size: 14px;
            opacity: 0.8;
        }}
    </style>
</head>
<body>
    <div class="header">
        <h1>{data['name']} ({data['ticker']})</h1>
        <h2>{data['tagline']}</h2>
        <p>{data['period']} Earnings Infographic | {data['report_date']}</p>
    </div>
    
    <div class="metrics-grid">
        <div class="metric-box">
            <div class="metric-label">Total Revenue</div>
            <div class="metric-value">${data['revenue']}M</div>
            <div class="metric-change">+{data['yoy_growth']}% YoY</div>
        </div>
        <div class="metric-box">
            <div class="metric-label">Gross Margin</div>
            <div class="metric-value">{data['gross_margin']}%</div>
        </div>
        <div class="metric-box">
            <div class="metric-label">Total Customers</div>
            <div class="metric-value">{data['total_customers']}</div>
        </div>
        <div class="metric-box">
            <div class="metric-label">Net Revenue Retention</div>
            <div class="metric-value">{data['nrr']}%</div>
        </div>
    </div>
    
    <h3 style="margin: 20px 0 10px 0;">Revenue Breakdown</h3>
    <table class="data-table">
        <thead>
            <tr>
                <th>Revenue Type</th>
                <th class="number">Q2 FY2025</th>
                <th class="number">Q2 FY2024</th>
                <th class="number">Growth</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>Product Revenue</td>
                <td class="number">${data['product_revenue']}M</td>
                <td class="number">${int(data['product_revenue'] / (1 + data['yoy_growth']/100))}M</td>
                <td class="number">+{data['yoy_growth']}%</td>
            </tr>
            <tr>
                <td>Professional Services</td>
                <td class="number">${data['services_revenue']}M</td>
                <td class="number">${int(data['services_revenue'] / 1.2)}M</td>
                <td class="number">+20%</td>
            </tr>
            <tr style="background: rgba(255, 255, 255, 0.1); font-weight: bold;">
                <td>Total Revenue</td>
                <td class="number">${data['revenue']}M</td>
                <td class="number">${data['revenue_prior']}M</td>
                <td class="number">+{data['yoy_growth']}%</td>
            </tr>
        </tbody>
    </table>
    
    <h3 style="margin: 20px 0 10px 0;">Key Metrics</h3>
    <table class="data-table">
        <thead>
            <tr>
                <th>Metric</th>
                <th class="number">Value</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>Operating Margin (Non-GAAP)</td>
                <td class="number">{data['operating_margin']}%</td>
            </tr>
            <tr>
                <td>Free Cash Flow</td>
                <td class="number">${data['free_cash_flow']}M</td>
            </tr>
            <tr>
                <td>Customers with $1M+ Revenue</td>
                <td class="number">{data['customers_1m']}</td>
            </tr>
            <tr>
                <td>Remaining Performance Obligations</td>
                <td class="number">${data['rpo']}M</td>
            </tr>
            <tr>
                <td>RPO Growth (YoY)</td>
                <td class="number">+{data['rpo_growth']}%</td>
            </tr>
        </tbody>
    </table>
    
    <div class="footer">
        <p>&copy; 2024 {data['name']}. For Investor Relations. Confidential.</p>
    </div>
</body>
</html>
"""

def main():
    output_dir = Path("infographics_simple")
    output_dir.mkdir(exist_ok=True)
    
    print("=" * 70)
    print("Creating Simplified Infographics for All 8 Core Companies")
    print("=" * 70)
    print()
    
    for ticker, data in COMPANIES.items():
        html_content = create_infographic_html(ticker, data)
        output_file = output_dir / f"{ticker}_Earnings_Infographic_{data['period_label']}.html"
        output_file.write_text(html_content)
        print(f"✓ Created {output_file.name}")
    
    print()
    print("=" * 70)
    print(f"✅ Created {len(COMPANIES)} infographic HTML files")
    print(f"   Location: {output_dir}")
    print("=" * 70)
    print()
    print("Next steps:")
    print("1. Convert HTML to PDF/PNG")
    print("2. Upload to @DOCUMENT_AI.INFOGRAPHICS stage")
    print("3. Extract tables with AI_EXTRACT")
    
    return 0

if __name__ == "__main__":
    import sys
    sys.exit(main())

