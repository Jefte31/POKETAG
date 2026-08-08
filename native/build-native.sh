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
python3 - \
  "$WORK/otserv.cpp" \
  "$WORK/configure.ac" \
  "$WORK/house.h" \
  "$WORK/chat.cpp" \
  "$WORK/condition.h" \
  "$WORK/combat.cpp" \
  "$WORK/condition.cpp" \
  "$WORK/configmanager.cpp" \
  "$WORK/connection.cpp" \
  "$WORK/game.cpp" \
  "$WORK/luascript.cpp" \
  "$WORK/monster.cpp" \
  "$WORK/monsters.cpp" <<'PY'
from pathlib import Path
import sys

def read(path):
    return Path(path).read_text(encoding='latin-1')

def write(path, text):
    Path(path).write_text(text, encoding='latin-1')

# The original 2010-era engine blocks startup on dead remote services.
otserv = Path(sys.argv[1])
text = read(otserv)
start = '\tstd::cout << ">> Checking software version... ";'
end = '\tstd::cout << ">> Loading RSA key" << std::endl;'
si = text.find(start)
ei = text.find(end, si)
if si < 0 or ei < 0:
    raise SystemExit('Could not locate legacy version/blacklist block in otserv.cpp')
text = text[:si] + (
    '\tstd::cout << ">> PokeTag local mode: legacy update/blacklist checks disabled." << std::endl;\n\n'
) + text[ei:]
write(otserv, text)

# Modern Boost no longer ships the old boost/tr1 wrapper.
configure = Path(sys.argv[2])
cfg = read(configure)
old = 'AC_CHECK_HEADERS([boost/tr1/unordered_set.hpp], , [AC_MSG_ERROR("boost::unordered_set header not found.")])'
new = 'AC_CHECK_HEADERS([boost/unordered_set.hpp], , [AC_MSG_ERROR("boost::unordered_set header not found.")])'
if old not in cfg:
    raise SystemExit('Could not locate legacy Boost unordered_set configure check')
write(configure, cfg.replace(old, new))

house = Path(sys.argv[3])
h = read(house)
old_include = '#include <boost/tr1/unordered_set.hpp>'
old_type = 'typedef std::tr1::unordered_set<uint32_t> PlayerList;'
if old_include not in h or old_type not in h:
    raise SystemExit('Could not locate legacy TR1 unordered_set usage in house.h')
h = h.replace(old_include, '#include <boost/unordered_set.hpp>')
h = h.replace(old_type, 'typedef boost::unordered_set<uint32_t> PlayerList;')
write(house, h)

# GCC 11+ correctly rejects bool as a pointer return value.
chat = Path(sys.argv[4])
c = read(chat)
needle = 'if(!player || player->isRemoved())\n\t\treturn false;'
if needle not in c:
    raise SystemExit('Could not locate Chat::getChannel null return')
c = c.replace(needle, 'if(!player || player->isRemoved())\n\t\treturn NULL;', 1)
write(chat, c)

# PokeTibia added a steel combat type but omitted a condition enum bit. The
# existing CONDITION_TEST bit is unused and is retained as a compatibility alias.
condition = Path(sys.argv[5])
cond = read(condition)
needle = '\tCONDITION_TEST = 1 << 24,\n\tCONDITION_ELECTRIC = 1 << 25,'
if needle not in cond:
    raise SystemExit('Could not locate condition enum compatibility slot')
cond = cond.replace(
    needle,
    '\tCONDITION_TEST = 1 << 24,\n\tCONDITION_STEEL = CONDITION_TEST,\n\tCONDITION_ELECTRIC = 1 << 25,',
    1,
)
write(condition, cond)

