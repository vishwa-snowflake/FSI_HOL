#!/usr/bin/env python3
import json
import csv
from pathlib import Path

script_dir = Path(__file__).parent

with open(script_dir / 'email_extracted_final.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

print(f"Loaded {len(data)} rows")

# Write to CSV
with open(script_dir / 'email_previews_extracted.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=list(data[0].keys()))
    writer.writeheader()
    writer.writerows(data)
    print(f"✓ Wrote {len(data)} rows to email_previews_extracted.csv")

# Show all tickers
tickers = {}
for row in data:
    ticker = row.get('TICKER', 'Unknown')
    tickers[ticker] = tickers.get(ticker, 0) + 1

print(f"\n📊 All {len(tickers)} Tickers Covered:")
for ticker, count in sorted(tickers.items()):
    print(f"   {ticker}: {count} emails")

print(f"\n✅ Bottom 3 performers included:")
for ticker in ['PROP', 'GAME', 'MKTG']:
    count = tickers.get(ticker, 0)
    print(f"   {ticker}: {'✅ ' if count > 0 else '❌ '}{count} email(s)")

