#!/usr/bin/env python3
"""
Create varied infographic designs for each company
Different layouts, styles, and visual treatments
"""

from pathlib import Path
import math

# Company data (same as before)
COMPANIES = {
    'SNOW': {
        'name': 'Snowflake Inc.', 'ticker': 'SNOW', 'tagline': 'Cloud Data Platform Leader',
        'period': 'Q2 FY2025', 'period_label': 'FY25-Q2', 'report_date': 'August 2024',
        'color_primary': '#29B5E8', 'color_secondary': '#1E3A8A', 'color_accent': '#60A5FA',
        'revenue': 900, 'revenue_prior': 701, 'yoy_growth': 29, 'product_revenue': 868,
        'services_revenue': 32, 'gross_margin': 75, 'operating_margin': 11,
        'free_cash_flow': 544, 'total_customers': 10000, 'customers_1m': 542,
        'nrr': 127, 'rpo': 5700, 'rpo_growth': 38,
        'style': 'corporate'  # Professional grid layout
    },
    'ICBG': {
        'name': 'ICBG Data Systems', 'ticker': 'ICBG', 'tagline': 'Open Lakehouse Platform',
        'period': 'Q2 FY2025', 'period_label': 'FY25-Q2', 'report_date': 'August 2024',
        'color_primary': '#00BCD4', 'color_secondary': '#006064', 'color_accent': '#4DD0E1',
        'revenue': 87, 'revenue_prior': 34, 'yoy_growth': 156, 'product_revenue': 79,
        'services_revenue': 8, 'gross_margin': 70, 'operating_margin': -24,
        'free_cash_flow': -45, 'total_customers': 847, 'customers_1m': 267,
        'nrr': 138, 'rpo': 245, 'rpo_growth': 178,
        'style': 'minimal'  # Clean, open design
    },
    'QRYQ': {
        'name': 'Querybase Technologies', 'ticker': 'QRYQ', 'tagline': 'Price-Performance Leader',
        'period': 'Q2 FY2025', 'period_label': 'FY25-Q2', 'report_date': 'August 2024',
        'color_primary': '#FF5722', 'color_secondary': '#D84315', 'color_accent': '#FF8A65',
        'revenue': 94, 'revenue_prior': 24.3, 'yoy_growth': 287, 'product_revenue': 88,
        'services_revenue': 6, 'gross_margin': 70, 'operating_margin': -37,
        'free_cash_flow': -78, 'total_customers': 1456, 'customers_1m': 187,
        'nrr': 142, 'rpo': 312, 'rpo_growth': 295,
        'style': 'bold'  # Aggressive, angular design
    },
    'DFLX': {
        'name': 'DataFlex Analytics', 'ticker': 'DFLX', 'tagline': 'Platform-Agnostic BI',
        'period': 'Q2 FY2025', 'period_label': 'FY25-Q2', 'report_date': 'August 2024',
        'color_primary': '#4CAF50', 'color_secondary': '#2E7D32', 'color_accent': '#81C784',
        'revenue': 67, 'revenue_prior': 54, 'yoy_growth': 24, 'product_revenue': 62,
        'services_revenue': 5, 'gross_margin': 75, 'operating_margin': -9,
        'free_cash_flow': 8.5, 'total_customers': 1847, 'customers_1m': 248,
        'nrr': 118, 'rpo': 185, 'rpo_growth': 28,
        'style': 'charts'  # Heavy chart focus (BI company)
    },
    'STRM': {
        'name': 'StreamPipe Systems', 'ticker': 'STRM', 'tagline': 'Real-Time Data Integration',
        'period': 'Q2 FY2025', 'period_label': 'FY25-Q2', 'report_date': 'August 2024',
        'color_primary': '#3F51B5', 'color_secondary': '#7C4DFF', 'color_accent': '#9FA8DA',
        'revenue': 51, 'revenue_prior': 17, 'yoy_growth': 200, 'product_revenue': 48,
        'services_revenue': 3, 'gross_margin': 71, 'operating_margin': -35,
        'free_cash_flow': -42, 'total_customers': 723, 'customers_1m': 145,
        'nrr': 135, 'rpo': 168, 'rpo_growth': 205,
        'style': 'flow'  # Pipeline/flow design
    },
    'VLTA': {
        'name': 'Voltaic AI', 'ticker': 'VLTA', 'tagline': 'Production AI Platform',
        'period': 'Q2 FY2025', 'period_label': 'FY25-Q2', 'report_date': 'August 2024',
        'color_primary': '#FDD835', 'color_secondary': '#F57F17', 'color_accent': '#FFF176',
        'revenue': 73, 'revenue_prior': 23, 'yoy_growth': 217, 'product_revenue': 69,
        'services_revenue': 4, 'gross_margin': 68, 'operating_margin': -60,
        'free_cash_flow': -98, 'total_customers': 287, 'customers_1m': 125,
        'nrr': 145, 'rpo': 235, 'rpo_growth': 225,
        'style': 'tech'  # Futuristic AI design
    },
    'CTLG': {
        'name': 'CatalogX', 'ticker': 'CTLG', 'tagline': 'Cross-Platform Governance',
        'period': 'Q2 FY2025', 'period_label': 'FY25-Q2', 'report_date': 'August 2024',
        'color_primary': '#37474F', 'color_secondary': '#607D8B', 'color_accent': '#90A4AE',
        'revenue': 48, 'revenue_prior': 17.5, 'yoy_growth': 174, 'product_revenue': 42.5,
        'services_revenue': 5.5, 'gross_margin': 70, 'operating_margin': -35,
        'free_cash_flow': -22, 'total_customers': 1124, 'customers_1m': 185,
        'nrr': 132, 'rpo': 156, 'rpo_growth': 180,
        'style': 'structured'  # Organized, hierarchical
    },
    'NRNT': {
        'name': 'Neuro-Nectar Corporation', 'ticker': 'NRNT', 'tagline': 'Cognitive Enhancement',
        'period': 'Q2 FY2025', 'period_label': 'FY25-Q2', 'report_date': 'August 2024',
        'color_primary': '#9C27B0', 'color_secondary': '#E91E63', 'color_accent': '#CE93D8',
        'revenue': 142, 'revenue_prior': 21.7, 'yoy_growth': 554, 'product_revenue': 138,
        'services_revenue': 4, 'gross_margin': 66, 'operating_margin': -55,
        'free_cash_flow': -125, 'total_customers': 1842, 'customers_1m': 425,
        'nrr': 135, 'rpo': 420, 'rpo_growth': 625,
        'style': 'dynamic'  # Energetic, asymmetric
    },
}

