#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME="$ROOT/.poketag-runtime"
LOGS="$RUNTIME/logs"
PIDS="$RUNTIME/pids"

PDA_ROOT="$ROOT/upstream/PDA-By-Slicer/extraidos"
SERVER_SRC="$PDA_ROOT/Serv Full v2.9/Serv Full v2.9"
CLIENT_SRC="$PDA_ROOT/OTClient v1.8/OTClient v1.8"
ASSET_SRC="$PDA_ROOT/Client v1.9 - v2.9/Client v1.9 - v2.9"

SERVER_DIR="$RUNTIME/server"
CLIENT_DIR="$RUNTIME/client"
WINEPREFIX_DIR="$RUNTIME/wine"

SERVER_EXE="PO Dash World [Advanced] - GUI.exe"
CLIENT_EXE="otclient.exe"
DISPLAY_ID=":99"
VNC_PORT=5900
NOVNC_PORT=6080
LOGIN_PORT=7171
GAME_PORT=7172

say() { printf '\n[POKETAG] %s\n' "$*"; }
warn() { printf '\n[POKETAG][AVISO] %s\n' "$*" >&2; }
fail() { printf '\n[POKETAG][ERRO] %s\n' "$*" >&2; exit 1; }

need_file() {
  [[ -f "$1" ]] || fail "Arquivo obrigatório não encontrado: $1"
}

need_dir() {
  [[ -d "$1" ]] || fail "Diretório obrigatório não encontrado: $1"
}

port_open() {
  local port="$1"
  ss -ltnH 2>/dev/null | awk '{print $4}' | grep -Eq ":${port}$"
}

install_deps() {
  say "Instalando dependências para o modo local no Cloud Shell..."
  sudo dpkg --add-architecture i386 || true
  sudo apt-get update
  sudo apt-get install -y \
    xvfb x11vnc novnc websockify xdotool \
    wine wine64 wine32:i386 \
    cabextract winbind procps iproute2 python3
  say "Dependências instaladas."
}

doctor() {
  say "Verificando os três blocos do Frankenstein..."
  need_dir "$SERVER_SRC"
  need_dir "$CLIENT_SRC"
  need_dir "$ASSET_SRC"
  need_file "$SERVER_SRC/$SERVER_EXE"
  need_file "$CLIENT_SRC/$CLIENT_EXE"
  need_file "$ASSET_SRC/POK.dat"
  need_file "$ASSET_SRC/POK.spr"
  need_file "$ROOT/upstream/poketibia-sirninja/Servidor/Pokemon EX 2.0/Server Sources/resources.h"
  need_file "$ROOT/upstream/otclient-opentibiabr/CMakeLists.txt"
  need_file "$ROOT/upstream/otclient-opentibiabr/data/things/854/Tibia.dat"
  need_file "$ROOT/upstream/otclient-opentibiabr/data/things/854/Tibia.spr"

  printf '  PDA 2.9 (conteúdo/servidor): OK\n'
  printf '  PokeTibia sirninja (fonte TFS 8.54): OK\n'
  printf '  OTClient moderno + assets 8.54: OK\n'

  if command -v wine >/dev/null 2>&1; then
    printf '  Wine: OK\n'
  else
    printf '  Wine: NÃO INSTALADO (rode: bash poketag.sh install)\n'
  fi
  if command -v Xvfb >/dev/null 2>&1 && command -v x11vnc >/dev/null 2>&1 && command -v websockify >/dev/null 2>&1; then
    printf '  Desktop virtual/noVNC: OK\n'
  else
    printf '  Desktop virtual/noVNC: NÃO INSTALADO\n'
  fi
  if command -v xdotool >/dev/null 2>&1; then
    printf '  Automação de prompts legados: OK\n'
  else
    printf '  Automação de prompts legados: NÃO INSTALADA (rode: bash poketag.sh install)\n'
  fi
}

