#!/usr/bin/env python3
"""Independent scalar bit-arithmetic regression of all golden vectors."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]
settings=json.loads((ROOT/'results'/'lut_values.json').read_text())

def log_convert(mag,table,low_w):
    assert 0 < mag < 256
    k=mag.bit_length()-1
    bits=((mag << (7-k)) & 0xFF) & 0x7F
    upper=(bits>>4)&7
    addr=(bits>>1)&7
    return (k<<(3+low_w)) | (upper<<low_w) | table[addr]

def model(a,b,table,low_w,signed):
    aa=abs(a) if signed else a
    bb=abs(b) if signed else b
    if aa==0 or bb==0: return 0
    f=3+low_w
    logsum=log_convert(aa,table,low_w)+log_convert(bb,table,low_w)
    exp=logsum>>f
    frac=logsum & ((1<<f)-1)
    p=(((1<<f)+frac)<<exp)>>f
    if signed and ((a<0) != (b<0)):p=-p
    return p&0xffff

def check(mode,low_w):
    signed=(mode=='signed')
    lut=settings[str(low_w)]
    file=ROOT/'vectors'/f'lutalm_{mode}_ref_low{low_w}.hex'
    lo=-128 if signed else 0
    hi=128 if signed else 256
    failures=0
    with file.open() as f:
        for a in range(lo,hi):
            for b in range(lo,hi):
                ref=int(next(f).strip(),16)
                computed=model(a,b,lut,low_w,signed)
                if ref!=computed:
                    if failures<5:
                        print('MISMATCH',a,b,ref,computed)
                    failures+=1
        if f.readline():
            raise AssertionError('Extra entries found')
    if failures: raise AssertionError(f'{mode} LOW_W={low_w} mismatches={failures}')
    print(f'PASS independent scalar reference: {mode}, LOW_W={low_w}, 65536 cases')

if __name__=='__main__':
    for mode in ('signed','unsigned'):
        for low_w in (3,4):check(mode,low_w)
