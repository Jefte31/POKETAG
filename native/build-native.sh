#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/upstream/poketibia-sirninja/Servidor/Pokemon EX 2.0/Server Sources"
BUILD_ROOT="$ROOT/.poketag-native-build"
WORK="$BUILD_ROOT/src"
OUT="$BUILD_ROOT/bin"

say() { printf '\n[POKETAG-NATIVE] %s\n' "$*"; }

[[ -d "$SRC" ]] || { echo "Source not found: $SRC" >&2; exit 1; }

rm -rf "$WORK" "$OUT"
mkdir -p "$WORK" "$OUT"
cp -a "$SRC/." "$WORK/"

say "Disabling obsolete remote version/blacklist checks in build copy..."
python3 - "$WORK/otserv.cpp" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
text = p.read_text(encoding='latin-1')
start = '\tstd::cout << ">> Checking software version... ";'
end = '\tstd::cout << ">> Loading RSA key" << std::endl;'
si = text.find(start)
ei = text.find(end, si)
if si < 0 or ei < 0:
    raise SystemExit('Could not locate legacy version/blacklist block in otserv.cpp')
replacement = (
    '\tstd::cout << ">> PokeTag local mode: legacy update/blacklist checks disabled." << std::endl;\n\n'
)
text = text[:si] + replacement + text[ei:]
p.write_text(text, encoding='latin-1')
PY

say "Generating build system..."
cd "$WORK"
autoreconf -fiv

say "Configuring TFS 0.3.x for SQLite/local mode..."
CXXFLAGS="${CXXFLAGS:--O2 -std=gnu++03}" ./configure --enable-sqlite

say "Building..."
make -j"${JOBS:-2}"

BIN="$WORK/theforgottenserver"
[[ -x "$BIN" ]] || { echo "Native server binary was not produced: $BIN" >&2; exit 1; }
cp -f "$BIN" "$OUT/theforgottenserver"
chmod +x "$OUT/theforgottenserver"

say "Build complete: $OUT/theforgottenserver"
"$OUT/theforgottenserver" --version || true
