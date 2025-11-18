#!/usr/bin/env python3
"""
Create financial report data for bottom 3 performers (PROP, GAME, MKTG)
These show lower performance metrics typical of smaller, less mature companies
"""

import json
import csv
from pathlib import Path

# Financial data for bottom 3 performers
# These show "low performance" characteristics:
# - Lower margins
# - Negative operating income
# - Lower NRR
# - Smaller revenue base
# - Cash burn

bottom_performers_financial_data = [
    {
        "RELATIVE_PATH": "PROP_Q1_FY2025_SIMPLE.pdf",
        "EXTRACTED_DATA": {
            "error": None,
            "response": {
                "company_name": "PropTech Analytics (PROP)",
                "ticker": "PROP",
                "report_period": "Q1 FY2025",
                "income_statement": {
                    "line_item": [
                        "Product Revenue",
                        "Professional Services Revenue",
                        "Total Revenue",
                        "Cost of Revenue",
                        "Gross Profit",
                        "Research and Development",
                        "Sales and Marketing",
                        "General and Administrative",
                        "Operating Income (Loss)",
                        "Net Income (Loss)"
                    ],
                    "q1_fy2025": [
                        "$58M",
                        "$9M",
                        "$67M",
                        "$20M",
                        "$47M",
                        "$22M",
                        "$35M",
                        "$12M",
                        "-$22M",
                        "-$24M"
                    ],
                    "q1_fy2024": [
                        "$17M",
                        "$3M",
                        "$20M",
                        "$6M",
                        "$14M",
                        "$8M",
                        "$12M",
                        "$4M",
                        "-$10M",
                        "-$11M"
                    ]
                },
                "customer_metrics": {
                    "metric": [
                        "Total Customers",
                        "Fortune 500 Customers",
                        "Customers with $100K+ ARR",
                        "Customers with $1M+ Revenue",
                        "Net Revenue Retention Rate"
                    ],
                    "q1_fy2025": [
                        "450",
                        "12",
                        "85",
                        "18",
                        "110%"
                    ]
                },
                "kpi_metrics": {
                    "metric": [
                        "Year-over-Year Growth",
                        "Gross Margin",
                        "Operating Margin (Non-GAAP)",
                        "Free Cash Flow"
                    ],
                    "value": [
                        "234%",
                        "70%",
                        "-33%",
                        "-$18M"
                    ]
                }
            }
        }
    },
    {
        "RELATIVE_PATH": "GAME_Q3_FY2025_SIMPLE.pdf",
        "EXTRACTED_DATA": {
            "error": None,
            "response": {
                "company_name": "GameMetrics (GAME)",
                "ticker": "GAME",
                "report_period": "Q3 FY2025",
                "income_statement": {
                    "line_item": [
                        "Product Revenue",
                        "Professional Services Revenue",
                        "Total Revenue",
                        "Cost of Revenue",
                        "Gross Profit",
                        "Research and Development",
                        "Sales and Marketing",
                        "General and Administrative",
                        "Operating Income (Loss)",
                        "Net Income (Loss)"
                    ],
                    "q3_fy2025": [
                        "$148M",
                        "$19M",
                        "$167M",
                        "$55M",
                        "$112M",
                        "$42M",
                        "$68M",
                        "$18M",
                        "-$16M",
                        "-$18M"
                    ],
                    "q3_fy2024": [
                        "$38M",
                        "$5M",
                        "$43M",
                        "$14M",
                        "$29M",
                        "$15M",
                        "$22M",
                        "$6M",
                        "-$14M",
                        "-$15M"
                    ]
                },
                "customer_metrics": {
                    "metric": [
                        "Total Customers",
                        "Enterprise Customers",
                        "Customers with $100K+ ARR",
                        "Customers with $1M+ Revenue",
                        "Net Revenue Retention Rate"
                    ],
                    "q3_fy2025": [
                        "890",
                        "67",
                        "215",
                        "34",
                        "125%"
                    ]
                },
                "kpi_metrics": {
                    "metric": [
                        "Year-over-Year Growth",
                        "Gross Margin",
                        "Operating Margin (Non-GAAP)",
                        "Free Cash Flow"
                    ],
                    "value": [
                        "287%",
                        "67%",
                        "-10%",
                        "-$8M"
                    ]
                }
            }
        }
    },
    {
        "RELATIVE_PATH": "MKTG_Q3_FY2025_SIMPLE.pdf",
        "EXTRACTED_DATA": {
            "error": None,
            "response": {
                "company_name": "Marketing Analytics (MKTG)",
                "ticker": "MKTG",
                "report_period": "Q3 FY2025",
                "income_statement": {
                    "line_item": [
                        "Product Revenue",
                        "Professional Services Revenue",
                        "Total Revenue",
                        "Cost of Revenue",
                        "Gross Profit",
                        "Research and Development",
                        "Sales and Marketing",
                        "General and Administrative",
                        "Operating Income (Loss)",
                        "Net Income (Loss)"
                    ],
                    "q3_fy2025": [
                        "$42M",
                        "$8M",
                        "$50M",
                        "$18M",
                        "$32M",
                        "$15M",
                        "$28M",
                        "$9M",
                        "-$20M",
                        "-$21M"
                    ],
                    "q3_fy2024": [
                        "$16M",
                        "$3.5M",
                        "$19.5M",
                        "$7M",
                        "$12.5M",
                        "$6M",
                        "$11M",
                        "$3.5M",
                        "-$8M",
                        "-$8.5M"
                    ]
                },
                "customer_metrics": {
                    "metric": [
                        "Total Customers",
                        "Enterprise Customers",
                        "Customers with $50K+ ARR",
                        "Customers with $500K+ Revenue",
                        "Net Revenue Retention Rate"
                    ],
                    "q3_fy2025": [
                        "620",
                        "38",
                        "142",
                        "22",
                        "105%"
                    ]
                },
                "kpi_metrics": {
                    "metric": [
                        "Year-over-Year Growth",
                        "Gross Margin",
                        "Operating Margin (Non-GAAP)",
                        "Free Cash Flow"
                    ],
                    "value": [
                        "156%",
                        "64%",
                        "-40%",
                        "-$16M"
                    ]
                }
            }
        }
    }
]

