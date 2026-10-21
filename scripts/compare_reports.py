#!/usr/bin/env python3
"""Compare benchmark files generated with matched flows; never invent data."""
from pathlib import Path
import re
ROOT = Path(__file__).resolve().parents[1]

def try_find(p, pattern):
    if not p.is_file():
        return None
    m = re.search(pattern, p.read_text(errors='replace'), flags=re.M|re.I)
    return m.group(1) if m else None

def path_for(prefix, top, suffix):
    return ROOT / 'reports' / f'{prefix}_{top}_low3.{suffix}'

metrics = {}
for label, top in [('V0', 'lutalm_mul_s8'), ('EXACT', 'exact_mul_s8')]:
    util = path_for('fpga_util', top, 'rpt')
    area = path_for('asic_area', top, 'txt')
    sta = path_for('sta', top, 'txt')
    metrics[label] = {
        'FPGA LUTs': try_find(util, r'\|\s*Slice LUTs\*?\s*\|\s*(\d+)\s*\|'),
        'FPGA DSPs': try_find(util, r'\|\s*DSPs?\s*\|\s*(\d+)\s*\|'),
        'ASIC area (um^2)': try_find(area, r'Chip area[^\n]*?:\s*([0-9.]+)'),
        'ASIC STA exists': 'YES' if sta.is_file() else None,
    }

print('=== mul_int8 — apples-to-apples report availability ===')
print(f"{'Metric':<28}{'V0':>18}{'EXACT':>18}")
print('-'*65)
for key in metrics['V0']:
    print(f"{key:<28}{str(metrics['V0'][key] or 'PENDING'):>18}{str(metrics['EXACT'][key] or 'PENDING'):>18}")

for metric in ('FPGA LUTs','ASIC area (um^2)'):
    a,b=metrics['V0'][metric],metrics['EXACT'][metric]
    if a and b and float(b)>0:
        print(f"{metric} reduction vs exact: {(1-float(a)/float(b))*100:.2f}%")

print('\nGenerated report paths:')
for top in ('lutalm_mul_s8','exact_mul_s8'):
    for prefix, ext in [('fpga_util','rpt'),('fpga_timing','rpt'),('asic_area','txt'),('sta','txt')]:
        path = path_for(prefix,top,ext)
        print(f"  {path.relative_to(ROOT)}: {'OK' if path.is_file() else 'PENDING'}")

# Fail if any available report breaks the no-DSP policy.
for label, top in [('V0', 'lutalm_mul_s8'), ('EXACT', 'exact_mul_s8')]:
    d=metrics[label]['FPGA DSPs']
    if d is not None and int(d) != 0:
        raise SystemExit(f'[FAIL] {label} has {d} DSPs; LUT-only policy violated')
