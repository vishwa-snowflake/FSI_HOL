#!/bin/bash

# Download Public Investment Research Papers
# This script downloads one example document for each investment research topic
# All sources are publicly available and free to download

set -e  # Exit on error

# Create directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$SCRIPT_DIR/esg"
mkdir -p "$SCRIPT_DIR/risk"
mkdir -p "$SCRIPT_DIR/portfolio"
mkdir -p "$SCRIPT_DIR/market"
mkdir -p "$SCRIPT_DIR/quant"

echo "📚 Downloading public investment research papers..."
echo ""

# =====================================================
# 1. ESG & Sustainable Investing
# =====================================================
echo "1️⃣  Downloading ESG research..."
cd "$SCRIPT_DIR/esg"

# UN PRI - ESG Integration Report (publicly available)
wget -q --show-progress \
  "https://www.unpri.org/download?ac=10948" \
  -O "UN_PRI_ESG_Integration_Framework.pdf" \
  2>/dev/null || echo "Note: UN PRI download may require manual download from https://www.unpri.org/research"

# Alternative: SASB Materiality Map
wget -q --show-progress \
  "https://www.sasb.org/wp-content/uploads/2020/03/SASB-Materiality-Map-March-2020.pdf" \
  -O "SASB_Materiality_Map.pdf" \
  2>/dev/null || echo "SASB Materiality Map may need manual download"

echo "✅ ESG papers ready"
echo ""

# =====================================================
# 2. Risk Management
# =====================================================
echo "2️⃣  Downloading Risk Management research..."
cd "$SCRIPT_DIR/risk"

# BIS Basel Committee - Stress Testing Principles (always public)
wget -q --show-progress \
  "https://www.bis.org/publ/bcbs155.pdf" \
  -O "BIS_Stress_Testing_Principles.pdf"

echo "✅ Risk Management papers ready"
echo ""

# =====================================================
# 3. Portfolio Strategy & Asset Allocation
# =====================================================
echo "3️⃣  Downloading Portfolio Strategy research..."
cd "$SCRIPT_DIR/portfolio"

# CFA Institute Research Foundation (public reports)
wget -q --show-progress \
  "https://www.cfainstitute.org/-/media/documents/book/rf-publication/2018/rflr-factor-investing.ashx" \
  -O "CFA_Factor_Investing_Review.pdf" \
  2>/dev/null || echo "CFA paper may need manual download from https://www.cfainstitute.org/en/research"

# Alternative: Download a free SSRN paper on portfolio optimization
# Note: SSRN links change, so this is a placeholder
echo "Note: For portfolio papers, visit https://papers.ssrn.com/ and search 'modern portfolio theory'"

echo "✅ Portfolio Strategy papers ready"
echo ""

# =====================================================
# 4. Market Research & Economics
# =====================================================
echo "4️⃣  Downloading Market Research..."
cd "$SCRIPT_DIR/market"

# IMF Global Financial Stability Report (always public)
wget -q --show-progress \
  "https://www.imf.org/-/media/Files/Publications/GFSR/2024/October/English/text.ashx" \
  -O "IMF_Global_Financial_Stability_Report.pdf" \
  2>/dev/null || \
wget -q --show-progress \
  "https://www.imf.org/-/media/Files/Publications/GFSR/2023/October/English/text.ashx" \
  -O "IMF_Global_Financial_Stability_Report_2023.pdf"

echo "✅ Market Research papers ready"
echo ""

# =====================================================
# 5. Quantitative Methods & Algorithmic Trading
# =====================================================
echo "5️⃣  Downloading Quantitative Methods research..."
cd "$SCRIPT_DIR/quant"

# ArXiv papers (always free) - Popular quantitative finance papers
# Portfolio optimization with transaction costs
wget -q --show-progress \
  "https://arxiv.org/pdf/1906.01446.pdf" \
  -O "ArXiv_Portfolio_Optimization_Deep_Learning.pdf"

# Machine learning for algorithmic trading
wget -q --show-progress \
  "https://arxiv.org/pdf/1911.10107.pdf" \
  -O "ArXiv_ML_Algorithmic_Trading.pdf"

# Quantitative portfolio management
wget -q --show-progress \
  "https://arxiv.org/pdf/2006.04281.pdf" \
  -O "ArXiv_Deep_Portfolio_Theory.pdf"

echo "✅ Quantitative Methods papers ready"
echo ""

# =====================================================
# Summary
# =====================================================
echo ""
echo "======================================"
echo "📊 Download Summary"
echo "======================================"
echo ""

for dir in esg risk portfolio market quant; do
  count=$(find "$SCRIPT_DIR/$dir" -name "*.pdf" 2>/dev/null | wc -l | tr -d ' ')
  echo "  $dir: $count PDF(s)"
done

echo ""
echo "✅ All downloads complete!"
echo ""
echo "Next steps:"
echo "1. Review downloaded papers in: $SCRIPT_DIR"
echo "2. Add more papers manually if needed"
echo "3. Run the deployment pipeline to upload to Snowflake"
echo ""

