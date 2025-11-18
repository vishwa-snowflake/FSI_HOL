#!/bin/bash
# Regenerate Sterling Partners PDFs with consistent text extraction settings

# Navigate to the directory
cd "$(dirname "$0")"

echo "Regenerating Sterling Partners PDFs for consistent text extraction..."

# Output directory
OUTPUT_DIR="synthetic_analyst_reports"

# Use Python with weasyprint for better text extraction consistency
python3 << 'PYTHON_SCRIPT'
import os
from weasyprint import HTML
from pathlib import Path

svg_dir = Path("svg_files")
output_dir = Path("synthetic_analyst_reports")

# Sterling Partners HTML files
sterling_files = [
    ("Sterling Partners Report (Aug 22, 2024).html", "Sterling_Partners_Report_2024-08-22.pdf"),
    ("Sterling Partners Report (Sep 25, 2024).html", "Sterling_Partners_Report_2024-09-25.pdf"),
    ("Sterling Partners Report (Nov 22, 2024) .html", "Sterling_Partners_Report_2024-11-22.pdf"),
    ("Sterling Partners Report (Feb 22, 2025).html", "Sterling_Partners_Report_2025-02-22.pdf"),
    ("Sterling Partners Report (May 23, 2025).html", "Sterling_Partners_Report_2025-05-23.pdf"),
]

for html_file, pdf_file in sterling_files:
    html_path = svg_dir / html_file
    pdf_path = output_dir / pdf_file
    
    if html_path.exists():
        print(f"Converting {html_file} -> {pdf_file}")
        try:
            HTML(filename=str(html_path)).write_pdf(
                str(pdf_path),
                optimize_size=('fonts', 'images')  # Optimize but keep text extractable
            )
            print(f"  ✓ Successfully created {pdf_file}")
        except Exception as e:
            print(f"  ✗ Error: {e}")
    else:
        print(f"  ⚠ HTML file not found: {html_file}")

print("\nDone! All Sterling Partners PDFs regenerated with consistent text extraction.")
PYTHON_SCRIPT


