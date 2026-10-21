# Design specification — signed INT8 LUT-based approximate multiplier

**Top**: `lutalm_mul_s8`, default `LOW_W=3`.

- Input: `a_i[7:0]`, `b_i[7:0]`, two's-complement values [-128,127].
- Output: `p_o[15:0]`, signed two's complement approximate product.
- Latency: combinational, no clock or pipeline stages.
- Reset: none.
- Invalid inputs: none; all 256 bit patterns are valid, including -128 and 0.
- Zero rule: if either operand is zero, result **must** be zero.
- Sign rule: exact sign restore using 16-bit two's complement.
- Precision: `LOW_W=3` (log fraction 6-bit) or 4 (log fraction 7-bit).
- Fraction LUT: 8 addresses from normalized fraction `[3:1]`.
- High map: identity fraction bits `[6:4]`.
- LUT objective: exhaustive signed INT8 MED, optimized using coordinate descent.
- Arithmetic truncation: integer right shifts on nonnegative magnitudes.
- Static timing: combinational paths from A/B inputs to P output.

## Fixed point word widths

For `LOW_W=L`: fractional width `F=L+3`.

- `k`: 3 bits, possible 0..7 for nonzero operands.
- `frac`: 7 bits, normalized magnitude fraction.
- `log_frac`: F bits.
- `log` word: 3+F bits.
- `log_sum`: 4+F bits, preserving carry.
- `exponent`: 4 bits.
- `mantissa`: F+1 bits, implicit leading 1.
- `shifted`: 24-bit unsigned intermediate, no inadvertent early truncation.
- `product`: 16-bit result, then 16-bit sign correction.

## Risk and tool validation

- PPA not yet measured.
- Scripts require Yosys, OpenSTA, Vivado or Icarus installed externally.
- No external simulation engine was available when this archive was built.
- Article-inspired **LUT-ALM0-style**, NOT original author's code, NO ASH/LOA.