configure_server() {
  local cfg="$SERVER_DIR/config.lua"
  need_file "$cfg"

  python3 - "$cfg" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
text = path.read_text(encoding='utf-8', errors='replace')

replacements = {
    'ip': '"127.0.0.1"',
    'serverName': '"PokeTag Local"',
    'motd': '"Bem-vindo ao PokeTag Local"',
    'loginMessage': '"Sua jornada local PokeTag"',
    'worldType': '"no-pvp"',
    'maxPlayers': '4',
    'onePlayerOnlinePerAccount': 'true',
    'allowClones': 'false',
    'freePremium': 'true',
    'idleWarningTime': '364 * 24 * 60 * 60 * 1000',
    'idleKickTime': '365 * 24 * 60 * 60 * 1000',
    'confirmOutdatedVersion': 'false',
}

for key, value in replacements.items():
    pattern = rf'(?m)^(\s*){re.escape(key)}\s*=.*$'
    repl = rf'\1{key} = {value}'
    text, count = re.subn(pattern, repl, text, count=1)
    if count == 0:
        text += f'\n\t{key} = {value}\n'

path.write_text(text, encoding='utf-8')
PY
}

patch_dead_tfs_endpoints() {
  local exe="$SERVER_DIR/$SERVER_EXE"
  need_file "$exe"

  python3 - "$exe" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])
data = path.read_bytes()
old = b'forgottenserver.otland.net'
replacement_host = b'127.0.0.1'
new = replacement_host + (b'\x00' * (len(old) - len(replacement_host)))

if old in data:
    backup = path.with_name(path.name + '.pre-poketag-blacklist-fix')
    if not backup.exists():
        backup.write_bytes(data)
    data = data.replace(old, new)
    path.write_bytes(data)
    print('[POKETAG] Endpoints antigos de version/blacklist neutralizados no executável de runtime.')
elif replacement_host in data:
    print('[POKETAG] Correção dos endpoints antigos já aplicada.')
else:
    print('[POKETAG][AVISO] Assinatura antiga de blacklist/version não encontrada; seguindo sem patch.')
PY
}

configure_legacy_client() {
  mkdir -p "$CLIENT_DIR/modules/game_tibiafiles/854"
  cp -f "$ASSET_SRC/POK.dat" "$CLIENT_DIR/modules/game_tibiafiles/854/Tibia.dat"
  cp -f "$ASSET_SRC/POK.spr" "$CLIENT_DIR/modules/game_tibiafiles/854/Tibia.spr"

  cat > "$CLIENT_DIR/otclientrc.lua" <<'LUA'
-- PokeTag local profile for the PDA OTClient.
-- Uses the original 8.54 protocol and points only to the local server.
local function poketagLocal()
  g_settings.set('host', '127.0.0.1')
  g_settings.set('port', 7171)
  g_settings.set('client-version', 854)
  g_settings.set('autologin', false)

  if EnterGame then
    EnterGame.setUniqueServer('127.0.0.1', 7171, 854, 330, 220)
  end
end

addEvent(poketagLocal)
LUA
}

prepare_runtime() {
  doctor >/dev/null
  mkdir -p "$RUNTIME" "$LOGS" "$PIDS"

  if [[ ! -d "$SERVER_DIR/data" ]]; then
    say "Criando servidor local persistente a partir do PDA 2.9..."
    mkdir -p "$SERVER_DIR"
    cp -a "$SERVER_SRC/." "$SERVER_DIR/"
  fi

  if [[ ! -f "$CLIENT_DIR/$CLIENT_EXE" ]]; then
    say "Criando cliente compatível a partir do OTClient PDA..."
    mkdir -p "$CLIENT_DIR"
    cp -a "$CLIENT_SRC/." "$CLIENT_DIR/"
  fi

  configure_server
  patch_dead_tfs_endpoints
  configure_legacy_client

  mkdir -p "$WINEPREFIX_DIR"
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
    say "$name já está rodando (PID $(cat "$pidfile"))."
    return
  fi
  "$@" &
  echo $! > "$pidfile"
}

