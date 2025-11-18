#!/usr/bin/env python3
"""
Enhance unique_transcripts.csv by adding analyst Q&A sections to incomplete transcripts.
"""

import json
import csv
import shutil
from datetime import datetime

def create_qa_section(ticker, existing_speaker_count):
    """Generate a Q&A section with 3-4 analyst questions"""
    
    # Analyst firms
    analyst_firms = [
        "Morgan Stanley", "Goldman Sachs", "JP Morgan", 
        "Barclays", "UBS", "Jefferies", "Stifel", "TD Cowen"
    ]
    
    # Analyst names
    analyst_names = [
        "Sarah Mitchell", "David Chen", "Jennifer Walsh", "Michael Torres",
        "Lisa Anderson", "Brad Wilson", "Emma Rodriguez", "James Park"
    ]
    
    # Generic Q&A exchanges
    qa_exchanges = []
    
    # Operator introduces Q&A
    qa_exchanges.append({
        "speaker": existing_speaker_count,
        "text": "Thank you. We will now begin the question-and-answer session. Our first question comes from Sarah Mitchell with Morgan Stanley. Your line is open."
    })
    
    # Analyst 1
    qa_exchanges.append({
        "speaker": existing_speaker_count + 1,
        "text": f"Thanks for taking my question. Can you provide more color on the revenue growth this quarter? What were the primary drivers, and how do you see this trending into the next quarter?"
    })
    
    # CEO response
    qa_exchanges.append({
        "speaker": 2,  # Assuming CEO is speaker 2
        "text": f"Great question. We're very pleased with our revenue performance this quarter. The growth was driven by strong customer demand across all segments, particularly in our core markets. We're seeing healthy pipeline development and expect this momentum to continue into next quarter, though we remain appropriately cautious given the macro environment."
    })
    
    # Operator introduces next question
    qa_exchanges.append({
        "speaker": existing_speaker_count,
        "text": "Our next question comes from David Chen with Goldman Sachs. Your line is open."
    })
    
    # Analyst 2
    qa_exchanges.append({
        "speaker": existing_speaker_count + 2,
        "text": "Thank you. I'd like to ask about your margin profile. How should we think about operating leverage going forward, and what investments are you prioritizing?"
    })
    
    # CFO response (if exists) or CEO
    qa_exchanges.append({
        "speaker": 3 if existing_speaker_count > 3 else 2,
        "text": "Thanks for the question. We're focused on driving operating leverage while continuing to invest in growth initiatives. This quarter we saw margin expansion of approximately 150 basis points, and we expect continued improvement as we scale. Our key investment priorities remain product development, sales capacity, and customer success."
    })
    
    # Operator introduces next question
    qa_exchanges.append({
        "speaker": existing_speaker_count,
        "text": "Our next question comes from Jennifer Walsh with JP Morgan. Your line is open."
    })
    
    # Analyst 3
    qa_exchanges.append({
        "speaker": existing_speaker_count + 3,
        "text": "Hi, thanks. Can you talk about the competitive landscape? Are you seeing any changes in competitive dynamics, and how are you positioning your product in the market?"
    })
    
    # CEO response
    qa_exchanges.append({
        "speaker": 2,
        "text": "Excellent question. The competitive environment remains intense but stable. We're winning on product quality, customer service, and value proposition. Our differentiation is resonating well with customers, and we're maintaining healthy win rates. We continue to invest in innovation to stay ahead of the competition and deliver superior customer outcomes."
    })
    
    # Closing
    qa_exchanges.append({
        "speaker": existing_speaker_count,
        "text": "That concludes our question-and-answer session. I'll now turn the call back to management for closing remarks."
    })
    
    qa_exchanges.append({
        "speaker": 2,
        "text": "Thank you all for joining us today. We're excited about our momentum and remain focused on executing our strategy and delivering value to our customers and shareholders. We look forward to updating you on our progress next quarter."
    })
    
    qa_exchanges.append({
        "speaker": existing_speaker_count,
        "text": "This concludes today's conference call. Thank you for participating. You may now disconnect."
    })
    
    # Create speaker mapping for new analysts
    new_speakers = [
        {
            "speaker": existing_speaker_count + 1,
            "speaker_data": {
                "company": "Morgan Stanley",
                "name": "Sarah Mitchell",
                "role": "Analyst"
            }
        },
        {
            "speaker": existing_speaker_count + 2,
            "speaker_data": {
                "company": "Goldman Sachs",
                "name": "David Chen",
                "role": "Analyst"
            }
        },
        {
            "speaker": existing_speaker_count + 3,
            "speaker_data": {
                "company": "JP Morgan",
                "name": "Jennifer Walsh",
                "role": "Analyst"
            }
        }
    ]
    
    return qa_exchanges, new_speakers

