#!/bin/bash
# Convert infographic HTMLs to PNG using Chrome
#
# Chrome can take screenshots in headless mode

set -e
cd "$(dirname "$0")"

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

if [ ! -f "$CHROME" ]; then
    echo "❌ Google Chrome not found"
    exit 1
fi

echo "Converting infographics HTML to PNG..."
echo ""

INPUT_DIR="$(pwd)/infographics_simple"
OUTPUT_DIR="$INPUT_DIR"

# Core 8 companies (Q2)
companies_q2=("SNOW" "ICBG" "QRYQ" "DFLX" "STRM" "VLTA" "CTLG" "NRNT")

# Bottom 3 performers (different quarters)
# PROP: Q1, GAME: Q3, MKTG: Q3
companies_other=(
    "PROP:Q1"
    "GAME:Q3"
    "MKTG:Q3"
)

# Convert bottom 3 performers only (others already exist)
for entry in "${companies_other[@]}"; do
    ticker="${entry%%:*}"
    quarter="${entry##*:}"
    
    input_file="${INPUT_DIR}/${ticker}_Earnings_Infographic_FY25-${quarter}.html"
    output_file="${INPUT_DIR}/${ticker}_Earnings_Infographic_FY25-${quarter}.png"
    
    if [ -f "$input_file" ]; then
        "$CHROME" \
            --headless \
            --disable-gpu \
            --window-size=1200,1900 \
            --screenshot="$output_file" \
            "file://${input_file}" \
            2>/dev/null
        
        if [ -f "$output_file" ]; then
            size=$(ls -lh "$output_file" | awk '{print $5}')
            echo "✓ ${ticker}_Earnings_Infographic_FY25-${quarter}.png ($size)"
        else
            echo "✗ Failed: $ticker $quarter"
        fi
    else
        echo "⚠️  HTML not found: ${ticker}_Earnings_Infographic_FY25-${quarter}.html"
    fi
done

echo ""
echo "✅ PNG conversion complete!"
echo "   Output: $OUTPUT_DIR"
echo ""
echo "Total infographics:"
ls -1 "$INPUT_DIR"/*.png 2>/dev/null | wc -l | awk '{print "   " $1 " PNG files"}'
echo ""
echo "📤 Next: Upload to Snowflake stage"
echo "   PUT file://${INPUT_DIR}/*.png @DOCUMENT_AI.INFOGRAPHICS AUTO_COMPRESS=FALSE;"
