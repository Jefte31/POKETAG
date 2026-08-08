#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER_ROOT="$ROOT/upstream/poketibia-sirninja/Servidor/Pokemon EX 2.0"
BUILD_ROOT="$ROOT/.poketag-native-build"
STATE_ROOT="$ROOT/.poketag-native-state"
STATE_DB="$STATE_ROOT/forgottenserver.s3db"
BIN="$BUILD_ROOT/bin/theforgottenserver"
RUNTIME="$BUILD_ROOT/runtime"
CASE_FIXER="$ROOT/native/fix-runtime-case.py"

say() { printf '\n[POKETAG-RUNTIME] %s\n' "$*"; }

[[ -x "$BIN" ]] || { echo "Native binary not found: $BIN" >&2; exit 1; }
[[ -f "$SERVER_ROOT/config.lua" ]] || { echo "config.lua not found under $SERVER_ROOT" >&2; exit 1; }
[[ -d "$SERVER_ROOT/data" ]] || { echo "data directory not found under $SERVER_ROOT" >&2; exit 1; }
[[ -f "$SERVER_ROOT/forgottenserver.s3db" ]] || { echo "SQLite database not found under $SERVER_ROOT" >&2; exit 1; }
[[ -f "$SERVER_ROOT/data/world/Poke.otbm" ]] || { echo "Expected Linux-case map data/world/Poke.otbm not found" >&2; exit 1; }
[[ -f "$CASE_FIXER" ]] || { echo "Runtime case fixer not found: $CASE_FIXER" >&2; exit 1; }

mkdir -p "$STATE_ROOT"
if [[ ! -f "$STATE_DB" ]]; then
  say "Creating persistent SQLite state from the historical seed database..."
  cp -f "$SERVER_ROOT/forgottenserver.s3db" "$STATE_DB"
fi

rm -rf "$RUNTIME"
mkdir -p "$RUNTIME"

cp -f "$BIN" "$RUNTIME/theforgottenserver"
chmod +x "$RUNTIME/theforgottenserver"
cp -f "$SERVER_ROOT/config.lua" "$RUNTIME/config.lua"
ln -s "$STATE_DB" "$RUNTIME/forgottenserver.s3db"

# Build an isolated directory tree without duplicating the large map. Hardlinks
# are fast and cheap, while the separate directory structure lets us add Linux
# case-compatibility aliases without changing the vendored historical datapack.
if ! cp -al "$SERVER_ROOT/data" "$RUNTIME/data" 2>/dev/null; then
  echo "[POKETAG-RUNTIME] Hardlink clone unavailable; falling back to normal copy."
  rm -rf "$RUNTIME/data"
  cp -a "$SERVER_ROOT/data" "$RUNTIME/data"
fi

# The historical datapack was authored on Windows. Scan all XML registries and
# materialize exact-case symlink aliases in the isolated runtime for references
# whose actual file exists with different capitalization (e.g. paras.xml vs
# Paras.xml, pokemon/system vs pokemon/System, earthquake.lua vs Earthquake.lua).
python3 "$CASE_FIXER" "$RUNTIME/data"

python3 - "$RUNTIME/config.lua" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
text = p.read_text(encoding="latin-1")

replacements = {
    'ip = "5.68.36.113"': 'ip = "127.0.0.1"',
    'bindOnlyConfiguredIpAddress = false': 'bindOnlyConfiguredIpAddress = true',
    'mapName = "poke"': 'mapName = "Poke"',
    'serverName = "Pokemon EX"': 'serverName = "PokeTag Native"',
    'motd = "Welcome to Pokemon EX!"': 'motd = "Welcome to PokeTag Native!"',
    'loginMessage = "Welcome to Pokemon EX!"': 'loginMessage = "Welcome to PokeTag Native!"',
    'defaultPriority = "high"': 'defaultPriority = "normal"',
}

for old, new in replacements.items():
    if old not in text:
        raise SystemExit(f"Expected runtime config entry not found: {old}")
    text = text.replace(old, new, 1)

p.write_text(text, encoding="latin-1")
PY

say "Runtime staged at $RUNTIME"
echo "  binary: $RUNTIME/theforgottenserver"
echo "  config: $RUNTIME/config.lua"
echo "  persistent database: $STATE_DB"
echo "  datapack: isolated Linux-compatible tree at $RUNTIME/data"