def create_donut_chart(value, max_val, color_main, color_bg):
    """Create a donut chart SVG"""
    percentage = min(value / max_val * 100, 100)
    angle = percentage * 3.6 * (math.pi / 180)
    x = 80 + 70 * math.sin(angle)
    y = 80 - 70 * math.cos(angle)
    large_arc = 1 if percentage > 50 else 0
    
    return f"""
    <svg width="160" height="160" viewBox="0 0 160 160">
        <circle cx="80" cy="80" r="70" fill="none" stroke="{color_bg}" stroke-width="20" opacity="0.3"/>
        <path d="M 80 10 A 70 70 0 {large_arc} 1 {x} {y}" 
              fill="none" stroke="{color_main}" stroke-width="20" 
              stroke-linecap="round"/>
        <text x="80" y="85" text-anchor="middle" font-size="32" font-weight="bold" fill="white">{int(percentage)}%</text>
    </svg>
    """

def create_bar_chart(values, labels, color):
    """Create horizontal bar chart SVG"""
    max_val = max(values)
    bars = ""
    for i, (val, label) in enumerate(zip(values, labels)):
        y = i * 50 + 10
        width = (val / max_val) * 250
        bars += f"""
        <rect x="0" y="{y}" width="250" height="35" fill="rgba(255,255,255,0.2)" rx="5"/>
        <rect x="0" y="{y}" width="{width}" height="35" fill="{color}" rx="5"/>
        <text x="260" y="{y + 23}" font-size="14" fill="white" font-weight="bold">${val}M</text>
        <text x="5" y="{y + 23}" font-size="12" fill="white">{label}</text>
        """
    
    return f'<svg width="320" height="{len(values) * 50}" viewBox="0 0 320 {len(values) * 50}">{bars}</svg>'

# Different template functions for each style

def create_snow_corporate(data):
    """SNOW: Professional corporate grid"""
    donut_nrr = create_donut_chart(data['nrr'], 150, data['color_accent'], 'white')
    donut_margin = create_donut_chart(data['gross_margin'], 100, data['color_accent'], 'white')
    
    return f"""<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>{data['name']}</title>
<style>
html, body {{ margin: 0; padding: 0; width: 100%; height: 100vh; overflow: hidden; }}
body {{ background: linear-gradient(135deg, {data['color_primary']} 0%, {data['color_secondary']} 100%); color: white; font-family: Arial, sans-serif; }}
.grid {{ display: grid; grid-template-columns: repeat(4, 1fr); grid-template-rows: auto repeat(3, 1fr); gap: 20px; padding: 35px; height: 100vh; box-sizing: border-box; }}
.header {{ grid-column: span 4; text-align: center; background: rgba(0,0,0,0.3); padding: 25px; border-radius: 15px; }}
.header h1 {{ font-size: 42px; margin: 0; }}
.header h2 {{ font-size: 20px; margin: 5px 0; opacity: 0.9; }}
.kpi {{ background: rgba(255,255,255,0.15); border-radius: 15px; padding: 20px; text-align: center; backdrop-filter: blur(10px); border: 2px solid rgba(255,255,255,0.3); display: flex; flex-direction: column; justify-content: center; }}
.kpi-icon {{ font-size: 36px; margin-bottom: 10px; }}
.kpi-label {{ font-size: 13px; text-transform: uppercase; opacity: 0.85; margin-bottom: 8px; }}
.kpi-value {{ font-size: 38px; font-weight: bold; margin: 5px 0; }}
.kpi-sub {{ font-size: 15px; opacity: 0.8; margin-top: 5px; }}
</style></head><body>
<div class="grid">
<div class="header"><h1>{data['name']} ({data['ticker']})</h1><h2>{data['tagline']}</h2><p>{data['period']} | {data['report_date']}</p></div>
<div class="kpi" style="grid-column: span 2; grid-row: span 2;"><div class="kpi-icon">💰</div><div class="kpi-label">Total Revenue</div><div class="kpi-value">${data['revenue']}M</div><div class="kpi-sub">▲ {data['yoy_growth']}% YoY</div></div>
<div class="kpi">{donut_nrr}<div class="kpi-label">Net Revenue Retention</div></div>
<div class="kpi">{donut_margin}<div class="kpi-label">Gross Margin</div></div>
<div class="kpi"><div class="kpi-icon">👥</div><div class="kpi-label">Total Customers</div><div class="kpi-value">{data['total_customers']:,}</div></div>
<div class="kpi"><div class="kpi-icon">⭐</div><div class="kpi-label">$1M+ Customers</div><div class="kpi-value">{data['customers_1m']}</div></div>
<div class="kpi"><div class="kpi-icon">💵</div><div class="kpi-label">Free Cash Flow</div><div class="kpi-value">${data['free_cash_flow']}M</div></div>
<div class="kpi"><div class="kpi-icon">📋</div><div class="kpi-label">RPO</div><div class="kpi-value">${data['rpo']}M</div><div class="kpi-sub">+{data['rpo_growth']}%</div></div>
<div class="kpi"><div class="kpi-icon">💎</div><div class="kpi-label">Product Revenue</div><div class="kpi-value">${data['product_revenue']}M</div></div>
<div class="kpi"><div class="kpi-icon">📊</div><div class="kpi-label">Operating Margin</div><div class="kpi-value">{data['operating_margin']}%</div></div>
</div></body></html>"""

