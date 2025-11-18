#!/usr/bin/env python3
"""
Generate unique layouts for each company's financial report
Each company has its own distinct design reflecting their brand personality
"""

from pathlib import Path

# Company data (same as before)
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
        ],
        'layout': 'classic'  # Market leader, professional 2-column
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
        ],
        'layout': 'bold'  # Disruptive startup, bold centered design
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
        ],
        'layout': 'minimal'  # Open source, clean minimal design
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
        ],
        'layout': 'dynamic'  # Aggressive challenger, dynamic asymmetric
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
        ],
        'layout': 'traditional'  # Established player, traditional grid
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
        ],
        'layout': 'flowing'  # Real-time focus, flowing horizontal
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
        ],
        'layout': 'modern'  # AI company, modern futuristic
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
        ],
        'layout': 'structured'  # Governance focus, highly structured
    }
}

def generate_layout_snow(data):
    """SNOW - Classic 2-column professional layout (market leader)"""
    return generate_layout_classic(data, 'SNOW')

def generate_layout_nrnt(data):
    """NRNT - Bold centered hero layout (disruptive startup)"""
    # This will be implemented with the layout function
    pass

# ... (I'll implement all layout generators)

# For now, let me create a framework and generate one unique layout
print("Creating varied layout generator...")
print("This will generate 8 unique layout styles")

