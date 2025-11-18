#!/bin/bash
# Convert simplified financial reports HTML to PDF using Chrome

set -e
cd "$(dirname "$0")"

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

if [ ! -f "$CHROME" ]; then
    echo "❌ Google Chrome not found"
    exit 1
fi

echo "Converting simplified financial reports to PDF..."
echo ""

INPUT_DIR="$(pwd)/financial_reports_html_simple"
OUTPUT_DIR="$(pwd)/financial_reports_pdf_simple"

mkdir -p "$OUTPUT_DIR"

# Core 8 companies (Q2 FY2025)
companies_q2=("SNOW" "ICBG" "QRYQ" "DFLX" "STRM" "VLTA" "CTLG" "NRNT")

# Bottom 3 performers (different quarters)
# PROP: Q1, GAME: Q3, MKTG: Q3
companies_other=(
    "PROP:Q1"
    "GAME:Q3"
    "MKTG:Q3"
)

# Convert Q2 companies
for ticker in "${companies_q2[@]}"; do
    input_file="${INPUT_DIR}/${ticker}_Q2_FY2025_SIMPLE.html"
    output_file="${OUTPUT_DIR}/${ticker}_Q2_FY2025_SIMPLE.pdf"
    
    if [ -f "$input_file" ]; then
        "$CHROME" \
            --headless \
            --disable-gpu \
            --no-pdf-header-footer \
            --print-to-pdf="$output_file" \
            "file://${input_file}" \
            2>/dev/null
        
        if [ -f "$output_file" ]; then
            size=$(ls -lh "$output_file" | awk '{print $5}')
            echo "✓ ${ticker}_Q2_FY2025_SIMPLE.pdf ($size)"
        else
            echo "✗ Failed: $ticker"
        fi
    else
        echo "⚠️  HTML not found: $ticker"
    fi
done

# Convert bottom 3 performers (different quarters)
for entry in "${companies_other[@]}"; do
    ticker="${entry%%:*}"
    quarter="${entry##*:}"
    
    input_file="${INPUT_DIR}/${ticker}_${quarter}_FY2025_SIMPLE.html"
    output_file="${OUTPUT_DIR}/${ticker}_${quarter}_FY2025_SIMPLE.pdf"
    
    if [ -f "$input_file" ]; then
        "$CHROME" \
            --headless \
            --disable-gpu \
            --no-pdf-header-footer \
            --print-to-pdf="$output_file" \
            "file://${input_file}" \
            2>/dev/null
        
        if [ -f "$output_file" ]; then
            size=$(ls -lh "$output_file" | awk '{print $5}')
            echo "✓ ${ticker}_${quarter}_FY2025_SIMPLE.pdf ($size)"
        else
            echo "✗ Failed: $ticker $quarter"
        fi
    else
        echo "⚠️  HTML not found: ${ticker}_${quarter}_FY2025_SIMPLE.html"
    fi
done

echo ""
echo "✅ PDF conversion complete!"
echo "   Output: $OUTPUT_DIR"
echo ""
echo "📤 Next: Upload to Snowflake stage"
echo "   PUT file://${OUTPUT_DIR}/*.pdf @DOCUMENT_AI.FINANCIAL_REPORTS AUTO_COMPRESS=FALSE;"