def create_icbg_minimal(data):
    """ICBG: Minimal, open design - NO TABLES"""
    product_pct = (data['product_revenue'] / data['revenue']) * 100
    
    return f"""<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>{data['name']}</title>
<style>
html, body {{ margin: 0; padding: 0; width: 100%; height: 100vh; overflow: hidden; }}
body {{ background: linear-gradient(to bottom, {data['color_primary']} 0%, {data['color_secondary']} 100%); color: white; font-family: 'Courier New', monospace; }}
.container {{ padding: 40px; height: 100vh; box-sizing: border-box; display: flex; flex-direction: column; gap: 25px; }}
.title {{ font-size: 56px; font-weight: 300; letter-spacing: 3px; }}
.subtitle {{ font-size: 24px; opacity: 0.8; font-weight: 300; }}
.metrics {{ display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; flex: 1; }}
.metric-box {{ background: rgba(0,0,0,0.2); padding: 25px; border-radius: 10px; border-left: 6px solid white; display: flex; flex-direction: column; justify-content: center; }}
.metric-icon {{ font-size: 36px; margin-bottom: 10px; }}
.metric-label {{ font-size: 13px; opacity: 0.8; margin-bottom: 10px; text-transform: uppercase; }}
.metric-value {{ font-size: 42px; font-weight: bold; }}
.metric-detail {{ font-size: 15px; opacity: 0.9; margin-top: 8px; }}
</style></head><body>
<div class="container">
<div><div class="title">{data['ticker']}</div><div class="subtitle">{data['name']} • {data['tagline']}</div><div style="opacity: 0.7; margin-top: 10px; font-size: 18px;">{data['period']} | {data['report_date']}</div></div>
<div class="metrics">
<div class="metric-box" style="grid-column: span 2; grid-row: span 2; background: rgba(0,0,0,0.3);"><div class="metric-icon">💰</div><div class="metric-label">Total Revenue</div><div class="metric-value" style="font-size: 56px;">${data['revenue']}M</div><div class="metric-detail" style="font-size: 20px;">▲ {data['yoy_growth']}% YoY</div></div>
<div class="metric-box"><div class="metric-icon">💎</div><div class="metric-label">Product Revenue</div><div class="metric-value">${data['product_revenue']}M</div><div class="metric-detail">{int(product_pct)}% of total</div></div>
<div class="metric-box"><div class="metric-icon">🔧</div><div class="metric-label">Services Revenue</div><div class="metric-value">${data['services_revenue']}M</div></div>
<div class="metric-box"><div class="metric-icon">👥</div><div class="metric-label">Total Customers</div><div class="metric-value">{data['total_customers']}</div></div>
<div class="metric-box"><div class="metric-icon">⭐</div><div class="metric-label">$1M+ Customers</div><div class="metric-value">{data['customers_1m']}</div></div>
<div class="metric-box"><div class="metric-icon">🔄</div><div class="metric-label">Net Revenue Retention</div><div class="metric-value">{data['nrr']}%</div></div>
<div class="metric-box"><div class="metric-icon">📊</div><div class="metric-label">Gross Margin</div><div class="metric-value">{data['gross_margin']}%</div></div>
<div class="metric-box"><div class="metric-icon">📈</div><div class="metric-label">RPO Growth</div><div class="metric-value">{data['rpo_growth']}%</div></div>
<div class="metric-box"><div class="metric-icon">📋</div><div class="metric-label">RPO</div><div class="metric-value">${data['rpo']}M</div></div>
<div class="metric-box"><div class="metric-icon">💵</div><div class="metric-label">Free Cash Flow</div><div class="metric-value">${data['free_cash_flow']}M</div></div>
<div class="metric-box"><div class="metric-icon">⚙️</div><div class="metric-label">Operating Margin</div><div class="metric-value">{data['operating_margin']}%</div></div>
</div>
</div></body></html>"""

