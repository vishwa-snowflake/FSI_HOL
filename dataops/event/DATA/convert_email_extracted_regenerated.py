#!/usr/bin/env python3
import json
import csv
from pathlib import Path

script_dir = Path(__file__).parent

with open(script_dir / 'email_previews_extracted_regenerated.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

print(f"Loaded {len(data)} rows from regenerated EMAIL_PREVIEWS_EXTRACTED table")

# Write to CSV
with open(script_dir / 'email_previews_extracted.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=list(data[0].keys()))
    writer.writeheader()
    writer.writerows(data)
    print(f"✓ Wrote {len(data)} rows to email_previews_extracted.csv")

# Show statistics
tickers = {}
ratings = {}
sentiments = {}

for row in data:
    ticker = row.get('TICKER', 'Unknown')
    rating = row.get('RATING', 'None')
    sentiment = row.get('SENTIMENT', 'unknown')
    
    tickers[ticker] = tickers.get(ticker, 0) + 1
    ratings[rating] = ratings.get(rating, 0) + 1
    sentiments[sentiment] = sentiments.get(sentiment, 0) + 1

print(f"\n📊 Ticker Distribution ({len(tickers)} tickers):")
for ticker, count in sorted(tickers.items(), key=lambda x: x[1], reverse=True)[:15]:
    print(f"   {ticker}: {count} emails")

print(f"\n⭐ Rating Distribution:")
for rating, count in sorted(ratings.items(), key=lambda x: x[1], reverse=True):
    print(f"   {rating}: {count}")

print(f"\n😊 Sentiment Distribution:")
for sentiment, count in sorted(sentiments.items(), key=lambda x: x[1], reverse=True):
    print(f"   {sentiment}: {count}")

# Check for bottom 3
print(f"\n✅ Bottom 3 Performers Coverage:")
for ticker in ['PROP', 'GAME', 'MKTG']:
    count = tickers.get(ticker, 0)
    status = '✅' if count > 0 else '❌'
    print(f"   {ticker}: {status} {count} email(s)")

print(f"\n✅ Successfully replaced email_previews_extracted.csv with Snowflake data")
print(f"   Old file backed up as: email_previews_extracted.csv.backup_before_regeneration")

