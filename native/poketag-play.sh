#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_ROOT="$ROOT/.poketag-native-state"
PLAY_ROOT="$STATE_ROOT/play"
CLIENT_DIR="$PLAY_ROOT/client"
WINEPREFIX_DIR="$PLAY_ROOT/wine"
LOGS="$PLAY_ROOT/logs"
PIDS="$PLAY_ROOT/pids"
NOVNC_WEB="$PLAY_ROOT/novnc-web"

PDA_ROOT="$ROOT/upstream/PDA-By-Slicer/extraidos"
CLIENT_SRC="$PDA_ROOT/OTClient v1.8/OTClient v1.8"
ASSET_SRC="$PDA_ROOT/Client v1.9 - v2.9/Client v1.9 - v2.9"
CLIENT_EXE="otclient.exe"

DISPLAY_ID=":99"
VNC_PORT=5900
NOVNC_PORT=6080
LOGIN_PORT=7171
GAME_PORT=7172

say()  { printf '\n[POKETAG-PLAY] %s\n' "$*"; }
warn() { printf '\n[POKETAG-PLAY][AVISO] %s\n' "$*" >&2; }
fail() { printf '\n[POKETAG-PLAY][ERRO] %s\n' "$*" >&2; exit 1; }

need_file() { [[ -f "$1" ]] || fail "Arquivo obrigatório não encontrado: $1"; }
need_dir()  { [[ -d "$1" ]] || fail "Diretório obrigatório não encontrado: $1"; }

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
    say "Preparando OTClient 8.54..."
    rm -rf "$CLIENT_DIR"
    mkdir -p "$CLIENT_DIR"
    cp -a "$CLIENT_SRC/." "$CLIENT_DIR/"
  fi

  mkdir -p "$CLIENT_DIR/modules/game_tibiafiles/854"
  cp -f "$ASSET_SRC/POK.dat" "$CLIENT_DIR/modules/game_tibiafiles/854/Tibia.dat"
  cp -f "$ASSET_SRC/POK.spr" "$CLIENT_DIR/modules/game_tibiafiles/854/Tibia.spr"

  cat > "$CLIENT_DIR/otclientrc.lua" <<'LUA'
-- PokeTag gameplay test: native server + protocol 8.54.
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

prepare_novnc_web() {
  local system_webroot="/usr/share/novnc"
  need_dir "$system_webroot"

  if [[ ! -f "$NOVNC_WEB/vnc.html" ]]; then
    rm -rf "$NOVNC_WEB"
    mkdir -p "$NOVNC_WEB"
    cp -a "$system_webroot/." "$NOVNC_WEB/"
  fi

  cat > "$NOVNC_WEB/index.html" <<'HTML'
<!doctype html>
<html><head>
<meta charset="utf-8">
<meta http-equiv="refresh" content="0; url=vnc.html?autoconnect=1&resize=scale">
<title>PokeTag</title>
</head><body>
<a href="vnc.html?autoconnect=1&resize=scale">Abrir PokeTag</a>
</body></html>
HTML
}

start_desktop() {
  mkdir -p "$LOGS" "$PIDS"
  prepare_novnc_web
  export DISPLAY="$DISPLAY_ID"

  start_bg xvfb bash -c "exec Xvfb '$DISPLAY_ID' -screen 0 1440x900x24 -ac >'$LOGS/xvfb.log' 2>&1"
  sleep 2
  start_bg x11vnc bash -c "exec x11vnc -display '$DISPLAY_ID' -forever -shared -nopw -rfbport '$VNC_PORT' -noxdamage >'$LOGS/x11vnc.log' 2>&1"
  sleep 1
  start_bg novnc bash -c "exec websockify --web='$NOVNC_WEB' '$NOVNC_PORT' localhost:'$VNC_PORT' >'$LOGS/novnc.log' 2>&1"
}

start_server() {
  say "Garantindo que o servidor Linux nativo esteja online..."
  bash "$ROOT/native/poketag-native.sh" start
  port_open "$LOGIN_PORT" || fail "Servidor não abriu a porta $LOGIN_PORT."
  port_open "$GAME_PORT" || fail "Servidor não abriu a porta $GAME_PORT."
}