def create_qryq_bold(data):
    """QRYQ: Bold, aggressive design"""
    return f"""<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>{data['name']}</title>
<style>
html, body {{ margin: 0; padding: 0; width: 100%; height: 100vh; overflow: hidden; }}
body {{ background: linear-gradient(45deg, {data['color_primary']} 0%, {data['color_secondary']} 50%, black 100%); color: white; font-family: Impact, sans-serif; }}
.hero {{ padding: 40px; height: 100vh; box-sizing: border-box; display: grid; grid-template-rows: auto 1fr; gap: 30px; }}
.mega-header {{ text-align: center; background: rgba(0,0,0,0.5); padding: 35px; clip-path: polygon(0 0, 100% 0, 95% 100%, 5% 100%); }}
.mega-header h1 {{ font-size: 64px; margin: 0; letter-spacing: 4px; text-shadow: 4px 4px 8px rgba(0,0,0,0.5); }}
.mega-header h2 {{ font-size: 28px; margin: 10px 0; opacity: 0.9; }}
.stats-grid {{ display: grid; grid-template-columns: repeat(3, 1fr); gap: 25px; }}
.stat-card {{ background: linear-gradient(135deg, rgba(0,0,0,0.4) 0%, rgba(0,0,0,0.2) 100%); padding: 30px; clip-path: polygon(5% 0, 100% 0, 95% 100%, 0 100%); text-align: center; border: 3px solid rgba(255,255,255,0.2); }}
.stat-card.big {{ grid-column: span 2; grid-row: span 2; clip-path: polygon(0 0, 100% 0, 100% 100%, 0 100%); }}
.stat-icon {{ font-size: 52px; }}
.stat-label {{ font-size: 16px; margin: 12px 0; opacity: 0.9; letter-spacing: 2px; }}
.stat-value {{ font-size: 52px; font-weight: bold; text-shadow: 3px 3px 6px rgba(0,0,0,0.5); }}
.stat-growth {{ font-size: 22px; margin-top: 10px; background: rgba(255,255,255,0.2); padding: 8px 20px; display: inline-block; clip-path: polygon(10% 0, 100% 0, 90% 100%, 0 100%); }}
</style></head><body>
<div class="hero">
<div class="mega-header"><h1>{data['ticker']}</h1><h2>{data['name']}</h2><p style="font-size: 18px; font-family: Arial;">{data['tagline']} • {data['period']}</p></div>
<div class="stats-grid">
<div class="stat-card big"><div class="stat-icon">🚀</div><div class="stat-label">REVENUE EXPLOSION</div><div class="stat-value">${data['revenue']}M</div><div class="stat-growth">▲ {data['yoy_growth']}% YoY</div></div>
<div class="stat-card"><div class="stat-icon">👥</div><div class="stat-label">CUSTOMERS</div><div class="stat-value">{data['total_customers']}</div></div>
<div class="stat-card"><div class="stat-icon">⭐</div><div class="stat-label">$1M+ TIER</div><div class="stat-value">{data['customers_1m']}</div></div>
<div class="stat-card"><div class="stat-icon">🔄</div><div class="stat-label">NRR</div><div class="stat-value">{data['nrr']}%</div></div>
<div class="stat-card"><div class="stat-icon">📊</div><div class="stat-label">GROSS MARGIN</div><div class="stat-value">{data['gross_margin']}%</div></div>
<div class="stat-card"><div class="stat-icon">📈</div><div class="stat-label">RPO GROWTH</div><div class="stat-value">{data['rpo_growth']}%</div></div>
<div class="stat-card"><div class="stat-icon">💰</div><div class="stat-label">RPO</div><div class="stat-value">${data['rpo']}M</div></div>
</div>
</div></body></html>"""

