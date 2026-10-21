#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
TOP="${TOP:-lutalm_mul_s8}"
LOW_W="${LOW_W:-3}"
LIB="lib/nangate45/normal.lib"
case "$TOP" in lutalm_mul_s8|lutalm_mul_u8|exact_mul_s8) ;; *) echo "Invalid TOP: $TOP" >&2; exit 2;; esac
case "$LOW_W" in 3|4) ;; *) echo "LOW_W must be 3 or 4" >&2; exit 2;; esac
if ! command -v yosys >/dev/null 2>&1; then
    echo 'ERROR: yosys not found. Ubuntu: sudo apt install -y yosys' >&2; exit 127
fi
if [ ! -s "$LIB" ] || [ "$(wc -c < "$LIB")" -lt 1000000 ]; then
    echo "ERROR: $LIB is empty or incomplete; expected Nangate45 normal.lib (>1 MB)." >&2; exit 2
fi
mkdir -p build reports
# Expand Verilog paths in Bash before writing the Yosys .ys script.
RTL_FILES=(rtl/*.v)
RTL_LIST="${RTL_FILES[*]}"
if [ "$TOP" = exact_mul_s8 ]; then
  PARAM_CMD=""
else
  PARAM_CMD="hierarchy -check -top ${TOP} -chparam LOW_W ${LOW_W}"
fi
cat > "build/synthesis_${TOP}_low${LOW_W}.ys" <<YS
# Generated from BTC synthesis template; paths resolved from project root.
read_verilog ${RTL_LIST}
${PARAM_CMD}
synth -top ${TOP} -flatten
opt -purge
opt
# No read_liberty -lib: old projects crashed when supplied an EMPTY .lib.
# Both DUTs are combinational, so no dfflibmap is required.
abc -liberty ${LIB}
clean
tee -o reports/asic_area_${TOP}_low${LOW_W}.txt stat -liberty ${LIB}
write_verilog -noattr -noexpr build/netlist_${TOP}_low${LOW_W}.v
YS
printf 'ASIC synthesis: TOP=%s LOW_W=%s, liberty=%s\n' "$TOP" "$LOW_W" "$LIB"
if ! yosys -s "build/synthesis_${TOP}_low${LOW_W}.ys" 2>&1 | tee "reports/yosys_${TOP}_low${LOW_W}.log"; then
    echo 'ERROR: Yosys failed. Check reports/yosys_*.log. Try isolating the Liberty reader:' >&2
    echo "    yosys -Q -p 'read_liberty -lib $LIB'" >&2
    echo 'Do not interpret a segmentation fault as an RTL logic error.' >&2
    exit 1
fi
test -s "build/netlist_${TOP}_low${LOW_W}.v"
echo "[PASS] ASIC netlist and area report for $TOP"