start_desktop() {
  export DISPLAY="$DISPLAY_ID"

  start_bg xvfb bash -c "exec Xvfb '$DISPLAY_ID' -screen 0 1440x900x24 -ac >'$LOGS/xvfb.log' 2>&1"
  sleep 2
  start_bg x11vnc bash -c "exec x11vnc -display '$DISPLAY_ID' -forever -shared -nopw -rfbport '$VNC_PORT' -noxdamage >'$LOGS/x11vnc.log' 2>&1"
  sleep 1

  local webroot="/usr/share/novnc"
  [[ -d "$webroot" ]] || fail "noVNC não encontrado em $webroot. Rode: bash poketag.sh install"
  start_bg novnc bash -c "exec websockify --web='$webroot' '$NOVNC_PORT' localhost:'$VNC_PORT' >'$LOGS/novnc.log' 2>&1"
}

auto_accept_blacklist_prompt() {
  export DISPLAY="$DISPLAY_ID"
  : > "$LOGS/legacy-prompts.log"

  (
    for _ in $(seq 1 180); do
      local wid=""
      wid="$(xdotool search --onlyvisible --name 'Blacklist' 2>/dev/null | head -n 1 || true)"
      if [[ -n "$wid" ]]; then
        printf '[POKETAG] Prompt legado Blacklist detectado; aceitando Continue/Yes.\n' >> "$LOGS/legacy-prompts.log"
        xdotool windowactivate --sync "$wid" 2>/dev/null || true
        xdotool key --window "$wid" Return 2>/dev/null || true
        return 0
      fi
      sleep 0.5
    done
    printf '[POKETAG] Nenhum prompt Blacklist apareceu no período de espera.\n' >> "$LOGS/legacy-prompts.log"
  ) &
}

wait_for_server_ready() {
  say "Aguardando o servidor abrir as portas $LOGIN_PORT/$GAME_PORT..."
  for _ in $(seq 1 120); do
    if port_open "$LOGIN_PORT" && port_open "$GAME_PORT"; then
      say "Servidor pronto: portas $LOGIN_PORT e $GAME_PORT abertas."
      return 0
    fi
    if ! pid_alive "$PIDS/server.pid"; then
      fail "O processo do servidor encerrou durante a inicialização. Rode: bash poketag.sh logs"
    fi
    sleep 1
  done

  warn "O processo do servidor continua vivo, mas não abriu $LOGIN_PORT/$GAME_PORT em 120 segundos."
  warn "Abra o noVNC e confira a janela do servidor. Depois rode: bash poketag.sh status"
  return 1
}

start_wine() {
  export DISPLAY="$DISPLAY_ID"
  export WINEPREFIX="$WINEPREFIX_DIR"
  export WINEDEBUG=-all

  if ! command -v wine >/dev/null 2>&1; then
    fail "Wine não está instalado. Rode primeiro: bash poketag.sh install"
  fi
  if ! command -v xdotool >/dev/null 2>&1; then
    fail "xdotool não está instalado. Rode novamente: bash poketag.sh install"
  fi

  if [[ ! -f "$WINEPREFIX_DIR/.poketag-wine-ready" ]]; then
    say "Inicializando Wine pela primeira vez..."
    env DISPLAY="$DISPLAY_ID" WINEPREFIX="$WINEPREFIX_DIR" WINEDEBUG=-all wineboot -u >/dev/null 2>&1 || true
    touch "$WINEPREFIX_DIR/.poketag-wine-ready"
  fi

  if ! pid_alive "$PIDS/server.pid"; then
    say "Iniciando servidor PDA 2.9 em 127.0.0.1:$LOGIN_PORT/$GAME_PORT..."
    (
      cd "$SERVER_DIR"
      exec env DISPLAY="$DISPLAY_ID" WINEPREFIX="$WINEPREFIX_DIR" WINEDEBUG=-all wine "$SERVER_EXE" >"$LOGS/server.log" 2>&1
    ) &
    echo $! > "$PIDS/server.pid"
  fi

  auto_accept_blacklist_prompt

  if ! wait_for_server_ready; then
    return 1
  fi

  if ! pid_alive "$PIDS/client.pid"; then
    say "Iniciando OTClient PDA no desktop virtual..."
    (
      cd "$CLIENT_DIR"
      exec env DISPLAY="$DISPLAY_ID" WINEPREFIX="$WINEPREFIX_DIR" WINEDEBUG=-all wine "$CLIENT_EXE" >"$LOGS/client.log" 2>&1
    ) &
    echo $! > "$PIDS/client.pid"
  fi
}

