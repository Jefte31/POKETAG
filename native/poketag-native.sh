#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_ROOT="$ROOT/.poketag-native-build"
STATE_ROOT="$ROOT/.poketag-native-state"
RUNTIME="$BUILD_ROOT/runtime"
PIDFILE="$STATE_ROOT/server.pid"
LOGFILE="$STATE_ROOT/server.log"
LOGIN_PORT=7171
GAME_PORT=7172

say() { printf '\n[POKETAG-NATIVE] %s\n' "$*"; }
fail() { printf '\n[POKETAG-NATIVE][ERRO] %s\n' "$*" >&2; exit 1; }

port_open() {
  ss -ltnH 2>/dev/null | awk '{print $4}' | grep -Eq ":${1}$"
}

pid_alive() {
  [[ -f "$PIDFILE" ]] || return 1
  local pid
  pid="$(cat "$PIDFILE" 2>/dev/null || true)"
  [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}

install_deps() {
  say "Instalando dependências do servidor Linux nativo..."
  sudo apt-get update
  sudo apt-get install -y \
    build-essential autoconf automake libtool pkg-config python3 \
    libxml2-dev libgmp-dev libboost-dev libboost-filesystem-dev \
    libboost-date-time-dev libboost-system-dev libboost-regex-dev \
    libboost-thread-dev liblua5.1-0-dev libsqlite3-dev iproute2
  say "Dependências instaladas."
}

build() {
  say "Compilando o servidor PokeTag nativamente..."
  bash "$ROOT/native/build-native.sh"
}

prepare() {
  [[ -x "$BUILD_ROOT/bin/theforgottenserver" ]] || build
  bash "$ROOT/native/prepare-runtime.sh"
}

wait_ready() {
  say "Aguardando 127.0.0.1:${LOGIN_PORT}/${GAME_PORT}..."
  for _ in $(seq 1 180); do
    if port_open "$LOGIN_PORT" && port_open "$GAME_PORT"; then
      say "Servidor ONLINE: portas ${LOGIN_PORT} e ${GAME_PORT} abertas."
      return 0
    fi
    if ! pid_alive; then
      echo "[POKETAG-NATIVE] O servidor encerrou durante a inicialização." >&2
      tail -n 160 "$LOGFILE" >&2 || true
      return 1
    fi
    sleep 1
  done
  echo "[POKETAG-NATIVE] Timeout esperando as portas do servidor." >&2
  tail -n 160 "$LOGFILE" >&2 || true
  return 1
}

start() {
  mkdir -p "$STATE_ROOT"
  if pid_alive; then
    say "Servidor já está rodando (PID $(cat "$PIDFILE"))."
    status
    return 0
  fi

  rm -f "$PIDFILE"
  prepare
  : > "$LOGFILE"

  say "Iniciando PokeTag Native..."
  (
    cd "$RUNTIME"
    exec ./theforgottenserver >>"$LOGFILE" 2>&1
  ) &
  echo $! > "$PIDFILE"

  if ! wait_ready; then
    rm -f "$PIDFILE"
    return 1
  fi

  printf '\nBanco persistente: %s/forgottenserver.s3db\n' "$STATE_ROOT"
  printf 'Log: %s\n' "$LOGFILE"
  printf 'Status: bash native/poketag-native.sh status\n'
  printf 'Parar:  bash native/poketag-native.sh stop\n'
}

stop() {
  if ! pid_alive; then
    rm -f "$PIDFILE"
    say "Servidor já está parado."
    return 0
  fi

  local pid
  pid="$(cat "$PIDFILE")"
  say "Encerrando servidor (PID $pid)..."
  kill "$pid" 2>/dev/null || true
  for _ in $(seq 1 40); do
    kill -0 "$pid" 2>/dev/null || break
    sleep 0.25
  done
  if kill -0 "$pid" 2>/dev/null; then
    kill -9 "$pid" 2>/dev/null || true
  fi
  wait "$pid" 2>/dev/null || true
  rm -f "$PIDFILE"
  say "Servidor parado."
}

status() {
  printf 'PokeTag Native status:\n'
  if pid_alive; then
    printf '  processo : RUNNING (PID %s)\n' "$(cat "$PIDFILE")"
  else
    printf '  processo : STOPPED\n'
  fi
  if port_open "$LOGIN_PORT"; then
    printf '  login    : OPEN 127.0.0.1:%s\n' "$LOGIN_PORT"
  else
    printf '  login    : CLOSED :%s\n' "$LOGIN_PORT"
  fi
  if port_open "$GAME_PORT"; then
    printf '  game     : OPEN 127.0.0.1:%s\n' "$GAME_PORT"
  else
    printf '  game     : CLOSED :%s\n' "$GAME_PORT"
  fi
  [[ -f "$STATE_ROOT/forgottenserver.s3db" ]] && printf '  database : %s\n' "$STATE_ROOT/forgottenserver.s3db"
}

logs() {
  [[ -f "$LOGFILE" ]] || fail "Log ainda não existe: $LOGFILE"
  tail -n "${LINES:-160}" "$LOGFILE"
}

follow_logs() {
  [[ -f "$LOGFILE" ]] || fail "Log ainda não existe: $LOGFILE"
  tail -n "${LINES:-100}" -f "$LOGFILE"
}

smoke() {
  [[ -x "$BUILD_ROOT/bin/theforgottenserver" ]] || build
  prepare
  bash "$ROOT/native/smoke-native.sh"
}

rebuild() {
  local was_running=0
  pid_alive && was_running=1 || true
  if [[ "$was_running" -eq 1 ]]; then
    stop
  fi
  build
  prepare
  if [[ "$was_running" -eq 1 ]]; then
    start
  fi
}

doctor() {
  local failed=0
  for cmd in g++ autoconf automake make pkg-config python3 ss; do
    if command -v "$cmd" >/dev/null 2>&1; then
      printf '  %-12s OK\n' "$cmd"
    else
      printf '  %-12s FALTANDO\n' "$cmd"
      failed=1
    fi
  done
  for file in \
    "$ROOT/native/build-native.sh" \
    "$ROOT/native/prepare-runtime.sh" \
    "$ROOT/native/smoke-native.sh" \
    "$ROOT/upstream/poketibia-sirninja/Servidor/Pokemon EX 2.0/data/world/Poke.otbm" \
    "$ROOT/upstream/poketibia-sirninja/Servidor/Pokemon EX 2.0/forgottenserver.s3db"; do
    if [[ -e "$file" ]]; then
      printf '  arquivo      OK %s\n' "${file#$ROOT/}"
    else
      printf '  arquivo      FALTANDO %s\n' "${file#$ROOT/}"
      failed=1
    fi
  done
  [[ "$failed" -eq 0 ]] || return 1
}

usage() {
  cat <<'EOF'
PokeTag Native - controlador do servidor Linux

Uso:
  bash native/poketag-native.sh install   # instala dependências no Cloud Shell
  bash native/poketag-native.sh build     # compila a engine
  bash native/poketag-native.sh start     # prepara e inicia, preservando SQLite
  bash native/poketag-native.sh stop
  bash native/poketag-native.sh restart
  bash native/poketag-native.sh status
  bash native/poketag-native.sh logs
  bash native/poketag-native.sh follow
  bash native/poketag-native.sh smoke
  bash native/poketag-native.sh rebuild   # recompila sem apagar o banco
  bash native/poketag-native.sh doctor
  bash native/poketag-native.sh setup     # install + build + start
EOF
}

case "${1:-}" in
  install) install_deps ;;
  build) build ;;
  prepare) prepare ;;
  start) start ;;
  stop) stop ;;
  restart) stop; start ;;
  status) status ;;
  logs) logs ;;
  follow) follow_logs ;;
  smoke) smoke ;;
  rebuild) rebuild ;;
  doctor) doctor ;;
  setup) install_deps; build; start ;;
  help|-h|--help|"") usage ;;
  *) usage; exit 2 ;;
esac
