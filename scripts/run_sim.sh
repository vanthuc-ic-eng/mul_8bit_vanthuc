#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v iverilog >/dev/null 2>&1 || ! command -v vvp >/dev/null 2>&1; then
    echo 'ERROR: Icarus Verilog missing. Ubuntu: sudo apt update && sudo apt install -y iverilog' >&2
    exit 127
fi
mkdir -p build reports
for kind in s8 u8; do
    for precision in 3 4; do
        TB="tb_lutalm_${kind}"
        EXE="build/${TB}_low${precision}.vvp"
        echo "=== RTL regression: ${TB}, LOW_W=${precision}, 65536 cases ==="
        iverilog -g2012 -s "$TB" -P "${TB}.LOW_W=${precision}" \
            -o "$EXE" rtl/*.v "tb/${TB}.sv"
        vvp "$EXE" | tee "reports/${TB}_low${precision}.txt"
    done
done
