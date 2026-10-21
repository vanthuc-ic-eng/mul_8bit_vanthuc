#!/usr/bin/env python3
"""Optimize a small LUT for an original, paper-inspired logarithmic multiplier.

This does NOT reproduce the unpublished/uncaptured exact LUT contents of LUT-ALM 2026.
Objective: minimize exhaustive signed INT8 mean absolute error (MED).
"""
from pathlib import Path
import argparse
import json
import numpy as np

ROOT = Path(__file__).resolve().parents[1]

def signed_mags():
    vals = np.arange(-128,128,dtype=np.int64)
    mag = np.abs(vals)
    return vals, mag

def convert_all(mag, low_w, table):
    k = np.zeros_like(mag)
    for i in range(1,8):
        k = np.where(mag >= (1 << i), i, k)
    norm = (mag << (7-k)) & 255
    frac = norm & 127
    high = (frac >> 4) & 7
    low_addr = (frac >> 1) & 7
    lfrac = (high << low_w) | np.take(table,low_addr)
    return k, lfrac

def metric(table,low_w,save_vectors=False):
    vals,mag = signed_mags()
    k,lfrac=convert_all(mag,low_w,table)
    fbits=3+low_w
    logval = (k << fbits) | lfrac
    logsum = logval[:,None] + logval[None,:]
    exponent = logsum >> fbits
    fraction = logsum & ((1<<fbits)-1)
    mantissa = (1<<fbits) + fraction
    approx_mag = (mantissa << exponent) >> fbits
    p = np.where(np.logical_or(mag[:,None]==0,mag[None,:]==0),0,approx_mag)
    exact_mag = mag[:,None]*mag[None,:]
    errors=p-exact_mag
    abs_errors=np.abs(errors)
    med=float(abs_errors.mean())
    if not save_vectors: return med
    signs=np.where(vals < 0,-1,1)
    signed_p = (p * signs[:,None] * signs[None,:]).astype(np.int16)
    exact_signed= vals[:,None]*vals[None,:]
    assert np.all(np.abs(signed_p.astype(np.int64)) < 32768)
    assert np.all(signed_p[mag==0, :] == 0)
    result={'med':med,
            'er':float((signed_p!=exact_signed).mean()*100),
            'mean_signed_error':float((signed_p.astype(np.int64)-exact_signed).mean()),
            'max_abs_error':int(abs_errors.max()),
            'nmed':float(med/16384),
            'mred_nonzero':float((abs_errors[exact_mag!=0] / exact_mag[exact_mag!=0]).mean()*100),
            'table':[int(x) for x in table]}
    return result,signed_p,exact_signed

def optimize(low_w):
    table=np.arange(8,dtype=np.int64)
    best=metric(table,low_w)
    print('initial',low_w,'MED',best, 'LUT',table.tolist())
    for r in range(32):
        updates=0
        for idx in range(8):
            best_v=int(table[idx]); best_local=best
            for val in range(1<<low_w):
                table[idx]=val
                cost=metric(table,low_w)
                if cost < best_local-1.e-11:
                    best_v,best_local=val,cost
            table[idx]=best_v
            if best_local < best-1.e-11:
                best=best_local;updates+=1
        print(f'pass {r+1}: MED {best:.6f}, updates {updates}, LUT {table.tolist()}')
        if updates==0: break
    result, signed_p, exact_signed=metric(table,low_w,True)
    vpath=ROOT/'vectors'/f'lutalm_signed_ref_low{low_w}.hex'
    vpath.write_text(''.join(f'{int(v)&65535:04x}\n' for v in signed_p.flat))
    jpath=ROOT/'results'/f'accuracy_low{low_w}.json'
    jpath.write_text(json.dumps(result,indent=2)+'\n')
    print('result',result)
    return table.tolist()

if __name__=='__main__':
    t3=optimize(3)
    t4=optimize(4)
    (ROOT/'results'/'lut_values.json').write_text(json.dumps({'3':t3,'4':t4},indent=2)+'\n')
