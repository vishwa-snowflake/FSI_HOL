#!/usr/bin/env python3
"""
Convert enhanced markdown financial reports to professional HTML with Tailwind CSS
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
    """Convert markdown table to HTML table"""
    if not lines or len(lines) < 2:
        return ""
    
    # Parse header
    header_row = [cell.strip() for cell in lines[0].split('|')[1:-1]]
    
    # Skip separator line (line 1)
    # Parse data rows
    rows = []
    for line in lines[2:]:
        if line.strip():
            cells = [cell.strip() for cell in line.split('|')[1:-1]]
            if cells:
                rows.append(cells)
    
    # Build HTML table
    html = '<table class="w-full border-collapse mb-6">\n'
    html += '  <thead class="bg-gray-100">\n    <tr>\n'
    for cell in header_row:
        cell_clean = cell.replace('**', '')
        html += f'      <th class="border border-gray-300 px-3 py-2 text-left text-sm font-semibold">{cell_clean}</th>\n'
    html += '    </tr>\n  </thead>\n  <tbody>\n'
    
    for row in rows:
        html += '    <tr>\n'
        for i, cell in enumerate(row):
            # Check if this is a bold cell
            if cell.startswith('**') and cell.endswith('**'):
                cell_clean = cell.replace('**', '')
                html += f'      <td class="border border-gray-300 px-3 py-2 text-sm font-bold">{cell_clean}</td>\n'
            else:
                # Right-align numeric columns (columns with $ or %)
                align_class = "text-right" if (i > 0 and ('$' in cell or '%' in cell or cell.replace(',', '').replace('.', '').replace('-', '').replace('(', '').replace(')', '').isdigit())) else "text-left"
                html += f'      <td class="border border-gray-300 px-3 py-2 text-sm {align_class}">{cell}</td>\n'
        html += '    </tr>\n'
    
    html += '  </tbody>\n</table>\n'
    return html

def convert_md_to_html(md_path, ticker):
    """Convert a markdown financial report to HTML"""
    
    with open(md_path, 'r') as f:
        content = f.read()
    
    # Get company colors
    colors = COMPANY_COLORS.get(ticker, COMPANY_COLORS['SNOW'])
    
    # Split into lines
    lines = content.split('\n')
    
    # Extract title info
    title_match = re.search(r'# (.+)', content)
    title = title_match.group(1) if title_match else ticker
    
    # Start building HTML
    html = f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title} - Q2 FY2025 Financial Report</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        @media print {{
            .page-break {{
                page-break-after: always;
            }}
            body {{
                print-color-adjust: exact;
                -webkit-print-color-adjust: exact;
            }}
        }}
        .header-bar {{
            background: linear-gradient(135deg, {colors['primary']} 0%, {colors['secondary']} 100%);
        }}
        .accent-border {{
            border-left: 4px solid {colors['primary']};
        }}
    </style>
</head>
<body class="bg-white text-gray-900">
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
                html += '</div>\n'  # Close previous page
            page_count += 1
            page_title = line.replace('## PAGE', '').strip()
            page_class = "page-break" if page_count > 1 else ""
            html += f'''
<div class="min-h-screen p-8 {page_class}">
    <div class="header-bar text-white px-6 py-4 mb-6">
        <h1 class="text-2xl font-bold">{title}</h1>
        <p class="text-sm opacity-90">Q2 Fiscal Year 2025 Financial Results</p>
    </div>
    <div class="px-6">
        <h2 class="text-xl font-bold mb-4 accent-border pl-4">{page_title}</h2>
'''
        
        # Section headers (###)
        elif line.startswith('###'):
            heading = line.replace('###', '').strip()
            html += f'<h3 class="text-lg font-semibold text-gray-700 mt-6 mb-3">{heading}</h3>\n'
        
        # Detect table start
        elif '|' in line and not in_table:
            in_table = True
            table_lines = [line]
        
        # Continue table
        elif '|' in line and in_table:
            table_lines.append(line)
        
        # End of table
        elif in_table and '|' not in line:
            html += parse_table(table_lines)
            table_lines = []
            in_table = False
            # Process the current line too
            if line and line != '---':
                if line.startswith('**') and line.endswith('**'):
                    text = line.replace('**', '')
                    html += f'<p class="font-bold mb-2">{text}</p>\n'
                elif line.startswith('*') and line.endswith('*') and not line.startswith('**'):
                    text = line.replace('*', '')
                    html += f'<p class="italic text-gray-600 mb-2">{text}</p>\n'
                elif line.startswith('-'):
                    html += f'<li class="ml-6 mb-1 text-sm">{line[1:].strip()}</li>\n'
                elif line.strip():
                    html += f'<p class="mb-2 text-sm">{line}</p>\n'
        
        # Regular text
        elif not in_table and line and line != '---':
            if line.startswith('**') and ':' in line:
                # Bold labels
                html += f'<p class="font-semibold mb-2 text-sm">{line.replace("**", "")}</p>\n'
            elif line.startswith('-'):
                # Bullet points
                html += f'<li class="ml-6 mb-1 text-sm">{line[1:].strip()}</li>\n'
            elif line.strip():
                html += f'<p class="mb-2 text-sm leading-relaxed">{line}</p>\n'
        
        i += 1
    
    # Close last page
    if page_count > 0:
        html += '''
    </div>
</div>
'''
    
    # Close HTML
    html += '''
</body>
</html>
'''
    
    return html

def main():
    """Convert all enhanced markdown reports to HTML"""
    input_dir = Path('markdown_drafts/august_2024')
    output_dir = Path('../financial_reports_html_enhanced')
    output_dir.mkdir(exist_ok=True)
    
    companies = ['SNOW', 'NRNT', 'ICBG', 'QRYQ', 'DFLX', 'STRM', 'VLTA', 'CTLG']
    
    for ticker in companies:
        md_file = input_dir / f'{ticker}_Q2_FY2025_ENHANCED.md'
        html_file = output_dir / f'{ticker}_Q2_FY2025_ENHANCED.html'
        
        if md_file.exists():
            print(f'Converting {ticker}...')
            html_content = convert_md_to_html(md_file, ticker)
            
            with open(html_file, 'w') as f:
                f.write(html_content)
            
            print(f'  ✓ Created {html_file.name}')
        else:
            print(f'  ✗ {md_file.name} not found')
    
    print(f'\n✅ Conversion complete! Files saved to {output_dir}')

if __name__ == '__main__':
    main()

