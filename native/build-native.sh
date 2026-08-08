#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/upstream/poketibia-sirninja/Servidor/Pokemon EX 2.0/Server Sources"
BUILD_ROOT="$ROOT/.poketag-native-build"
WORK="$BUILD_ROOT/src"
OUT="$BUILD_ROOT/bin"
BUILD_LOG="$BUILD_ROOT/build.log"

say() { printf '\n[POKETAG-NATIVE] %s\n' "$*"; }

[[ -d "$SRC" ]] || { echo "Source not found: $SRC" >&2; exit 1; }
[[ -f "$ROOT/native/patch-native.py" ]] || { echo "Patch driver not found: $ROOT/native/patch-native.py" >&2; exit 1; }
[[ -f "$ROOT/native/patch-native-followup.py" ]] || { echo "Follow-up patch driver not found: $ROOT/native/patch-native-followup.py" >&2; exit 1; }

rm -rf "$WORK" "$OUT"
mkdir -p "$WORK" "$OUT"
cp -a "$SRC/." "$WORK/"

say "Applying local/native compatibility patches in build copy..."
python3 "$ROOT/native/patch-native.py" "$WORK"
python3 "$ROOT/native/patch-native-followup.py" "$WORK"

say "Generating build system..."
cd "$WORK"
autoreconf -fiv

say "Configuring TFS 0.3.x for SQLite/local mode..."
CXXFLAGS="${CXXFLAGS:--O2 -std=gnu++03}" ./configure --enable-sqlite

say "Building..."
if ! make -j"${JOBS:-2}" >"$BUILD_LOG" 2>&1; then
  echo
  echo "[POKETAG-NATIVE] Build failed. Compiler/linker errors:"
  grep -n -E '(^|: )(fatal )?error:|undefined reference|collect2: error|make(\[[0-9]+\])?: \*\*\*' "$BUILD_LOG" | tail -n 100 || true
  echo
  echo "[POKETAG-NATIVE] Last 120 build log lines:"
  tail -n 120 "$BUILD_LOG" || true
  exit 1
fi

echo "[POKETAG-NATIVE] Build succeeded. Final build log lines:"
tail -n 30 "$BUILD_LOG" || true

BIN="$WORK/theforgottenserver"
[[ -x "$BIN" ]] || { echo "Native server binary was not produced: $BIN" >&2; exit 1; }
cp -f "$BIN" "$OUT/theforgottenserver"
chmod +x "$OUT/theforgottenserver"

say "Build complete: $OUT/theforgottenserver"
"$OUT/theforgottenserver" --version || true
