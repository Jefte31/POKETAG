#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME="$ROOT/.poketag-native-build/runtime"
LOG="$ROOT/.poketag-native-build/server-smoke.log"
TIMEOUT_SECONDS="${SMOKE_TIMEOUT_SECONDS:-120}"

say() { printf '\n[POKETAG-SMOKE] %s\n' "$*"; }

[[ -x "$RUNTIME/theforgottenserver" ]] || { echo "Runtime binary not found. Run native/prepare-runtime.sh first." >&2; exit 1; }

rm -f "$LOG"
cd "$RUNTIME"

say "Starting native server (timeout ${TIMEOUT_SECONDS}s)..."
./theforgottenserver >"$LOG" 2>&1 &
PID=$!

cleanup() {
  if kill -0 "$PID" 2>/dev/null; then
    kill "$PID" 2>/dev/null || true
    for _ in $(seq 1 20); do
      kill -0 "$PID" 2>/dev/null || break
      sleep 0.25
    done
    kill -9 "$PID" 2>/dev/null || true
  fi
  wait "$PID" 2>/dev/null || true
}
trap cleanup EXIT

ready=0
for _ in $(seq 1 "$TIMEOUT_SECONDS"); do
  if ! kill -0 "$PID" 2>/dev/null; then
    echo "[POKETAG-SMOKE] Server exited before opening both game ports." >&2
    tail -n 160 "$LOG" >&2 || true
    exit 1
  fi

  login_ready=0
  game_ready=0
  ss -ltn 2>/dev/null | grep -Eq '[:.]7171[[:space:]]' && login_ready=1 || true
  ss -ltn 2>/dev/null | grep -Eq '[:.]7172[[:space:]]' && game_ready=1 || true

  if [[ "$login_ready" -eq 1 && "$game_ready" -eq 1 ]]; then
    ready=1
    break
  fi

  sleep 1
done

if [[ "$ready" -ne 1 ]]; then
  echo "[POKETAG-SMOKE] Server stayed alive but did not open both 7171 and 7172 within ${TIMEOUT_SECONDS}s." >&2
  echo "[POKETAG-SMOKE] Listening sockets:" >&2
  ss -ltnp >&2 || true
  echo "[POKETAG-SMOKE] Server log tail:" >&2
  tail -n 200 "$LOG" >&2 || true
  exit 1
fi

if grep -Eiq '(^|[^a-z])(fatal|segmentation fault|assertion failed)([^a-z]|$)' "$LOG"; then
  echo "[POKETAG-SMOKE] Fatal marker found in startup log." >&2
  tail -n 200 "$LOG" >&2 || true
  exit 1
fi

say "Server is alive and listening on 7171/7172."
echo "[POKETAG-SMOKE] Listening sockets:"
ss -ltnp | grep -E '(:7171|:7172)' || true

echo
echo "[POKETAG-SMOKE] Startup log tail:"
tail -n 100 "$LOG" || true

say "Smoke test passed."
