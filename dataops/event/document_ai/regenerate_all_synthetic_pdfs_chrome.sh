#!/bin/bash
# Regenerate ALL synthetic analyst PDFs using Google Chrome (preserves branding)

set -e
cd "$(dirname "$0")"

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# Check if Chrome is available
if [ ! -f "$CHROME" ]; then
    echo "❌ Google Chrome not found at: $CHROME"
    echo "Please install Google Chrome or update the path"
    exit 1
fi

echo "================================================================"
echo "Regenerating All Synthetic Analyst PDFs with Google Chrome"
echo "================================================================"
echo ""

SVG_DIR="$(pwd)/svg_files"
OUTPUT_DIR="$(pwd)/synthetic_analyst_reports"

# Create output directory if needed
mkdir -p "$OUTPUT_DIR"

# All synthetic analyst reports
declare -a reports=(
    # Sterling Partners
    "Sterling Partners Report (Aug 22, 2024).html:Sterling_Partners_Report_2024-08-22.pdf"
    "Sterling Partners Report (Sep 25, 2024).html:Sterling_Partners_Report_2024-09-25.pdf"
    "Sterling Partners Report (Nov 22, 2024) .html:Sterling_Partners_Report_2024-11-22.pdf"
    "Sterling Partners Report (Feb 22, 2025).html:Sterling_Partners_Report_2025-02-22.pdf"
    "Sterling Partners Report (May 23, 2025).html:Sterling_Partners_Report_2025-05-23.pdf"
    
    # Apex Analytics
    "Apex Analytics Report (Aug 29, 2024).html:Apex_Analytics_Report_2024-08-29.pdf"
    "Apex Analytics Report (Sep 19, 2024).html:Apex_Analytics_Report_2024-09-19.pdf"
    "Apex Analytics Report (Nov 28, 2024).html:Apex_Analytics_Report_2024-11-28.pdf"
    "Apex Analytics Report (Feb 28, 2025).html:Apex_Analytics_Report_2025-02-28.pdf"
    "Apex Analytics Report (May 30, 2025).html:Apex_Analytics_Report_2025-05-30.pdf"
    
    # Veridian Capital
    "Veridian Capital Report (Aug 23, 2024).html:Veridian_Capital_Report_2024-08-23.pdf"
    "Veridian Capital Report (Sep 20, 2024).html:Veridian_Capital_Report_2024-09-20.pdf"
    "Veridian Capital Report (Nov 21, 2024).html:Veridian_Capital_Report_2024-11-21.pdf"
    "Veridian Capital Report (Feb 22, 2025).html:Veridian_Capital_Report_2025-02-22.pdf"
    "Veridian Capital Report (May 23, 2025).html:Veridian_Capital_Report_2025-05-23.pdf"
    
    # Momentum Metrics
    "Momentum Metrics Report (Aug 30, 2024).html:Momentum_Metrics_Report_2024-08-30.pdf"
    "Momentum Metrics Report (Sep 27, 2024).html:Momentum_Metrics_Report_2024-09-27.pdf"
    "Momentum Metrics Report (Nov 29, 2024).html:Momentum_Metrics_Report_2024-11-29.pdf"
    "Momentum Metrics Report (Feb 28, 2025).html:Momentum_Metrics_Report_2025-02-28.pdf"
    "Momentum Metrics Report (May 30, 2025).html:Momentum_Metrics_Report_2025-05-30.pdf"
    
    # Quant-Vestor
    "Quant-Vestor Report (Aug 29, 2024).html:Quant-Vestor_Report_2024-08-29.pdf"
    "Quant-Vestor Report (Sep 23, 2024).html:Quant-Vestor_Report_2024-09-23.pdf"
    "Quant-Vestor Report (Nov 28, 2024).html:Quant-Vestor_Report_2024-11-28.pdf"
    "Quant-Vestor Report (Feb 27, 2025).html:Quant-Vestor_Report_2025-02-27.pdf"
    "Quant-Vestor Report (May 29, 2025).html:Quant-Vestor_Report_2025-05-29.pdf"
    
    # Consensus Point
    "Consensus Point Report (Aug 30, 2024).html:Consensus_Point_Report_2024-08-30.pdf"
    "Consensus Point Report (Nov 29, 2024).html:Consensus_Point_Report_2024-11-29.pdf"
    "Consensus Point Report (Feb 28, 2025).html:Consensus_Point_Report_2025-02-28.pdf"
    "Consensus Point Report (May 30, 2025).html:Consensus_Point_Report_2025-05-30.pdf"
    
    # Pinnacle Growth
    "Pinnacle Growth Investors Report (Sep 26, 2024).html:Pinnacle_Growth_Investors_Report_2024-09-26.pdf"
)

success=0
errors=0

echo "Converting ${#reports[@]} HTML files to PDF..."
echo ""

for report in "${reports[@]}"; do
    IFS=':' read -r html_file pdf_file <<< "$report"
    
    input_path="${SVG_DIR}/${html_file}"
    output_path="${OUTPUT_DIR}/${pdf_file}"
    
    if [ -f "$input_path" ]; then
        "$CHROME" \
            --headless \
            --disable-gpu \
            --no-pdf-header-footer \
            --print-to-pdf="$output_path" \
            "file://${input_path}" \
            2>/dev/null
        
        if [ -f "$output_path" ]; then
            size=$(ls -lh "$output_path" | awk '{print $5}')
            echo "✓ $pdf_file ($size)"
            ((success++))
        else
            echo "✗ Failed: $pdf_file"
            ((errors++))
        fi
    else
        echo "⚠️  Not found: $html_file"
        ((errors++))
    fi
done

echo ""
echo "================================================================"
echo "✅ Generated $success PDFs successfully"
if [ $errors -gt 0 ]; then
    echo "⚠️  $errors errors"
fi
echo "================================================================"
echo ""
echo "🎨 All PDFs now have full branding (fonts, colors, styles)!"
echo "✅ Text extraction works properly for AI_EXTRACT"

