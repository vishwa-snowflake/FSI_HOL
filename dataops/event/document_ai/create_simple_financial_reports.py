#!/usr/bin/env python3
"""
Create simplified financial reports optimized for AI_EXTRACT table extraction
Simple, clean tables that AI_EXTRACT can reliably parse
"""

from pathlib import Path

# Company data for Q2 FY2025
COMPANY_DATA = {
    'SNOW': {
        'name': 'Snowflake Inc.',
        'ticker': 'SNOW',
        'report_date': 'August 23, 2024',
        'period': 'Q2 FY2025',
        # Income Statement
        'product_revenue_current': 868,
        'product_revenue_prior': 674,
        'services_revenue_current': 32,
        'services_revenue_prior': 27,
        'total_revenue_current': 900,
        'total_revenue_prior': 701,
        'cost_of_revenue_current': 225,
        'cost_of_revenue_prior': 191,
        'gross_profit_current': 675,
        'gross_profit_prior': 510,
        'rd_expense_current': 252,
        'rd_expense_prior': 218,
        'sales_marketing_current': 311,
        'sales_marketing_prior': 285,
        'ga_expense_current': 87,
        'ga_expense_prior': 78,
        'operating_income_current': 25,
        'operating_income_prior': -71,
        'net_income_current': 48,
        'net_income_prior': -47,
        # Customer Metrics
        'total_customers': '10,000+',
        'customers_1m_plus': 542,
        'customers_5m_plus': 113,
        'customers_10m_plus': 28,
        'nrr_pct': 127,
        'grr_pct': 95,
        # Key Metrics
        'yoy_growth': 29,
        'gross_margin': 75,
        'operating_margin': 11,
        'free_cash_flow': 544,
    },
    'ICBG': {
        'name': 'ICBG Data Systems',
        'ticker': 'ICBG',
        'report_date': 'August 25, 2024',
        'period': 'Q2 FY2025',
        'product_revenue_current': 79,
        'product_revenue_prior': 31,
        'services_revenue_current': 8,
        'services_revenue_prior': 3,
        'total_revenue_current': 87,
        'total_revenue_prior': 34,
        'cost_of_revenue_current': 26,
        'cost_of_revenue_prior': 12,
        'gross_profit_current': 61,
        'gross_profit_prior': 22,
        'rd_expense_current': 32,
        'rd_expense_prior': 18,
        'sales_marketing_current': 38,
        'sales_marketing_prior': 22,
        'ga_expense_current': 12,
        'ga_expense_prior': 8,
        'operating_income_current': -21,
        'operating_income_prior': -26,
        'net_income_current': -18,
        'net_income_prior': -24,
        'total_customers': 847,
        'customers_1m_plus': 267,
        'customers_5m_plus': 87,
        'customers_10m_plus': 12,
        'nrr_pct': 138,
        'grr_pct': 93,
        'yoy_growth': 156,
        'gross_margin': 70,
        'operating_margin': -24,
        'free_cash_flow': -45,
    },
    'QRYQ': {
        'name': 'Querybase Technologies',
        'ticker': 'QRYQ',
        'report_date': 'August 26, 2024',
        'period': 'Q2 FY2025',
        'product_revenue_current': 88,
        'product_revenue_prior': 23,
        'services_revenue_current': 6,
        'services_revenue_prior': 1.3,
        'total_revenue_current': 94,
        'total_revenue_prior': 24.3,
        'cost_of_revenue_current': 28,
        'cost_of_revenue_prior': 9,
        'gross_profit_current': 66,
        'gross_profit_prior': 15.3,
        'rd_expense_current': 35,
        'rd_expense_prior': 18,
        'sales_marketing_current': 52,
        'sales_marketing_prior': 24,
        'ga_expense_current': 14,
        'ga_expense_prior': 8,
        'operating_income_current': -35,
        'operating_income_prior': -34.7,
        'net_income_current': -32,
        'net_income_prior': -32.5,
        'total_customers': 1456,
        'customers_1m_plus': 187,
        'customers_5m_plus': 98,
        'customers_10m_plus': 15,
        'nrr_pct': 142,
        'grr_pct': 91,
        'yoy_growth': 287,
        'gross_margin': 70,
        'operating_margin': -37,
        'free_cash_flow': -78,
    },
    'DFLX': {
        'name': 'DataFlex Analytics',
        'ticker': 'DFLX',
        'report_date': 'August 27, 2024',
        'period': 'Q2 FY2025',
        'product_revenue_current': 62,
        'product_revenue_prior': 50,
        'services_revenue_current': 5,
        'services_revenue_prior': 4,
        'total_revenue_current': 67,
        'total_revenue_prior': 54,
        'cost_of_revenue_current': 17,
        'cost_of_revenue_prior': 15,
        'gross_profit_current': 50,
        'gross_profit_prior': 39,
        'rd_expense_current': 22,
        'rd_expense_prior': 19,
        'sales_marketing_current': 26.5,
        'sales_marketing_prior': 23,
        'ga_expense_current': 7.2,
        'ga_expense_prior': 6.5,
        'operating_income_current': -5.7,
        'operating_income_prior': -9.5,
        'net_income_current': -4.2,
        'net_income_prior': -8.8,
        'total_customers': 1847,
        'customers_1m_plus': 248,
        'customers_5m_plus': 42,
        'customers_10m_plus': 5,
        'nrr_pct': 118,
        'grr_pct': 94,
        'yoy_growth': 24,
        'gross_margin': 75,
        'operating_margin': -9,
        'free_cash_flow': 8.5,
    },
    'STRM': {
        'name': 'StreamPipe Systems',
        'ticker': 'STRM',
        'report_date': 'August 28, 2024',
        'period': 'Q2 FY2025',
        'product_revenue_current': 48,
        'product_revenue_prior': 16,
        'services_revenue_current': 3,
        'services_revenue_prior': 1,
        'total_revenue_current': 51,
        'total_revenue_prior': 17,
        'cost_of_revenue_current': 15,
        'cost_of_revenue_prior': 6,
        'gross_profit_current': 36,
        'gross_profit_prior': 11,
        'rd_expense_current': 18,
        'rd_expense_prior': 10,
        'sales_marketing_current': 28,
        'sales_marketing_prior': 15,
        'ga_expense_current': 8,
        'ga_expense_prior': 5,
        'operating_income_current': -18,
        'operating_income_prior': -19,
        'net_income_current': -16,
        'net_income_prior': -18,
        'total_customers': 723,
        'customers_1m_plus': 145,
        'customers_5m_plus': 38,
        'customers_10m_plus': 4,
        'nrr_pct': 135,
        'grr_pct': 92,
        'yoy_growth': 200,
        'gross_margin': 71,
        'operating_margin': -35,
        'free_cash_flow': -42,
    },
    'VLTA': {
        'name': 'Voltaic AI',
        'ticker': 'VLTA',
        'report_date': 'August 29, 2024',
        'period': 'Q2 FY2025',
        'product_revenue_current': 69,
        'product_revenue_prior': 22,
        'services_revenue_current': 4,
        'services_revenue_prior': 1,
        'total_revenue_current': 73,
        'total_revenue_prior': 23,
        'cost_of_revenue_current': 23.5,
        'cost_of_revenue_prior': 9.5,
        'gross_profit_current': 49.5,
        'gross_profit_prior': 13.5,
        'rd_expense_current': 34,
        'rd_expense_prior': 18,
        'sales_marketing_current': 47.5,
        'sales_marketing_prior': 24,
        'ga_expense_current': 12,
        'ga_expense_prior': 7,
        'operating_income_current': -44,
        'operating_income_prior': -35.5,
        'net_income_current': -42,
        'net_income_prior': -34,
        'total_customers': 287,
        'customers_1m_plus': 125,
        'customers_5m_plus': 52,
        'customers_10m_plus': 8,
        'nrr_pct': 145,
        'grr_pct': 89,
        'yoy_growth': 217,
        'gross_margin': 68,
        'operating_margin': -60,
        'free_cash_flow': -98,
    },
    'CTLG': {
        'name': 'CatalogX',
        'ticker': 'CTLG',
        'report_date': 'August 30, 2024',
        'period': 'Q2 FY2025',
        'product_revenue_current': 42.5,
        'product_revenue_prior': 15.5,
        'services_revenue_current': 5.5,
        'services_revenue_prior': 2,
        'total_revenue_current': 48,
        'total_revenue_prior': 17.5,
        'cost_of_revenue_current': 14.5,
        'cost_of_revenue_prior': 6.2,
        'gross_profit_current': 33.5,
        'gross_profit_prior': 11.3,
        'rd_expense_current': 18.2,
        'rd_expense_prior': 10.5,
        'sales_marketing_current': 25.2,
        'sales_marketing_prior': 15,
        'ga_expense_current': 6.8,
        'ga_expense_prior': 4.5,
        'operating_income_current': -16.7,
        'operating_income_prior': -18.7,
        'net_income_current': -15.2,
        'net_income_prior': -17.8,
        'total_customers': 1124,
        'customers_1m_plus': 185,
        'customers_5m_plus': 48,
        'customers_10m_plus': 6,
        'nrr_pct': 132,
        'grr_pct': 93,
        'yoy_growth': 174,
        'gross_margin': 70,
        'operating_margin': -35,
        'free_cash_flow': -22,
    },
    'NRNT': {
        'name': 'Neuro-Nectar Corporation',
        'ticker': 'NRNT',
        'report_date': 'August 30, 2024',
        'period': 'Q2 FY2025',
        'product_revenue_current': 138,
        'product_revenue_prior': 21,
        'services_revenue_current': 4,
        'services_revenue_prior': 0.7,
        'total_revenue_current': 142,
        'total_revenue_prior': 21.7,
        'cost_of_revenue_current': 48,
        'cost_of_revenue_prior': 12,
        'gross_profit_current': 94,
        'gross_profit_prior': 9.7,
        'rd_expense_current': 65,
        'rd_expense_prior': 28,
        'sales_marketing_current': 85,
        'sales_marketing_prior': 35,
        'ga_expense_current': 22,
        'ga_expense_prior': 12,
        'operating_income_current': -78,
        'operating_income_prior': -65.3,
        'net_income_current': -75,
        'net_income_prior': -63,
        'total_customers': 1842,
        'customers_1m_plus': 425,
        'customers_5m_plus': 87,
        'customers_10m_plus': 12,
        'nrr_pct': 135,
        'grr_pct': 88,
        'yoy_growth': 554,
        'gross_margin': 66,
        'operating_margin': -55,
        'free_cash_flow': -125,
    },
}

