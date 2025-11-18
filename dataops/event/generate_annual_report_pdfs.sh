#!/bin/bash
#
# Generate PDFs from Annual Report Markdown Files
#
# This script converts all 22 annual reports (markdown + HTML/CSS + SVG charts)
# into professional PDF documents
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Annual Reports PDF Generation                               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Create output directory
OUTPUT_DIR="annual_reports_pdfs"
mkdir -p "$OUTPUT_DIR"

# Check for required tools
if ! command -v pandoc &> /dev/null; then
    echo -e "${RED}Error: pandoc not found${NC}"
    echo "Install: brew install pandoc (Mac) or apt-get install pandoc (Linux)"
    exit 1
fi

if ! command -v wkhtmltopdf &> /dev/null; then
    echo -e "${RED}Error: wkhtmltopdf not found${NC}"
    echo "Install: brew install wkhtmltopdf (Mac) or apt-get install wkhtmltopdf (Linux)"
    exit 1
fi

echo -e "${GREEN}✓ Required tools found${NC}"
echo ""

# Convert FY2025 reports
echo "Converting FY2025 Annual Reports..."
echo ""

for file in annual_reports_2025/*.md; do
    if [ "$(basename "$file")" != "README.md" ]; then
        filename=$(basename "$file" .md)
        echo -n "  Converting $filename..."
        
        pandoc "$file" \
            -o "$OUTPUT_DIR/${filename}.pdf" \
            --pdf-engine=wkhtmltopdf \
            -V margin-top=15mm \
            -V margin-bottom=15mm \
            -V margin-left=15mm \
            -V margin-right=15mm \
            -V papersize=letter \
            --quiet \
            2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo -e " ${GREEN}✓${NC}"
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
        echo -n "  Converting $filename..."
        
        pandoc "$file" \
            -o "$OUTPUT_DIR/${filename}.pdf" \
            --pdf-engine=wkhtmltopdf \
            -V margin-top=15mm \
            -V margin-bottom=15mm \
            -V margin-left=15mm \
            -V margin-right=15mm \
            -V papersize=letter \
            --quiet \
            2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo -e " ${GREEN}✓${NC}"
        else
            echo -e " ${RED}✗${NC}"
        fi
    fi
done

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo ""

PDF_COUNT=$(ls -1 "$OUTPUT_DIR"/*.pdf 2>/dev/null | wc -l)
echo -e "${GREEN}Conversion complete!${NC}"
echo "  PDFs created: $PDF_COUNT"
echo "  Location: $(pwd)/$OUTPUT_DIR/"
echo ""

# List created PDFs
echo "Created PDFs:"
ls -1 "$OUTPUT_DIR"/*.pdf 2>/dev/null | sed 's/.*\//  - /' || echo "  (none created - check errors above)"
echo ""