def create_dflx_charts(data):
    """DFLX: Chart-heavy BI style - NO TABLES, visual KPIs only"""
    donut1 = create_donut_chart(data['nrr'], 150, data['color_accent'], 'white')
    donut2 = create_donut_chart(data['gross_margin'], 100, data['color_accent'], 'white')
    donut3 = create_donut_chart(min(data['yoy_growth'], 100), 100, data['color_accent'], 'white')
    
    return f"""<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>{data['name']}</title>
<style>
html, body {{ margin: 0; padding: 0; width: 100%; height: 100vh; overflow: hidden; }}
body {{ background: linear-gradient(135deg, {data['color_primary']} 0%, {data['color_secondary']} 100%); color: white; font-family: 'Trebuchet MS', sans-serif; }}
.dash {{ padding: 35px; height: 100vh; box-sizing: border-box; display: flex; flex-direction: column; gap: 20px; }}
.top {{ background: rgba(0,0,0,0.25); padding: 20px; border-radius: 12px; text-align: center; }}
.top h1 {{ font-size: 40px; margin: 0; }}
.main {{ display: grid; grid-template-columns: repeat(4, 1fr); gap: 18px; flex: 1; }}
.chart-box {{ background: rgba(255,255,255,0.12); padding: 20px; border-radius: 12px; backdrop-filter: blur(8px); border: 2px solid rgba(255,255,255,0.25); display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center; }}
.kpi-icon {{ font-size: 38px; margin-bottom: 12px; }}
.kpi-label {{ font-size: 13px; text-transform: uppercase; opacity: 0.85; margin-bottom: 8px; }}
.kpi-value {{ font-size: 38px; font-weight: bold; }}
.kpi-sub {{ font-size: 15px; opacity: 0.8; margin-top: 8px; }}
</style></head><body>
<div class="dash">
<div class="top"><h1>📊 {data['name']} ({data['ticker']})</h1><p style="font-size: 18px; margin: 5px 0;">{data['tagline']} • {data['period']}</p></div>
<div class="main">
<div class="chart-box" style="grid-column: span 2; grid-row: span 2;"><div class="kpi-icon">💰</div><div class="kpi-label">Total Revenue</div><div class="kpi-value" style="font-size: 52px;">${data['revenue']}M</div><div class="kpi-sub" style="font-size: 18px;">▲ {data['yoy_growth']}% YoY</div></div>
<div class="chart-box">{donut1}<div class="kpi-label" style="margin-top: 10px;">NRR</div></div>
<div class="chart-box">{donut2}<div class="kpi-label" style="margin-top: 10px;">Gross Margin</div></div>
<div class="chart-box"><div class="kpi-icon">💎</div><div class="kpi-label">Product Revenue</div><div class="kpi-value">${data['product_revenue']}M</div></div>
<div class="chart-box"><div class="kpi-icon">🔧</div><div class="kpi-label">Services Revenue</div><div class="kpi-value">${data['services_revenue']}M</div></div>
<div class="chart-box"><div class="kpi-icon">👥</div><div class="kpi-label">Total Customers</div><div class="kpi-value">{data['total_customers']}</div></div>
<div class="chart-box"><div class="kpi-icon">⭐</div><div class="kpi-label">$1M+ Customers</div><div class="kpi-value">{data['customers_1m']}</div></div>
<div class="chart-box"><div class="kpi-icon">📋</div><div class="kpi-label">RPO</div><div class="kpi-value">${data['rpo']}M</div><div class="kpi-sub">+{data['rpo_growth']}%</div></div>
<div class="chart-box"><div class="kpi-icon">💵</div><div class="kpi-label">Free Cash Flow</div><div class="kpi-value">${data['free_cash_flow']}M</div></div>
<div class="chart-box"><div class="kpi-icon">⚙️</div><div class="kpi-label">Operating Margin</div><div class="kpi-value">{data['operating_margin']}%</div></div>
<div class="chart-box">{donut3}<div class="kpi-label" style="margin-top: 10px;">YoY Growth</div></div>
</div>
</div></body></html>"""

def create_strm_flow(data):
    """STRM: Pipeline/flow design"""
    return f"""<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>{data['name']}</title>
<style>
html, body {{ margin: 0; padding: 0; width: 100%; height: 100vh; overflow: hidden; }}
body {{ background: linear-gradient(90deg, {data['color_primary']} 0%, {data['color_secondary']} 100%); color: white; font-family: 'Helvetica Neue', sans-serif; }}
.flow {{ padding: 35px; height: 100vh; box-sizing: border-box; display: flex; gap: 25px; }}
.flow-col {{ flex: 1; display: flex; flex-direction: column; gap: 20px; }}
.flow-header {{ background: rgba(0,0,0,0.3); padding: 25px; border-radius: 15px; text-align: center; }}
.flow-header h1 {{ font-size: 44px; margin: 0; }}
.flow-node {{ background: linear-gradient(135deg, rgba(255,255,255,0.2) 0%, rgba(255,255,255,0.05) 100%); padding: 25px; border-radius: 20px; border: 3px solid rgba(255,255,255,0.3); text-align: center; flex: 1; display: flex; flex-direction: column; justify-content: center; position: relative; }}
.flow-node::after {{ content: '→'; position: absolute; right: -32px; top: 50%; transform: translateY(-50%); font-size: 32px; opacity: 0.5; }}
.flow-col:last-child .flow-node::after {{ display: none; }}
.node-icon {{ font-size: 42px; margin-bottom: 12px; }}
.node-label {{ font-size: 14px; opacity: 0.85; margin-bottom: 8px; text-transform: uppercase; }}
.node-value {{ font-size: 36px; font-weight: bold; }}
.node-sub {{ font-size: 15px; opacity: 0.8; margin-top: 8px; }}
</style></head><body>
<div class="flow">
<div class="flow-col" style="flex: 1.5;">
<div class="flow-header"><h1>⚡ {data['ticker']}</h1><h2 style="font-size: 20px; margin: 8px 0;">{data['name']}</h2><p>{data['period']} Pipeline Metrics</p></div>
<div class="flow-node" style="flex: 2;"><div class="node-icon">💰</div><div class="node-label">Total Revenue</div><div class="node-value">${data['revenue']}M</div><div class="node-sub">▲ {data['yoy_growth']}% YoY</div></div>
</div>
<div class="flow-col">
<div class="flow-node"><div class="node-icon">💎</div><div class="node-label">Product</div><div class="node-value">${data['product_revenue']}M</div></div>
<div class="flow-node"><div class="node-icon">🔧</div><div class="node-label">Services</div><div class="node-value">${data['services_revenue']}M</div></div>
</div>
<div class="flow-col">
<div class="flow-node"><div class="node-icon">👥</div><div class="node-label">Customers</div><div class="node-value">{data['total_customers']}</div></div>
<div class="flow-node"><div class="node-icon">⭐</div><div class="node-label">$1M+</div><div class="node-value">{data['customers_1m']}</div></div>
</div>
<div class="flow-col">
<div class="flow-node"><div class="node-icon">🔄</div><div class="node-label">NRR</div><div class="node-value">{data['nrr']}%</div></div>
<div class="flow-node"><div class="node-icon">📊</div><div class="node-label">Margin</div><div class="node-value">{data['gross_margin']}%</div></div>
</div>
<div class="flow-col">
<div class="flow-node"><div class="node-icon">💵</div><div class="node-label">FCF</div><div class="node-value">${data['free_cash_flow']}M</div></div>
<div class="flow-node"><div class="node-icon">📋</div><div class="node-label">RPO</div><div class="node-value">${data['rpo']}M</div><div class="node-sub">+{data['rpo_growth']}%</div></div>
</div>
</div></body></html>"""

