#!/usr/bin/env python3
"""Fail a LUT-only run if a Vivado utilization report contains DSP usage."""
from pathlib import Path
import re
import sys

if len(sys.argv) != 2:
    raise SystemExit('Usage: check_fpga_no_dsp.py <fpga_util_*.rpt>')
p = Path(sys.argv[1]); text = p.read_text(errors='replace')
# Report examples: '| DSPs | 0 | ...' and '| DSP48E1 | 0 | ...'
pattern = r'^\|\s*(DSPs?|DSP48E1|DSP48E2)\s*\|\s*([0-9,]+)\s*\|'
rows = re.findall(pattern, text, flags=re.M | re.I)
if not rows:
    raise SystemExit(f'[FAIL] DSP utilization row not found: {p}; cannot certify LUT-only')
for label, count in rows:
    n = int(count.replace(',', ''))
    print(f'{label}: {n}')
    if n:
        raise SystemExit(f'[FAIL] DSP forbidden; report has {label}={n} ({p})')
print('[PASS] Vivado utilization confirms DSP usage = 0')
