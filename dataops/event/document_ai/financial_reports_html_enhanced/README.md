# Enhanced Financial Reports - HTML Format

## Overview

Professional multi-page HTML financial reports for all 8 core companies, featuring:
- **Tailwind CSS** styling for modern, clean design
- **Company-specific branding** with custom color schemes
- **Comprehensive financial tables** optimized for table extraction
- **Print-ready layout** with proper page breaks
- **Responsive design** for web viewing

## Files Created

| Company | Ticker | File Size | Pages | Key Features |
|---------|--------|-----------|-------|--------------|
| Snowflake Inc. | SNOW | 112KB | 8 | Blue gradient header, detailed P&L |
| Neuro-Nectar | NRNT | 104KB | 8 | Pink branding, cognitive ice cream narrative |
| ICBG Data Systems | ICBG | 95KB | 8 | Green theme, open lakehouse positioning |
| Querybase Technologies | QRYQ | 89KB | 8 | Orange theme, competitive win rate tables |
| DataFlex Analytics | DFLX | 100KB | 8 | Purple theme, multi-platform analysis |
| StreamPipe Systems | STRM | 95KB | 8 | Cyan theme, real-time data metrics |
| Voltaic AI | VLTA | 101KB | 8 | Red theme, GPU compute and Gen AI stats |
| CatalogX | CTLG | 103KB | 8 | Indigo theme, compliance framework tables |

## Features

### Styling & Branding
- **Color-coded headers**: Each company has unique primary/secondary colors
- **Gradient header bars**: Professional look with company branding
- **Accent borders**: Visual hierarchy with colored left borders
- **Responsive tables**: Border-collapsed tables with proper alignment

### Table Features
- **Well-structured HTML tables** with `<thead>` and `<tbody>`
- **Semantic markup** for easy parsing by Document AI
- **Right-aligned numbers** for financial data
- **Bold formatting** for totals and key metrics
- **Consistent cell padding** and borders

### Print Optimization
- **Page breaks** between major sections
- **Print color preservation** with `print-color-adjust: exact`
- **Proper page sizing** for letter/A4 format
- **Footer information** on each page

## Viewing Instructions

### In Browser
1. Open any `.html` file in a web browser
2. Use browser zoom for comfortable reading
3. Tables are scrollable on smaller screens

### Printing to PDF
1. Open HTML file in browser (Chrome recommended)
2. File → Print (or Cmd/Ctrl + P)
3. Destination: "Save as PDF"
4. Settings:
   - Paper size: Letter
   - Margins: Default
   - Background graphics: ON
5. Save

## Technical Details

### HTML Structure
```html
<!DOCTYPE html>
<html>
  <head>
    <title>Company - Q2 FY2025 Financial Report</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>/* Print styles */</style>
  </head>
  <body>
    <div class="page"> <!-- Page 1 -->
      <div class="header-bar">Company Header</div>
      <div class="content">
        <h2>Page Title</h2>
        <table><!-- Financial tables --></table>
      </div>
    </div>
    <!-- More pages... -->
  </body>
</html>
```

### Table Structure (for Document AI)
```html
<table class="w-full border-collapse">
  <thead class="bg-gray-100">
    <tr>
      <th>Column Header 1</th>
      <th>Column Header 2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td class="text-left">Label</td>
      <td class="text-right">$123.4</td>
    </tr>
  </tbody>
</table>
```

## Document AI Table Extraction

These HTML reports are optimized for Snowflake Document AI table extraction:

### Key Tables in Each Report:
1. **Consolidated P&L Statement** (5 columns, 30+ rows)
2. **Operating Expenses Breakdown** (3-4 columns, 15+ rows)
3. **Balance Sheet** (3 columns, 25+ rows)
4. **Cash Flow Statement** (4 columns, 20+ rows)
5. **Key Operating Metrics** (5 quarters, 6+ metrics)
6. **Company-Specific Tables** (varies by company)

### Table Extraction Benefits:
- ✅ Clean HTML structure (no nested tables)
- ✅ Semantic `<thead>` and `<tbody>` tags
- ✅ Consistent cell alignment (left for text, right for numbers)
- ✅ Bold formatting for totals
- ✅ No merged cells (except where necessary)
- ✅ Numeric data properly formatted with $ and %

## Next Steps

### Option 1: Direct PDF Conversion
Use browser print functionality:
- Open HTML in Chrome
- Print → Save as PDF
- Enable background graphics

### Option 2: Automated PDF Generation
Use headless Chrome or similar:
```bash
# Using headless Chrome (requires Chrome installed)
chrome --headless --print-to-pdf=output.pdf input.html
```

### Option 3: Document AI Processing
1. Upload HTML or PDF files to Snowflake
2. Use Document AI to extract tables
3. Verify table extraction quality
4. Demonstrate multi-table extraction capabilities

## File Locations

- **Markdown source**: `../markdown_drafts/august_2024/*_ENHANCED.md`
- **HTML output**: `./*_Q2_FY2025_ENHANCED.html`
- **PDF output** (TBD): `../financial_reports_pdf/*_Q2_FY2025.pdf`
- **Conversion script**: `../convert_md_to_html.py`

## Quality Assurance

✅ All 8 companies generated  
✅ Company-specific branding applied  
✅ All tables properly formatted  
✅ Multi-page layout with page breaks  
✅ Print-ready CSS styles  
✅ Consistent narrative with `DATA/companies.csv`  

---

**Generated**: October 23, 2024  
**Purpose**: Table extraction demonstration for Snowflake Document AI  
**Format**: HTML5 with Tailwind CSS  
**Tool**: Python conversion script from enhanced markdown

