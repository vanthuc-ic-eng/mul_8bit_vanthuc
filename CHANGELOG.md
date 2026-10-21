# Changelog

## v0.1.0-lut-only-zybo (2026-10-21)

- Frozen LUT-ALM 0-inspired (signed INT8, LOW_W=3) and exact signed baseline.
- Explicit FPGA target: Digilent Zybo Zynq-7010 `xc7z010clg400-1`.
- **FPGA fabric only** for both designs: `-max_dsp 0`, post-synthesis DSP48 hard assertion,
  and DSP utilization report parser; nonzero DSP makes `make fpga` fail.
- ASIC measurements use the supplied Nangate45 standard-cell Liberty, no FPGA DSP.
- Kept supplied V0 RTL, lookup tables, full vector regression and BTC templates.
- Included optional Digilent Zybo board XML (B.3/B.4) for board-aware workflows;
  FPGA synthesis uses `-part` and does NOT require board XML installation.
- `make fpga-pair`, `make check`, Git tag/release workflow documented.

### Verification status
The project scripts and numerical Python model were validated in the creator's
execution environment. Vivado/Yosys/OpenSTA/Icarus were unavailable there.
`make sim`, `make fpga-pair`, and `make asic-pair` must still run on the user's system.
