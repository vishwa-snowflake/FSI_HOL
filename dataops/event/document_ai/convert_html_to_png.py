#!/usr/bin/env python3
"""
Convert HTML infographic files to PNG using Chrome headless
"""
import subprocess
import os
from pathlib import Path

# Configuration
CHROME_PATH = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
INFOGRAPHICS_DIR = Path(__file__).parent / "infographics_simple"
WINDOW_SIZE = "1754,1900"

companies = ["SNOW", "ICBG", "QRYQ", "DFLX", "STRM", "VLTA", "CTLG", "NRNT"]

print("=" * 64)
print("Converting Infographics HTML to PNG")
print("=" * 64)
print()

if not Path(CHROME_PATH).exists():
    print(f"❌ Google Chrome not found at: {CHROME_PATH}")
    exit(1)

for ticker in companies:
    html_file = INFOGRAPHICS_DIR / f"{ticker}_Earnings_Infographic_FY25-Q2.html"
    png_file = INFOGRAPHICS_DIR / f"{ticker}_Earnings_Infographic_FY25-Q2.png"
    
    if not html_file.exists():
        print(f"⚠️  HTML file not found: {ticker}")
        continue
    
    print(f"Converting {ticker}...")
    
    try:
        result = subprocess.run([
            CHROME_PATH,
            "--headless=new",
            "--disable-gpu",
            f"--screenshot={png_file}",
            f"--window-size={WINDOW_SIZE}",
            "--hide-scrollbars",
            f"file://{html_file.absolute()}"
        ], capture_output=True, text=True, timeout=10)
        
        if result.returncode != 0:
            print(f"  ✗ Chrome error: {result.stderr}")
            continue
        
        if png_file.exists():
            size_kb = png_file.stat().st_size / 1024
            print(f"  ✓ Created {ticker}_Earnings_Infographic_FY25-Q2.png ({size_kb:.1f}KB)")
        else:
            print(f"  ✗ Failed to create PNG")
    except subprocess.TimeoutExpired:
        print(f"  ✗ Timeout converting {ticker}")
    except subprocess.CalledProcessError as e:
        print(f"  ✗ Error converting {ticker}: {e}")

print()
print("=" * 64)
print("✅ PNG conversion complete!")
print("=" * 64)
print()
print(f"Files saved to: {INFOGRAPHICS_DIR}")
print()
print("📤 Upload to Snowflake:")
print(f"   PUT file://{INFOGRAPHICS_DIR}/*.png @DOCUMENT_AI.INFOGRAPHICS AUTO_COMPRESS=FALSE;")


