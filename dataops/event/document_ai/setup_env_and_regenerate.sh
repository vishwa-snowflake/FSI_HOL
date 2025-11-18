#!/bin/bash
# Setup Python virtual environment and regenerate Sterling Partners PDFs

set -e  # Exit on error

cd "$(dirname "$0")"

echo "=========================================="
echo "PDF Regeneration Environment Setup"
echo "=========================================="
echo ""

# Check if Python3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is not installed"
    echo "Please install Python 3.8 or higher"
    exit 1
fi

echo "✓ Python 3 found: $(python3 --version)"
echo ""

# Create virtual environment
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
    echo "✓ Virtual environment created"
else
    echo "✓ Virtual environment already exists"
fi
echo ""

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate
echo "✓ Virtual environment activated"
echo ""

# Install dependencies
echo "Installing dependencies (this may take a few minutes)..."
pip install --upgrade pip -q
pip install -r requirements.txt -q
echo "✓ Dependencies installed"
echo ""

# Check weasyprint installation
echo "Verifying weasyprint installation..."
python3 << 'VERIFY'
try:
    import weasyprint
    print(f"✓ weasyprint {weasyprint.__version__} is ready")
except ImportError as e:
    print(f"❌ Error: {e}")
    exit(1)
VERIFY
echo ""

# Run the PDF regeneration script
echo "=========================================="
echo "Regenerating Sterling Partners PDFs"
echo "=========================================="
echo ""

python3 << 'PYTHON_SCRIPT'
import os
from weasyprint import HTML, CSS
from pathlib import Path

svg_dir = Path("svg_files")
output_dir = Path("synthetic_analyst_reports")

# Ensure output directory exists
output_dir.mkdir(exist_ok=True)

# Sterling Partners HTML files to regenerate
sterling_files = [
    ("Sterling Partners Report (Aug 22, 2024).html", "Sterling_Partners_Report_2024-08-22.pdf"),
    ("Sterling Partners Report (Sep 25, 2024).html", "Sterling_Partners_Report_2024-09-25.pdf"),
    ("Sterling Partners Report (Nov 22, 2024) .html", "Sterling_Partners_Report_2024-11-22.pdf"),
    ("Sterling Partners Report (Feb 22, 2025).html", "Sterling_Partners_Report_2025-02-22.pdf"),
    ("Sterling Partners Report (May 23, 2025).html", "Sterling_Partners_Report_2025-05-23.pdf"),
]

print(f"Processing {len(sterling_files)} files...\n")

success_count = 0
error_count = 0

for html_file, pdf_file in sterling_files:
    html_path = svg_dir / html_file
    pdf_path = output_dir / pdf_file
    
    if html_path.exists():
        print(f"📄 Converting: {html_file}")
        try:
            # Generate PDF with proper text extraction settings
            HTML(filename=str(html_path)).write_pdf(
                str(pdf_path),
                presentational_hints=True,  # Preserve text styling
                optimize_size=('fonts',)     # Optimize fonts but keep text layer
            )
            file_size = pdf_path.stat().st_size / 1024  # Size in KB
            print(f"   ✓ Created {pdf_file} ({file_size:.1f} KB)")
            success_count += 1
        except Exception as e:
            print(f"   ✗ Error: {e}")
            error_count += 1
    else:
        print(f"⚠️  HTML file not found: {html_file}")
        error_count += 1
    print()

print("=" * 50)
print(f"Summary: {success_count} successful, {error_count} errors")
print("=" * 50)

if success_count > 0:
    print("\n✅ PDFs regenerated with consistent text extraction!")
    print("   All Sterling Partners reports should now work with AI_EXTRACT")
else:
    print("\n❌ No PDFs were successfully generated")
    exit(1)
PYTHON_SCRIPT

PDF_STATUS=$?

echo ""
echo "=========================================="
echo "Cleanup"
echo "=========================================="
echo ""

# Deactivate virtual environment
deactivate
echo "✓ Virtual environment deactivated"
echo ""

if [ $PDF_STATUS -eq 0 ]; then
    echo "✅ All done! Sterling Partners PDFs are ready for AI_EXTRACT"
else
    echo "❌ PDF generation failed. Check errors above."
    exit 1
fi

