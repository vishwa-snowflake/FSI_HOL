#!/usr/bin/env python3
"""
Create fully graphical infographics with KPI cards instead of tables
Visual dashboard style optimized for AI_EXTRACT
"""

from pathlib import Path
import math

# Company data
COMPANIES = {
    'SNOW': {
        'name': 'Snowflake Inc.', 'ticker': 'SNOW', 'tagline': 'Cloud Data Platform Leader',
        'period': 'Q2 FY2025', 'period_label': 'FY25-Q2', 'report_date': 'August 2024',
        'color_primary': '#29B5E8', 'color_secondary': '#1E3A8A', 'color_accent': '#60A5FA',
        'revenue': 900, 'revenue_prior': 701, 'yoy_growth': 29, 'product_revenue': 868,
        'services_revenue': 32, 'gross_margin': 75, 'operating_margin': 11,
        'free_cash_flow': 544, 'total_customers': 10000, 'customers_1m': 542,
        'nrr': 127, 'rpo': 5700, 'rpo_growth': 38,
    },
    'ICBG': {
        'name': 'ICBG Data Systems', 'ticker': 'ICBG', 'tagline': 'Open Lakehouse Platform',
        'period': 'Q2 FY2025', 'period_label': 'FY25-Q2', 'report_date': 'August 2024',
        'color_primary': '#00BCD4', 'color_secondary': '#006064', 'color_accent': '#4DD0E1',
        'revenue': 87, 'revenue_prior': 34, 'yoy_growth': 156, 'product_revenue': 79,
        'services_revenue': 8, 'gross_margin': 70, 'operating_margin': -24,
        'free_cash_flow': -45, 'total_customers': 847, 'customers_1m': 267,
        'nrr': 138, 'rpo': 245, 'rpo_growth': 178,
    },
    'QRYQ': {
        'name': 'Querybase Technologies', 'ticker': 'QRYQ', 'tagline': 'Price-Performance Leader',
        'period': 'Q2 FY2025', 'period_label': 'FY25-Q2', 'report_date': 'August 2024',
        'color_primary': '#FF5722', 'color_secondary': '#D84315', 'color_accent': '#FF8A65',
        'revenue': 94, 'revenue_prior': 24.3, 'yoy_growth': 287, 'product_revenue': 88,
        'services_revenue': 6, 'gross_margin': 70, 'operating_margin': -37,
        'free_cash_flow': -78, 'total_customers': 1456, 'customers_1m': 187,
        'nrr': 142, 'rpo': 312, 'rpo_growth': 295,
    },
    'DFLX': {
        'name': 'DataFlex Analytics', 'ticker': 'DFLX', 'tagline': 'Platform-Agnostic BI',
        'period': 'Q2 FY2025', 'period_label': 'FY25-Q2', 'report_date': 'August 2024',
        'color_primary': '#4CAF50', 'color_secondary': '#2E7D32', 'color_accent': '#81C784',
        'revenue': 67, 'revenue_prior': 54, 'yoy_growth': 24, 'product_revenue': 62,
        'services_revenue': 5, 'gross_margin': 75, 'operating_margin': -9,
        'free_cash_flow': 8.5, 'total_customers': 1847, 'customers_1m': 248,
        'nrr': 118, 'rpo': 185, 'rpo_growth': 28,
    },
    'STRM': {
        'name': 'StreamPipe Systems', 'ticker': 'STRM', 'tagline': 'Real-Time Data Integration',
        'period': 'Q2 FY2025', 'period_label': 'FY25-Q2', 'report_date': 'August 2024',
        'color_primary': '#3F51B5', 'color_secondary': '#7C4DFF', 'color_accent': '#9FA8DA',
        'revenue': 51, 'revenue_prior': 17, 'yoy_growth': 200, 'product_revenue': 48,
        'services_revenue': 3, 'gross_margin': 71, 'operating_margin': -35,
        'free_cash_flow': -42, 'total_customers': 723, 'customers_1m': 145,
        'nrr': 135, 'rpo': 168, 'rpo_growth': 205,
    },
    'VLTA': {
        'name': 'Voltaic AI', 'ticker': 'VLTA', 'tagline': 'Production AI Platform',
        'period': 'Q2 FY2025', 'period_label': 'FY25-Q2', 'report_date': 'August 2024',
        'color_primary': '#FDD835', 'color_secondary': '#F57F17', 'color_accent': '#FFF176',
        'revenue': 73, 'revenue_prior': 23, 'yoy_growth': 217, 'product_revenue': 69,
        'services_revenue': 4, 'gross_margin': 68, 'operating_margin': -60,
        'free_cash_flow': -98, 'total_customers': 287, 'customers_1m': 125,
        'nrr': 145, 'rpo': 235, 'rpo_growth': 225,
    },
    'CTLG': {
        'name': 'CatalogX', 'ticker': 'CTLG', 'tagline': 'Cross-Platform Governance',
        'period': 'Q2 FY2025', 'period_label': 'FY25-Q2', 'report_date': 'August 2024',
        'color_primary': '#37474F', 'color_secondary': '#607D8B', 'color_accent': '#90A4AE',
        'revenue': 48, 'revenue_prior': 17.5, 'yoy_growth': 174, 'product_revenue': 42.5,
        'services_revenue': 5.5, 'gross_margin': 70, 'operating_margin': -35,
        'free_cash_flow': -22, 'total_customers': 1124, 'customers_1m': 185,
        'nrr': 132, 'rpo': 156, 'rpo_growth': 180,
    },
    'NRNT': {
        'name': 'Neuro-Nectar Corporation', 'ticker': 'NRNT', 'tagline': 'Cognitive Enhancement',
        'period': 'Q2 FY2025', 'period_label': 'FY25-Q2', 'report_date': 'August 2024',
        'color_primary': '#9C27B0', 'color_secondary': '#E91E63', 'color_accent': '#CE93D8',
        'revenue': 142, 'revenue_prior': 21.7, 'yoy_growth': 554, 'product_revenue': 138,
        'services_revenue': 4, 'gross_margin': 66, 'operating_margin': -55,
        'free_cash_flow': -125, 'total_customers': 1842, 'customers_1m': 425,
        'nrr': 135, 'rpo': 420, 'rpo_growth': 625,
    },
}

