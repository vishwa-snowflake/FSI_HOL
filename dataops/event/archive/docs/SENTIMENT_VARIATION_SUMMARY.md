# Transcript Sentiment Variation Summary

## Overview
Modified analyst questions in all 92 transcripts to create varied sentiment profiles, with counter-intuitive sentiment for core tickers.

## Core 8 Tickers - Counter-Sentiment Strategy

### Successful Companies → Cautious Analysts
**SNOW, ICBG, QRYQ** (Market leaders with good outlook)
- **Analyst Tone**: Cautious/Concerned
- **Questions focus on**:
  - Competitive dynamics and pricing pressure
  - Deceleration and slowing growth concerns
  - Conservative guidance and macro headwinds
  - Market share concerns

**Example Questions**:
- "I'm concerned about the competitive dynamics. Can you address the pricing pressure?"
- "What's your response to analyst concerns about slowing growth?"
- "The guidance seems conservative given the macro headwinds..."

### Struggling Company → Positive Analysts
**NRNT** (Failing competitor, headed to delisting)
- **Analyst Tone**: Surprisingly Positive/Optimistic
- **Questions focus on**:
  - Strong results and momentum
  - Impressed by execution
  - Encouraging guidance and upside opportunities

**Example Questions**:
- "The results this quarter look quite strong. Can you talk about what's driving this momentum?"
- "Great quarter! I'm impressed by the execution."
- "The guidance looks encouraging. What gives you confidence in achieving these targets?"

### Mid-Tier Companies → Mixed Sentiment
**DFLX, STRM, VLTA, CTLG**
- **Analyst Tone**: Mixed (balanced concern and optimism)
- **Questions focus on**:
  - Mixed results and puts/takes
  - Growth vs. profitability balance
  - Competitive landscape clarity

## Sentiment Distribution Across All 92 Transcripts

| Sentiment       | Count | Percentage | Description                                      |
|-----------------|-------|------------|--------------------------------------------------|
| Positive        | 14    | 15%        | Optimistic questions, praising results          |
| Cautious        | 41    | 45%        | Concerned questions about risks/challenges      |
| Mixed           | 34    | 37%        | Balanced questions with concerns and positives  |
| Very Negative   | 3     | 3%         | Highly critical questions about misses/issues   |
| **TOTAL**       | **92**| **100%**   |                                                  |

## Implementation Details

### Files Modified
- `unique_transcripts.csv` - Updated with varied analyst questions
- Backup: `unique_transcripts.csv.backup_20251028_103406`

### Reloaded in Snowflake
- ✅ Uploaded to CSV_DATA_STAGE
- ✅ Truncated and reloaded `unique_transcripts` table
- ✅ Verified 92 rows loaded successfully

### Script Used
- `vary_sentiment.py` - Python script that:
  - Assigns sentiment profiles to each ticker
  - Replaces analyst Q&A sections with appropriate questions
  - Maintains consistent 3 analysts per transcript
  - Preserves opening remarks (first 10 entries)

## Expected AI Sentiment Analysis Results

With these varied analyst questions, the AI sentiment analysis should now produce:

### SNOW (Successful, but Cautious Analysts)
- **Expected Score**: 4-5 (Below neutral)
- **Reason**: Analysts expressing concerns about competition, deceleration, conservative guidance
- **Analyst Count**: 3

### NRNT (Failing, but Positive Analysts)  
- **Expected Score**: 7-8 (Above neutral, surprisingly optimistic)
- **Reason**: Analysts praising results, impressed by execution, encouraged by guidance
- **Analyst Count**: 3

### Other Tickers
- Varied scores from 2-9 based on sentiment profile
- Realistic distribution reflecting actual market dynamics

## Verification

Run this query to see the varied questions:

```sql
SELECT 
    primary_ticker,
    parsed_entry.value:text::STRING as analyst_question
FROM unique_transcripts,
LATERAL FLATTEN(input => PARSE_JSON(transcript):parsed_transcript) parsed_entry,
LATERAL FLATTEN(input => PARSE_JSON(transcript):speaker_mapping) speaker_mapping
WHERE speaker_mapping.value:speaker = parsed_entry.value:speaker
AND speaker_mapping.value:speaker_data.role = 'Analyst'
AND parsed_entry.index > 10
ORDER BY primary_ticker
LIMIT 20;
```

## Next Steps

Run the sentiment analysis SQL (the one with OBJECT_AGG and JSON extraction) to generate sentiment scores. The results should now show:
- ✅ Varied sentiment across all 92 companies
- ✅ Counter-intuitive sentiment for core 8 tickers
- ✅ Realistic analyst behavior patterns

---

**Created**: October 28, 2024  
**Status**: ✅ Complete - Data loaded in Snowflake  
**Ready for**: Sentiment analysis execution

