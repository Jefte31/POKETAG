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

say "Applying local/native compatibility patches in build copy..."
python3 - "$WORK/otserv.cpp" "$WORK/configure.ac" "$WORK/house.h" <<'PY'
from pathlib import Path
import sys

otserv = Path(sys.argv[1])
text = otserv.read_text(encoding='latin-1')
start = '\tstd::cout << ">> Checking software version... ";'
end = '\tstd::cout << ">> Loading RSA key" << std::endl;'
si = text.find(start)
ei = text.find(end, si)
if si < 0 or ei < 0:
    raise SystemExit('Could not locate legacy version/blacklist block in otserv.cpp')
replacement = (
    '\tstd::cout << ">> PokeTag local mode: legacy update/blacklist checks disabled." << std::endl;\n\n'
)
otserv.write_text(text[:si] + replacement + text[ei:], encoding='latin-1')

configure = Path(sys.argv[2])
cfg = configure.read_text(encoding='latin-1')
old = 'AC_CHECK_HEADERS([boost/tr1/unordered_set.hpp], , [AC_MSG_ERROR("boost::unordered_set header not found.")])'
new = 'AC_CHECK_HEADERS([boost/unordered_set.hpp], , [AC_MSG_ERROR("boost::unordered_set header not found.")])'
if old not in cfg:
    raise SystemExit('Could not locate legacy Boost unordered_set configure check')
configure.write_text(cfg.replace(old, new), encoding='latin-1')

house = Path(sys.argv[3])
h = house.read_text(encoding='latin-1')
old_include = '#include <boost/tr1/unordered_set.hpp>'
old_type = 'typedef std::tr1::unordered_set<uint32_t> PlayerList;'
if old_include not in h or old_type not in h:
    raise SystemExit('Could not locate legacy TR1 unordered_set usage in house.h')
h = h.replace(old_include, '#include <boost/unordered_set.hpp>')
h = h.replace(old_type, 'typedef boost::unordered_set<uint32_t> PlayerList;')
house.write_text(h, encoding='latin-1')
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
