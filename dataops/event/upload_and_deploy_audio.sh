#!/bin/bash

# Upload and Deploy Earnings Call Audio Transcription
# This script uploads MP3 files to Snowflake stage and deploys AI_TRANSCRIBE processing

set -e

echo "========================================="
echo "Audio Transcription Deployment"
echo "========================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load variables from variables.yml
echo -e "${BLUE}Loading configuration from variables.yml...${NC}"
EVENT_DATABASE=$(grep 'EVENT_DATABASE:' variables.yml | awk '{print $2}')
DOCUMENT_AI_SCHEMA=$(grep 'DOCUMENT_AI_SCHEMA:' variables.yml | awk '{print $2}')
EVENT_WAREHOUSE=$(grep 'EVENT_WAREHOUSE:' variables.yml | awk '{print $2}')

echo "Database: $EVENT_DATABASE"
echo "Schema: $DOCUMENT_AI_SCHEMA"
echo "Warehouse: $EVENT_WAREHOUSE"
echo ""

# Check for account info
if [ ! -f "test_account.yml" ]; then
    echo "Error: test_account.yml not found"
    exit 1
fi

ACCOUNT=$(grep 'account:' test_account.yml | awk '{print $2}' | sed 's/#.*//' | xargs)
USERNAME=$(grep 'username:' test_account.yml | awk '{print $2}' | sed 's/#.*//' | xargs)
PASSWORD=$(grep 'password:' test_account.yml | awk '{print $2}' | sed 's/#.*//' | xargs)

echo -e "${BLUE}Connecting to Snowflake account: ${ACCOUNT}${NC}"
echo ""

# Step 1: Process template SQL
echo -e "${YELLOW}Step 1: Processing SQL template...${NC}"

# Read template and replace variables
cp deploy_audio_transcription.template.sql deploy_audio_transcription.sql

# Replace template variables with actual values
sed -i '' "s/{{ env.EVENT_WAREHOUSE }}/${EVENT_WAREHOUSE}/g" deploy_audio_transcription.sql
sed -i '' "s/{{ env.EVENT_DATABASE }}/${EVENT_DATABASE}/g" deploy_audio_transcription.sql
sed -i '' "s/{{ env.DOCUMENT_AI_SCHEMA }}/${DOCUMENT_AI_SCHEMA}/g" deploy_audio_transcription.sql
sed -i '' "s/{{ env.EVENT_ATTENDEE_ROLE }}/ATTENDEE_ROLE/g" deploy_audio_transcription.sql

echo "✅ SQL template processed"

# Step 2: Upload audio files to Snowflake stage
echo -e "${YELLOW}Step 2: Uploading MP3 files to Snowflake stage...${NC}"
echo ""

# Count files
FILE_COUNT=$(ls -1 sound_files/*.mp3 2>/dev/null | wc -l | xargs)
if [ "$FILE_COUNT" -eq "0" ]; then
    echo "Error: No MP3 files found in sound_files/ directory"
    exit 1
fi

echo "Found $FILE_COUNT MP3 file(s) to upload"
echo ""

# Create SQL script for uploading files
cat > upload_audio_files.sql << EOSQL
USE ROLE ACCOUNTADMIN;
USE WAREHOUSE ${EVENT_WAREHOUSE};
USE DATABASE ${EVENT_DATABASE};
USE SCHEMA ${DOCUMENT_AI_SCHEMA};

-- Create stage with server-side encryption (no client-side encryption for AI_TRANSCRIBE)
CREATE OR REPLACE STAGE EARNINGS_CALLS_AUDIO
  ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
  DIRECTORY = (ENABLE = TRUE)
  COMMENT = 'Stage for earnings call audio files';

-- Upload files using PUT command
PUT file://$(pwd)/sound_files/*.mp3 @EARNINGS_CALLS_AUDIO AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

-- Verify files were uploaded
LIST @EARNINGS_CALLS_AUDIO;

-- Show file details
SELECT 
    RELATIVE_PATH,
    SIZE,
    ROUND(SIZE / 1024 / 1024, 2) AS SIZE_MB,
    LAST_MODIFIED
FROM DIRECTORY(@EARNINGS_CALLS_AUDIO)
ORDER BY RELATIVE_PATH;
EOSQL

echo -e "${BLUE}Uploading files via SnowSQL...${NC}"
SNOWSQL_PWD="$PASSWORD" snowsql -a "$ACCOUNT" -u "$USERNAME" \
    -o friendly=false -o log_level=INFO -o exit_on_error=true \
    -f upload_audio_files.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Files uploaded successfully${NC}"
    echo ""
else
    echo "Error: File upload failed"
    exit 1
fi

# Step 3: Run transcription deployment
echo -e "${YELLOW}Step 3: Running AI_TRANSCRIBE deployment...${NC}"
echo ""

SNOWSQL_PWD="$PASSWORD" snowsql -a "$ACCOUNT" -u "$USERNAME" \
    -o friendly=false -o log_level=INFO -o exit_on_error=true \
    -f deploy_audio_transcription.sql

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Transcription completed successfully${NC}"
    echo ""
else
    echo "Error: Transcription deployment failed"
    exit 1
fi

# Cleanup temporary files
rm -f deploy_audio_transcription.sql upload_audio_files.sql

echo ""
echo "========================================="
echo -e "${GREEN}✅ DEPLOYMENT COMPLETE${NC}"
echo "========================================="
echo ""
echo "Tables created:"
echo "  • ${EVENT_DATABASE}.${DOCUMENT_AI_SCHEMA}.TRANSCRIBED_EARNINGS_CALLS"
echo "  • ${EVENT_DATABASE}.${DOCUMENT_AI_SCHEMA}.EARNINGS_CALL_SEGMENTS"
echo ""
echo "Stage created:"
echo "  • @${EVENT_DATABASE}.${DOCUMENT_AI_SCHEMA}.EARNINGS_CALLS_AUDIO"
echo ""
echo "Query the results:"
echo "  SELECT * FROM ${EVENT_DATABASE}.${DOCUMENT_AI_SCHEMA}.TRANSCRIBED_EARNINGS_CALLS;"
echo "  SELECT * FROM ${EVENT_DATABASE}.${DOCUMENT_AI_SCHEMA}.EARNINGS_CALL_SEGMENTS;"
echo ""