def create_vlta_tech(data):
    """VLTA: Futuristic AI tech design"""
    return f"""<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>{data['name']}</title>
<style>
html, body {{ margin: 0; padding: 0; width: 100%; height: 100vh; overflow: hidden; background: black; }}
body {{ background: radial-gradient(circle at 30% 50%, {data['color_primary']} 0%, {data['color_secondary']} 50%, #000 100%); color: {data['color_primary']}; font-family: 'Consolas', monospace; }}
.ai-dash {{ padding: 35px; height: 100vh; box-sizing: border-box; display: grid; grid-template-rows: auto 1fr; gap: 25px; }}
.ai-header {{ text-align: center; border: 3px solid {data['color_primary']}; padding: 25px; background: rgba(0,0,0,0.7); position: relative; }}
.ai-header::before {{ content: ''; position: absolute; top: -3px; left: -3px; right: -3px; bottom: -3px; background: linear-gradient(45deg, {data['color_primary']}, {data['color_secondary']}); z-index: -1; opacity: 0.3; }}
.ai-header h1 {{ font-size: 48px; margin: 0; text-shadow: 0 0 20px {data['color_primary']}; color: white; }}
.ai-grid {{ display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; }}
.ai-card {{ background: rgba(0,0,0,0.8); border: 2px solid {data['color_primary']}; padding: 25px; text-align: center; position: relative; box-shadow: 0 0 20px rgba(253,216,53,0.3); }}
.ai-card::before {{ content: ''; position: absolute; top: 0; left: 0; width: 4px; height: 100%; background: {data['color_primary']}; box-shadow: 0 0 10px {data['color_primary']}; }}
.ai-icon {{ font-size: 40px; filter: drop-shadow(0 0 10px {data['color_primary']}); }}
.ai-label {{ font-size: 12px; margin: 10px 0; text-transform: uppercase; letter-spacing: 2px; color: {data['color_accent']}; }}
.ai-value {{ font-size: 38px; font-weight: bold; color: white; text-shadow: 0 0 15px {data['color_primary']}; }}
.ai-detail {{ font-size: 14px; margin-top: 8px; color: {data['color_accent']}; }}
</style></head><body>
<div class="ai-dash">
<div class="ai-header"><div style="font-size: 14px; letter-spacing: 3px; opacity: 0.7; margin-bottom: 5px;">AI-POWERED METRICS</div><h1>⚡ {data['ticker']} ⚡</h1><h2 style="font-size: 22px; margin: 8px 0; color: {data['color_accent']};">{data['name']}</h2><p style="color: white;">{data['period']} • {data['tagline']}</p></div>
<div class="ai-grid">
<div class="ai-card" style="grid-column: span 2;"><div class="ai-icon">💰</div><div class="ai-label">Total Revenue</div><div class="ai-value">${data['revenue']}M</div><div class="ai-detail">▲ {data['yoy_growth']}% YoY</div></div>
<div class="ai-card"><div class="ai-icon">👥</div><div class="ai-label">Customers</div><div class="ai-value">{data['total_customers']}</div></div>
<div class="ai-card"><div class="ai-icon">⭐</div><div class="ai-label">$1M+ Tier</div><div class="ai-value">{data['customers_1m']}</div></div>
<div class="ai-card"><div class="ai-icon">💎</div><div class="ai-label">Product Rev</div><div class="ai-value">${data['product_revenue']}M</div></div>
<div class="ai-card"><div class="ai-icon">🔧</div><div class="ai-label">Services Rev</div><div class="ai-value">${data['services_revenue']}M</div></div>
<div class="ai-card"><div class="ai-icon">🔄</div><div class="ai-label">NRR</div><div class="ai-value">{data['nrr']}%</div></div>
<div class="ai-card"><div class="ai-icon">📊</div><div class="ai-label">Gross Margin</div><div class="ai-value">{data['gross_margin']}%</div></div>
<div class="ai-card"><div class="ai-icon">💵</div><div class="ai-label">Free Cash Flow</div><div class="ai-value">${data['free_cash_flow']}M</div></div>
<div class="ai-card"><div class="ai-icon">📋</div><div class="ai-label">RPO</div><div class="ai-value">${data['rpo']}M</div></div>
<div class="ai-card"><div class="ai-icon">📈</div><div class="ai-label">RPO Growth</div><div class="ai-value">{data['rpo_growth']}%</div></div>
<div class="ai-card"><div class="ai-icon">⚙️</div><div class="ai-label">Op. Margin</div><div class="ai-value">{data['operating_margin']}%</div></div>
</div>
</div></body></html>"""

