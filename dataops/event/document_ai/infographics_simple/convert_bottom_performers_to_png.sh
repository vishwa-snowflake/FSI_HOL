#!/bin/bash

# Convert bottom performer infographic HTMLs to PNG
# Since automated tools aren't available, this script provides instructions

echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║   Convert Bottom Performer Infographics HTML → PNG                      ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "HTML files created:"
echo "  ✅ PROP_Earnings_Infographic_FY25-Q1.html (Red theme)"
echo "  ✅ GAME_Earnings_Infographic_FY25-Q3.html (Purple theme)"
echo "  ✅ MKTG_Earnings_Infographic_FY25-Q3.html (Orange theme)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "OPTION 1: Browser Screenshot (Recommended)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Opening HTML files in browser..."
echo ""

# Open each HTML file in default browser
open "PROP_Earnings_Infographic_FY25-Q1.html"
sleep 2
open "GAME_Earnings_Infographic_FY25-Q3.html"  
sleep 2
open "MKTG_Earnings_Infographic_FY25-Q3.html"

echo "✅ HTML files opened in browser"
echo ""
echo "Manual Steps:"
echo "  1. For each open tab, press CMD+Shift+4 then Space"
echo "  2. Click on the browser window to capture"
echo "  3. Save screenshots as:"
echo "     - PROP_Earnings_Infographic_FY25-Q1.png"
echo "     - GAME_Earnings_Infographic_FY25-Q3.png"
echo "     - MKTG_Earnings_Infographic_FY25-Q3.png"
echo "  4. Move PNG files to this directory"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "OPTION 2: Automated Conversion (Requires Installation)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Install wkhtmltoimage:"
echo "  brew install wkhtmltopdf"
echo ""
echo "Then run:"
echo "  wkhtmltoimage --width 1200 --height 1900 PROP_Earnings_Infographic_FY25-Q1.html PROP_Earnings_Infographic_FY25-Q1.png"
echo "  wkhtmltoimage --width 1200 --height 1900 GAME_Earnings_Infographic_FY25-Q3.html GAME_Earnings_Infographic_FY25-Q3.png"
echo "  wkhtmltoimage --width 1200 --height 1900 MKTG_Earnings_Infographic_FY25-Q3.html MKTG_Earnings_Infographic_FY25-Q3.png"
echo ""
echo "✅ Once PNGs are created, they'll be ready for Snowflake upload!"