wine_prefix_is_32bit() {
  [[ -f "$WINEPREFIX_DIR/system.reg" ]] && grep -q '^#arch=win32' "$WINEPREFIX_DIR/system.reg"
}

prepare_wine32() {
  command -v wine >/dev/null 2>&1 || fail "Wine não instalado. Rode: bash native/poketag-play.sh install"
  mkdir -p "$LOGS"

  if [[ -d "$WINEPREFIX_DIR" ]] && ! wine_prefix_is_32bit; then
    warn "Prefixo Wine incompatível detectado; recriando somente o ambiente do cliente em 32 bits."
    rm -rf "$WINEPREFIX_DIR"
  fi

  if ! wine_prefix_is_32bit; then
    say "Criando prefixo Wine 32-bit para o OTClient legado..."
    rm -rf "$WINEPREFIX_DIR"
    mkdir -p "$WINEPREFIX_DIR"

    set +e
    env \
      DISPLAY="$DISPLAY_ID" \
      WINEPREFIX="$WINEPREFIX_DIR" \
      WINEARCH=win32 \
      WINEDLLOVERRIDES='mscoree,mshtml=' \
      wineboot -u >"$LOGS/wineboot.log" 2>&1
    local rc=$?
    set -e

    if [[ "$rc" -ne 0 ]] || ! wine_prefix_is_32bit; then
      cat "$LOGS/wineboot.log" >&2 || true
      fail "Não foi possível criar o prefixo Wine 32-bit."
    fi
  fi
}

start_client() {
  prepare_wine32
  export DISPLAY="$DISPLAY_ID"

  if pid_alive "$PIDS/client.pid"; then
    say "OTClient já está rodando (PID $(cat "$PIDS/client.pid"))."
    return 0
  fi

  rm -f "$PIDS/client.pid"
  : > "$LOGS/client.log"
  say "Abrindo OTClient 8.54 em Wine 32-bit..."

  (
    cd "$CLIENT_DIR"
    exec env \
      DISPLAY="$DISPLAY_ID" \
      WINEPREFIX="$WINEPREFIX_DIR" \
      WINEARCH=win32 \
      WINEDLLOVERRIDES='mscoree,mshtml=' \
      LIBGL_ALWAYS_SOFTWARE=1 \
      WINEDEBUG=-all \
      wine "./$CLIENT_EXE" >>"$LOGS/client.log" 2>&1
  ) &
  echo $! > "$PIDS/client.pid"

  for _ in $(seq 1 20); do
    if ! pid_alive "$PIDS/client.pid"; then
      tail -n 160 "$LOGS/client.log" >&2 || true
      fail "O OTClient encerrou durante a inicialização."
    fi
    if DISPLAY="$DISPLAY_ID" xwininfo -root -tree 2>/dev/null | grep -qi 'OTClient'; then
      say "Janela do OTClient detectada."
      return 0
    fi
    sleep 0.5
  done

  # Algumas versões não expõem o título imediatamente, mas permanecem funcionais.
  pid_alive "$PIDS/client.pid" || fail "OTClient não permaneceu em execução."
  say "OTClient em execução."
}

wait_novnc() {
  for _ in $(seq 1 30); do
    if port_open "$NOVNC_PORT"; then return 0; fi
    sleep 1
  done
  fail "noVNC não abriu a porta $NOVNC_PORT."
}

