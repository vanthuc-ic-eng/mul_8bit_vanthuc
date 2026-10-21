# mul_int8 — LUT-ALM 0-inspired | Signed INT8 Multiplier

**Author:** NGUYEN VAN THUC - 24161421  
**Purpose:** Reproducible V0 baseline for the AI Accelerator Challenge.  
**Language:** Verilog-2005 RTL, SystemVerilog testbenches.

## V0 frozen evaluation configuration

- **Version:** `v0.1.0-lut-only-zybo` (`VERSION` and `CHANGELOG.md`).
- **FPGA part:** `xc7z010clg400-1` (Digilent Zybo **Z-7010**, **not** Nexys).
- **DSP:** forbidden on FPGA for both exact and V0. Enforced by both Vivado
  `synth_design -max_dsp 0` and post-synthesis checks (`make fpga-pair`).
- **ASIC:** separate Nangate45 standard-cell mapping. ASIC has no Xilinx DSPs.
- **Critical caveat:** Earlier observed 61 LUT vs 101 LUT figures were from a
  *different* FPGA part; rerun the comparisons. The organizer's 130 LUT value
  is not an invariant of the signed exact multiplier, and cannot be forced.

Read `docs/BENCHMARK_PROTOCOL.md` and `docs/GIT_RELEASE.md` before freezing.

## 1. Scope, accuracy, and scientific status

- `rtl/lutalm_mul_s8.v`: signed INT8 approximate LUT-logarithmic 8×8 -> signed INT16.
- `rtl/lutalm_mul_u8.v`: optional unsigned 8×8 variant.
- `rtl/exact_mul_s8.v`: correct signed INT8 reference multiplier.
- `LOW_W=3` is the default V0 architecture; `LOW_W=4` is also supported.
- The low LUT table entries were independently optimized for signed INT8. **This is LUT-ALM 0-inspired, not the official authors' exact implementation.**
- The 8-bit datapath is combinational; no hardware clock or reset pins.
- Golden vectors match the calibrated mathematical model. They are *not* exact-product results.

## 2. Directory layout

```text
mul_int8/
├── Makefile                       central commands
├── rtl/                           12 separated, aligned Verilog RTL modules
├── tb/                            V0 s8/u8 and exact exhaustive simulations
├── vectors/                       4 x 65536 golden vectors
├── lib/nangate45/normal.lib       PROVIDED BY USER, full 6.69 MB (not 0 bytes)
├── constraints/asic_io.sdc        instantiated port names (a_i/b_i/p_o)
├── reference/btc_templates/       ORIGINAL unmodified BTC SDC/STA/Yosys templates
├── scripts/                       self-contained root-relative runner scripts
├── docs/                          module/specification/style notes
├── results/                       reference accuracy and computed accuracy
├── build/                         generated intermediate files (empty initially)
└── reports/                       generated Vivado/Yosys/OpenSTA reports
```

Do not execute the BTC template `.ys/.tcl/.sdc` files directly; the reference
files contain placeholders. Active scripts and constraints use real port names.

## 3. Requirements

Run on Ubuntu with a working shell and Python 3:

```bash
sudo apt update
sudo apt install -y build-essential python3 iverilog yosys
```

- **Vivado** 2024.2 or compatible must already be installed for `make fpga`.
  Add Vivado to PATH in the shell where you run `make`. Example:
  `source /tools/Xilinx/Vivado/2024.2/settings64.sh` (adjust to YOUR installation path).
- **OpenSTA** executable `sta` required for `make sta`; distribution/package
  availability differs on Ubuntu. Check with `command -v sta`. If missing, install
  OpenSTA from your local university/BTC toolchain rather than pretending it ran.
- `lib/nangate45/normal.lib` is included and should be **6,691,483 bytes**.
- For reliable ASIC estimates compare on the **same** Nangate45 corner/version,
  PVT conditions, IO constraints, and mapping script.

## 4. From ZIP to measurements (run from the project ROOT)

```bash
unzip mul_int8_V0.zip
cd mul_int8
make deps           # display missing programs / validate LUT/vector files
make check          # static invariants + verify vectors
make verify         # Python mathematical-model / golden vector consistency
make accuracy       # compute signed accuracy (MED, MRED, WCE)
make sim            # V0 exhaustive RTL regression, s8/u8 LOW_W=3 and 4
make sim-baseline   # exact signed 8x8 exhaustive simulation
make asic           # V0 area and standard-cell netlist
make sta            # V0 OpenSTA paths / approximate power
make fpga           # V0 Zybo Z-7010 LUT and timing, DSP=0 enforced
make fpga-pair      # run V0 and exact, assert 0 DSP in both
make asic-baseline
make sta-baseline
make fpga-baseline
python3 scripts/compare_reports.py
```

