#!/bin/bash
# Script to get DDLs for all tables/views used in semantic views using SnowSQL

OUTPUT_FILE="semantic_view_tables_ddls.sql"
TEMP_FILE="temp_ddl.txt"

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
    
    # Use snowsql to execute the GET_DDL query
    snowsql -o output_format=plain -o header=false -o timing=false -o friendly=false \
        -q "SELECT GET_DDL('$TYPE', '$FULLNAME');" > $TEMP_FILE 2>/dev/null
    
    # Append the result to output file
    cat $TEMP_FILE >> $OUTPUT_FILE
    echo "" >> $OUTPUT_FILE
done

# Clean up temp file
rm -f $TEMP_FILE

echo ""
echo "✅ DDLs saved to: $OUTPUT_FILE"
echo ""
echo "Review the file and then I'll add these DDLs to data_foundation.template.sql"

