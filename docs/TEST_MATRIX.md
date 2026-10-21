# V0 Verification and PPA Experiment Matrix

## Known-good tests executed when this package was generated

- `make verify`: PASS; signed and unsigned, LOW_W=3/4, 4 x 65,536 cases.
- `make accuracy`: PASS; independently calculated INT8 signed numerical errors.
- `bash -n scripts/*.sh`: PASS; shell script syntax checked.
- `python3 -m py_compile scripts/*.py`: PASS; Python syntax checked.
- Original `lib/nangate45/normal.lib`: complete, SHA256 matches `Training.zip` source.

### Tool-backed tests NOT run in the package creation environment

- `make sim`: pending installed `iverilog` and `vvp`.
- `make asic`: pending installed `yosys`.
- `make sta`: pending installed `sta` (OpenSTA) and successful ASIC netlist generation.
- `make fpga`: pending installed Vivado.

These are intentional pending statuses, not implicit PASS assertions. Run and archive
reports in `reports/` on Ubuntu before citing PPA or claiming compile-clean.

## V0 evaluation baseline checklist

| Target | V0 top | Exact top | Same controls |
|---|---|---|---|
| FPGA LUT | lutalm_mul_s8 | exact_mul_s8 | Zybo Z-7010 xc7z010clg400-1, -max_dsp 0, -no_iobuf |
| ASIC area | lutalm_mul_s8 | exact_mul_s8 | Nangate45 normal.lib, Yosys ABC |
| STA delay | lutalm_mul_s8 | exact_mul_s8 | Same SDC and OpenSTA |
| Power | lutalm_mul_s8 | exact_mul_s8 | Must match switching activity assumptions |
| Accuracy | approximate values | exact values | All 65,536 signed INT8 operand pairs |

## Reproducibility data you should record

- tool versions: `iverilog -V`, `yosys -V`, `vivado -version`, `sta -version` (if supported)
- date and hardware operating system, liberty corner and hash
- exact synthesis scripts, SDC/XDC, top, LOW_W and part
- post-synthesis or post-place-and-route status
- LUT count, DSP count, standard-cell area, critical path, power assumptions
- MED, MRED, worst-case error and inference accuracy (if CNN made available)
