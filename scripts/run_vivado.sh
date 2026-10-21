#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
TOP="${TOP:-lutalm_mul_s8}"
LOW_W="${LOW_W:-3}"
PART="${PART:-xc7z010clg400-1}"
case "$TOP" in lutalm_mul_s8|lutalm_mul_u8|exact_mul_s8) ;; *) echo "Invalid TOP=$TOP" >&2; exit 2;; esac
case "$LOW_W" in 3|4) ;; *) echo "Invalid LOW_W=$LOW_W" >&2; exit 2;; esac
command -v vivado >/dev/null 2>&1 || { echo 'ERROR: source Vivado settings64.sh first' >&2; exit 127; }
mkdir -p build reports
# Refuse to validate outdated reports from another board/configuration.
for kind in util timing paths; do
  rm -f "reports/fpga_${kind}_${TOP}_low${LOW_W}.rpt"
done
rm -f "build/${TOP}_low${LOW_W}_synth.dcp"
echo "[FPGA] TOP=$TOP LOW_W=$LOW_W PART=$PART DSP=0 (hard-fail)"
vivado -mode batch -nojournal -nolog -source scripts/run_vivado.tcl \
  2>&1 | tee "reports/vivado_${TOP}_low${LOW_W}.log"
python3 scripts/check_fpga_no_dsp.py \
  "reports/fpga_util_${TOP}_low${LOW_W}.rpt"
test -s "reports/fpga_timing_${TOP}_low${LOW_W}.rpt"
test -s "build/${TOP}_low${LOW_W}_synth.dcp"
echo "[PASS] $TOP: ZYBO/fabric-only output and report validated"
