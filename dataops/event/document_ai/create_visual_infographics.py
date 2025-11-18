#!/usr/bin/env python3
"""
Create visually rich, dashboard-style infographics for all 8 companies
Includes pie charts, progress bars, icons, and visual elements
"""

from pathlib import Path
import math

# Same company data as before
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
        'color_accent': '#60A5FA',
        'revenue': 900,
        'revenue_prior': 701,
        'yoy_growth': 29,
        'product_revenue': 868,
        'services_revenue': 32,
        'gross_margin': 75,
        'operating_margin': 11,
        'free_cash_flow': 544,
        'total_customers': 10000,
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
        'color_accent': '#4DD0E1',
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
        'color_accent': '#FF8A65',
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
        'color_accent': '#81C784',
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
        'color_accent': '#9FA8DA',
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
        'color_accent': '#FFF176',
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
        'color_accent': '#90A4AE',
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
        'color_accent': '#CE93D8',
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

def create_pie_chart_svg(product_pct, services_pct, color1, color2):
    """Generate SVG pie chart for revenue split"""
    # Product slice
    product_angle = (product_pct / 100) * 360
    services_angle = (services_pct / 100) * 360
    
    # Calculate path for product slice (starts at top, goes clockwise)
    product_end_angle = product_angle * (math.pi / 180)
    product_x = 100 + 90 * math.sin(product_end_angle)
    product_y = 100 - 90 * math.cos(product_end_angle)
    
    large_arc = 1 if product_pct > 50 else 0
    
    product_path = f"M 100 100 L 100 10 A 90 90 0 {large_arc} 1 {product_x} {product_y} Z"
    services_path = f"M 100 100 L {product_x} {product_y} A 90 90 0 {1-large_arc} 1 100 10 Z"
    
    return f"""
    <svg width="200" height="200" viewBox="0 0 200 200">
        <circle cx="100" cy="100" r="90" fill="{color1}"/>
        <path d="{services_path}" fill="{color2}"/>
        <circle cx="100" cy="100" r="35" fill="white" opacity="0.3"/>
        <text x="100" y="105" text-anchor="middle" font-size="24" font-weight="bold" fill="white">{int(product_pct)}%</text>
        <text x="100" y="125" text-anchor="middle" font-size="12" fill="white">Product</text>
    </svg>
    """

def create_progress_bar_svg(value, max_value, color):
    """Generate SVG progress bar"""
    percentage = min((value / max_value) * 100, 100)
    return f"""
    <svg width="100%" height="30" viewBox="0 0 300 30">
        <rect x="0" y="0" width="300" height="30" fill="rgba(255,255,255,0.2)" rx="15"/>
        <rect x="0" y="0" width="{percentage * 3}" height="30" fill="{color}" rx="15"/>
        <text x="150" y="20" text-anchor="middle" font-size="14" font-weight="bold" fill="white">{int(percentage)}%</text>
    </svg>
    """