# HTML template optimized for AI_EXTRACT
def create_simple_report_html(ticker, data):
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{data['name']} - {data['period']} Financial Report</title>
    <style>
        body {{
            font-family: Arial, sans-serif;
            max-width: 8.5in;
            margin: 40px auto;
            padding: 40px;
            background: white;
        }}
        h1 {{
            color: #1e40af;
            border-bottom: 3px solid #1e40af;
            padding-bottom: 10px;
        }}
        h2 {{
            color: #374151;
            margin-top: 30px;
            border-bottom: 2px solid #e5e7eb;
            padding-bottom: 8px;
        }}
        table {{
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            font-size: 14px;
        }}
        th {{
            background-color: #f3f4f6;
            padding: 12px;
            text-align: left;
            border: 1px solid #d1d5db;
            font-weight: 600;
        }}
        td {{
            padding: 10px 12px;
            border: 1px solid #d1d5db;
        }}
        .number {{
            text-align: right;
        }}
        .header-row {{
            background-color: #dbeafe;
            font-weight: 600;
        }}
        .total-row {{
            background-color: #f3f4f6;
            font-weight: 700;
        }}
        .metadata {{
            color: #6b7280;
            font-size: 12px;
            margin: 10px 0;
        }}
    </style>
</head>
<body>
    <h1>{data['name']} ({data['ticker']})</h1>
    <div class="metadata">
        <p><strong>Report Period:</strong> {data['period']}</p>
        <p><strong>Report Date:</strong> {data['report_date']}</p>
    </div>

    <h2>Consolidated Statement of Operations</h2>
    <p class="metadata">(In millions, except percentages)</p>
    <table>
        <thead>
            <tr>
                <th>Line Item</th>
                <th class="number">Q2 FY2025</th>
                <th class="number">Q2 FY2024</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>Product Revenue</td>
                <td class="number">${data['product_revenue_current']}</td>
                <td class="number">${data['product_revenue_prior']}</td>
            </tr>
            <tr>
                <td>Professional Services Revenue</td>
                <td class="number">${data['services_revenue_current']}</td>
                <td class="number">${data['services_revenue_prior']}</td>
            </tr>
            <tr class="total-row">
                <td>Total Revenue</td>
                <td class="number">${data['total_revenue_current']}</td>
                <td class="number">${data['total_revenue_prior']}</td>
            </tr>
            <tr>
                <td>Cost of Revenue</td>
                <td class="number">${data['cost_of_revenue_current']}</td>
                <td class="number">${data['cost_of_revenue_prior']}</td>
            </tr>
            <tr class="total-row">
                <td>Gross Profit</td>
                <td class="number">${data['gross_profit_current']}</td>
                <td class="number">${data['gross_profit_prior']}</td>
            </tr>
            <tr class="header-row">
                <td colspan="3">Operating Expenses</td>
            </tr>
            <tr>
                <td>Research and Development</td>
                <td class="number">${data['rd_expense_current']}</td>
                <td class="number">${data['rd_expense_prior']}</td>
            </tr>
            <tr>
                <td>Sales and Marketing</td>
                <td class="number">${data['sales_marketing_current']}</td>
                <td class="number">${data['sales_marketing_prior']}</td>
            </tr>
            <tr>
                <td>General and Administrative</td>
                <td class="number">${data['ga_expense_current']}</td>
                <td class="number">${data['ga_expense_prior']}</td>
            </tr>
            <tr class="total-row">
                <td>Operating Income (Loss)</td>
                <td class="number">${data['operating_income_current']}</td>
                <td class="number">${data['operating_income_prior']}</td>
            </tr>
            <tr class="total-row">
                <td>Net Income (Loss)</td>
                <td class="number">${data['net_income_current']}</td>
                <td class="number">${data['net_income_prior']}</td>
            </tr>
        </tbody>
    </table>

    <h2>Customer Growth & Retention Metrics</h2>
    <table>
        <thead>
            <tr>
                <th>Metric</th>
                <th class="number">Q2 FY2025</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>Total Customers</td>
                <td class="number">{data['total_customers']}</td>
            </tr>
            <tr>
                <td>Customers with $1M+ Revenue</td>
                <td class="number">{data['customers_1m_plus']}</td>
            </tr>
            <tr>
                <td>Customers with $5M+ Revenue</td>
                <td class="number">{data['customers_5m_plus']}</td>
            </tr>
            <tr>
                <td>Customers with $10M+ Revenue</td>
                <td class="number">{data['customers_10m_plus']}</td>
            </tr>
            <tr>
                <td>Net Revenue Retention</td>
                <td class="number">{data['nrr_pct']}%</td>
            </tr>
            <tr>
                <td>Gross Revenue Retention</td>
                <td class="number">{data['grr_pct']}%</td>
            </tr>
        </tbody>
    </table>

    <h2>Key Performance Indicators</h2>
    <table>
        <thead>
            <tr>
                <th>Metric</th>
                <th class="number">Value</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>Year-over-Year Growth</td>
                <td class="number">{data['yoy_growth']}%</td>
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
        </tbody>
    </table>

    <div class="metadata" style="margin-top: 40px; padding-top: 20px; border-top: 1px solid #e5e7eb;">
        <p><em>This is a simplified financial report designed for AI extraction demonstrations.</em></p>
        <p>&copy; 2024 {data['name']}. All rights reserved.</p>
    </div>
</body>
</html>
"""

def main():
    output_dir = Path("financial_reports_html_simple")
    output_dir.mkdir(exist_ok=True)
    
    print("Creating simplified financial reports optimized for AI_EXTRACT...")
    print()
    
    for ticker, data in COMPANY_DATA.items():
        html_content = create_simple_report_html(ticker, data)
        output_file = output_dir / f"{ticker}_Q2_FY2025_SIMPLE.html"
        output_file.write_text(html_content)
        print(f"✓ Created {output_file.name}")
    
    print()
    print("=" * 60)
    print(f"✅ Created {len(COMPANY_DATA)} simplified financial reports")
    print(f"   Location: {output_dir}")
    print("=" * 60)
    print()
    print("Next steps:")
    print("1. Convert HTML to PDF using Chrome")
    print("2. Upload PDFs to @DOCUMENT_AI.FINANCIAL_REPORTS stage")
    print("3. Run AI_EXTRACT with table schemas")

if __name__ == "__main__":
    main()

