#!/usr/bin/env python3
"""Static V0.1.0/LUT-only invariants. No EDA installation required."""
from pathlib import Path
import re
ROOT = Path(__file__).resolve().parents[1]

make=(ROOT/'Makefile').read_text()
tcl=(ROOT/'scripts/run_vivado.tcl').read_text()
rtl=ROOT/'rtl'
assert 'PART ?= xc7z010clg400-1' in make
assert 'xc7z010clg400-1' in tcl
assert '-max_dsp 0' in tcl
assert 'LUT-ONLY POLICY VIOLATED' in tcl
assert 'get_cells -hier -quiet -filter {REF_NAME =~ DSP48*}' in tcl
assert 'module exact_mul_s8' in (rtl/'exact_mul_s8.v').read_text()
assert 'module lutalm_mul_s8' in (rtl/'lutalm_mul_s8.v').read_text()
assert 'signed [7:0]' in (rtl/'exact_mul_s8.v').read_text()
assert 'sign_a_w ^ sign_b_w' in (rtl/'lutalm_mul_s8.v').read_text()
assert (ROOT/'lib/nangate45/normal.lib').stat().st_size > 1_000_000
for prec in (3,4):
 for mode in ('signed','unsigned'):
  p=ROOT/'vectors'/f'lutalm_{mode}_ref_low{prec}.hex'
  with p.open() as f:
   n=sum(1 for _ in f)
  assert n==65536,(p,n)
print('[PASS] Project invariants: ZYBO, DSP=0 guard, RTL tops, full library and 4 golden vectors')
