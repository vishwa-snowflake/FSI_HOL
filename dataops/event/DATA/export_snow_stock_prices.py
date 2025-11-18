#!/usr/bin/env python3
"""
Export STOCK_PRICE_TIMESERIES for SNOW ticker only to Parquet format
"""

import snowflake.connector
import pandas as pd
from pathlib import Path

def export_snow_stock_prices():
    """Export stock price timeseries for SNOW ticker to Parquet file"""
    
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
        print("Connected. Fetching SNOW ticker data from STOCK_PRICE_TIMESERIES...")
        
        # Query only SNOW ticker data
        query = """
        SELECT * 
        FROM ORGDATACLOUD$INTERNAL$TRANSCRIPTS_FROM_EARNINGS_CALLS.ACCELERATE_WITH_AI_DOC_AI.STOCK_PRICE_TIMESERIES
        WHERE TICKER = 'SNOW'
        ORDER BY DATE
        """
        
        # Use pandas to read directly into DataFrame
        df = pd.read_sql(query, conn)
        
        print(f"Fetched {len(df):,} rows")
        print(f"Date range: {df['DATE'].min()} to {df['DATE'].max()}")
        print(f"Columns: {list(df.columns)}")
        
        # Write to parquet with compression
        output_file = Path(__file__).parent / 'stock_price_timeseries_snow.parquet'
        df.to_parquet(
            output_file,
            engine='pyarrow',
            compression='snappy',
            index=False
        )
        
        import os
        file_size = os.path.getsize(output_file)
        print(f"\n✅ Successfully exported to Parquet!")
        print(f"   File: {output_file.name}")
        print(f"   Size: {file_size / 1024:.2f} KB")
        print(f"   Rows: {len(df):,}")
        
        # Show sample data
        print("\nSample data (first 5 rows):")
        print(df.head().to_string())
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        raise
    finally:
        conn.close()
        print("\nConnection closed.")

if __name__ == '__main__':
    export_snow_stock_prices()