# This fork has a missing brace around attackerPlayer logic, leaving `color`
# out of scope on conforming compilers. Restore the intended block structure.
combat = Path(sys.argv[6])
co = read(combat)
old_block = '''\t\tconst Player* attackerPlayer = NULL;
\t\tif((attackerPlayer = attacker->getPlayer()) || (attacker->getMaster()
\t\t\t&& (attackerPlayer = attacker->getMaster()->getPlayer())))
\t\t\tuint32_t color = g_config.getNumber(ConfigManager::NO_DAMAGE_TO_SAME_COLORS);
\t\tif(color != 0)
\t\t{
                 Outfit_t attackerOutfit = attackerPlayer->getCurrentOutfit();
                 Outfit_t targetOutfit = targetPlayer->getCurrentOutfit();
                 if(attackerOutfit.lookHead == targetOutfit.lookHead && attackerOutfit.lookBody == targetOutfit.lookBody && attackerOutfit.lookLegs == targetOutfit.lookLegs && attackerOutfit.lookFeet == targetOutfit.lookFeet)
                 {
                  return RET_YOUMAYNOTATTACKTHISPLAYER;
                 }
        }
\t\t{
\t\t\tcheckZones = true;
\t\t\tif((g_game.getWorldType() == WORLD_TYPE_NO_PVP && !Combat::isInPvpZone(attacker, target)) ||
\t\t\t\tisProtected(const_cast<Player*>(attackerPlayer), const_cast<Player*>(targetPlayer))
\t\t\t\t|| (g_config.getBool(ConfigManager::CANNOT_ATTACK_SAME_LOOKFEET) &&
\t\t\t\tattackerPlayer->getDefaultOutfit().lookFeet == targetPlayer->getDefaultOutfit().lookFeet)
\t\t\t\t|| !attackerPlayer->canSeeCreature(targetPlayer))
\t\t\t\treturn RET_YOUMAYNOTATTACKTHISPLAYER;
\t\t}
'''
new_block = '''\t\tconst Player* attackerPlayer = NULL;
\t\tif((attackerPlayer = attacker->getPlayer()) || (attacker->getMaster()
\t\t\t&& (attackerPlayer = attacker->getMaster()->getPlayer())))
\t\t{
\t\t\tuint32_t color = g_config.getNumber(ConfigManager::NO_DAMAGE_TO_SAME_COLORS);
\t\t\tif(color != 0)
\t\t\t{
\t\t\t\tOutfit_t attackerOutfit = attackerPlayer->getCurrentOutfit();
\t\t\t\tOutfit_t targetOutfit = targetPlayer->getCurrentOutfit();
\t\t\t\tif(attackerOutfit.lookHead == targetOutfit.lookHead && attackerOutfit.lookBody == targetOutfit.lookBody && attackerOutfit.lookLegs == targetOutfit.lookLegs && attackerOutfit.lookFeet == targetOutfit.lookFeet)
\t\t\t\t\treturn RET_YOUMAYNOTATTACKTHISPLAYER;
\t\t\t}

\t\t\tcheckZones = true;
\t\t\tif((g_game.getWorldType() == WORLD_TYPE_NO_PVP && !Combat::isInPvpZone(attacker, target)) ||
\t\t\t\tisProtected(const_cast<Player*>(attackerPlayer), const_cast<Player*>(targetPlayer))
\t\t\t\t|| (g_config.getBool(ConfigManager::CANNOT_ATTACK_SAME_LOOKFEET) &&
\t\t\t\tattackerPlayer->getDefaultOutfit().lookFeet == targetPlayer->getDefaultOutfit().lookFeet)
\t\t\t\t|| !attackerPlayer->canSeeCreature(targetPlayer))
\t\t\t\treturn RET_YOUMAYNOTATTACKTHISPLAYER;
\t\t}
'''
if old_block not in co:
    raise SystemExit('Could not locate malformed attackerPlayer block in combat.cpp')
write(combat, co.replace(old_block, new_block, 1))

# Typo in the fork prevents ConditionSpeed from compiling.
condition_cpp = Path(sys.argv[7])
cc = read(condition_cpp)
needle = 'propWrifream.ADD_VALUE(minb);'
if needle not in cc:
    raise SystemExit('Could not locate ConditionSpeed serialization typo')
write(condition_cpp, cc.replace(needle, 'propWriteStream.ADD_VALUE(minb);', 1))

# This one line kept the pre-refactor Lua-state parameter while every nearby
# config read uses the current member helper signature.
configmanager = Path(sys.argv[8])
cm = read(configmanager)
needle = 'getGlobalNumber(L, "noDamageToSameColors", 0)'
if needle not in cm:
    raise SystemExit('Could not locate legacy getGlobalNumber call')
write(configmanager, cm.replace(needle, 'getGlobalNumber("noDamageToSameColors", 0)', 1))

# Newer Boost.Date_Time deliberately does not classify an unnamed enum as an
# integral template argument. Preserve the legacy timeout values while giving
# seconds() the int type it expects.
connection = Path(sys.argv[9])
cn = read(connection)
replacements = {
    'boost::posix_time::seconds(Connection::readTimeout)':
        'boost::posix_time::seconds(static_cast<int>(Connection::readTimeout))',
    'boost::posix_time::seconds(Connection::writeTimeout)':
        'boost::posix_time::seconds(static_cast<int>(Connection::writeTimeout))',
}
for old, new in replacements.items():
    if old not in cn:
        raise SystemExit('Could not locate legacy Connection timeout expression: ' + old)
    cn = cn.replace(old, new)
