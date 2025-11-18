#!/usr/bin/env python3
"""
Convert summary markdown reports (with charts) to HTML
"""

import re
from pathlib import Path

# Company branding colors (same as before)
COMPANY_COLORS = {
    'SNOW': {'primary': '#29B5E8', 'secondary': '#1E3A8A'},
    'NRNT': {'primary': '#EC4899', 'secondary': '#BE185D'},
    'ICBG': {'primary': '#10B981', 'secondary': '#047857'},
    'QRYQ': {'primary': '#F59E0B', 'secondary': '#D97706'},
    'DFLX': {'primary': '#8B5CF6', 'secondary': '#6D28D9'},
    'STRM': {'primary': '#06B6D4', 'secondary': '#0E7490'},
    'VLTA': {'primary': '#EF4444', 'secondary': '#B91C1C'},
    'CTLG': {'primary': '#6366F1', 'secondary': '#4338CA'},
}

def convert_md_to_html(md_path, ticker):
    """Convert markdown summary report to HTML"""
    
    with open(md_path, 'r') as f:
        content = f.read()
    
    colors = COMPANY_COLORS.get(ticker, COMPANY_COLORS['SNOW'])
    
    # Extract title
    title_match = re.search(r'# (.+)', content)
    title = title_match.group(1) if title_match else ticker
    
    # Start HTML
    html = f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title} - Q2 FY2025 Summary</title>
    <style>
        @page {{ size: A4; margin: 15mm; }}
        @media print {{
            * {{ print-color-adjust: exact; -webkit-print-color-adjust: exact; }}
            .page {{ page-break-after: always; }}
        }}
        
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            font-size: 9pt;
            line-height: 1.4;
            color: #1a1a1a;
            max-width: 210mm;
            margin: 0 auto;
            padding: 0;
        }}
        
        .header {{
            background: linear-gradient(135deg, {colors['primary']}, {colors['secondary']});
            color: white;
            padding: 10mm 15mm;
            margin-bottom: 8mm;
        }}
        
        .header h1 {{ font-size: 18pt; margin: 0 0 2mm 0; }}
        .header p {{ font-size: 10pt; opacity: 0.9; margin: 0; }}
        
        h2 {{
            font-size: 14pt;
            color: {colors['primary']};
            margin: 6mm 0 3mm 0;
            border-left: 4mm solid {colors['primary']};
            padding-left: 3mm;
        }}
        
        h3 {{ font-size: 11pt; color: #333; margin: 4mm 0 2mm 0; }}
        
        table {{
            width: 100%;
            border-collapse: collapse;
            margin: 3mm 0 5mm 0;
            font-size: 8.5pt;
        }}
        
        th {{
            background: #f5f5f5;
            border: 0.5pt solid #999;
            padding: 2mm;
            text-align: left;
            font-weight: 600;
        }}
        
        td {{
            border: 0.5pt solid #ccc;
            padding: 1.5mm 2mm;
        }}
        
        td:nth-child(n+2) {{ text-align: right; font-family: 'Courier New', monospace; }}
        
        pre {{
            background: #f8f8f8;
            border: 1pt solid #ddd;
            border-radius: 2mm;
            padding: 3mm;
            font-size: 8pt;
            overflow-x: auto;
            line-height: 1.3;
        }}
        
        ul {{ margin: 2mm 0 2mm 6mm; }}
        li {{ margin-bottom: 1mm; }}
        p {{ margin: 0 0 2mm 0; }}
        
        .content {{ padding: 0 15mm 10mm 15mm; }}
    </style>
</head>
<body>
    <div class="header">
        <h1>{title}</h1>
        <p>Q2 Fiscal Year 2025 Financial Results</p>
    </div>
    <div class="content">
'''
    
    # Process content
    lines = content.split('\n')
    in_table = False
    in_code_block = False
    table_lines = []
    
    for i, line in enumerate(lines):
        line = line.strip()
        
        # Skip initial title section
        if i < 10:
            continue
        
        # Handle code blocks (charts)
        if line.startswith('```'):
            if not in_code_block:
                html += '<pre>\n'
                in_code_block = True
            else:
                html += '</pre>\n'
                in_code_block = False
            continue
        
        if in_code_block:
            html += line + '\n'
            continue
        
        # Handle headers
        if line.startswith('## '):
            html += f'<h2>{line[3:]}</h2>\n'
        elif line.startswith('### '):
            html += f'<h3>{line[4:]}</h3>\n'
        
        # Handle tables
        elif '|' in line and not line.startswith('|---|'):
            if not in_table:
                in_table = True
                table_lines = [line]
            else:
                table_lines.append(line)
        elif in_table and '|' not in line:
            # End of table
            html += convert_table(table_lines)
            table_lines = []
            in_table = False
            # Process current line
            if line and line != '---':
                if line.startswith('**') and line.endswith('**'):
                    html += f'<p><strong>{line[2:-2]}</strong></p>\n'
                elif line.startswith('-'):
                    html += f'<li>{line[1:].strip()}</li>\n'
                elif line:
                    html += f'<p>{line}</p>\n'
        
        # Regular text
        elif not in_table and line and line != '---':
            if line.startswith('**') and ':' in line:
                html += f'<p><strong>{line.replace("**", "")}</strong></p>\n'
            elif line.startswith('-'):
                html += f'<li>{line[1:].strip()}</li>\n'
            elif line:
                html += f'<p>{line}</p>\n'
    
    html += '''
    </div>
</body>
</html>
'''
    
    return html

def convert_table(lines):
    """Convert markdown table to HTML"""
    if len(lines) < 2:
        return ""
    
    # Parse header
    header = [c.strip() for c in lines[0].split('|')[1:-1]]
    
    # Parse rows (skip separator)
    rows = []
    for line in lines[2:]:
        cells = [c.strip() for c in line.split('|')[1:-1]]
        if cells:
            rows.append(cells)
    
    html = '<table>\n<thead>\n<tr>\n'
    for cell in header:
        html += f'<th>{cell.replace("**", "")}</th>\n'
    html += '</tr>\n</thead>\n<tbody>\n'
    
    for row in rows:
        html += '<tr>\n'
        for cell in row:
            html += f'<td>{cell.replace("**", "")}</td>\n'
        html += '</tr>\n'
    
    html += '</tbody>\n</table>\n'
    return html

def main():
    """Convert all summary markdown reports to HTML"""
    input_dir = Path('markdown_drafts/august_2024')
    output_dir = Path('../financial_reports_html')
    output_dir.mkdir(exist_ok=True)
    
    companies = ['SNOW', 'NRNT', 'ICBG', 'QRYQ', 'DFLX', 'STRM', 'VLTA', 'CTLG']
    
    print("Converting summary reports to HTML...\n")
    
    for ticker in companies:
        md_file = input_dir / f'{ticker}_Q2_FY2025.md'
        html_file = output_dir / f'{ticker}_Q2_FY2025_Summary.html'
        
        if md_file.exists():
            print(f'Converting {ticker}...')
            html = convert_md_to_html(md_file, ticker)
            
            with open(html_file, 'w') as f:
                f.write(html)
            
            print(f'  ✓ Created {html_file.name}')
    
    print(f'\n✅ Summary HTML files created in {output_dir}')

if __name__ == '__main__':
    main()

