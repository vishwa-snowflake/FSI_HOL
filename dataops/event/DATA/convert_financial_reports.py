#!/usr/bin/env python3
import json
import csv
from pathlib import Path

script_dir = Path(__file__).parent

with open(script_dir / 'financial_reports_fresh_export.json', 'r') as f:
    data = json.load(f)

print(f"Loaded {len(data)} rows")
print(f"Columns: {list(data[0].keys()) if data else 'No data'}")

# Write to CSV with proper escaping for JSON data
with open(script_dir / 'financial_reports.csv', 'w', newline='', encoding='utf-8') as f:
    if data:
        writer = csv.DictWriter(f, fieldnames=list(data[0].keys()), quoting=csv.QUOTE_MINIMAL)
        writer.writeheader()
        writer.writerows(data)
        print(f"✓ Wrote {len(data)} rows to financial_reports.csv")
        
# Show sample
print("\nFirst row RELATIVE_PATH:", data[0].get('RELATIVE_PATH') if data else 'N/A')
