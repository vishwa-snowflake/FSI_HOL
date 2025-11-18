#!/bin/bash
# Regenerate ALL synthetic analyst PDFs with corrected HTML structure

set -e
cd "$(dirname "$0")"

echo "================================================================"
echo "Regenerating All Synthetic Analyst PDFs"
echo "================================================================"
echo ""

# Create/activate virtual environment
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
    echo "✓ Virtual environment created"
else
    echo "✓ Using existing virtual environment"
fi
echo ""

source venv/bin/activate

# Install dependencies if needed
echo "Checking dependencies..."
pip install -q weasyprint pillow
echo "✓ Dependencies ready"
echo ""

# Regenerate all PDFs
python3 << 'PYTHON_SCRIPT'
from weasyprint import HTML
from pathlib import Path

svg_dir = Path("svg_files")
output_dir = Path("synthetic_analyst_reports")
output_dir.mkdir(exist_ok=True)

# All synthetic analyst reports
reports_to_generate = [
    # Sterling Partners
    ("Sterling Partners Report (Aug 22, 2024).html", "Sterling_Partners_Report_2024-08-22.pdf"),
    ("Sterling Partners Report (Sep 25, 2024).html", "Sterling_Partners_Report_2024-09-25.pdf"),
    ("Sterling Partners Report (Nov 22, 2024) .html", "Sterling_Partners_Report_2024-11-22.pdf"),
    ("Sterling Partners Report (Feb 22, 2025).html", "Sterling_Partners_Report_2025-02-22.pdf"),
    ("Sterling Partners Report (May 23, 2025).html", "Sterling_Partners_Report_2025-05-23.pdf"),
    
    # Apex Analytics  
    ("Apex Analytics Report (Aug 29, 2024).html", "Apex_Analytics_Report_2024-08-29.pdf"),
    ("Apex Analytics Report (Sep 19, 2024).html", "Apex_Analytics_Report_2024-09-19.pdf"),
    ("Apex Analytics Report (Nov 28, 2024).html", "Apex_Analytics_Report_2024-11-28.pdf"),
    ("Apex Analytics Report (Feb 28, 2025).html", "Apex_Analytics_Report_2025-02-28.pdf"),
    ("Apex Analytics Report (May 30, 2025).html", "Apex_Analytics_Report_2025-05-30.pdf"),
    
    # Veridian Capital
    ("Veridian Capital Report (Aug 23, 2024).html", "Veridian_Capital_Report_2024-08-23.pdf"),
    ("Veridian Capital Report (Sep 20, 2024).html", "Veridian_Capital_Report_2024-09-20.pdf"),
    ("Veridian Capital Report (Nov 21, 2024).html", "Veridian_Capital_Report_2024-11-21.pdf"),
    ("Veridian Capital Report (Feb 22, 2025).html", "Veridian_Capital_Report_2025-02-22.pdf"),
    ("Veridian Capital Report (May 23, 2025).html", "Veridian_Capital_Report_2025-05-23.pdf"),
    
    # Momentum Metrics
    ("Momentum Metrics Report (Aug 30, 2024).html", "Momentum_Metrics_Report_2024-08-30.pdf"),
    ("Momentum Metrics Report (Sep 27, 2024).html", "Momentum_Metrics_Report_2024-09-27.pdf"),
    ("Momentum Metrics Report (Nov 29, 2024).html", "Momentum_Metrics_Report_2024-11-29.pdf"),
    ("Momentum Metrics Report (Feb 28, 2025).html", "Momentum_Metrics_Report_2025-02-28.pdf"),
    ("Momentum Metrics Report (May 30, 2025).html", "Momentum_Metrics_Report_2025-05-30.pdf"),
    
    # Quant-Vestor
    ("Quant-Vestor Report (Aug 29, 2024).html", "Quant-Vestor_Report_2024-08-29.pdf"),
    ("Quant-Vestor Report (Sep 23, 2024).html", "Quant-Vestor_Report_2024-09-23.pdf"),
    ("Quant-Vestor Report (Nov 28, 2024).html", "Quant-Vestor_Report_2024-11-28.pdf"),
    ("Quant-Vestor Report (Feb 27, 2025).html", "Quant-Vestor_Report_2025-02-27.pdf"),
    ("Quant-Vestor Report (May 29, 2025).html", "Quant-Vestor_Report_2025-05-29.pdf"),
    
    # Consensus Point
    ("Consensus Point Report (Aug 30, 2024).html", "Consensus_Point_Report_2024-08-30.pdf"),
    ("Consensus Point Report (Nov 29, 2024).html", "Consensus_Point_Report_2024-11-29.pdf"),
    ("Consensus Point Report (Feb 28, 2025).html", "Consensus_Point_Report_2025-02-28.pdf"),
    ("Consensus Point Report (May 30, 2025).html", "Consensus_Point_Report_2025-05-30.pdf"),
    
    # Pinnacle Growth
    ("Pinnacle Growth Investors Report (Sep 26, 2024).html", "Pinnacle_Growth_Investors_Report_2024-09-26.pdf"),
]

print(f"Regenerating {len(reports_to_generate)} PDFs...\n")

success = 0
errors = 0

for html_file, pdf_file in reports_to_generate:
    html_path = svg_dir / html_file
    pdf_path = output_dir / pdf_file
    
    if not html_path.exists():
        print(f"⚠️  Not found: {html_file}")
        errors += 1
        continue
    
    try:
        HTML(filename=str(html_path)).write_pdf(
            str(pdf_path),
            presentational_hints=True,
            optimize_size=('fonts',)
        )
        size_kb = pdf_path.stat().st_size / 1024
        print(f"✓ {pdf_file} ({size_kb:.0f} KB)")
        success += 1
    except Exception as e:
        print(f"✗ Error: {pdf_file}: {e}")
        errors += 1

print(f"\n{'='*60}")
print(f"✅ Generated {success} PDFs successfully")
if errors > 0:
    print(f"⚠️  {errors} errors")
print(f"{'='*60}")
PYTHON_SCRIPT

deactivate
echo ""
echo "✅ All synthetic analyst PDFs regenerated!"
echo "   PDFs now have proper text extraction for AI_EXTRACT"