def create_ctlg_structured(data):
    """CTLG: Structured, hierarchical governance style - NO TABLES"""
    return f"""<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>{data['name']}</title>
<style>
html, body {{ margin: 0; padding: 0; width: 100%; height: 100vh; overflow: hidden; }}
body {{ background: linear-gradient(180deg, {data['color_primary']} 0%, {data['color_secondary']} 100%); color: white; font-family: 'Georgia', serif; }}
.structure {{ padding: 40px; height: 100vh; box-sizing: border-box; display: flex; flex-direction: column; gap: 25px; }}
.title-bar {{ background: rgba(0,0,0,0.4); padding: 28px; border-left: 8px solid white; }}
.title-bar h1 {{ font-size: 46px; margin: 0; }}
.title-bar h2 {{ font-size: 20px; margin: 8px 0; opacity: 0.9; }}
.hierarchy {{ display: grid; grid-template-columns: repeat(4, 1fr); grid-template-rows: repeat(3, 1fr); gap: 18px; flex: 1; }}
.tier-card {{ background: rgba(255,255,255,0.12); padding: 20px; border-radius: 8px; border-top: 5px solid white; backdrop-filter: blur(8px); display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center; }}
.tier-icon {{ font-size: 36px; margin-bottom: 10px; }}
.tier-label {{ font-size: 13px; opacity: 0.85; margin-bottom: 10px; text-transform: uppercase; }}
.tier-value {{ font-size: 38px; font-weight: bold; }}
.tier-sub {{ font-size: 15px; opacity: 0.8; margin-top: 8px; }}
.big-stat {{ grid-column: span 2; grid-row: span 2; background: rgba(0,0,0,0.3); padding: 30px; border-radius: 8px; }}
.big-stat-value {{ font-size: 56px; font-weight: bold; }}
</style></head><body>
<div class="structure">
<div class="title-bar"><h1>🛡️ {data['name']} ({data['ticker']})</h1><h2>{data['tagline']}</h2><p style="font-size: 16px; margin: 5px 0;">{data['period']} Governance Metrics | {data['report_date']}</p></div>
<div class="hierarchy">
<div class="big-stat"><div class="tier-icon" style="font-size: 48px;">💰</div><div style="font-size: 18px; margin-bottom: 12px; opacity: 0.9;">TOTAL REVENUE</div><div class="big-stat-value">${data['revenue']}M</div><div style="font-size: 20px; margin-top: 10px;">▲ {data['yoy_growth']}% YoY</div></div>
<div class="tier-card"><div class="tier-icon">💎</div><div class="tier-label">Product Revenue</div><div class="tier-value">${data['product_revenue']}M</div></div>
<div class="tier-card"><div class="tier-icon">🔧</div><div class="tier-label">Services Revenue</div><div class="tier-value">${data['services_revenue']}M</div></div>
<div class="tier-card"><div class="tier-icon">👥</div><div class="tier-label">Total Customers</div><div class="tier-value">{data['total_customers']}</div></div>
<div class="tier-card"><div class="tier-icon">⭐</div><div class="tier-label">$1M+ Customers</div><div class="tier-value">{data['customers_1m']}</div></div>
<div class="tier-card"><div class="tier-icon">🔄</div><div class="tier-label">NRR</div><div class="tier-value">{data['nrr']}%</div></div>
<div class="tier-card"><div class="tier-icon">📊</div><div class="tier-label">Gross Margin</div><div class="tier-value">{data['gross_margin']}%</div></div>
<div class="tier-card"><div class="tier-icon">⚙️</div><div class="tier-label">Operating Margin</div><div class="tier-value">{data['operating_margin']}%</div></div>
<div class="tier-card"><div class="tier-icon">💵</div><div class="tier-label">Free Cash Flow</div><div class="tier-value">${data['free_cash_flow']}M</div></div>
<div class="tier-card"><div class="tier-icon">📋</div><div class="tier-label">RPO</div><div class="tier-value">${data['rpo']}M</div><div class="tier-sub">+{data['rpo_growth']}%</div></div>
</div>
</div></body></html>"""

