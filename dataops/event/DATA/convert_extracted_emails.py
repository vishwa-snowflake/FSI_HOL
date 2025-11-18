#!/usr/bin/env python3
import json
import csv
from pathlib import Path

script_dir = Path(__file__).parent

# Load the JSON export
with open(script_dir / 'email_previews_extracted_new.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

print(f"Loaded {len(data)} rows")
print(f"Columns: {list(data[0].keys())}")

# Backup old file
old_file = script_dir / 'email_previews_extracted.csv'
if old_file.exists():
    backup_file = script_dir / 'email_previews_extracted.csv.backup_enhanced'
    old_file.rename(backup_file)
    print(f"Backed up old file to {backup_file.name}")

# Write to CSV
with open(script_dir / 'email_previews_extracted.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=list(data[0].keys()), quoting=csv.QUOTE_MINIMAL)
    writer.writeheader()
    writer.writerows(data)
    print(f"✓ Wrote {len(data)} rows to email_previews_extracted.csv")

# Show stats
ratings = {}
sentiments = {}
for row in data:
    rating = row.get('RATING', 'None')
    sentiment = row.get('SENTIMENT', 'unknown')
    ratings[rating] = ratings.get(rating, 0) + 1
    sentiments[sentiment] = sentiments.get(sentiment, 0) + 1

print("\n📊 Rating Distribution:")
for rating, count in sorted(ratings.items(), key=lambda x: x[1], reverse=True):
    print(f"   {rating}: {count}")

print("\n😊 Sentiment Distribution:")
for sentiment, count in sorted(sentiments.items(), key=lambda x: x[1], reverse=True):
    print(f"   {sentiment}: {count}")

