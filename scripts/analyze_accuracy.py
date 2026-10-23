#!/usr/bin/env python3
"""Evaluate signed INT8 numerical error of the exact and approximate multipliers."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]

for precision in (3, 4):
    path = ROOT / 'vectors' / f'lutalm_signed_ref_low{precision}.hex'
    n = 0
    incorrect = 0
    sum_ae = 0
    sum_re = 0.0
    nz = 0
    worst = (0, None, None, 0, 0)
    with path.open() as f:
        for a in range(-128, 128):
            for b in range(-128, 128):
                sample = int(next(f).strip(), 16)
                approx = sample - 65536 if (sample & 0x8000) else sample
                exact = a * b
                ae = abs(approx - exact)
                n += 1
                incorrect += (ae != 0)
                sum_ae += ae
                if exact != 0:
                    sum_re += ae / abs(exact)
                    nz += 1
                if ae > worst[0]:
                    worst = (ae, a, b, approx, exact)
    result = {
        'configuration': f'lutalm_mul_s8 LOW_W={precision}',
        'cases': n, 'incorrect_cases': incorrect,
        'error_rate_percent': 100 * incorrect / n,
        'MED': sum_ae / n,
        'MRED_percent_excluding_zero_exact_product': 100 * sum_re / nz,
        'max_absolute_error': worst[0],
        'worst_case': {'a': worst[1], 'b': worst[2], 'approx': worst[3], 'exact': worst[4]}
    }
    dest = ROOT / 'results' / f'accuracy_recomputed_low{precision}.json'
    dest.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))
    print(f'Saved: {dest.relative_to(ROOT)}')