credentials() {
  local db="$STATE_ROOT/forgottenserver.s3db"
  [[ -f "$db" ]] || { warn "Banco persistente ainda não existe. Inicie o servidor primeiro."; return 1; }

  python3 - "$db" <<'PY'
import sqlite3, sys
conn = sqlite3.connect(sys.argv[1])
cur = conn.cursor()
row = cur.execute("SELECT id, name, password FROM accounts WHERE name='1' LIMIT 1").fetchone()
if row and str(row[2]) == '1':
    print('Conta padrão de teste detectada:')
    print('  account : 1')
    print('  password: 1')
    chars = cur.execute("SELECT name FROM players WHERE account_id=? AND deleted=0 ORDER BY name", (row[0],)).fetchall()
    if chars:
        print('  personagens:')
        for (name,) in chars[:20]: print(f'    - {name}')
    else:
        print('  personagens: nenhum cadastrado nessa conta')
else:
    print('A conta padrão 1/1 não foi encontrada.')
    print('Contas/personagens existentes (sem senhas):')
    for account, player in cur.execute("""
        SELECT a.name, p.name FROM accounts a
        LEFT JOIN players p ON p.account_id=a.id AND p.deleted=0
        ORDER BY a.id, p.name LIMIT 30
    """):
        print(f'  account={account}  character={player or "-"}')
conn.close()
PY
}

start_all() {
  prepare_client
  start_server
  start_desktop
  wait_novnc
  start_client

  say "PokeTag pronto para teste jogável."
  printf '\nAbra no Google Cloud Shell:\n'
  printf '  Web Preview -> Preview on port %s\n' "$NOVNC_PORT"
  printf '  A página agora redireciona automaticamente para o noVNC.\n'
  printf '\nServidor : 127.0.0.1:%s / game %s\n' "$LOGIN_PORT" "$GAME_PORT"
  printf 'Protocolo: 8.54\n'
  printf 'Credenciais: bash native/poketag-play.sh credentials\n'
  printf 'Status      : bash native/poketag-play.sh status\n'
  printf 'Logs        : bash native/poketag-play.sh logs\n'
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
  if command -v wineserver >/dev/null 2>&1 && [[ -d "$WINEPREFIX_DIR" ]]; then
    WINEPREFIX="$WINEPREFIX_DIR" wineserver -k >/dev/null 2>&1 || true
  fi
  say "Interface parada. O servidor nativo permanece separado."
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
  port_open "$LOGIN_PORT" && printf '  login    OPEN 127.0.0.1:%s\n' "$LOGIN_PORT" || printf '  login    CLOSED :%s\n' "$LOGIN_PORT"
  port_open "$GAME_PORT"  && printf '  game     OPEN 127.0.0.1:%s\n' "$GAME_PORT"  || printf '  game     CLOSED :%s\n' "$GAME_PORT"
  port_open "$NOVNC_PORT" && printf '  noVNC    OPEN :%s\n' "$NOVNC_PORT" || printf '  noVNC    CLOSED :%s\n' "$NOVNC_PORT"
  wine_prefix_is_32bit && printf '  wine     PREFIX win32 OK\n' || printf '  wine     PREFIX win32 AUSENTE/INVÁLIDO\n'
}

logs() {
  printf '\n===== SERVER =====\n'
  bash "$ROOT/native/poketag-native.sh" logs 2>/dev/null || true
  printf '\n===== CLIENT =====\n'
  tail -n "${LINES:-160}" "$LOGS/client.log" 2>/dev/null || true
  printf '\n===== WINEBOOT =====\n'
  tail -n 80 "$LOGS/wineboot.log" 2>/dev/null || true
  printf '\n===== noVNC =====\n'
  tail -n 60 "$LOGS/novnc.log" 2>/dev/null || true
}

doctor() {
  local failed=0
  for file in \
    "$ROOT/native/poketag-native.sh" \
    "$CLIENT_SRC/$CLIENT_EXE" \
    "$ASSET_SRC/POK.dat" \
    "$ASSET_SRC/POK.spr"; do
    if [[ -e "$file" ]]; then
      printf '  arquivo          OK  %s\n' "${file#$ROOT/}"
    else
      printf '  arquivo          FALTA %s\n' "${file#$ROOT/}"
      failed=1
    fi
  done
  for cmd in wine Xvfb x11vnc websockify xwininfo python3 ss; do
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
  bash native/poketag-play.sh install
  bash native/poketag-play.sh prepare
  bash native/poketag-play.sh start
  bash native/poketag-play.sh stop
  bash native/poketag-play.sh status
  bash native/poketag-play.sh logs
  bash native/poketag-play.sh credentials
  bash native/poketag-play.sh doctor
  bash native/poketag-play.sh setup

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