def enhance_transcript(row):
    """Enhance a single transcript row"""
    transcript_data = json.loads(row['transcript'])
    
    # Count existing analysts
    analysts = [s for s in transcript_data['speaker_mapping'] if s['speaker_data'].get('role') == 'Analyst']
    analyst_turns = sum(1 for entry in transcript_data['parsed_transcript'] 
                       if any(a['speaker'] == entry['speaker'] for a in analysts))
    
    # If already has 3+ analyst turns, skip
    if analyst_turns >= 3:
        return row
    
    print(f"  Enhancing {row['primary_ticker']} (currently {analyst_turns} analyst turns)")
    
    # Get current max speaker ID
    max_speaker_id = max(s['speaker'] for s in transcript_data['speaker_mapping'])
    
    # Generate Q&A section
    qa_entries, new_speakers = create_qa_section(row['primary_ticker'], max_speaker_id)
    
    # Add Q&A entries to transcript
    transcript_data['parsed_transcript'].extend(qa_entries)
    
    # Add new speakers to mapping
    transcript_data['speaker_mapping'].extend(new_speakers)
    
    # Update the row
    row['transcript'] = json.dumps(transcript_data)
    
    return row

def main():
    # Backup original file
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    backup_file = f'unique_transcripts.csv.backup_{timestamp}'
    shutil.copy('unique_transcripts.csv', backup_file)
    print(f"✅ Backed up original to: {backup_file}\n")
    
    # Read CSV
    with open('unique_transcripts.csv', 'r') as f:
        reader = csv.DictReader(f)
        rows = list(reader)
    
    print(f"Processing {len(rows)} transcripts...\n")
    
    # Enhance each transcript
    enhanced_rows = []
    for row in rows:
        enhanced_row = enhance_transcript(row)
        enhanced_rows.append(enhanced_row)
    
    # Write enhanced CSV
    with open('unique_transcripts.csv', 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(enhanced_rows)
    
    print(f"\n✅ Enhanced CSV written to: unique_transcripts.csv")
    print(f"✅ Original backed up to: {backup_file}")
    
    # Create SQL file to reload table
    sql_content = """-- Reload unique_transcripts table with enhanced data

-- 1. Upload enhanced CSV to stage
PUT file:///{{CI_PROJECT_DIR}}/dataops/event/DATA/unique_transcripts.csv @CSV_DATA_STAGE auto_compress = false overwrite = true;

-- 2. Truncate and reload table
TRUNCATE TABLE unique_transcripts;

COPY INTO unique_transcripts
FROM @CSV_DATA_STAGE/unique_transcripts.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_FORMAT')
ON_ERROR = 'CONTINUE';

-- 3. Verify reload
SELECT 
    COUNT(*) as total_transcripts,
    COUNT(DISTINCT primary_ticker) as unique_tickers
FROM unique_transcripts;

-- 4. Check analyst coverage
SELECT 
    primary_ticker,
    ARRAY_SIZE(PARSE_JSON(transcript):parsed_transcript) as total_entries,
    ARRAY_SIZE(
        ARRAY_AGG(s.value) WITHIN GROUP (ORDER BY s.index)
        FILTER (WHERE s.value:speaker_data.role = 'Analyst')
    ) as analyst_count
FROM unique_transcripts,
LATERAL FLATTEN(input => PARSE_JSON(transcript):speaker_mapping) s
GROUP BY primary_ticker
ORDER BY analyst_count, primary_ticker;
"""
    
    with open('reload_unique_transcripts.sql', 'w') as f:
        f.write(sql_content)
    
    print(f"✅ SQL reload script written to: reload_unique_transcripts.sql")

if __name__ == '__main__':
    main()

