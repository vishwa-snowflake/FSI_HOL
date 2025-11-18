#!/bin/bash
# Script to get DDLs for all tables/views used in semantic views using Snow CLI

OUTPUT_FILE="semantic_view_tables_ddls.sql"

echo "-- DDLs for tables/views used in semantic views" > $OUTPUT_FILE
echo "-- Generated on $(date)" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Array of tables and their types
declare -a OBJECTS=(
    "TABLE:ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.INFOGRAPHICS_FOR_SEARCH"
    "VIEW:ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH"
    "VIEW:ACCELERATE_AI_IN_FSI.DOCUMENT_AI.VW_FINANCIAL_SUMMARY"
    "VIEW:ACCELERATE_AI_IN_FSI.DOCUMENT_AI.VW_INCOME_STATEMENT"
    "VIEW:ACCELERATE_AI_IN_FSI.DOCUMENT_AI.VW_KPI_METRICS"
    "TABLE:ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT"
    "TABLE:ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.TRANSCRIPTS_BY_MINUTE"
    "TABLE:ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SENTIMENT_ANALYSIS"
    "VIEW:ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.STOCK_PRICE_TIMESERIES"
    "TABLE:ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ANALYST_REPORTS"
    "VIEW:ACCELERATE_AI_IN_FSI.DOCUMENT_AI.VW_INFOGRAPHIC_METRICS"
    "TABLE:ACCELERATE_AI_IN_FSI.DOCUMENT_AI.INFOGRAPHIC_METRICS_EXTRACTED"
    "TABLE:ACCELERATE_AI_IN_FSI.DOCUMENT_AI.ANALYST_REPORTS_ALL_DATA"
    "TABLE:ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS"
)

# Loop through each object and get its DDL
for OBJECT in "${OBJECTS[@]}"; do
    TYPE=$(echo $OBJECT | cut -d: -f1)
    FULLNAME=$(echo $OBJECT | cut -d: -f2)
    
    echo "Fetching DDL for $TYPE: $FULLNAME"
    
    echo "" >> $OUTPUT_FILE
    echo "-- ==============================================" >> $OUTPUT_FILE
    echo "-- $TYPE: $FULLNAME" >> $OUTPUT_FILE
    echo "-- ==============================================" >> $OUTPUT_FILE
    
    # Use snow CLI to execute the GET_DDL query
    snow sql -q "SELECT GET_DDL('$TYPE', '$FULLNAME')" --format json | \
        jq -r '.[0].GET_DDL' >> $OUTPUT_FILE
    
    echo "" >> $OUTPUT_FILE
done

echo ""
echo "✅ DDLs saved to: $OUTPUT_FILE"
echo ""
echo "Review the file and then add these DDLs to data_foundation.template.sql"

