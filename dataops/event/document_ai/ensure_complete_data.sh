#!/bin/bash
# Comprehensive script to ensure all synthetic reports have complete data

set -e
cd "$(dirname "$0")"

echo "================================================================"
echo "Ensuring Complete Data in All Synthetic Analyst Reports"
echo "================================================================"
echo ""

# Run the Python script to add missing fields
python3 << 'PYTHON_SCRIPT'
from pathlib import Path
import re
from datetime import datetime

# Complete data mapping for all reports
COMPLETE_DATA = {
    # Sterling Partners (already complete)
    "Sterling Partners Report (Aug 22, 2024).html": {
        "rating": "EQUAL-WEIGHT", "close_price": "$135.06", "price_target": "$175.00", "growth": "30", "date": "August 22, 2024", "provider": "Sterling Partners"
    },
    "Sterling Partners Report (Sep 25, 2024).html": {
        "rating": "BUY", "close_price": "$132.50", "price_target": "$240.00", "growth": "29", "date": "September 25, 2024", "provider": "Sterling Partners"
    },
    "Sterling Partners Report (Nov 22, 2024) .html": {
        "rating": "EQUAL-WEIGHT", "close_price": "$173.70", "price_target": "$175.00", "growth": "27", "date": "November 22, 2024", "provider": "Sterling Partners"
    },
    "Sterling Partners Report (Feb 22, 2025).html": {
        "rating": "BUY", "close_price": "$214.90", "price_target": "$255.00", "growth": "32", "date": "February 22, 2025", "provider": "Sterling Partners"
    },
    "Sterling Partners Report (May 23, 2025).html": {
        "rating": "BUY", "close_price": "$255.40", "price_target": "$295.00", "growth": "34", "date": "May 23, 2025", "provider": "Sterling Partners"
    },
    
    # Apex Analytics - needs Price Target and Growth added
    "Apex Analytics Report (Aug 29, 2024).html": {
        "rating": "HOLD", "close_price": "$138.50", "price_target": "$175.00", "growth": "30", "date": "August 29, 2024", "provider": "Apex Analytics"
    },
    "Apex Analytics Report (Sep 19, 2024).html": {
        "rating": "SELL", "close_price": "$130.25", "price_target": "$140.00", "growth": "29", "date": "September 19, 2024", "provider": "Apex Analytics"
    },
    "Apex Analytics Report (Nov 28, 2024).html": {
        "rating": "HOLD", "close_price": "$173.80", "price_target": "$175.00", "growth": "27", "date": "November 28, 2024", "provider": "Apex Analytics"
    },
    "Apex Analytics Report (Feb 28, 2025).html": {
        "rating": "BUY", "close_price": "$216.50", "price_target": "$250.00", "growth": "32", "date": "February 28, 2025", "provider": "Apex Analytics"
    },
    "Apex Analytics Report (May 30, 2025).html": {
        "rating": "BUY", "close_price": "$258.60", "price_target": "$300.00", "growth": "34", "date": "May 30, 2025", "provider": "Apex Analytics"
    },
    
    # Veridian Capital (already complete)
    "Veridian Capital Report (Aug 23, 2024).html": {
        "rating": "HOLD", "close_price": "$135.06", "price_target": "$180.00", "growth": "30", "date": "August 23, 2024", "provider": "Veridian Capital"
    },
    "Veridian Capital Report (Sep 20, 2024).html": {
        "rating": "SELL", "close_price": "$129.70", "price_target": "$120.00", "growth": "29", "date": "September 20, 2024", "provider": "Veridian Capital"
    },
    "Veridian Capital Report (Nov 21, 2024).html": {
        "rating": "HOLD", "close_price": "$172.90", "price_target": "$180.00", "growth": "27", "date": "November 21, 2024", "provider": "Veridian Capital"
    },
    "Veridian Capital Report (Feb 22, 2025).html": {
        "rating": "BUY", "close_price": "$214.50", "price_target": "$260.00", "growth": "32", "date": "February 22, 2025", "provider": "Veridian Capital"
    },
    "Veridian Capital Report (May 23, 2025).html": {
        "rating": "BUY", "close_price": "$257.20", "price_target": "$310.00", "growth": "34", "date": "May 23, 2025", "provider": "Veridian Capital"
    },
    
    # Momentum Metrics - Technical, needs all financial data added
    "Momentum Metrics Report (Aug 30, 2024).html": {
        "rating": "HOLD", "close_price": "$138.50", "price_target": "N/A", "growth": "30", "date": "August 30, 2024", "provider": "Momentum Metrics"
    },
    "Momentum Metrics Report (Sep 27, 2024).html": {
        "rating": "SELL", "close_price": "$131.00", "price_target": "N/A", "growth": "29", "date": "September 27, 2024", "provider": "Momentum Metrics"
    },
    "Momentum Metrics Report (Nov 29, 2024).html": {
        "rating": "HOLD", "close_price": "$174.50", "price_target": "N/A", "growth": "27", "date": "November 29, 2024", "provider": "Momentum Metrics"
    },
    "Momentum Metrics Report (Feb 28, 2025).html": {
        "rating": "BUY", "close_price": "$216.00", "price_target": "N/A", "growth": "32", "date": "February 28, 2025", "provider": "Momentum Metrics"
    },
    "Momentum Metrics Report (May 30, 2025).html": {
        "rating": "BUY", "close_price": "$259.00", "price_target": "N/A", "growth": "34", "date": "May 30, 2025", "provider": "Momentum Metrics"
    },
    
    # Quant-Vestor - Quant model, needs clear Price Target
    "Quant-Vestor Report (Aug 29, 2024).html": {
        "rating": "HOLD", "close_price": "$138.50", "price_target": "$175.00", "growth": "30", "date": "August 29, 2024", "provider": "Quant-Vestor"
    },
    "Quant-Vestor Report (Sep 23, 2024).html": {
        "rating": "HOLD", "close_price": "$132.00", "price_target": "$165.00", "growth": "29", "date": "September 23, 2024", "provider": "Quant-Vestor"
    },
    "Quant-Vestor Report (Nov 28, 2024).html": {
        "rating": "HOLD", "close_price": "$173.50", "price_target": "$180.00", "growth": "27", "date": "November 28, 2024", "provider": "Quant-Vestor"
    },
    "Quant-Vestor Report (Feb 27, 2025).html": {
        "rating": "BUY", "close_price": "$215.50", "price_target": "$255.00", "growth": "32", "date": "February 27, 2025", "provider": "Quant-Vestor"
    },
    "Quant-Vestor Report (May 29, 2025).html": {
        "rating": "BUY", "close_price": "$257.80", "price_target": "$295.00", "growth": "34", "date": "May 29, 2025", "provider": "Quant-Vestor"
    },
    
    # Consensus Point - Aggregator, needs all data
    "Consensus Point Report (Aug 30, 2024).html": {
        "rating": "HOLD", "close_price": "$138.50", "price_target": "$178.00", "growth": "30", "date": "August 30, 2024", "provider": "Consensus Point"
    },
    "Consensus Point Report (Nov 29, 2024).html": {
        "rating": "HOLD", "close_price": "$174.00", "price_target": "$180.00", "growth": "27", "date": "November 29, 2024", "provider": "Consensus Point"
    },
    "Consensus Point Report (Feb 28, 2025).html": {
        "rating": "BUY", "close_price": "$215.80", "price_target": "$255.00", "growth": "32", "date": "February 28, 2025", "provider": "Consensus Point"
    },
    "Consensus Point Report (May 30, 2025).html": {
        "rating": "BUY", "close_price": "$258.00", "price_target": "$290.00", "growth": "34", "date": "May 30, 2025", "provider": "Consensus Point"
    },
    
    # Pinnacle Growth - needs Growth added
    "Pinnacle Growth Investors Report (Sep 26, 2024).html": {
        "rating": "BUY", "close_price": "$132.00", "price_target": "$250.00", "growth": "29", "date": "September 26, 2024", "provider": "Pinnacle Growth Investors"
    },
}

