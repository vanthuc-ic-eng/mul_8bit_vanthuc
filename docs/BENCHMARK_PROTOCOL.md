# Benchmark protocol: fair signed 8x8, fabric LUT-only

**FPGA:** Digilent Zybo Zynq-7010 `xc7z010clg400-1`.
Both designs synthesized with identical part/flags/virtual clock/I/O constraints.
`-max_dsp 0` prevents synthesizing either design into DSP48 macros.
There are TWO separate safeguards: post-synthesis DSP48 cell query in Tcl, and
`reports/fpga_util_*.rpt` must contain a `DSPs | 0` row (enforced in Python).
`-no_iobuf` excludes I/O buffers in this bare IP post-synthesis resource comparison.
LUT counts are post-synthesis and may change after placement/optimization.

**FPGA tops:** exact `exact_mul_s8`; approximate `lutalm_mul_s8 LOW_W=3`.
Sign: signed two's-complement, 8-bit A/B, 16-bit output.
FPGA resources (LUT and DSP) are NOT ASIC cell area.

**ASIC:** Yosys/Nangate45 with same `normal.lib`, script, ports and constraint
settings, independent of the FPGA's DSP inference settings.
OpenSTA reported path timing includes 2 ns input delay; do not call the resulting
data arrival time internal gate delay without subtracting external delay.

**Numerical accuracy:** Python and exhaustive RTL simulation provide approximate
product versus independently generated model, not exact equality.
The published 130 LUT, 337.022 um^2, 1.2615ns, 180uW baseline uses unverified
conditions and must NOT be claimed reproducible from this project's flow.
See screenshots/messages for the original supplied third-party values.
