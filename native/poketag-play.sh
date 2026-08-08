#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_ROOT="$ROOT/.poketag-native-state"
PLAY_ROOT="$STATE_ROOT/play"
CLIENT_DIR="$PLAY_ROOT/client"
WINEPREFIX_DIR="$PLAY_ROOT/wine"
LOGS="$PLAY_ROOT/logs"
PIDS="$PLAY_ROOT/pids"

PDA_ROOT="$ROOT/upstream/PDA-By-Slicer/extraidos"
CLIENT_SRC="$PDA_ROOT/OTClient v1.8/OTClient v1.8"
ASSET_SRC="$PDA_ROOT/Client v1.9 - v2.9/Client v1.9 - v2.9"
CLIENT_EXE="otclient.exe"

DISPLAY_ID=":99"
VNC_PORT=5900
NOVNC_PORT=6080
LOGIN_PORT=7171
GAME_PORT=7172

say() { printf '\n[POKETAG-PLAY] %s\n' "$*"; }
warn() { printf '\n[POKETAG-PLAY][AVISO] %s\n' "$*" >&2; }
fail() { printf '\n[POKETAG-PLAY][ERRO] %s\n' "$*" >&2; exit 1; }

need_file() { [[ -f "$1" ]] || fail "Arquivo obrigatório não encontrado: $1"; }
need_dir() { [[ -d "$1" ]] || fail "Diretório obrigatório não encontrado: $1"; }

port_open() {
  ss -ltnH 2>/dev/null | awk '{print $4}' | grep -Eq ":${1}$"
}

