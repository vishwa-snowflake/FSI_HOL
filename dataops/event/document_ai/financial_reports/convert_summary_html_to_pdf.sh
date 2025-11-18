#!/bin/bash
# Convert summary HTML reports to PDF

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
INPUT_DIR="$(pwd)/../financial_reports_html"
OUTPUT_DIR="$(pwd)/../financial_reports_pdf"

companies=("SNOW" "NRNT" "ICBG" "QRYQ" "DFLX" "STRM" "VLTA" "CTLG")

echo "Converting summary HTML to PDF..."
echo ""

for ticker in "${companies[@]}"; do
    input_file="${INPUT_DIR}/${ticker}_Q2_FY2025_Summary.html"
    output_file="${OUTPUT_DIR}/${ticker}_Q2_FY2025_Summary.pdf"
    
    if [ -f "$input_file" ]; then
        echo "Converting ${ticker} Summary..."
        "$CHROME" \
            --headless \
            --disable-gpu \
            --no-pdf-header-footer \
            --print-to-pdf="$output_file" \
            "file://${input_file}" \
            2>/dev/null
        
        if [ -f "$output_file" ]; then
            size=$(ls -lh "$output_file" | awk '{print $5}')
            echo "  ✓ Created ${ticker}_Q2_FY2025_Summary.pdf (${size})"
        else
            echo "  ✗ Failed to create PDF"
        fi
    else
        echo "  ✗ ${ticker}_Q2_FY2025_Summary.html not found"
    fi
done

echo ""
echo "✅ Summary PDF conversion complete!"

