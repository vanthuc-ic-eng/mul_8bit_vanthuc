#!/usr/bin/env python3
"""Emit unsigned golden vectors and numerical accuracy summaries."""
import json
from pathlib import Path
import sys
import numpy as np
sys.path.insert(0,str(Path(__file__).resolve().parent))
from optimize_lut import convert_all,ROOT

vals = np.arange(256,dtype=np.int64)
for lw in (3,4):
    data=json.loads((ROOT/'results'/'lut_values.json').read_text())
    table=np.asarray(data[str(lw)],dtype=np.int64)
    k,frac=convert_all(vals,lw,table)
    f=3+lw
    lg=(k<<f)|frac
    s=lg[:,None]+lg[None,:]
    pmag=(((1<<f)+(s&((1<<f)-1))) << (s>>f))>>f
    pmag=np.where(np.logical_or(vals[:,None]==0,vals[None,:]==0),0,pmag)
    assert int(pmag.max())<=65535
    (ROOT/'vectors'/f'lutalm_unsigned_ref_low{lw}.hex').write_text(''.join(f'{int(v)&65535:04x}\n' for v in pmag.flat))
    ref=vals[:,None]*vals[None,:]
    err=pmag-ref
    metrics={'med':float(np.abs(err).mean()),'er':float((err!=0).mean()*100),
             'mean_signed_error':float(err.mean()),'max_abs_error':int(np.abs(err).max()),
             'mred_nonzero':float((np.abs(err)[ref!=0]/ref[ref!=0]).mean()*100),
             'table':table.tolist()}
    (ROOT/'results'/f'accuracy_unsigned_low{lw}.json').write_text(json.dumps(metrics,indent=2)+'\n')
    print('UNSIGNED',lw,metrics)
