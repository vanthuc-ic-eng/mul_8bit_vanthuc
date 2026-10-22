#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v iverilog >/dev/null 2>&1 || ! command -v vvp >/dev/null 2>&1; then
    echo 'ERROR: install iverilog (sudo apt install -y iverilog)' >&2
    exit 127
fi

mkdir -p build reports

# Biên dịch toàn bộ các module phần cứng và testbench
iverilog -g2012 -s tb_exact_mul_s8 -o build/tb_exact_mul_s8.vvp \
    rtl/exact_mul_s8.v \
    rtl/TheMultiplier.v \
    rtl/ADD_ROW.v \
    rtl/LAST_ROW.v \
    rtl/PARTIAL_PRODUCT_ROW.v \
    rtl/PP_NROW.v \
    rtl/FullAdder1bit.v \
    rtl/HalfAdder1bit.v \
    tb/tb_exact_mul_s8.sv

vvp build/tb_exact_mul_s8.vvp | tee reports/tb_exact_mul_s8.txt