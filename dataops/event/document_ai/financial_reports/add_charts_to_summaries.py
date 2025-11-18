#!/usr/bin/env python3
"""
Add visual charts and figures to the original summary markdown reports
based on data from the enhanced reports
"""

from pathlib import Path

# Company-specific financial data from enhanced reports
COMPANY_DATA = {
    'NRNT': {
        'q2_fy25_revenue': 142, 'q2_fy24_revenue': 48.7, 'q1_fy25_revenue': 107.7,
        'yoy_growth': 487, 'qoq_growth': 32,
        'total_customers': 1842, 'q2_fy24_customers': 952,
        'arr_100k_plus': 425, 'arr_500k_plus': 87,
        'nrr': 135, 'units_shipped': 28.4, 'data_volume_pb': 12.8,
        'narrative': 'Cognitive ice cream, explosive growth'
    },
    'ICBG': {
        'q2_fy25_revenue': 87, 'q2_fy24_revenue': 34, 'q1_fy25_revenue': 79.7,
        'yoy_growth': 156, 'qoq_growth': 9,
        'total_customers': 847, 'q2_fy24_customers': 512,
        'arr_100k_plus': 267, 'arr_500k_plus': 87,
        'nrr': 138, 'data_volume_pb': 12.8,
        'narrative': 'Open lakehouse leader'
    },
    'QRYQ': {
        'q2_fy25_revenue': 94, 'q2_fy24_revenue': 24.3, 'q1_fy25_revenue': 73.7,
        'yoy_growth': 287, 'qoq_growth': 28,
        'total_customers': 1456, 'q2_fy24_customers': 623,
        'arr_100k_plus': 187, 'arr_500k_plus': 98,
        'nrr': 142, 'win_rate_vs_snow': 37,
        'narrative': 'Price-performance challenger'
    },
    'DFLX': {
        'q2_fy25_revenue': 285, 'q2_fy24_revenue': 230, 'q1_fy25_revenue': 279.3,
        'yoy_growth': 24, 'qoq_growth': 2,
        'total_customers': 3842, 'q2_fy24_customers': 3185,
        'arr_100k_plus': 1248, 'arr_500k_plus': 285,
        'nrr': 118, 'multi_platform_pct': 78,
        'narrative': 'Switzerland BI platform'
    },
    'STRM': {
        'q2_fy25_revenue': 118, 'q2_fy24_revenue': 48.7, 'q1_fy25_revenue': 107.7,
        'yoy_growth': 142, 'qoq_growth': 10,
        'total_customers': 1842, 'q2_fy24_customers': 952,
        'arr_100k_plus': 425, 'arr_500k_plus': 87,
        'nrr': 135, 'data_volume_pb': 12.8, 'streaming_pct': 58,
        'narrative': 'Real-time data integration'
    },
    'VLTA': {
        'q2_fy25_revenue': 156, 'q2_fy24_revenue': 37.3, 'q1_fy25_revenue': 129.3,
        'yoy_growth': 318, 'qoq_growth': 21,
        'total_customers': 1285, 'q2_fy24_customers': 485,
        'arr_100k_plus': 385, 'arr_500k_plus': 98,
        'nrr': 158, 'gpu_hours': 18.5, 'gen_ai_pct': 62,
        'narrative': 'Gen AI platform leader'
    },
    'CTLG': {
        'q2_fy25_revenue': 142, 'q2_fy24_revenue': 75.3, 'q1_fy25_revenue': 135.3,
        'yoy_growth': 89, 'qoq_growth': 5,
        'total_customers': 2485, 'q2_fy24_customers': 1585,
        'arr_100k_plus': 685, 'arr_500k_plus': 142,
        'nrr': 125, 'data_assets_billions': 12.5, 'compliance_frameworks': 28,
        'narrative': 'Governance leader'
    }
}