write(connection, cn)

# Modern GCC rejects false as an Item* sentinel. This function uses NULL as
# the conventional not-found result elsewhere in this codebase.
game = Path(sys.argv[10])
gm = read(game)
needle = '''Item* Game::findItemOfType(Cylinder* cylinder, uint16_t itemId,
\tbool depthSearch /*= true*/, int32_t subType /*= -1*/)
{
\tif(!cylinder)
\t\treturn false;'''
replacement = '''Item* Game::findItemOfType(Cylinder* cylinder, uint16_t itemId,
\tbool depthSearch /*= true*/, int32_t subType /*= -1*/)
{
\tif(!cylinder)
\t\treturn NULL;'''
if needle not in gm:
    raise SystemExit('Could not locate Game::findItemOfType pointer sentinel')
gm = gm.replace(needle, replacement, 1)

# Two stale switch labels still use the fork's old TEST placeholder. The
# published enum already has COMBAT_STEELDAMAGE and the condition/combat layer
# maps the corresponding steel condition to that type, so use the canonical
# combat enum here as well.
count = gm.count('case COMBAT_TESTDAMAGE:')
if count != 2:
    raise SystemExit('Expected exactly 2 stale COMBAT_TESTDAMAGE cases, found %d' % count)
gm = gm.replace('case COMBAT_TESTDAMAGE:', 'case COMBAT_STEELDAMAGE:')
write(game, gm)

# Boost.Filesystem removed directory_entry::leaf(). filename().string() is the
# direct modern equivalent and keeps the loader's sorting/filtering behavior.
luascript = Path(sys.argv[11])
ls = read(luascript)
needle = 'std::string s = it->leaf();'
if needle not in ls:
    raise SystemExit('Could not locate legacy Boost filesystem leaf() call')
write(luascript, ls.replace(needle, 'std::string s = it->path().filename().string();', 1))

# A stray, incomplete symbol was left between two Monster method definitions.
# It has no declaration/body and is not a valid function definition, so remove
# only that orphan line while leaving the surrounding behavior untouched.
monster = Path(sys.argv[12])
mo = read(monster)
needle = '\nCreature::createCorpse\nvoid Monster::getPathSearchParams'
if needle not in mo:
    raise SystemExit('Could not locate orphan Creature::createCorpse token')
write(monster, mo.replace(needle, '\nvoid Monster::getPathSearchParams', 1))

# The fork already defines COMBAT_STEELDAMAGE, but two monster parsing paths
# still reference a removed COMBAT_TESTDAMAGE placeholder. Preserve old XML
# files that may say "test" while also accepting the intended "steel" name.
monsters = Path(sys.argv[13])
ms = read(monsters)
name_needle = 'else if(tmpName == "test")\n\t\t\tcombat->setParam(COMBATPARAM_COMBATTYPE, COMBAT_TESTDAMAGE);'
name_replacement = 'else if(tmpName == "test" || tmpName == "steel")\n\t\t\tcombat->setParam(COMBATPARAM_COMBATTYPE, COMBAT_STEELDAMAGE);'
if name_needle not in ms:
    raise SystemExit('Could not locate legacy monster test/steel spell mapping')
ms = ms.replace(name_needle, name_replacement, 1)
remaining = ms.count('COMBAT_TESTDAMAGE')
if remaining != 1:
    raise SystemExit('Expected exactly 1 remaining COMBAT_TESTDAMAGE mapping, found %d' % remaining)
ms = ms.replace('COMBAT_TESTDAMAGE', 'COMBAT_STEELDAMAGE', 1)
write(monsters, ms)
PY

say "Generating build system..."
cd "$WORK"
autoreconf -fiv

say "Configuring TFS 0.3.x for SQLite/local mode..."
CXXFLAGS="${CXXFLAGS:--O2 -std=gnu++03}" ./configure --enable-sqlite

say "Building..."
BUILD_LOG="$BUILD_ROOT/build.log"
# Single-job mode keeps the first compiler failure deterministic while we
# modernize this old codebase. JOBS can still be overridden explicitly.
if ! make -j"${JOBS:-1}" >"$BUILD_LOG" 2>&1; then
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
