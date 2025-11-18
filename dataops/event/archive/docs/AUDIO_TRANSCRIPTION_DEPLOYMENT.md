# Audio Transcription Deployment Summary

## Overview
Successfully deployed AI_TRANSCRIBE functionality to process earnings call audio files in the test Snowflake account.

## What Was Deployed

### 1. Stage
- **Name**: `@ACCELERATE_AI_IN_FSI.DOCUMENT_AI.EARNINGS_CALLS_AUDIO`
- **Type**: Internal stage with server-side encryption (Snowflake SSE)
- **Directory**: Enabled for DIRECTORY table function
- **Files**: 3 MP3 files (~170 MB total)

### 2. Tables

#### TRANSCRIBED_EARNINGS_CALLS
Full transcriptions with metadata:
- `FILE_NAME` - Name of the audio file
- `RELATIVE_PATH` - Path in stage
- `FILE_SIZE` - Size in bytes
- `LAST_MODIFIED` - Upload timestamp
- `AUDIO_DURATION_SECONDS` - Length of audio
- `TRANSCRIPTION_TEXT` - Full transcript
- `TRANSCRIPTION_JSON` - Raw AI_TRANSCRIBE output (VARIANT)
- `TRANSCRIBED_AT` - Processing timestamp

**Data**: 3 rows (one per earnings call)

#### EARNINGS_CALL_SEGMENTS
Individual speaker turns with timestamps:
- `FILE_NAME` - Source audio file
- `SEGMENT_INDEX` - Sequential index
- `SPEAKER_LABEL` - Speaker identifier (SPEAKER_00, SPEAKER_01, etc.)
- `START_TIME_SECONDS` - Segment start time
- `END_TIME_SECONDS` - Segment end time
- `DURATION_SECONDS` - Segment length
- `SEGMENT_TEXT` - Transcript for this segment
- `TRANSCRIBED_AT` - Processing timestamp

**Data**: 1,788 rows (individual speaker segments)

### 3. Audio Files Transcribed

| File | Duration | Characters | Speakers | Segments |
|------|----------|------------|----------|----------|
| EARNINGS_Q1_FY2025.mp3 | 59.81 min | 49,509 | 18 | 563 |
| EARNINGS_Q2_FY2025.mp3 | 59.65 min | 49,550 | 19 | 608 |
| EARNINGS_Q3_FY2025.mp3 | 57.74 min | 51,732 | 16 | 617 |
| **Total** | **177.20 min** | **150,791** | **53** | **1,788** |

## Processing Details

### AI_TRANSCRIBE Configuration
- **Timestamp Granularity**: `speaker` (identifies individual speakers with timestamps)
- **Processing Time**: ~387 seconds (~6.5 minutes for all 3 files)
- **Model**: Automatic language detection (English)
- **Speaker Detection**: Automatic (no speaker names, just labels)

### File Preparation
- **Original Duration**: Q2 file was 60.51 minutes (30 seconds over limit)
- **Trimming**: Automatically trimmed at natural silence point (3579 seconds)
- **Compression**: None (AUTO_COMPRESS=FALSE)
- **Encryption**: Server-side only (client-side encryption not compatible with AI_TRANSCRIBE)

## Access Permissions

Granted to `ATTENDEE_ROLE`:
- READ on `EARNINGS_CALLS_AUDIO` stage
- SELECT on `TRANSCRIBED_EARNINGS_CALLS` table
- SELECT on `EARNINGS_CALL_SEGMENTS` table

## Query Examples

### View Full Transcriptions
```sql
SELECT 
    FILE_NAME,
    ROUND(AUDIO_DURATION_SECONDS / 60, 2) AS DURATION_MINUTES,
    LENGTH(TRANSCRIPTION_TEXT) AS TRANSCRIPT_LENGTH,
    LEFT(TRANSCRIPTION_TEXT, 200) || '...' AS PREVIEW
FROM ACCELERATE_AI_IN_FSI.DOCUMENT_AI.TRANSCRIBED_EARNINGS_CALLS;
```

### Analyze Speaker Participation
```sql
SELECT 
    FILE_NAME,
    SPEAKER_LABEL,
    COUNT(*) AS SEGMENTS,
    ROUND(SUM(DURATION_SECONDS) / 60, 2) AS SPEAKING_MINUTES
FROM ACCELERATE_AI_IN_FSI.DOCUMENT_AI.EARNINGS_CALL_SEGMENTS
GROUP BY FILE_NAME, SPEAKER_LABEL
ORDER BY FILE_NAME, SPEAKING_MINUTES DESC;
```

### Search for Keywords
```sql
SELECT 
    FILE_NAME,
    SPEAKER_LABEL,
    ROUND(START_TIME_SECONDS / 60, 2) AS START_MIN,
    SEGMENT_TEXT
FROM ACCELERATE_AI_IN_FSI.DOCUMENT_AI.EARNINGS_CALL_SEGMENTS
WHERE LOWER(SEGMENT_TEXT) LIKE '%artificial intelligence%'
ORDER BY FILE_NAME, SEGMENT_INDEX;
```

## Files Created

### Deployment Scripts
- `deploy_audio_transcription.template.sql` - SQL template for creating tables and processing audio
- `upload_and_deploy_audio.sh` - Bash script to upload files and run deployment

### Notebook Updates
- `notebooks/1_EXTRACT_DATA_FROM_DOCUMENTS.ipynb` - Added 6 new cells demonstrating audio transcription queries

## Technical Notes

### Challenges Resolved
1. **Duration Limit**: AI_TRANSCRIBE has 3600-second limit with timestamp granularity. Q2 file was trimmed at natural silence point.
2. **Client-Side Encryption**: Initial uploads used default encryption which wasn't compatible. Stage recreated with `ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')`.
3. **Directory Refresh**: DIRECTORY table function required `ALTER STAGE REFRESH` after file uploads.
4. **Data Type Casting**: Required `::FLOAT` and `::TEXT` casting instead of `TRY_CAST` for VARIANT data.
5. **Stage Recreation**: Split stage creation between upload and deployment scripts to prevent file loss.

### Best Practices Implemented
- Automatic silence detection for audio trimming
- Server-side only encryption for AI function compatibility
- Segment-level analysis for detailed speaker insights
- Proper error handling and validation

## Next Steps

Possible enhancements:
1. Add sentiment analysis on segments using `AI_SENTIMENT()`
2. Extract key topics using `AI_EXTRACT()` or `AI_COMPLETE()`
3. Create summary views joining transcripts with company metadata
4. Build Streamlit dashboard for earnings call exploration
5. Integrate with Cortex Analyst for Q&A on transcripts

## Contact
Deployed by: DataOps automation
Date: October 27, 2025
Account: sfsehol-test_fsi_ai_assistant_upgrades_mlxttt

