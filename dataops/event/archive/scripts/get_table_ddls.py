#!/usr/bin/env python3
"""
Script to get DDLs for all tables/views used in semantic views
"""
import snowflake.connector
import os
from datetime import datetime

# Objects to fetch DDLs for
OBJECTS = [
    ("TABLE", "ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.INFOGRAPHICS_FOR_SEARCH"),
    ("VIEW", "ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SENTIMENT_WITH_TRANSCRIPTS_FOR_SEARCH"),
    ("VIEW", "ACCELERATE_AI_IN_FSI.DOCUMENT_AI.VW_FINANCIAL_SUMMARY"),
    ("VIEW", "ACCELERATE_AI_IN_FSI.DOCUMENT_AI.VW_INCOME_STATEMENT"),
    ("VIEW", "ACCELERATE_AI_IN_FSI.DOCUMENT_AI.VW_KPI_METRICS"),
    ("TABLE", "ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.TRANSCRIBED_EARNINGS_CALLS_WITH_SENTIMENT"),
    ("TABLE", "ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.TRANSCRIPTS_BY_MINUTE"),
    ("TABLE", "ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.SENTIMENT_ANALYSIS"),
    ("VIEW", "ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.STOCK_PRICE_TIMESERIES"),
    ("TABLE", "ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.ANALYST_REPORTS"),
    ("VIEW", "ACCELERATE_AI_IN_FSI.DOCUMENT_AI.VW_INFOGRAPHIC_METRICS"),
    ("TABLE", "ACCELERATE_AI_IN_FSI.DOCUMENT_AI.INFOGRAPHIC_METRICS_EXTRACTED"),
    ("TABLE", "ACCELERATE_AI_IN_FSI.DOCUMENT_AI.ANALYST_REPORTS_ALL_DATA"),
    ("TABLE", "ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.AI_TRANSCRIPTS_ANALYSTS_SENTIMENTS"),
]

def get_connection():
    """Get Snowflake connection using environment variables or default config"""
    # Try to use snowsql config if available
    return snowflake.connector.connect(
        authenticator='externalbrowser'
    )

def main():
    output_file = "semantic_view_tables_ddls.sql"
    
    print("Connecting to Snowflake...")
    conn = get_connection()
    cursor = conn.cursor()
    
    with open(output_file, 'w') as f:
        f.write("-- DDLs for tables/views used in semantic views\n")
        f.write(f"-- Generated on {datetime.now()}\n")
        f.write("\n")
        
        for obj_type, full_name in OBJECTS:
            print(f"Fetching DDL for {obj_type}: {full_name}")
            
            f.write("\n")
            f.write(f"-- {'=' * 60}\n")
            f.write(f"-- {obj_type}: {full_name}\n")
            f.write(f"-- {'=' * 60}\n")
            
            try:
                query = f"SELECT GET_DDL('{obj_type}', '{full_name}')"
                cursor.execute(query)
                result = cursor.fetchone()
                
                if result:
                    ddl = result[0]
                    f.write(ddl)
                    f.write(";\n\n")
                else:
                    f.write(f"-- ERROR: No DDL returned for {full_name}\n\n")
                    
            except Exception as e:
                f.write(f"-- ERROR: {str(e)}\n\n")
                print(f"  ⚠️  Error: {str(e)}")
    
    cursor.close()
    conn.close()
    
    print(f"\n✅ DDLs saved to: {output_file}")
    print("\nReview the file and then I'll add these DDLs to data_foundation.template.sql")

if __name__ == "__main__":
    main()