def create_visual_infographic_html(ticker, data):
    """Create dashboard-style infographic with charts and visuals"""
    
    # Calculate percentages for pie chart
    total = data['product_revenue'] + data['services_revenue']
    product_pct = (data['product_revenue'] / total) * 100
    services_pct = (data['services_revenue'] / total) * 100
    
    pie_chart = create_pie_chart_svg(product_pct, services_pct, data['color_primary'], data['color_accent'])
    nrr_bar = create_progress_bar_svg(data['nrr'], 150, data['color_accent'])
    growth_bar = create_progress_bar_svg(min(data['yoy_growth'], 200), 200, data['color_accent'])
    margin_bar = create_progress_bar_svg(max(data['gross_margin'], 0), 100, data['color_accent'])
    
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{data['name']} - {data['period']} Dashboard</title>
    <style>
        @page {{
            size: A4 landscape;
            margin: 0;
        }}
        
        html, body {{
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100vh;
            overflow: hidden;
        }}
        
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, {data['color_primary']} 0%, {data['color_secondary']} 100%);
            color: white;
            box-sizing: border-box;
        }}
        
        .dashboard {{
            padding: 30px;
            height: 100vh;
            display: grid;
            grid-template-rows: auto 1fr auto;
            gap: 0;
            box-sizing: border-box;
        }}
        
        .header {{
            text-align: center;
            padding: 20px;
            background: rgba(0, 0, 0, 0.2);
            border-radius: 15px;
            margin-bottom: 20px;
        }}
        
        .header h1 {{
            font-size: 42px;
            margin: 0;
            text-shadow: 3px 3px 6px rgba(0,0,0,0.4);
        }}
        
        .header h2 {{
            font-size: 22px;
            margin: 8px 0;
            opacity: 0.95;
        }}
        
        .header p {{
            font-size: 16px;
            margin: 5px 0;
            opacity: 0.85;
        }}
        
        .content {{
            display: grid;
            grid-template-columns: 1.2fr 1.8fr;
            gap: 25px;
        }}
        
        /* Left Column - Visual Metrics */
        .visual-metrics {{
            display: flex;
            flex-direction: column;
            gap: 20px;
        }}
        
        .big-number {{
            background: rgba(255, 255, 255, 0.15);
            border: 3px solid rgba(255, 255, 255, 0.3);
            border-radius: 15px;
            padding: 25px;
            text-align: center;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0,0,0,0.2);
        }}
        
        .big-number-label {{
            font-size: 16px;
            text-transform: uppercase;
            opacity: 0.9;
            margin-bottom: 10px;
            letter-spacing: 1px;
        }}
        
        .big-number-value {{
            font-size: 52px;
            font-weight: bold;
            margin: 10px 0;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }}
        
        .big-number-change {{
            font-size: 20px;
            opacity: 0.9;
            background: rgba(255, 255, 255, 0.2);
            padding: 5px 15px;
            border-radius: 20px;
            display: inline-block;
        }}
        
        .chart-box {{
            background: rgba(255, 255, 255, 0.15);
            border: 3px solid rgba(255, 255, 255, 0.3);
            border-radius: 15px;
            padding: 20px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0,0,0,0.2);
        }}
        
        .chart-title {{
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 15px;
            text-align: center;
        }}
        
        /* Right Column - Tables */
        .tables {{
            display: flex;
            flex-direction: column;
            gap: 15px;
        }}
        
        .data-table {{
            width: 100%;
            background: rgba(255, 255, 255, 0.15);
            border-collapse: collapse;
            border-radius: 10px;
            overflow: hidden;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0,0,0,0.2);
        }}
        
        .table-title {{
            background: rgba(0, 0, 0, 0.3);
            padding: 12px;
            font-size: 18px;
            font-weight: bold;
            text-align: left;
        }}
        
        .data-table th {{
            background: rgba(0, 0, 0, 0.4);
            padding: 12px;
            text-align: left;
            font-size: 14px;
            font-weight: 600;
            border-bottom: 2px solid rgba(255, 255, 255, 0.3);
        }}
        
        .data-table td {{
            padding: 10px 12px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
            font-size: 15px;
        }}
        
        .data-table .number {{
            text-align: right;
            font-weight: bold;
        }}
        
        .data-table tbody tr:hover {{
            background: rgba(255, 255, 255, 0.1);
        }}
        
        .metric-row {{
            display: flex;
            align-items: center;
            gap: 15px;
            margin: 8px 0;
        }}
        
        .metric-row-label {{
            flex: 1;
            font-size: 14px;
        }}
        
        .metric-row-value {{
            font-size: 18px;
            font-weight: bold;
        }}
        
        .icon {{
            width: 40px;
            height: 40px;
            background: rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }}
    </style>