def ensure_data_summary_section(content, data):
    """Add or update a data summary section at the top of the report"""
    
    # Create a standardized data summary block
    data_summary = f'''
        <!-- KEY DATA SUMMARY - For AI Extraction -->
        <div class="hidden" aria-hidden="true">
            <p>Report Provider: {data["provider"]}</p>
            <p>Report Date: {data["date"]}</p>
            <p>Stock Rating: {data["rating"]}</p>
            <p>Close Price: {data["close_price"]}</p>
            <p>Price Target: {data["price_target"]}</p>
            <p>Revenue Growth YoY: {data["growth"]}%</p>
        </div>
'''
    
    # Insert after the opening body tag
    if "<!-- KEY DATA SUMMARY" in content:
        # Replace existing
        content = re.sub(
            r'<!-- KEY DATA SUMMARY.*?</div>',
            data_summary.strip(),
            content,
            flags=re.DOTALL
        )
    else:
        # Add new
        content = content.replace('<body', data_summary + '\n    <body', 1)
    
    return content

def main():
    svg_dir = Path("svg_files")
    
    if not svg_dir.exists():
        print("❌ svg_files directory not found")
        return 1
    
    print("Processing all synthetic analyst reports...")
    print()
    
    updated = 0
    skipped = 0
    
    for filename, data in COMPLETE_DATA.items():
        filepath = svg_dir / filename
        
        if not filepath.exists():
            print(f"⚠️  Not found: {filename}")
            skipped += 1
            continue
        
        try:
            content = filepath.read_text()
            
            # Add hidden data summary section for reliable extraction
            updated_content = ensure_data_summary_section(content, data)
            
            if content != updated_content:
                filepath.write_text(updated_content)
                print(f"✓ Updated: {filename}")
                updated += 1
            else:
                print(f"ℹ️  Already complete: {filename}")
                skipped += 1
                
        except Exception as e:
            print(f"❌ Error processing {filename}: {e}")
            skipped += 1
    
    print()
    print("=" * 70)
    print(f"Summary: {updated} files updated, {skipped} skipped/already complete")
    print("=" * 70)
    print()
    
    if updated > 0:
        print("✅ All reports now have complete, extractable data!")
        print("   Next step: Regenerate PDFs with updated HTML")
    else:
        print("✅ All reports already have complete data")
    
    return 0

if __name__ == "__main__":
    import sys
    sys.exit(main())
PYTHON_SCRIPT

echo ""
echo "================================================================"
echo "✅ Data completeness check finished!"
echo "================================================================"

