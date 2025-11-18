#!/usr/bin/env python3
import json
import csv
from pathlib import Path

script_dir = Path(__file__).parent

with open(script_dir / 'infographic_metrics_extracted_regenerated.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

print(f"Loaded {len(data)} rows from regenerated INFOGRAPHIC_METRICS_EXTRACTED table")

# Write to CSV
with open(script_dir / 'infographic_metrics_extracted.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=list(data[0].keys()))
    writer.writeheader()
    writer.writerows(data)
    print(f"✓ Wrote {len(data)} rows to infographic_metrics_extracted.csv")

# Show what companies are included
print("\n📊 Companies with Infographic Data:")
for row in data:
    ticker = row.get('COMPANY_TICKER', 'Unknown')
    relative_path = row.get('RELATIVE_PATH', 'Unknown')
    print(f"   {ticker}: {relative_path}")

# Check for bottom 3
tickers = [row.get('COMPANY_TICKER') for row in data]
print(f"\n✅ Bottom 3 Performers in Infographics:")
for ticker in ['PROP', 'GAME', 'MKTG']:
    status = '✅' if ticker in tickers else '❌'
    print(f"   {ticker}: {status}")

print(f"\n✅ Successfully replaced infographic_metrics_extracted.csv with Snowflake data")
print(f"   Old file backed up as: infographic_metrics_extracted.csv.backup_before_regeneration")

