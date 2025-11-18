#!/usr/bin/env python3
"""
Convert enhanced markdown financial reports to professional HTML optimized for A4 printing
"""

import re
from pathlib import Path

# Company branding colors
COMPANY_COLORS = {
    'SNOW': {'primary': '#29B5E8', 'secondary': '#1E3A8A', 'accent': '#60A5FA'},
    'NRNT': {'primary': '#EC4899', 'secondary': '#BE185D', 'accent': '#F472B6'},
    'ICBG': {'primary': '#10B981', 'secondary': '#047857', 'accent': '#6EE7B7'},
    'QRYQ': {'primary': '#F59E0B', 'secondary': '#D97706', 'accent': '#FBBF24'},
    'DFLX': {'primary': '#8B5CF6', 'secondary': '#6D28D9', 'accent': '#A78BFA'},
    'STRM': {'primary': '#06B6D4', 'secondary': '#0E7490', 'accent': '#67E8F9'},
    'VLTA': {'primary': '#EF4444', 'secondary': '#B91C1C', 'accent': '#F87171'},
    'CTLG': {'primary': '#6366F1', 'secondary': '#4338CA', 'accent': '#818CF8'},
}

def parse_table(lines):
    """Convert markdown table to HTML table optimized for A4 printing"""
    if not lines or len(lines) < 2:
        return ""
    
    # Parse header
    header_row = [cell.strip() for cell in lines[0].split('|')[1:-1]]
    num_cols = len(header_row)
    
    # Skip separator line (line 1)
    # Parse data rows
    rows = []
    for line in lines[2:]:
        if line.strip():
            cells = [cell.strip() for cell in line.split('|')[1:-1]]
            if cells and len(cells) == num_cols:  # Ensure consistent column count
                rows.append(cells)
    
    # Build HTML table with full width
    html = '<table class="financial-table">\n'
    html += '  <thead>\n    <tr>\n'
    for cell in header_row:
        cell_clean = cell.replace('**', '')
        html += f'      <th>{cell_clean}</th>\n'
    html += '    </tr>\n  </thead>\n  <tbody>\n'
    
    for row in rows:
        html += '    <tr>\n'
        for i, cell in enumerate(row):
            # Check if this is a bold cell
            if cell.startswith('**') and cell.endswith('**'):
                cell_clean = cell.replace('**', '')
                html += f'      <td class="font-bold">{cell_clean}</td>\n'
            else:
                # Right-align numeric columns (columns with $ or %)
                align_class = "text-right" if (i > 0 and ('$' in cell or '%' in cell or cell.replace(',', '').replace('.', '').replace('-', '').replace('(', '').replace(')', '').lstrip('$').isdigit())) else ""
                html += f'      <td class="{align_class}">{cell}</td>\n'
        html += '    </tr>\n'
    
    html += '  </tbody>\n</table>\n'
    return html

def convert_md_to_html(md_path, ticker):
    """Convert a markdown financial report to A4-optimized HTML"""
    
    with open(md_path, 'r') as f:
        content = f.read()
    
    # Get company colors
    colors = COMPANY_COLORS.get(ticker, COMPANY_COLORS['SNOW'])
    
    # Split into lines
    lines = content.split('\n')
    
    # Extract title info
    title_match = re.search(r'# (.+)', content)
    title = title_match.group(1) if title_match else ticker
    
    # Start building HTML with A4-optimized CSS
    html = f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title} - Q2 FY2025 Financial Report</title>
    <style>
        /* A4 Page Setup */
        @page {{
            size: A4;
            margin: 15mm 15mm 15mm 15mm;
        }}
        
        @media print {{
            html, body {{
                width: 210mm;
                height: 297mm;
            }}
            
            body {{
                margin: 0;
                padding: 0;
            }}
            
            .page {{
                page-break-after: always;
                width: 100%;
                height: 297mm;
                padding: 0;
                margin: 0;
                box-sizing: border-box;
            }}
            
            .page:last-child {{
                page-break-after: auto;
            }}
            
            * {{
                print-color-adjust: exact;
                -webkit-print-color-adjust: exact;
            }}
        }}
        
        /* Base Styles */
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            font-size: 9pt;
            line-height: 1.3;
            color: #1a1a1a;
            background: white;
        }}
        
        .page {{
            width: 210mm;
            min-height: 297mm;
            padding: 0;
            margin: 0 auto;
            background: white;
            position: relative;
        }}
        
        /* Header Styles */
        .header-bar {{
            background: linear-gradient(135deg, {colors['primary']} 0%, {colors['secondary']} 100%);
            color: white;
            padding: 12mm 15mm;
            margin: 0;
        }}
        
        .header-bar h1 {{
            font-size: 18pt;
            font-weight: 700;
            margin-bottom: 3mm;
        }}
        
        .header-bar p {{
            font-size: 10pt;
            opacity: 0.95;
        }}
        
        /* Content Area */
        .content {{
            padding: 8mm 15mm 15mm 15mm;
        }}
        
        .page-title {{
            font-size: 14pt;
            font-weight: 700;
            color: #1a1a1a;
            margin-bottom: 5mm;
            padding-left: 4mm;
            border-left: 4mm solid {colors['primary']};
        }}
        
        h3 {{
            font-size: 11pt;
            font-weight: 600;
            color: #4a4a4a;
            margin-top: 5mm;
            margin-bottom: 3mm;
        }}
        
        p {{
            margin-bottom: 2mm;
            line-height: 1.4;
        }}
        
        .font-bold {{
            font-weight: 700;
        }}
        
        .font-semibold {{
            font-weight: 600;
        }}
        
        ul {{
            margin-left: 6mm;
            margin-bottom: 3mm;
        }}
        
        li {{
            margin-bottom: 1mm;
            line-height: 1.4;
        }}
        
        /* Table Styles - Full Width A4 */
        .financial-table {{
            width: 100%;
            border-collapse: collapse;
            margin: 3mm 0 5mm 0;
            font-size: 8.5pt;
        }}
        
        .financial-table thead {{
            background-color: #f5f5f5;
        }}
        
        .financial-table th {{
            border: 0.5pt solid #999;
            padding: 2mm 2mm;
            text-align: left;
            font-weight: 600;
            font-size: 8pt;
            color: #1a1a1a;
        }}
        
        .financial-table td {{
            border: 0.5pt solid #ccc;
            padding: 1.5mm 2mm;
            text-align: left;
            font-size: 8.5pt;
        }}
        
        .financial-table td.text-right {{
            text-align: right;
            font-family: 'Courier New', Courier, monospace;
        }}
        
        .financial-table td.font-bold {{
            font-weight: 700;
            background-color: #fafafa;
        }}
        
        .financial-table tbody tr:nth-child(even) {{
            background-color: #fefefe;
        }}
        
        /* Empty row styling */
        .financial-table tr:has(td:first-child:empty) {{
            height: 3mm;
            background-color: white !important;
        }}
        
        .financial-table tr:has(td:first-child:empty) td {{
            border-top: none;
            border-bottom: none;
        }}
        
        /* Screen-only styles */
        @media screen {{
            body {{
                background: #e5e5e5;
                padding: 10mm;
            }}
            
            .page {{
                box-shadow: 0 0 10mm rgba(0,0,0,0.1);
                margin-bottom: 10mm;
            }}
        }}
    </style>
