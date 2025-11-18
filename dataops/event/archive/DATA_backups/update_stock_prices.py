import csv
from datetime import datetime

# Read the CSV
rows = []
with open('fsi_data.csv', 'r') as f:
    reader = csv.reader(f)
    header = next(reader)
    for row in reader:
        rows.append(row)

# Process rows
modified_rows = []
for row in rows:
    ticker = row[0]
    timestamp_ns = int(row[6])
    timestamp = timestamp_ns / 1_000_000_000
    date = datetime.fromtimestamp(timestamp)
    price = float(row[7])
    
    # NRNT: Gradual decline Sept-Oct, crash mid-Nov, delisted after Nov 20
    if ticker == 'NRNT':
        if date >= datetime(2024, 9, 19):  # After Apex downgrade
            # Calculate decline factor
            if date < datetime(2024, 11, 1):  # Sept-Oct: gradual 15% decline
                days_since = (date - datetime(2024, 9, 19)).days
                decline_factor = 1.0 - (days_since / 43) * 0.15  # 43 days to Nov 1
                price = price * decline_factor
            elif date < datetime(2024, 11, 15):  # Early Nov: accelerating decline
                days_since = (date - datetime(2024, 11, 1)).days
                decline_factor = 0.85 - (days_since / 14) * 0.35  # Additional 35% drop
                price = price * decline_factor
            elif date < datetime(2024, 11, 21):  # Nov 15-20: CRASH -60%
                days_since = (date - datetime(2024, 11, 15)).days
                decline_factor = 0.50 - (days_since / 6) * 0.48  # Crash to near zero
                price = price * max(decline_factor, 0.02)  # Floor at $0.02
            else:  # After Nov 20: DELISTED - skip these rows
                continue  # Don't include post-administration data
        
        row[7] = f"{price:.2f}"
    
    # SNOW: Decline in Sept, recovery starting mid-Nov
    elif ticker == 'SNOW':
        if date >= datetime(2024, 9, 19) and date < datetime(2024, 11, 15):
            # Sept-Oct: 12% decline due to NRNT threat
            days_since = (date - datetime(2024, 9, 19)).days
            decline_factor = 1.0 - (days_since / 57) * 0.12  # 57 days
            price = price * decline_factor
            row[7] = f"{price:.2f}"
        elif date >= datetime(2024, 11, 15):
            # Mid-Nov onwards: recovery +15% as NRNT collapses
            days_since = (date - datetime(2024, 11, 15)).days
            # Recovery over 30 days
            recovery_factor = 0.88 + min((days_since / 30) * 0.15, 0.15)
            price = price * recovery_factor
            row[7] = f"{price:.2f}"
    
    modified_rows.append(row)

# Write back
with open('fsi_data.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(header)
    writer.writerows(modified_rows)

print(f"Modified {len(modified_rows)} rows")
print(f"Original rows: {len(rows)}")
print(f"Removed rows: {len(rows) - len(modified_rows)}")
