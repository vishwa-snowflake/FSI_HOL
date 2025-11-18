#!/bin/bash
#
# Generate PDFs from Annual Reports - Modern Approach
# Uses Chromium/Chrome headless (no discontinued tools)
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Annual Reports PDF Generation (Modern Method)              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Create output directory
OUTPUT_DIR="annual_reports_pdfs"
mkdir -p "$OUTPUT_DIR"

# Find Chrome/Chromium
CHROME=""
if [ -f "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then
    CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
elif [ -f "/Applications/Chromium.app/Contents/MacOS/Chromium" ]; then
    CHROME="/Applications/Chromium.app/Contents/MacOS/Chromium"
elif command -v google-chrome &> /dev/null; then
    CHROME="google-chrome"
elif command -v chromium &> /dev/null; then
    CHROME="chromium"
fi

if [ -z "$CHROME" ]; then
    echo -e "${RED}Error: Chrome or Chromium not found${NC}"
    echo ""
    echo "Install Google Chrome from: https://www.google.com/chrome/"
    echo "Or use the browser manual method (see GENERATE_PDFS_INSTRUCTIONS.md)"
    exit 1
fi

echo -e "${GREEN}✓ Found Chrome/Chromium${NC}"
echo ""

# Function to convert markdown to PDF via Chrome
convert_md_to_pdf() {
    local md_file=$1
    local pdf_file=$2
    local filename=$(basename "$md_file" .md)
    
    # Create temporary HTML
    local temp_html="/tmp/${filename}_$(date +%s).html"
    
    # Convert markdown to HTML with embedded styles
    cat > "$temp_html" << 'HTMLHEAD'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            line-height: 1.6;
            color: #1a1a1a;
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            font-size: 14px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 10px;
            text-align: left;
        }
        th {
            background: #f5f5f5;
            font-weight: 600;
        }
        h2 {
            margin-top: 30px;
            padding-bottom: 10px;
        }
        h3 {
            margin-top: 20px;
        }
        img {
            max-width: 100%;
            height: auto;
            display: block;
            margin: 20px auto;
        }
        @page {
            margin: 15mm;
        }
    </style>
</head>
<body>
HTMLHEAD
    
    # Append markdown content (it contains HTML already)
    cat "$md_file" >> "$temp_html"
    
    cat >> "$temp_html" << 'HTMLFOOT'
</body>
</html>
HTMLFOOT
    
    # Convert HTML to PDF using Chrome headless
    "$CHROME" \
        --headless \
        --disable-gpu \
        --print-to-pdf="$pdf_file" \
        --no-pdf-header-footer \
        "$temp_html" \
        2>/dev/null
    
    # Cleanup
    rm -f "$temp_html"
    
    if [ -f "$pdf_file" ]; then
        return 0
    else
        return 1
    fi
}

# Convert FY2025 reports
echo "Converting FY2025 Annual Reports..."
echo ""

converted=0
for file in annual_reports_2025/*.md; do
    if [ "$(basename "$file")" != "README.md" ]; then
        filename=$(basename "$file" .md)
        pdf_path="$OUTPUT_DIR/${filename}.pdf"
        
        echo -n "  $filename..."
        
        if convert_md_to_pdf "$file" "$pdf_path"; then
            echo -e " ${GREEN}✓${NC}"
            ((converted++))
        else
            echo -e " ${RED}✗${NC}"
        fi
    fi
done

echo ""
echo "Converting FY2024 Annual Reports..."
echo ""

for file in annual_reports_2024/*.md; do
    if [ "$(basename "$file")" != "README.md" ]; then
        filename=$(basename "$file" .md)
        pdf_path="$OUTPUT_DIR/${filename}.pdf"
        
        echo -n "  $filename..."
        
        if convert_md_to_pdf "$file" "$pdf_path"; then
            echo -e " ${GREEN}✓${NC}"
            ((converted++))
        else
            echo -e " ${RED}✗${NC}"
        fi
    fi
done

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo -e "${GREEN}Conversion complete!${NC}"
echo "  PDFs created: $converted"
echo "  Location: $(pwd)/$OUTPUT_DIR/"
echo ""
echo "Created files:"
ls -1 "$OUTPUT_DIR"/*.pdf 2>/dev/null | sed 's/.*\//  - /' || echo "  (Check for errors above)"
echo ""

