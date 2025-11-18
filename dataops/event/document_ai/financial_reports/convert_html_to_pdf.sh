#!/bin/bash
# Convert HTML financial reports to PDF using headless Chrome

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
INPUT_DIR="$(pwd)/../financial_reports_html_enhanced"
OUTPUT_DIR="$(pwd)/../financial_reports_pdf"

companies=("SNOW" "NRNT" "ICBG" "QRYQ" "DFLX" "STRM" "VLTA" "CTLG")

echo "Converting HTML to PDF using Google Chrome..."
echo ""

for ticker in "${companies[@]}"; do
    input_file="${INPUT_DIR}/${ticker}_Q2_FY2025_ENHANCED.html"
    output_file="${OUTPUT_DIR}/${ticker}_Q2_FY2025.pdf"
    
    if [ -f "$input_file" ]; then
        echo "Converting ${ticker}..."
        "$CHROME" \
            --headless \
            --disable-gpu \
            --no-pdf-header-footer \
            --print-to-pdf="$output_file" \
            "file://${input_file}" \
            2>/dev/null
        
        if [ -f "$output_file" ]; then
            size=$(ls -lh "$output_file" | awk '{print $5}')
            echo "  ✓ Created ${ticker}_Q2_FY2025.pdf (${size})"
        else
            echo "  ✗ Failed to create PDF"
        fi
    else
        echo "  ✗ ${ticker}_Q2_FY2025_ENHANCED.html not found"
    fi
done

echo ""
echo "✅ PDF conversion complete! Files saved to ${OUTPUT_DIR}"
echo ""
echo "To view PDFs:"
echo "  open ${OUTPUT_DIR}/*.pdf"

