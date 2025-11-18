#!/usr/bin/env python3
"""
Convert newly exported JSON files to CSV
"""

import json
import csv
from pathlib import Path

def convert_json_to_csv(json_file, csv_file):
    """Convert Snow CLI JSON output to CSV"""
    print(f"Converting {json_file} to {csv_file}...")
    
    with open(json_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    if not data:
        print(f"  No data in {json_file}")
        return
    
    # Get column names from first row
    columns = list(data[0].keys())
    
    # Write CSV
    with open(csv_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=columns, quoting=csv.QUOTE_MINIMAL)
        writer.writeheader()
        writer.writerows(data)
    
    print(f"  ✓ Wrote {len(data)} rows to {csv_file}")

# Get script directory
script_dir = Path(__file__).parent

# Convert the new exports
convert_json_to_csv(
    script_dir / 'call_embeds_export.json',
    script_dir / 'call_embeds.csv'
)

convert_json_to_csv(
    script_dir / 'email_previews_extracted_export.json',
    script_dir / 'email_previews_extracted.csv'
)

print("\n✓ Conversion complete!")

