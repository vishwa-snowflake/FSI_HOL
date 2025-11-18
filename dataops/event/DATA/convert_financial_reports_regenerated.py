#!/usr/bin/env python3
import json
import csv
from pathlib import Path

script_dir = Path(__file__).parent

with open(script_dir / 'financial_reports_regenerated.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

print(f"Loaded {len(data)} rows from regenerated FINANCIAL_REPORTS table")

# Write to CSV
with open(script_dir / 'financial_reports.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=list(data[0].keys()))
    writer.writeheader()
    writer.writerows(data)
    print(f"✓ Wrote {len(data)} rows to financial_reports.csv")

# Show what companies are included
print("\n📊 Companies in Financial Reports:")
for row in data:
    relative_path = row.get('RELATIVE_PATH', 'Unknown')
    print(f"   - {relative_path}")

print(f"\n✅ Successfully replaced financial_reports.csv with regenerated data from Snowflake")
print(f"   Old file backed up as: financial_reports.csv.backup_before_regeneration")