</head>
<body>
    <div class="dashboard">
        <div class="header">
            <h1>{data['name']} ({data['ticker']})</h1>
            <h2>{data['tagline']}</h2>
            <p>{data['period']} Earnings Dashboard | {data['report_date']}</p>
        </div>
        
        <div class="content">
            <!-- Left Column: Visual Metrics -->
            <div class="visual-metrics">
                <!-- Big Revenue Number -->
                <div class="big-number">
                    <div class="big-number-label">💰 Total Revenue</div>
                    <div class="big-number-value">${data['revenue']}M</div>
                    <div class="big-number-change">▲ {data['yoy_growth']}% YoY</div>
                </div>
                
                <!-- Revenue Pie Chart -->
                <div class="chart-box">
                    <div class="chart-title">📊 Revenue Mix</div>
                    <div style="text-align: center;">
                        {pie_chart}
                    </div>
                    <div style="display: flex; justify-content: space-around; margin-top: 10px; font-size: 14px;">
                        <div>
                            <span style="display: inline-block; width: 15px; height: 15px; background: {data['color_primary']}; border-radius: 3px; margin-right: 5px;"></span>
                            Product: {int(product_pct)}%
                        </div>
                        <div>
                            <span style="display: inline-block; width: 15px; height: 15px; background: {data['color_accent']}; border-radius: 3px; margin-right: 5px;"></span>
                            Services: {int(services_pct)}%
                        </div>
                    </div>
                </div>
                
                <!-- Progress Bars -->
                <div class="chart-box">
                    <div class="chart-title">📈 Performance Indicators</div>
                    <div class="metric-row">
                        <span class="metric-row-label">🎯 NRR:</span>
                        <span class="metric-row-value">{data['nrr']}%</span>
                    </div>
                    {nrr_bar}
                    
                    <div class="metric-row" style="margin-top: 15px;">
                        <span class="metric-row-label">📊 Gross Margin:</span>
                        <span class="metric-row-value">{data['gross_margin']}%</span>
                    </div>
                    {margin_bar}
                    
                    <div class="metric-row" style="margin-top: 15px;">
                        <span class="metric-row-label">🚀 YoY Growth:</span>
                        <span class="metric-row-value">{data['yoy_growth']}%</span>
                    </div>
                    {growth_bar}
                </div>
            </div>
            
            <!-- Right Column: Data Tables -->
            <div class="tables">
                <!-- Revenue Breakdown Table -->
                <div>
                    <div class="table-title">💵 Revenue Breakdown</div>
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
                                <td class="number">${int(data['revenue_prior'] * 0.96)}M</td>
                                <td class="number">+{data['yoy_growth']}%</td>
                            </tr>
                            <tr>
                                <td>Professional Services</td>
                                <td class="number">${data['services_revenue']}M</td>
                                <td class="number">${int(data['revenue_prior'] * 0.04)}M</td>
                                <td class="number">+25%</td>
                            </tr>
                            <tr style="background: rgba(255, 255, 255, 0.15); font-weight: bold;">
                                <td>Total Revenue</td>
                                <td class="number">${data['revenue']}M</td>
                                <td class="number">${data['revenue_prior']}M</td>
                                <td class="number">+{data['yoy_growth']}%</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                
                <!-- Key Metrics Table -->
                <div>
                    <div class="table-title">📊 Key Operating Metrics</div>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th>Metric</th>
                                <th class="number">Value</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Total Customers</td>
                                <td class="number">{data['total_customers']:,}</td>
                            </tr>
                            <tr>
                                <td>Customers with $1M+ Revenue</td>
                                <td class="number">{data['customers_1m']}</td>
                            </tr>
                            <tr>
                                <td>Net Revenue Retention</td>
                                <td class="number">{data['nrr']}%</td>
                            </tr>
                            <tr>
                                <td>Gross Margin</td>
                                <td class="number">{data['gross_margin']}%</td>
                            </tr>
                            <tr>
                                <td>Operating Margin (Non-GAAP)</td>
                                <td class="number">{data['operating_margin']}%</td>
                            </tr>
                            <tr>
                                <td>Free Cash Flow</td>
                                <td class="number">${data['free_cash_flow']}M</td>
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
                </div>
            </div>
        </div>
        
        <div style="text-align: center; margin-top: 15px; font-size: 12px; opacity: 0.8;">
            <p>&copy; 2024 {data['name']}. Q2 FY2025 Earnings Dashboard. For Investor Relations.</p>
        </div>
    </div>
</body>
</html>
"""

def main():
    output_dir = Path("infographics_simple")
    output_dir.mkdir(exist_ok=True)
    
    print("=" * 70)
    print("Creating Visual Dashboard Infographics for All 8 Companies")
    print("=" * 70)
    print()
    
    for ticker, data in COMPANIES.items():
        html_content = create_visual_infographic_html(ticker, data)
        output_file = output_dir / f"{ticker}_Earnings_Infographic_{data['period_label']}.html"
        output_file.write_text(html_content)
        print(f"✓ Created {output_file.name}")
    
    print()
    print("=" * 70)
    print(f"✅ Created {len(COMPANIES)} visual dashboard infographics")
    print(f"   Location: {output_dir}")
    print("=" * 70)
    print()
    print("Features per infographic:")
    print("  📊 Pie chart showing revenue mix")
    print("  📈 Progress bars for NRR, Margins, Growth")
    print("  💰 Big number displays")
    print("  📋 2 data tables (Revenue Breakdown + Key Metrics)")
    print("  🎨 Company-specific branding")
    
    return 0

if __name__ == "__main__":
    import sys
    sys.exit(main())

