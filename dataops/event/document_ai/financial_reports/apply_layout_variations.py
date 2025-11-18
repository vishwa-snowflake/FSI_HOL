#!/usr/bin/env python3
"""
Apply layout variations to each company report
Quick implementation using CSS and HTML tweaks
"""

import re

# Layout modifications for each company
LAYOUT_MODS = {
    'SNOW': {
        'header_align': 'split',  # Keep current
        'metrics': 'grid-cols-4',  # 4 columns
        'content': 'grid-cols-3',  # 2+1 layout
        'header_size': 'text-3xl',
        'style_notes': 'Classic professional - current design'
    },
    'NRNT': {
        'header_align': 'center',  # Centered bold
        'metrics': 'grid-cols-2',  # 2x2 grid
        'content': 'grid-cols-1',  # Single column
        'header_size': 'text-4xl',
        'style_notes': 'Bold centered - disruptive startup'
    },
    'ICBG': {
        'header_align': 'left',  # Left compact
        'metrics': 'flex',  # Horizontal flex
        'content': 'grid-cols-2',  # Wide 2-column
        'header_size': 'text-2xl',
        'style_notes': 'Minimal clean - open source'
    },
    'QRYQ': {
        'header_align': 'split',  # Split but compact
        'metrics': 'grid-cols-2',  # 2x2 asymmetric
        'content': 'grid-cols-3',  # 3-column
        'header_size': 'text-3xl',
        'style_notes': 'Dynamic asymmetric - challenger'
    },
    'DFLX': {
        'header_align': 'split',  # Traditional split
        'metrics': 'grid-cols-4',  # 4 columns
        'content': 'grid-cols-4',  # 4-column grid
        'header_size': 'text-3xl',
        'style_notes': 'Traditional grid - established'
    },
    'STRM': {
        'header_align': 'left',  # Left flowing
        'metrics': 'grid-cols-4',  # Horizontal flow
        'content': 'grid-cols-1',  # Single wide
        'header_size': 'text-3xl',
        'style_notes': 'Horizontal flow - real-time'
    },
    'VLTA': {
        'header_align': 'center',  # Centered modern
        'metrics': 'grid-cols-2',  # 2x2 cards
        'content': 'grid-cols-2',  # 2-column modern
        'header_size': 'text-4xl',
        'style_notes': 'Modern cards - AI/future'
    },
    'CTLG': {
        'header_align': 'split',  # Split structured
        'metrics': 'grid-cols-2',  # 2-column vertical
        'content': 'grid-cols-3',  # 3-column structured
        'header_size': 'text-3xl',
        'style_notes': 'Highly structured - governance'
    }
}

print("\n📐 Layout Variation Plan:\n")
print("="*60)
for ticker, mods in LAYOUT_MODS.items():
    print(f"{ticker:6} | {mods['style_notes']}")
print("="*60)
print("\nTo implement: Modify generate_report() function in update_visual_reports.py")
print("Add layout parameter and conditional HTML generation\n")