def create_pie_chart_svg(product_pct, services_pct, color1, color2):
    """Generate SVG pie chart"""
    product_angle = (product_pct / 100) * 360 * (math.pi / 180)
    product_x = 120 + 110 * math.sin(product_angle)
    product_y = 120 - 110 * math.cos(product_angle)
    large_arc = 1 if product_pct > 50 else 0
    
    return f"""
    <svg width="240" height="240" viewBox="0 0 240 240">
        <circle cx="120" cy="120" r="110" fill="{color1}"/>
        <path d="M 120 120 L 120 10 A 110 110 0 {large_arc} 1 {product_x} {product_y} Z" fill="{color2}"/>
        <circle cx="120" cy="120" r="45" fill="rgba(255,255,255,0.3)"/>
        <text x="120" y="125" text-anchor="middle" font-size="32" font-weight="bold" fill="white">{int(product_pct)}%</text>
        <text x="120" y="150" text-anchor="middle" font-size="16" fill="white">Product</text>
    </svg>
    """

def create_graphical_infographic_html(ticker, data):
    """Create fully graphical infographic with KPI cards (no tables)"""
    
    total = data['product_revenue'] + data['services_revenue']
    product_pct = (data['product_revenue'] / total) * 100
    services_pct = (data['services_revenue'] / total) * 100
    pie_chart = create_pie_chart_svg(product_pct, services_pct, data['color_primary'], data['color_accent'])
    
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{data['name']} - {data['period']}</title>
    <style>
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
        }}
        
        .dashboard {{
            padding: 35px;
            height: 100vh;
            display: flex;
            flex-direction: column;
            gap: 25px;
            box-sizing: border-box;
        }}
        
        .header {{
            text-align: center;
            padding: 25px;
            background: rgba(0, 0, 0, 0.25);
            border-radius: 20px;
            backdrop-filter: blur(10px);
        }}
        
        .header h1 {{
            font-size: 48px;
            margin: 0;
            text-shadow: 3px 3px 6px rgba(0,0,0,0.4);
        }}
        
        .header h2 {{
            font-size: 24px;
            margin: 8px 0;
            opacity: 0.95;
        }}
        
        .header p {{
            font-size: 16px;
            margin: 5px 0;
            opacity: 0.85;
        }}
        
        .kpi-grid {{
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            flex: 1;
        }}
        
        .kpi-card {{
            background: rgba(255, 255, 255, 0.15);
            border: 3px solid rgba(255, 255, 255, 0.3);
            border-radius: 20px;
            padding: 25px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            transition: transform 0.2s;
        }}
        
        .kpi-card:hover {{
            transform: translateY(-5px);
        }}
        
        .kpi-icon {{
            font-size: 48px;
            margin-bottom: 15px;
            filter: drop-shadow(2px 2px 4px rgba(0,0,0,0.3));
        }}
        
        .kpi-label {{
            font-size: 15px;
            text-transform: uppercase;
            opacity: 0.9;
            margin-bottom: 12px;
            letter-spacing: 1.5px;
            font-weight: 600;
        }}
        
        .kpi-value {{
            font-size: 44px;
            font-weight: bold;
            margin: 8px 0;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
            line-height: 1;
        }}
        
        .kpi-subtitle {{
            font-size: 16px;
            opacity: 0.85;
            margin-top: 8px;
        }}
        
        .kpi-change {{
            font-size: 18px;
            background: rgba(255, 255, 255, 0.25);
            padding: 6px 16px;
            border-radius: 20px;
            margin-top: 10px;
            font-weight: 600;
        }}
        
        .kpi-change.positive {{
            background: rgba(76, 175, 80, 0.4);
        }}
        
        .kpi-change.negative {{
            background: rgba(244, 67, 54, 0.4);
        }}
        
        .chart-card {{
            background: rgba(255, 255, 255, 0.15);
            border: 3px solid rgba(255, 255, 255, 0.3);
            border-radius: 20px;
            padding: 30px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }}
        
        .chart-title {{
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 20px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }}
        
        .progress-bar-container {{
            width: 100%;
            margin: 15px 0;
        }}
        
        .progress-label {{
            display: flex;
            justify-content: space-between;
            margin-bottom: 8px;
            font-size: 16px;
        }}
        
        .progress-bar {{
            width: 100%;
            height: 35px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 20px;
            overflow: hidden;
            position: relative;
        }}
        
        .progress-fill {{
            height: 100%;
            background: {data['color_accent']};
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: flex-end;
            padding-right: 15px;
            font-weight: bold;
            font-size: 16px;
            transition: width 1s ease;
        }}
        
        .footer {{
            text-align: center;
            font-size: 13px;
            opacity: 0.8;
            padding: 15px;
        }}
    </style>