pid_alive() {
  local file="$1"
  [[ -f "$file" ]] || return 1
  local pid
  pid="$(cat "$file" 2>/dev/null || true)"
  [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}

start_bg() {
  local name="$1"; shift
  local pidfile="$PIDS/$name.pid"
  if pid_alive "$pidfile"; then
    return 0
  fi
  "$@" &
  echo $! > "$pidfile"
}

install_ui_deps() {
  say "Instalando dependências da interface de teste..."
  sudo dpkg --add-architecture i386 || true
  sudo apt-get update
  sudo apt-get install -y \
    xvfb x11vnc novnc websockify xdotool \
    wine wine64 wine32:i386 cabextract winbind procps iproute2 python3
  say "Dependências da interface instaladas."
}

prepare_client() {
  need_dir "$CLIENT_SRC"
  need_file "$CLIENT_SRC/$CLIENT_EXE"
  need_file "$ASSET_SRC/POK.dat"
  need_file "$ASSET_SRC/POK.spr"

  mkdir -p "$PLAY_ROOT" "$LOGS" "$PIDS"

  if [[ ! -f "$CLIENT_DIR/$CLIENT_EXE" ]]; then
    say "Preparando OTClient 8.54 para o teste..."
    rm -rf "$CLIENT_DIR"
    mkdir -p "$CLIENT_DIR"
    cp -a "$CLIENT_SRC/." "$CLIENT_DIR/"
  fi

  mkdir -p "$CLIENT_DIR/modules/game_tibiafiles/854"
  cp -f "$ASSET_SRC/POK.dat" "$CLIENT_DIR/modules/game_tibiafiles/854/Tibia.dat"
  cp -f "$ASSET_SRC/POK.spr" "$CLIENT_DIR/modules/game_tibiafiles/854/Tibia.spr"

  cat > "$CLIENT_DIR/otclientrc.lua" <<'LUA'
-- PokeTag gameplay-test profile.
-- Native server: 127.0.0.1:7171/7172
-- Protocol: 8.54
local function configurePokeTagTest()
  g_settings.set('host', '127.0.0.1')
  g_settings.set('port', 7171)
  g_settings.set('client-version', 854)
  g_settings.set('autologin', false)

  if EnterGame then
    EnterGame.setUniqueServer('127.0.0.1', 7171, 854, 330, 220)
  end
end

addEvent(configurePokeTagTest)
LUA
}

start_desktop() {
  mkdir -p "$LOGS" "$PIDS"
  export DISPLAY="$DISPLAY_ID"

  start_bg xvfb bash -c "exec Xvfb '$DISPLAY_ID' -screen 0 1440x900x24 -ac >'$LOGS/xvfb.log' 2>&1"
  sleep 2

  start_bg x11vnc bash -c "exec x11vnc -display '$DISPLAY_ID' -forever -shared -nopw -rfbport '$VNC_PORT' -noxdamage >'$LOGS/x11vnc.log' 2>&1"
  sleep 1

  local webroot="/usr/share/novnc"
  [[ -d "$webroot" ]] || fail "noVNC não encontrado em $webroot. Rode: bash native/poketag-play.sh install"
  start_bg novnc bash -c "exec websockify --web='$webroot' '$NOVNC_PORT' localhost:'$VNC_PORT' >'$LOGS/novnc.log' 2>&1"
}

start_server() {
  say "Garantindo que o servidor nativo esteja online..."
  bash "$ROOT/native/poketag-native.sh" start
  port_open "$LOGIN_PORT" || fail "Servidor não abriu a porta $LOGIN_PORT."
  port_open "$GAME_PORT" || fail "Servidor não abriu a porta $GAME_PORT."
}

start_client() {
  export DISPLAY="$DISPLAY_ID"
  export WINEPREFIX="$WINEPREFIX_DIR"
  export WINEDEBUG=-all

  command -v wine >/dev/null 2>&1 || fail "Wine não instalado. Rode: bash native/poketag-play.sh install"
  mkdir -p "$WINEPREFIX_DIR"

  if [[ ! -f "$WINEPREFIX_DIR/.poketag-ready" ]]; then
    say "Inicializando o Wine do cliente pela primeira vez..."
    env DISPLAY="$DISPLAY_ID" WINEPREFIX="$WINEPREFIX_DIR" WINEDEBUG=-all wineboot -u >/dev/null 2>&1 || true
    touch "$WINEPREFIX_DIR/.poketag-ready"
  fi

  if ! pid_alive "$PIDS/client.pid"; then
    say "Abrindo OTClient 8.54..."
    (
      cd "$CLIENT_DIR"
      exec env DISPLAY="$DISPLAY_ID" WINEPREFIX="$WINEPREFIX_DIR" WINEDEBUG=-all wine "$CLIENT_EXE" >"$LOGS/client.log" 2>&1
    ) &
    echo $! > "$PIDS/client.pid"
  fi

  sleep 4
  if ! pid_alive "$PIDS/client.pid"; then
    tail -n 120 "$LOGS/client.log" >&2 || true
    fail "O OTClient encerrou durante a inicialização."
  fi
}

wait_novnc() {
  for _ in $(seq 1 30); do
    if port_open "$NOVNC_PORT"; then
      return 0
    fi
    sleep 1
  done
  fail "noVNC não abriu a porta $NOVNC_PORT."
}

credentials() {
  local db="$STATE_ROOT/forgottenserver.s3db"
  [[ -f "$db" ]] || {
    warn "Banco persistente ainda não existe. Inicie o servidor primeiro."
    return 1
  }

  python3 - "$db" <<'PY'
import sqlite3
import sys

path = sys.argv[1]
conn = sqlite3.connect(path)
cur = conn.cursor()

try:
    row = cur.execute("SELECT id, name, password FROM accounts WHERE name = '1' LIMIT 1").fetchone()
except sqlite3.Error as exc:
    print(f"Não foi possível consultar accounts: {exc}")
    raise SystemExit(1)

if row and str(row[2]) == '1':
    print("Conta padrão de teste detectada:")
    print("  account : 1")
    print("  password: 1")
    chars = cur.execute("SELECT name FROM players WHERE account_id = ? AND deleted = 0 ORDER BY name", (row[0],)).fetchall()
    if chars:
        print("  personagens:")
        for (name,) in chars[:20]:
            print(f"    - {name}")
    else:
        print("  personagens: nenhum cadastrado nessa conta")
else:
    print("A conta padrão 1/1 não foi encontrada no banco persistente.")
    print("Contas/personagens existentes (sem exibir senhas):")
    rows = cur.execute("""
        SELECT a.name, p.name
        FROM accounts a
        LEFT JOIN players p ON p.account_id = a.id AND p.deleted = 0
        ORDER BY a.id, p.name
        LIMIT 30
    """).fetchall()
    for account, player in rows:
        print(f"  account={account}  character={player or '-'}")
PY
}

start_all() {
  prepare_client
  start_server
  start_desktop
  start_client
  wait_novnc

  say "Ambiente de teste jogável iniciado."
  printf '\nNo Google Cloud Shell:\n'
  printf '  1. Abra Web Preview -> Preview on port %s\n' "$NOVNC_PORT"
  printf '  2. No noVNC, clique em Connect se necessário.\n'
  printf '  3. O OTClient deve abrir já apontando para 127.0.0.1:%s (8.54).\n' "$LOGIN_PORT"
  printf '  4. Veja credenciais locais com: bash native/poketag-play.sh credentials\n'
  printf '\nChecklist: native/GAME_TEST_PLAN.md\n'
  printf 'Status:    bash native/poketag-play.sh status\n'
  printf 'Logs:      bash native/poketag-play.sh logs\n'
  printf 'Parar UI:  bash native/poketag-play.sh stop\n'
}

stop_ui() {
  say "Encerrando cliente e desktop de teste..."
  for name in client novnc x11vnc xvfb; do
    local f="$PIDS/$name.pid"
    if [[ -f "$f" ]]; then
      local pid
      pid="$(cat "$f" 2>/dev/null || true)"
      if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
        kill "$pid" 2>/dev/null || true
        sleep 0.5
        kill -9 "$pid" 2>/dev/null || true
      fi
      rm -f "$f"
    fi
  done
  if command -v wineserver >/dev/null 2>&1; then
    WINEPREFIX="$WINEPREFIX_DIR" wineserver -k >/dev/null 2>&1 || true
  fi
  say "Interface de teste parada. O servidor nativo permanece separado."
}

status() {
  printf 'PokeTag Gameplay Test status:\n'
  for name in xvfb x11vnc novnc client; do
    if pid_alive "$PIDS/$name.pid"; then
      printf '  %-8s RUNNING (PID %s)\n' "$name" "$(cat "$PIDS/$name.pid")"
    else
      printf '  %-8s STOPPED\n' "$name"
    fi
  done

  if port_open "$LOGIN_PORT"; then
    printf '  login    OPEN 127.0.0.1:%s\n' "$LOGIN_PORT"
  else
    printf '  login    CLOSED :%s\n' "$LOGIN_PORT"
  fi
  if port_open "$GAME_PORT"; then
    printf '  game     OPEN 127.0.0.1:%s\n' "$GAME_PORT"
  else
    printf '  game     CLOSED :%s\n' "$GAME_PORT"
  fi
  if port_open "$NOVNC_PORT"; then
    printf '  noVNC    OPEN :%s\n' "$NOVNC_PORT"
  else
    printf '  noVNC    CLOSED :%s\n' "$NOVNC_PORT"
  fi
}

logs() {
  printf '\n===== SERVER =====\n'
  bash "$ROOT/native/poketag-native.sh" logs 2>/dev/null || true
  printf '\n===== CLIENT =====\n'
  tail -n "${LINES:-120}" "$LOGS/client.log" 2>/dev/null || true
  printf '\n===== noVNC =====\n'
  tail -n 40 "$LOGS/novnc.log" 2>/dev/null || true
}

doctor() {
  local failed=0
  for file in \
    "$ROOT/native/poketag-native.sh" \
    "$CLIENT_SRC/$CLIENT_EXE" \
    "$ASSET_SRC/POK.dat" \
    "$ASSET_SRC/POK.spr"; do
    if [[ -e "$file" ]]; then
      printf '  arquivo %-8s OK  %s\n' "" "${file#$ROOT/}"
    else
      printf '  arquivo %-8s FALTA %s\n' "" "${file#$ROOT/}"
      failed=1
    fi
  done

  for cmd in wine Xvfb x11vnc websockify python3 ss; do
    if command -v "$cmd" >/dev/null 2>&1; then
      printf '  %-16s OK\n' "$cmd"
    else
      printf '  %-16s FALTANDO\n' "$cmd"
      failed=1
    fi
  done
  return "$failed"
}

usage() {
  cat <<'EOF'
PokeTag Gameplay Test - cliente 8.54 + servidor Linux nativo

Uso:
  bash native/poketag-play.sh install      # instala dependências gráficas/Wine
  bash native/poketag-play.sh prepare      # prepara o cliente e assets 8.54
  bash native/poketag-play.sh start        # inicia servidor + noVNC + OTClient
  bash native/poketag-play.sh stop         # para somente cliente/noVNC
  bash native/poketag-play.sh status
  bash native/poketag-play.sh logs
  bash native/poketag-play.sh credentials  # mostra se 1/1 está disponível
  bash native/poketag-play.sh doctor
  bash native/poketag-play.sh setup        # install + start

Para encerrar também o servidor:
  bash native/poketag-native.sh stop
EOF
}

case "${1:-}" in
  install) install_ui_deps ;;
  prepare) prepare_client ;;
  start) start_all ;;
  stop) stop_ui ;;
  status) status ;;
  logs) logs ;;
  credentials) credentials ;;
  doctor) doctor ;;
  setup) install_ui_deps; start_all ;;
  help|-h|--help|"") usage ;;
  *) usage; exit 2 ;;
esac