`make sta` first runs `make asic` to ensure the netlist exists. `make compare`
performs these tasks sequentially, stopping on failures.

**Alternate V0 configuration:**

```bash
make sim
make asic LOW_W=4
make sta LOW_W=4
make fpga LOW_W=4
```

**Compare the exact and V0 with identical settings:**

```bash
make fpga TOP=lutalm_mul_s8 LOW_W=3
make fpga TOP=exact_mul_s8
make asic TOP=lutalm_mul_s8 LOW_W=3
make asic TOP=exact_mul_s8
make sta TOP=lutalm_mul_s8 LOW_W=3
make sta TOP=exact_mul_s8
```

### Important measurement controls

1. **FPGA:** `-max_dsp 0` is intentionally applied to **both** V0 and exact
   so that the comparison measures fabric LUT cost rather than comparing LUTs
   against DSP blocks. FPGA part defaults to `xc7z010clg400-1` (Digilent Zybo Z-7010).
   Reports are *post-synthesis estimates*, **not post-placement routing delays**.
2. **ASIC area:** Yosys `synth; abc -liberty; stat -liberty` in Nangate45.
   For this combinational circuit `dfflibmap` is unnecessary. The original
   project's `build/normal.lib` was 0 bytes and is deliberately not used.
3. **ASIC STA:** 10ns virtual clock, 2ns input/output delay, output load 0.05,
   BUF_X1 input drive, based on BTC examples, with actual ports substituted.
   The critical path in `reports/sta_*.txt` is a mapped **timing estimate**.
4. **Power:** OpenSTA can report library-based power **under assumed activity**;
   the default report is NOT a measured workload power result. For publishable
   power compare, both designs need equivalent stimulus, VCD/SAIF activity,
   timing corner/voltage, and consistent netlist/annotation. Do not claim
   `report_power` estimates match the provided exact baseline's 180 µW.
5. **Baseline numbers from chat:** 130 LUT, 337.022 µm², 1.2615 ns,
   180 µW were supplied in a screenshot; methodology was not confirmed. Do
   **not** compare these against measurements from a different flow.

## 5. Scripts and report paths

- `make sim` creates `reports/tb_lutalm_s8_low3.txt`, etc.
- `make asic` creates `reports/asic_area_lutalm_mul_s8_low3.txt` and
  `build/netlist_lutalm_mul_s8_low3.v`.
- `make sta` creates `reports/sta_lutalm_mul_s8_low3.txt`.
- `make fpga` creates `reports/fpga_util_lutalm_mul_s8_low3.rpt`,
  `reports/fpga_timing_lutalm_mul_s8_low3.rpt`, `reports/fpga_paths_*.rpt`.

## 6. Troubleshooting

**`iverilog: command not found`**: `sudo apt install -y iverilog` and rerun `make sim`.

**`yosys ... Segmentation fault` while reading liberty**: run `make deps`;
verify `normal.lib` is 6,691,483 bytes. Old ZIP had an empty zero-byte
`build/normal.lib`. This new project never references it. If the fault remains,
run `yosys -Q -p 'read_liberty -lib lib/nangate45/normal.lib'` and
`yosys -V` and share the results. A crash in library parsing does not establish
that the Verilog is wrong.

**`sta: command not found`**: install OpenSTA (not Yosys alone).

**Vivado cannot find an FPGA part**: supply your installed part via
`make fpga PART=<your-artix7-part>`.

**Timing report has no valid critical path**: inspect constraints; ensure
`a_i`, `b_i`, `p_o` ports are actually constrained, not `<Input_1>` placeholders.

**Changing project path**: always run from `mul_int8/`. All scripts locate
root via `$(dirname "$0")/..`; no absolute paths to the old workspace exist.

**Logic integrity**: the V0 RTL files are preserved from your uploaded
`mul_int8.zip`. Added tooling should not change its mathematical behavior.
Run RTL simulation before trusting numerical metrics or synthesis.

## 7. Git release (after local validation)

```bash
make check
make sim
make fpga-pair
make asic-pair
make sta-pair
git init
git branch -M main
git add .
git commit -m "release(v0): LUT-ALM V0 / exact signed, Zybo LUT-only"
git tag -a v0.1.0-lut-only-zybo -m "V0 frozen source, signed, DSP=0"
```

Do not treat these local commands as already performed by this ZIP producer.
