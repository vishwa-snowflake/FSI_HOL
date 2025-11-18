#!/usr/bin/env python3
"""
Add Growth percentage naturally to reports that are missing it
"""

from pathlib import Path
import re

# Growth data for each report
GROWTH_DATA = {
    "Apex Analytics Report (Sep 19, 2024).html": "29",
    "Consensus Point Report (Aug 30, 2025).html": "38",
    "Consensus Point Report (Feb 28, 2025).html": "32",
    "Momentum Metrics Report (Aug 30, 2024).html": "30",
    "Momentum Metrics Report (Aug 30, 2025).html": "38",
    "Momentum Metrics Report (Feb 28, 2025).html": "32",
    "Momentum Metrics Report (Nov 29, 2024).html": "27",
    "Momentum Metrics Report (Sep 27, 2024).html": "29",
    "Pinnacle Growth Investors Report (Sep 26, 2024).html": "29",
    "Veridian Capital Report (Aug 23, 2024).html": "30",
    "Veridian Capital Report (Sep 20, 2024).html": "29",
}

def add_growth_to_report(filepath, growth_pct):
    """Add growth percentage naturally to report content"""
    content = filepath.read_text()
    
    # Strategy 1: Add to table with Close Price and Price Target
    table_pattern = r'(<tr[^>]*>\s*<td[^>]*>Price Target</td>\s*<td[^>]*>.*?</td>\s*</tr>)'
    if re.search(table_pattern, content):
        replacement = r'\1\n                        <tr class="border-b"><td class="py-2 font-semibold">Product Revenue Growth (YoY)</td><td class="text-right font-bold">' + growth_pct + '%</td></tr>'
        content = re.sub(table_pattern, replacement, content, count=1)
        filepath.write_text(content)
        return True
    
    # Strategy 2: Add to div-based Stock Summary/Key Metrics
    div_pattern = r'(<div class="flex justify-between"><span>Price Target[^<]*</span>.*?</div>)'
    if re.search(div_pattern, content, re.DOTALL):
        replacement = r'\1<div class="flex justify-between"><span>Product Revenue Growth (YoY):</span> <span class="font-semibold">' + growth_pct + '%</span></div>'
        content = re.sub(div_pattern, replacement, content, count=1, flags=re.DOTALL)
        filepath.write_text(content)
        return True
    
    # Strategy 3: For Momentum Metrics - add after Close Price
    if "Momentum Metrics" in filepath.name:
        close_price_pattern = r'(<div class="text-center bg-gray-700 p-3 rounded-md"><p class="text-sm">Close Price</p><p class="text-2xl font-bold text-white">\$[\d,]+\.?\d*</p></div>)'
        if re.search(close_price_pattern, content):
            replacement = r'\1\n                <div class="text-center bg-gray-700 p-3 rounded-md mt-4"><p class="text-sm">Revenue Growth (YoY)</p><p class="text-2xl font-bold text-green-400">' + growth_pct + '%</p></div>'
            content = re.sub(close_price_pattern, replacement, content, count=1)
            filepath.write_text(content)
            return True
    
    return False

def main():
    svg_dir = Path("svg_files")
    
    print("Adding Growth percentage naturally to reports...")
    print()
    
    updated = 0
    failed = 0
    
    for filename, growth in GROWTH_DATA.items():
        filepath = svg_dir / filename
        
        if not filepath.exists():
            print(f"⚠️  Not found: {filename}")
            failed += 1
            continue
        
        if add_growth_to_report(filepath, growth):
            print(f"✓ Added {growth}% growth to: {filename}")
            updated += 1
        else:
            print(f"✗ Could not add growth to: {filename}")
            failed += 1
    
    print()
    print("=" * 60)
    print(f"✅ Updated {updated} reports")
    if failed > 0:
        print(f"⚠️  {failed} failed")
    print("=" * 60)
    print()
    print("All Growth data now naturally embedded in visible content!")

if __name__ == "__main__":
    main()