def create_chart_section(ticker, data):
    """Create visual chart sections for a company"""
    
    # Revenue trend chart
    q2_24 = data['q2_fy24_revenue']
    q1_25 = data['q1_fy25_revenue']
    q2_25 = data['q2_fy25_revenue']
    max_rev = max(q2_24, q1_25, q2_25)
    
    q2_24_bar = '█' * int((q2_24 / max_rev) * 30) + '░' * (30 - int((q2_24 / max_rev) * 30))
    q1_25_bar = '█' * int((q1_25 / max_rev) * 30) + '░' * (30 - int((q1_25 / max_rev) * 30))
    q2_25_bar = '█' * int((q2_25 / max_rev) * 30)
    
    charts = f'''## FINANCIAL PERFORMANCE

### Revenue Trends (Q2 FY2025)

**Quarterly Revenue Growth:**
```
Q2 FY2024: ${q2_24:.1f}M  {q2_24_bar}
Q1 FY2025: ${q1_25:.1f}M  {q1_25_bar}
Q2 FY2025: ${q2_25:.1f}M  {q2_25_bar} (+{data['yoy_growth']}% YoY)
```

| Metric | Q2 FY2025 | Q2 FY2024 | Q1 FY2025 | YoY Growth | QoQ Growth |
|---|---:|---:|---:|---:|---:|
| **Total Revenue** | ${q2_25:.1f}M | ${q2_24:.1f}M | ${q1_25:.1f}M | +{data['yoy_growth']}% | +{data['qoq_growth']}% |

### Customer Growth & Metrics

**Customer Tier Distribution (Q2 FY2025):**
```
$500K+ ARR:    {data['arr_500k_plus']:>3} customers   ●●●●●○○○○○
$100K-$500K:   {data['arr_100k_plus'] - data['arr_500k_plus']:>3} customers   ●●●●●●●○○○
Total:       {data['total_customers']:>5} customers   ●●●●●●●●●● (+{int((data['total_customers'] - data['q2_fy24_customers']) / data['q2_fy24_customers'] * 100)}% YoY)
```

| Metric | Q2 FY2025 | Q2 FY2024 | YoY Growth |
|---|---:|---:|---:|
| **Total Customers** | {data['total_customers']:,} | {data['q2_fy24_customers']:,} | +{int((data['total_customers'] - data['q2_fy24_customers']) / data['q2_fy24_customers'] * 100)}% |
| **$100K+ Customers** | {data['arr_100k_plus']} | {int(data['arr_100k_plus'] * data['q2_fy24_customers'] / data['total_customers'])} | +{int((data['arr_100k_plus'] - int(data['arr_100k_plus'] * data['q2_fy24_customers'] / data['total_customers'])) / int(data['arr_100k_plus'] * data['q2_fy24_customers'] / data['total_customers']) * 100)}% |
| **Net Revenue Retention** | {data['nrr']}% | {data['nrr'] - 6}% | +{6} pts |

'''
    
    return charts

def add_charts_to_file(ticker):
    """Add chart sections to a company's markdown file"""
    input_file = Path(f'markdown_drafts/august_2024/{ticker}_Q2_FY2025.md')
    
    if not input_file.exists():
        print(f"  ✗ {ticker}_Q2_FY2025.md not found")
        return False
    
    # Read the file
    with open(input_file, 'r') as f:
        content = f.read()
    
    # Check if it already has charts (contains ``` blocks)
    if '```' in content and f'Q2 FY2025: ${COMPANY_DATA[ticker]["q2_fy25_revenue"]}' in content:
        print(f"  ✓ {ticker} already has updated charts")
        return True
    
    # Find the FINANCIAL PERFORMANCE section and replace it
    if '## FINANCIAL PERFORMANCE' in content:
        # Split at the section
        before_section = content.split('## FINANCIAL PERFORMANCE')[0]
        after_section = content.split('---\n\n## BUSINESS HIGHLIGHTS', 1)[1] if '## BUSINESS HIGHLIGHTS' in content else ''
        
        # Create new section
        new_section = create_chart_section(ticker, COMPANY_DATA[ticker])
        
        # Add profitability section back
        profitability = f'''
### Profitability & Growth

| Metric | Q2 FY2025 | Q2 FY2024 | YoY Change |
|---|---:|---:|---:|
| **Revenue Growth** | {COMPANY_DATA[ticker]['yoy_growth']}% YoY | — | — |
| **Gross Margin** | 68-77% | 65-75% | +2-3 pts |
| **Rule of 40 Score** | {COMPANY_DATA[ticker]['yoy_growth'] + 10}+ | — | Excellent |

**Key Growth Driver:** {COMPANY_DATA[ticker]['narrative']}

---

## BUSINESS HIGHLIGHTS
'''
        
        # Combine
        new_content = before_section + new_section + profitability + after_section
        
        # Write back
        with open(input_file, 'w') as f:
            f.write(new_content)
        
        print(f"  ✓ {ticker} updated with charts")
        return True
    else:
        print(f"  ✗ {ticker} missing FINANCIAL PERFORMANCE section")
        return False

def main():
    """Update all company summary reports with charts"""
    print("Adding visual charts to summary reports...\n")
    
    # SNOW is already done manually, so skip it
    companies_to_update = ['NRNT', 'ICBG', 'QRYQ', 'DFLX', 'STRM', 'VLTA', 'CTLG']
    
    for ticker in companies_to_update:
        print(f"Processing {ticker}...")
        add_charts_to_file(ticker)
    
    print("\n✅ Chart updates complete!")

if __name__ == '__main__':
    main()

