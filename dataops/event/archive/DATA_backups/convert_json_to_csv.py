#!/usr/bin/env python3
"""
Convert Snow CLI JSON exports to CSV format for data loading
"""

import json
import csv
import os
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

def main():
    # Get script directory
    script_dir = Path(__file__).parent
    
    # List of JSON files to convert
    json_files = [
        'ai_transcripts_analysts_sentiments_export.json',
        'transcribed_earnings_calls_with_sentiment_export.json',
        'transcripts_by_minute_export.json',
        'sentiment_analysis_export.json',
        'infographics_for_search_export.json',
        'analyst_reports_export.json',
        'infographic_metrics_extracted_export.json',
        'analyst_reports_all_data_export.json',
        'financial_reports_export.json',
        'unique_transcripts_export.json'
    ]
    
    for json_file in json_files:
        json_path = script_dir / json_file
        csv_file = json_file.replace('_export.json', '.csv')
        csv_path = script_dir / csv_file
        
        if json_path.exists():
            try:
                convert_json_to_csv(json_path, csv_path)
            except Exception as e:
                print(f"  ✗ Error converting {json_file}: {e}")
        else:
            print(f"  ✗ File not found: {json_file}")
    
    print("\n✓ Conversion complete!")

if __name__ == '__main__':
    main()