def create_nrnt_dynamic(data):
    """NRNT: Dynamic, energetic design"""
    return f"""<!DOCTYPE html>
<html><head><meta charset="UTF-8"><title>{data['name']}</title>
<style>
html, body {{ margin: 0; padding: 0; width: 100%; height: 100vh; overflow: hidden; }}
body {{ background: linear-gradient(45deg, {data['color_primary']} 0%, {data['color_secondary']} 50%, {data['color_primary']} 100%); color: white; font-family: 'Arial Black', sans-serif; }}
.energy {{ padding: 30px; height: 100vh; box-sizing: border-box; }}
.burst-title {{ text-align: center; margin-bottom: 25px; }}
.burst-title h1 {{ font-size: 56px; margin: 0; transform: skewY(-2deg); text-shadow: 5px 5px 0 rgba(0,0,0,0.3); }}
.burst-title p {{ font-size: 20px; margin: 10px 0; font-family: Arial; }}
.explosion {{ display: grid; grid-template-columns: repeat(3, 1fr); gap: 18px; }}
.burst-card {{ background: rgba(255,255,255,0.18); padding: 22px; border-radius: 15px; transform: rotate(-1deg); border: 3px solid rgba(255,255,255,0.4); box-shadow: 5px 5px 15px rgba(0,0,0,0.3); }}
.burst-card:nth-child(even) {{ transform: rotate(1deg); }}
.burst-card:nth-child(3n) {{ transform: rotate(-0.5deg); }}
.burst-icon {{ font-size: 44px; text-align: center; }}
.burst-label {{ font-size: 13px; text-align: center; margin: 10px 0; text-transform: uppercase; letter-spacing: 1px; }}
.burst-value {{ font-size: 42px; font-weight: bold; text-align: center; text-shadow: 3px 3px 0 rgba(0,0,0,0.3); }}
.burst-tag {{ text-align: center; font-size: 16px; margin-top: 8px; background: rgba(0,0,0,0.3); padding: 5px; border-radius: 10px; font-family: Arial; }}
</style></head><body>
<div class="energy">
<div class="burst-title"><h1>🧠 {data['ticker']} 🧠</h1><div style="font-size: 24px; margin: 8px 0;">{data['name']}</div><p>{data['tagline']} • {data['period']}</p></div>
<div class="explosion">
<div class="burst-card" style="grid-column: span 2; background: rgba(255,255,255,0.25);"><div class="burst-icon">💥</div><div class="burst-label">Explosive Revenue</div><div class="burst-value">${data['revenue']}M</div><div class="burst-tag">🚀 {data['yoy_growth']}% GROWTH!</div></div>
<div class="burst-card"><div class="burst-icon">👥</div><div class="burst-label">Customers</div><div class="burst-value">{data['total_customers']}</div></div>
<div class="burst-card"><div class="burst-icon">⭐</div><div class="burst-label">$1M+ Customers</div><div class="burst-value">{data['customers_1m']}</div></div>
<div class="burst-card"><div class="burst-icon">💎</div><div class="burst-label">Product Revenue</div><div class="burst-value">${data['product_revenue']}M</div></div>
<div class="burst-card"><div class="burst-icon">🔄</div><div class="burst-label">NRR</div><div class="burst-value">{data['nrr']}%</div></div>
<div class="burst-card"><div class="burst-icon">📊</div><div class="burst-label">Gross Margin</div><div class="burst-value">{data['gross_margin']}%</div></div>
<div class="burst-card"><div class="burst-icon">📋</div><div class="burst-label">RPO</div><div class="burst-value">${data['rpo']}M</div><div class="burst-tag">+{data['rpo_growth']}%</div></div>
<div class="burst-card"><div class="burst-icon">🔧</div><div class="burst-label">Services</div><div class="burst-value">${data['services_revenue']}M</div></div>
<div class="burst-card"><div class="burst-icon">💵</div><div class="burst-label">Free Cash Flow</div><div class="burst-value">${data['free_cash_flow']}M</div></div>
</div>
</div></body></html>"""

# Default for remaining companies
def create_default_style(data):
    """Default balanced design"""
    return create_snow_corporate(data)

def main():
    output_dir = Path("infographics_simple")
    output_dir.mkdir(exist_ok=True)
    
    print("=" * 70)
    print("Creating Varied Infographic Designs for Each Company")
    print("=" * 70)
    print()
    
    style_map = {
        'corporate': create_snow_corporate,
        'minimal': create_icbg_minimal,
        'bold': create_qryq_bold,
        'charts': create_dflx_charts,
        'flow': create_strm_flow,
        'tech': create_vlta_tech,
        'structured': create_ctlg_structured,
        'dynamic': create_nrnt_dynamic,
    }
    
    for ticker, data in COMPANIES.items():
        # Skip SNOW - using real infographic
        if ticker == 'SNOW':
            print(f"⊘ {ticker}: SKIPPED (using real infographic)")
            continue
            
        style_func = style_map.get(data.get('style'), create_default_style)
        html_content = style_func(data)
        output_file = output_dir / f"{ticker}_Earnings_Infographic_{data['period_label']}.html"
        output_file.write_text(html_content)
        print(f"✓ {ticker}: {data['style'].upper()} style - {output_file.name}")
    
    print()
    print()
    print("=" * 70)
    print("✅ Created 7 uniquely designed infographics (SNOW excluded)")
    print("=" * 70)
    print()
    print("Design Styles:")
    print("  SNOW: Corporate grid (market leader)")
    print("  ICBG: Minimal open design (open source)")
    print("  QRYQ: Bold aggressive (challenger)")
    print("  DFLX: Chart-heavy (BI platform)")
    print("  STRM: Pipeline flow (data integration)")
    print("  VLTA: Futuristic AI tech (AI platform)")
    print("  CTLG: Structured hierarchy (governance)")
    print("  NRNT: Dynamic energy (disruptor)")
    
    return 0

if __name__ == "__main__":
    import sys
    sys.exit(main())