</head>
<body>
'''
    
    # Process content
    i = 0
    in_table = False
    table_lines = []
    page_count = 0
    
    while i < len(lines):
        line = lines[i].strip()
        
        # Skip the main title (already used)
        if i < 5:
            i += 1
            continue
        
        # Page headers
        if line.startswith('## PAGE'):
            if page_count > 0:
                html += '    </div>\n</div>\n'  # Close previous page
            
            page_count += 1
            page_title = line.replace('## PAGE', '').strip()
            
            html += f'''<div class="page">
    <div class="header-bar">
        <h1>{title}</h1>
        <p>Q2 Fiscal Year 2025 Financial Results</p>
    </div>
    <div class="content">
        <h2 class="page-title">{page_title}</h2>
'''
        
        # Section headers (###)
        elif line.startswith('###'):
            heading = line.replace('###', '').strip()
            html += f'        <h3>{heading}</h3>\n'
        
        # Detect table start
        elif '|' in line and not in_table:
            in_table = True
            table_lines = [line]
        
        # Continue table
        elif '|' in line and in_table:
            table_lines.append(line)
        
        # End of table
        elif in_table and '|' not in line:
            html += '        ' + parse_table(table_lines).replace('\n', '\n        ')
            table_lines = []
            in_table = False
            # Process the current line too
            if line and line != '---':
                if line.startswith('**') and line.endswith('**'):
                    text = line.replace('**', '')
                    html += f'        <p class="font-bold">{text}</p>\n'
                elif line.startswith('*') and line.endswith('*') and not line.startswith('**'):
                    text = line.replace('*', '')
                    html += f'        <p style="font-style: italic; color: #666;">{text}</p>\n'
                elif line.startswith('-'):
                    html += f'        <li>{line[1:].strip()}</li>\n'
                elif line.strip():
                    html += f'        <p>{line}</p>\n'
        
        # Regular text
        elif not in_table and line and line != '---':
            if line.startswith('**') and ':' in line:
                # Bold labels
                html += f'        <p class="font-semibold">{line.replace("**", "")}</p>\n'
            elif line.startswith('-'):
                # Bullet points
                html += f'        <li>{line[1:].strip()}</li>\n'
            elif line.strip():
                html += f'        <p>{line}</p>\n'
        
        i += 1
    
    # Close last page
    if page_count > 0:
        html += '''    </div>
</div>
'''
    
    # Close HTML
    html += '''</body>
</html>
'''
    
    return html

def main():
    """Convert all enhanced markdown reports to A4-optimized HTML"""
    input_dir = Path('markdown_drafts/august_2024')
    output_dir = Path('../financial_reports_html_enhanced')
    output_dir.mkdir(exist_ok=True)
    
    companies = ['SNOW', 'NRNT', 'ICBG', 'QRYQ', 'DFLX', 'STRM', 'VLTA', 'CTLG']
    
    print("Converting to A4-optimized HTML...")
    print()
    
    for ticker in companies:
        md_file = input_dir / f'{ticker}_Q2_FY2025_ENHANCED.md'
        html_file = output_dir / f'{ticker}_Q2_FY2025_ENHANCED.html'
        
        if md_file.exists():
            print(f'Converting {ticker}...')
            html_content = convert_md_to_html(md_file, ticker)
            
            with open(html_file, 'w') as f:
                f.write(html_content)
            
            print(f'  ✓ Created {html_file.name} (A4-optimized)')
        else:
            print(f'  ✗ {md_file.name} not found')
    
    print(f'\n✅ Conversion complete! Files saved to {output_dir}')
    print(f'\nA4 Specifications:')
    print(f'  - Page size: 210mm × 297mm')
    print(f'  - Margins: 15mm all sides')
    print(f'  - Content width: 180mm')
    print(f'  - Tables: Full width with optimized font sizes')

if __name__ == '__main__':
    main()