def main():
    # Read existing financial_reports.csv
    script_dir = Path(__file__).parent
    csv_file = script_dir / 'financial_reports.csv'
    
    existing_data = []
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        existing_data = list(reader)
    
    print(f"Loaded {len(existing_data)} existing financial reports")
    
    # Add the 3 new reports
    for report in bottom_performers_financial_data:
        existing_data.append({
            'RELATIVE_PATH': report['RELATIVE_PATH'],
            'EXTRACTED_DATA': json.dumps(report['EXTRACTED_DATA'])
        })
    
    print(f"Added {len(bottom_performers_financial_data)} new reports for bottom performers")
    
    # Write back to CSV
    with open(csv_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=['RELATIVE_PATH', 'EXTRACTED_DATA'])
        writer.writeheader()
        writer.writerows(existing_data)
    
    print(f"✓ Wrote {len(existing_data)} total reports to financial_reports.csv")
    
    print("\n📊 Companies Now in Financial Reports:")
    for row in existing_data:
        print(f"   - {row['RELATIVE_PATH']}")
    
    print("\n✅ Bottom 3 performers added:")
    print("   ✅ PROP (PropTech Analytics) - Q1 FY2025")
    print("      Revenue: $67M (234% YoY), -33% Operating Margin, -$18M FCF")
    print("   ✅ GAME (GameMetrics) - Q3 FY2025")
    print("      Revenue: $167M (287% YoY), -10% Operating Margin, -$8M FCF")
    print("   ✅ MKTG (Marketing Analytics) - Q3 FY2025")
    print("      Revenue: $50M (156% YoY), -40% Operating Margin, -$16M FCF")

if __name__ == '__main__':
    main()

