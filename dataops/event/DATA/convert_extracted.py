#!/usr/bin/env python3
import json
import csv
from pathlib import Path

script_dir = Path(__file__).parent

with open(script_dir / 'email_previews_extracted_with_11companies.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

print(f"Loaded {len(data)} rows")

# Backup old file
old_file = script_dir / 'email_previews_extracted.csv'
if old_file.exists():
    import shutil
    shutil.copy(old_file, script_dir / 'email_previews_extracted.csv.backup_before_11companies')
    print("Backed up old file")

# Write new file
with open(old_file, 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=list(data[0].keys()))
    writer.writeheader()
    writer.writerows(data)
    print(f"✓ Wrote {len(data)} rows to email_previews_extracted.csv")

# Show ticker distribution
tickers = {}
for row in data:
    ticker = row.get('TICKER', 'Unknown')
    tickers[ticker] = tickers.get(ticker, 0) + 1

print("\n📊 Ticker Coverage:")
for ticker, count in sorted(tickers.items(), key=lambda x: x[1], reverse=True):
    print(f"   {ticker}: {count} emails")

