# Infographics - Mixed Real and Synthetic

## Files in This Directory

### Real Infographic:
- **SNOW_Earnings_Infographic_FY25-Q2.png** - Original Snowflake earnings infographic (DO NOT OVERWRITE)

### Synthetic Infographics (7 companies):
- ICBG_Earnings_Infographic_FY25-Q2.png - Minimal open design
- QRYQ_Earnings_Infographic_FY25-Q2.png - Bold aggressive style
- DFLX_Earnings_Infographic_FY25-Q2.png - Chart-heavy BI style
- STRM_Earnings_Infographic_FY25-Q2.png - Pipeline flow design
- VLTA_Earnings_Infographic_FY25-Q2.png - Futuristic AI tech
- CTLG_Earnings_Infographic_FY25-Q2.png - Structured hierarchy
- NRNT_Earnings_Infographic_FY25-Q2.png - Dynamic energy style

## Regenerating Infographics

To regenerate the synthetic infographics (SNOW will be skipped):

```bash
cd /Users/boconnor/fsi-cortex-assistant/dataops/event/document_ai
python3 create_varied_infographics.py
./convert_infographics_to_png.sh
```

**SNOW is automatically excluded** to preserve the real infographic.

## Design Styles

Each company has a unique visual identity reflecting their market position:

- **SNOW**: Real infographic (professional, market leader)
- **ICBG**: Minimal bars and text (open, transparent)
- **QRYQ**: Angular shapes, Impact font (aggressive challenger)
- **DFLX**: Multiple charts, analytics focus (BI platform)
- **STRM**: Horizontal flow with arrows (data pipeline)
- **VLTA**: Neon glow, dark background (AI futuristic)
- **CTLG**: Hierarchical tiers (governance structure)
- **NRNT**: Rotated cards, radial gradient (energetic disruptor)

All optimized for AI_EXTRACT table extraction! 📊

