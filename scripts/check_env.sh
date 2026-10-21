#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo '=== Checking installed tools ==='
for tool in python3 make iverilog vvp yosys sta vivado; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "[OK] $tool: $(command -v "$tool")"
    else
        echo "[MISSING] $tool"
    fi
done
python3 - <<'PY'
from pathlib import Path
p = Path('lib/nangate45/normal.lib')
if p.is_file() and p.stat().st_size > 1000000 and 'library (' in p.read_text(errors='ignore')[:3000]:
    print(f'[OK] Nangate45 Liberty: {p.stat().st_size:,} bytes')
else:
    print('[ERROR] Nangate45 Liberty missing, invalid, or empty')
for v in sorted(Path('vectors').glob('*.hex')):
    n=sum(1 for _ in v.open())
    tag = 'OK' if n == 65536 else 'ERROR'
    print(f'[{tag}] {v}: {n} vectors')
PY