run_local() {
  prepare_runtime
  start_desktop
  start_wine

  say "PokeTag local iniciado."
  printf '\nAbra no Google Cloud Shell:\n'
  printf '  Web Preview -> Preview on port %s\n' "$NOVNC_PORT"
  printf 'Depois, no noVNC, clique em Connect se necessário.\n\n'
  printf 'Servidor: 127.0.0.1:%s / jogo: %s / protocolo: 8.54\n' "$LOGIN_PORT" "$GAME_PORT"
  printf 'A jornada fica salva em: %s\n' "$SERVER_DIR/forgottenserver.s3db"
  printf 'Logs: bash poketag.sh logs\n'
  printf 'Parar: bash poketag.sh stop\n'
}

stop_all() {
  say "Encerrando PokeTag..."
  for name in client server novnc x11vnc xvfb; do
    local f="$PIDS/$name.pid"
    if [[ -f "$f" ]]; then
      local pid
      pid="$(cat "$f" 2>/dev/null || true)"
      if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
        kill "$pid" 2>/dev/null || true
        sleep 1
        kill -9 "$pid" 2>/dev/null || true
      fi
      rm -f "$f"
    fi
  done
  if command -v wineserver >/dev/null 2>&1; then
    WINEPREFIX="$WINEPREFIX_DIR" wineserver -k >/dev/null 2>&1 || true
  fi
}

status() {
  printf 'PokeTag status:\n'
  for name in xvfb x11vnc novnc client; do
    if pid_alive "$PIDS/$name.pid"; then
      printf '  %-8s RUNNING (PID %s)\n' "$name" "$(cat "$PIDS/$name.pid")"
    else
      printf '  %-8s STOPPED\n' "$name"
    fi
  done

  if pid_alive "$PIDS/server.pid"; then
    if port_open "$LOGIN_PORT" && port_open "$GAME_PORT"; then
      printf '  %-8s READY (PID %s; %s/%s abertas)\n' "server" "$(cat "$PIDS/server.pid")" "$LOGIN_PORT" "$GAME_PORT"
    else
      printf '  %-8s BLOCKED/STARTING (PID %s; portas %s/%s fechadas)\n' "server" "$(cat "$PIDS/server.pid")" "$LOGIN_PORT" "$GAME_PORT"
    fi
  else
    printf '  %-8s STOPPED\n' "server"
  fi

  printf '\nPortas locais:\n'
  ss -ltn 2>/dev/null | grep -E ':(5900|6080|7171|7172)\b' || true
}

logs() {
  mkdir -p "$LOGS"
  for f in "$LOGS"/*.log; do
    [[ -f "$f" ]] || continue
    printf '\n===== %s =====\n' "$(basename "$f")"
    tail -n 60 "$f"
  done
}

reset_runtime() {
  stop_all
  say "Apagando a jornada/runtime local..."
  rm -rf "$RUNTIME"
  say "Runtime removido. O próximo 'run' criará uma jornada nova."
}

usage() {
  cat <<'EOF'
PokeTag Frankenstein local

Uso:
  bash poketag.sh doctor   verifica os arquivos dos 3 projetos
  bash poketag.sh install  instala Wine + Xvfb + noVNC + automação de prompts
  bash poketag.sh run      prepara e inicia servidor + cliente local
  bash poketag.sh status   mostra processos, readiness e portas
  bash poketag.sh logs     mostra os logs recentes
  bash poketag.sh stop     encerra cliente/servidor/noVNC
  bash poketag.sh reset    APAGA a jornada local de teste e recria do zero no próximo run

A jornada fica dentro de .poketag-runtime e não é commitada no Git.
O launcher neutraliza apenas no executável de runtime os endpoints antigos
forgottenserver.otland.net/version.xml e blacklist.xml, que não existem mais.
O executável original em upstream/ não é alterado.
EOF
}

case "${1:-}" in
  doctor) doctor ;;
  install) install_deps ;;
  run) run_local ;;
  status) status ;;
  logs) logs ;;
  stop) stop_all ;;
  reset) reset_runtime ;;
  *) usage ;;
esac
