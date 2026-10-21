#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
TOP="${TOP:-lutalm_mul_s8}"
LOW_W="${LOW_W:-3}"
NETLIST="build/netlist_${TOP}_low${LOW_W}.v"
LIB="lib/nangate45/normal.lib"
if ! command -v sta >/dev/null 2>&1; then
    echo 'ERROR: sta (OpenSTA) not found. Install OpenSTA before running timing analysis.' >&2; exit 127
fi
if [ ! -s "$NETLIST" ]; then
    echo "ERROR: $NETLIST not found. Run: make asic TOP=$TOP LOW_W=$LOW_W" >&2; exit 2
fi
mkdir -p reports build
cat > "build/sta_${TOP}_low${LOW_W}.tcl" <<TCL
# Auto-generated OpenSTA evaluation: same constraints for V0 and exact.
read_liberty ${LIB}
read_verilog ${NETLIST}
link_design ${TOP}
read_sdc constraints/asic_io.sdc
puts "==== CRITICAL PATH REPORT ==== "
report_checks -path_delay max -group_count 5 -fields {slew cap input_pins nets fanout} -digits 4
puts "==== POWER ESTIMATE (not measured switching power) ==== "
if {[llength [info commands set_power_activity]] > 0} {
    set_power_activity -global -activity 0.1 -duty 0.5
    puts "Assumed activity = 0.1 transitions per clock period; NOT measured from VCD"
}
if {[llength [info commands report_power]] > 0} {
    report_power
} else {
    puts "Power reporting is unavailable in this OpenSTA build."
}
exit
TCL
sta "build/sta_${TOP}_low${LOW_W}.tcl" 2>&1 | tee "reports/sta_${TOP}_low${LOW_W}.txt"
