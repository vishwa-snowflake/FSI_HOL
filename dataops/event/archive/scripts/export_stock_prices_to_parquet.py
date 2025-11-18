#!/usr/bin/env python3
"""
Export STOCK_PRICE_TIMESERIES from external data share to Parquet format
This is a large dataset (84M+ rows) so we use Snowflake's native COPY INTO for efficiency
"""

import snowflake.connector
import os
from pathlib import Path

def export_to_parquet():
    """Export stock price timeseries to Parquet file using Snowflake COPY INTO"""
    
    print("Connecting to Snowflake...")
    
    conn = snowflake.connector.connect(
        account='sfsehol-test_fsi_ai_assistant_upgrades_mlxttt',
        user='USER',
        password='sn0wf@ll',
        warehouse='DEFAULT_WH',
        database='ACCELERATE_AI_IN_FSI',
        schema='DEFAULT_SCHEMA'
    )
    
    try:
        cursor = conn.cursor()
        
        # Get row count
        print("Getting row count...")
        cursor.execute("""
            SELECT COUNT(*) 
            FROM ORGDATACLOUD$INTERNAL$TRANSCRIPTS_FROM_EARNINGS_CALLS.ACCELERATE_WITH_AI_DOC_AI.STOCK_PRICE_TIMESERIES
        """)
        row_count = cursor.fetchone()[0]
        print(f"Total rows to export: {row_count:,}")
        
        # Create temporary stage for export
        print("\nCreating temporary stage for export...")
        cursor.execute("""
            CREATE OR REPLACE TEMPORARY STAGE ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.stock_export_stage
            FILE_FORMAT = (TYPE = PARQUET COMPRESSION = SNAPPY)
        """)
        print("✓ Stage created")
        
        # Copy data to stage as Parquet
        print("\nExporting data to Parquet (this will take several minutes)...")
        cursor.execute("""
            COPY INTO @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.stock_export_stage/stock_price_timeseries
            FROM (
                SELECT * 
                FROM ORGDATACLOUD$INTERNAL$TRANSCRIPTS_FROM_EARNINGS_CALLS.ACCELERATE_WITH_AI_DOC_AI.STOCK_PRICE_TIMESERIES
            )
            FILE_FORMAT = (TYPE = PARQUET COMPRESSION = SNAPPY)
            HEADER = TRUE
            OVERWRITE = TRUE
            MAX_FILE_SIZE = 268435456
        """)
        result = cursor.fetchall()
        print(f"✓ Data exported to stage")
        print(f"  Files created: {len(result)}")
        for row in result[:5]:  # Show first 5 files
            print(f"    - {row[0]} ({row[1]:,} rows)")
        if len(result) > 5:
            print(f"    ... and {len(result) - 5} more files")
        
        # Get the exported files
        print("\nDownloading Parquet files from stage...")
        output_dir = Path(__file__).parent
        
        cursor.execute(f"""
            GET @ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.stock_export_stage 
            file://{output_dir}/
            PATTERN = '.*stock_price_timeseries.*'
        """)
        
        get_result = cursor.fetchall()
        print(f"✓ Downloaded {len(get_result)} file(s)")
        
        total_size = 0
        for row in get_result:
            file_name = row[0]
            file_size = row[1]
            total_size += file_size
            print(f"  - {file_name}: {file_size / 1024**2:.2f} MB")
        
        print(f"\n✅ Successfully exported to Parquet!")
        print(f"   Location: {output_dir}")
        print(f"   Total size: {total_size / 1024**2:.2f} MB")
        print(f"   Total rows: {row_count:,}")
        
        # Clean up stage
        print("\nCleaning up temporary stage...")
        cursor.execute("DROP STAGE IF EXISTS ACCELERATE_AI_IN_FSI.DEFAULT_SCHEMA.stock_export_stage")
        print("✓ Cleanup complete")
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        raise
    finally:
        cursor.close()
        conn.close()
        print("\nConnection closed.")

if __name__ == '__main__':
    export_to_parquet()