</head>
<body>
    <div class="dashboard">
        <!-- Header -->
        <div class="header">
            <h1>{data['name']} ({data['ticker']})</h1>
            <h2>{data['tagline']}</h2>
            <p>{data['period']} Earnings Dashboard | {data['report_date']}</p>
        </div>
        
        <!-- Top Row: 4 Key Metrics -->
        <div class="kpi-grid" style="grid-template-rows: repeat(2, 1fr);">
            <!-- Big Revenue Card -->
            <div class="kpi-card" style="grid-column: span 2; grid-row: span 2;">
                <div class="kpi-icon">💰</div>
                <div class="kpi-label">Total Revenue</div>
                <div class="kpi-value">${data['revenue']}M</div>
                <div class="kpi-change positive">▲ {data['yoy_growth']}% YoY</div>
                <div class="kpi-subtitle">vs ${data['revenue_prior']}M Q2 FY2024</div>
            </div>
            
            <!-- Revenue Mix Pie Chart -->
            <div class="chart-card" style="grid-row: span 2;">
                <div class="chart-title">📊 Revenue Mix</div>
                {pie_chart}
                <div style="margin-top: 15px; font-size: 14px;">
                    <div><span style="display: inline-block; width: 15px; height: 15px; background: {data['color_primary']}; border-radius: 3px; margin-right: 8px; vertical-align: middle;"></span>Product: {int(product_pct)}%</div>
                    <div style="margin-top: 5px;"><span style="display: inline-block; width: 15px; height: 15px; background: {data['color_accent']}; border-radius: 3px; margin-right: 8px; vertical-align: middle;"></span>Services: {int(services_pct)}%</div>
                </div>
            </div>
            
            <!-- Performance Indicators with Progress Bars -->
            <div class="chart-card" style="grid-row: span 2;">
                <div class="chart-title">📈 Performance</div>
                <div class="progress-bar-container">
                    <div class="progress-label"><span>🎯 NRR</span><span style="font-weight: bold;">{data['nrr']}%</span></div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: {min(data['nrr'], 150) / 150 * 100}%">{data['nrr']}%</div>
                    </div>
                </div>
                <div class="progress-bar-container">
                    <div class="progress-label"><span>📊 Gross Margin</span><span style="font-weight: bold;">{data['gross_margin']}%</span></div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: {data['gross_margin']}%">{data['gross_margin']}%</div>
                    </div>
                </div>
                <div class="progress-bar-container">
                    <div class="progress-label"><span>🚀 YoY Growth</span><span style="font-weight: bold;">{data['yoy_growth']}%</span></div>
                    <div class="progress-bar">
                        <div class="progress-fill" style="width: {min(data['yoy_growth'], 300) / 300 * 100}%">{data['yoy_growth']}%</div>
                    </div>
                </div>
            </div>
            
            <!-- Row 2: More KPIs -->
            <div class="kpi-card">
                <div class="kpi-icon">👥</div>
                <div class="kpi-label">Total Customers</div>
                <div class="kpi-value">{data['total_customers']:,}</div>
            </div>
            
            <div class="kpi-card">
                <div class="kpi-icon">⭐</div>
                <div class="kpi-label">$1M+ Customers</div>
                <div class="kpi-value">{data['customers_1m']}</div>
            </div>
            
            <div class="kpi-card">
                <div class="kpi-icon">💵</div>
                <div class="kpi-label">Free Cash Flow</div>
                <div class="kpi-value">${data['free_cash_flow']}M</div>
            </div>
            
            <div class="kpi-card">
                <div class="kpi-icon">📋</div>
                <div class="kpi-label">RPO</div>
                <div class="kpi-value">${data['rpo']}M</div>
                <div class="kpi-change positive">▲ {data['rpo_growth']}%</div>
            </div>
            
            <div class="kpi-card">
                <div class="kpi-icon">💎</div>
                <div class="kpi-label">Product Revenue</div>
                <div class="kpi-value">${data['product_revenue']}M</div>
            </div>
            
            <div class="kpi-card">
                <div class="kpi-icon">🔧</div>
                <div class="kpi-label">Services Revenue</div>
                <div class="kpi-value">${data['services_revenue']}M</div>
            </div>
            
            <div class="kpi-card">
                <div class="kpi-icon">📊</div>
                <div class="kpi-label">Operating Margin</div>
                <div class="kpi-value">{data['operating_margin']}%</div>
            </div>
            
            <div class="kpi-card">
                <div class="kpi-icon">🔄</div>
                <div class="kpi-label">Gross Margin</div>
                <div class="kpi-value">{data['gross_margin']}%</div>
            </div>
        </div>
        
        <!-- Footer -->
        <div class="footer">
            <p>© 2024 {data['name']}. {data['period']} Earnings Dashboard. For Investor Relations.</p>
        </div>
    </div>
</body>
</html>
"""

def main():
    output_dir = Path("infographics_simple")
    output_dir.mkdir(exist_ok=True)
    
    print("=" * 70)
    print("Creating Fully Graphical KPI Infographics")
    print("=" * 70)
    print()
    
    for ticker, data in COMPANIES.items():
        html_content = create_graphical_infographic_html(ticker, data)
        output_file = output_dir / f"{ticker}_Earnings_Infographic_{data['period_label']}.html"
        output_file.write_text(html_content)
        print(f"✓ Created {output_file.name}")
    
    print()
    print("=" * 70)
    print(f"✅ Created {len(COMPANIES)} graphical infographics")
    print("=" * 70)
    print()
    print("Features:")
    print("  📊 Large pie chart (revenue mix)")
    print("  📈 3 animated progress bars (NRR, Margin, Growth)")
    print("  💰 12 graphical KPI cards with icons")
    print("  🎨 Company-specific branding")
    print("  ✨ NO TABLES - All visual KPIs")
    
    return 0

if __name__ == "__main__":
    import sys
    sys.exit(main())

