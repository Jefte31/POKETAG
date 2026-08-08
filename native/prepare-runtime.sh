#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER_ROOT="$ROOT/upstream/poketibia-sirninja/Servidor/Pokemon EX 2.0"
BUILD_ROOT="$ROOT/.poketag-native-build"
BIN="$BUILD_ROOT/bin/theforgottenserver"
RUNTIME="$BUILD_ROOT/runtime"

say() { printf '\n[POKETAG-RUNTIME] %s\n' "$*"; }

[[ -x "$BIN" ]] || { echo "Native binary not found: $BIN" >&2; exit 1; }
[[ -f "$SERVER_ROOT/config.lua" ]] || { echo "config.lua not found under $SERVER_ROOT" >&2; exit 1; }
[[ -d "$SERVER_ROOT/data" ]] || { echo "data directory not found under $SERVER_ROOT" >&2; exit 1; }
[[ -f "$SERVER_ROOT/forgottenserver.s3db" ]] || { echo "SQLite database not found under $SERVER_ROOT" >&2; exit 1; }
[[ -f "$SERVER_ROOT/data/world/Poke.otbm" ]] || { echo "Expected Linux-case map data/world/Poke.otbm not found" >&2; exit 1; }

rm -rf "$RUNTIME"
mkdir -p "$RUNTIME"

cp -f "$BIN" "$RUNTIME/theforgottenserver"
chmod +x "$RUNTIME/theforgottenserver"
cp -f "$SERVER_ROOT/config.lua" "$RUNTIME/config.lua"
cp -f "$SERVER_ROOT/forgottenserver.s3db" "$RUNTIME/forgottenserver.s3db"

# The datapack is large (the map alone is tens of MB). Use a runtime symlink so
# CI/local startup does not duplicate it on every build. Runtime database/config
# remain isolated copies and may be modified safely.
ln -s "$SERVER_ROOT/data" "$RUNTIME/data"

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
echo "  database: $RUNTIME/forgottenserver.s3db"
echo "  datapack: $RUNTIME/data -> $SERVER_ROOT/data"
