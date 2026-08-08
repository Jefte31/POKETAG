#!/usr/bin/env python3
from pathlib import Path
import sys

if len(sys.argv) != 2:
    raise SystemExit("usage: patch-native.py <server-source-directory>")

work = Path(sys.argv[1])
if not work.is_dir():
    raise SystemExit(f"server source directory not found: {work}")


def path(name):
    return work / name


def read(name):
    return path(name).read_text(encoding="latin-1")


def write(name, text):
    path(name).write_text(text, encoding="latin-1")


def replace_once(name, old, new, description):
    text = read(name)
    if old not in text:
        raise SystemExit(f"{description}: expected source pattern not found in {name}")
    write(name, text.replace(old, new, 1))


# The original 2010-era engine blocks startup on dead remote services.
text = read("otserv.cpp")
start = '\tstd::cout << ">> Checking software version... ";'
end = '\tstd::cout << ">> Loading RSA key" << std::endl;'
si = text.find(start)
ei = text.find(end, si)
if si < 0 or ei < 0:
    raise SystemExit("legacy version/blacklist block not found in otserv.cpp")
text = text[:si] + (
    '\tstd::cout << ">> PokeTag local mode: legacy update/blacklist checks disabled." << std::endl;\n\n'
) + text[ei:]
write("otserv.cpp", text)

# Modern Boost no longer ships the old boost/tr1 wrapper.
replace_once(
    "configure.ac",
    'AC_CHECK_HEADERS([boost/tr1/unordered_set.hpp], , [AC_MSG_ERROR("boost::unordered_set header not found.")])',
    'AC_CHECK_HEADERS([boost/unordered_set.hpp], , [AC_MSG_ERROR("boost::unordered_set header not found.")])',
    "modern Boost unordered_set configure check",
)
replace_once(
    "house.h",
    '#include <boost/tr1/unordered_set.hpp>',
    '#include <boost/unordered_set.hpp>',
    "modern Boost unordered_set include",
)
replace_once(
    "house.h",
    'typedef std::tr1::unordered_set<uint32_t> PlayerList;',
    'typedef boost::unordered_set<uint32_t> PlayerList;',
    "modern Boost unordered_set type",
)

# GCC correctly rejects bool as a pointer return value.
replace_once(
    "chat.cpp",
    'if(!player || player->isRemoved())\n\t\treturn false;',
    'if(!player || player->isRemoved())\n\t\treturn NULL;',
    "Chat::getChannel null pointer return",
)

# PokeTibia added a steel combat type but omitted a condition enum bit. The
# existing CONDITION_TEST bit is unused and is retained as a compatibility alias.
replace_once(
    "condition.h",
    '\tCONDITION_TEST = 1 << 24,\n\tCONDITION_ELECTRIC = 1 << 25,',
    '\tCONDITION_TEST = 1 << 24,\n\tCONDITION_STEEL = CONDITION_TEST,\n\tCONDITION_ELECTRIC = 1 << 25,',
    "steel condition compatibility alias",
)

# This fork has a missing brace around attackerPlayer logic, leaving `color`
# out of scope on conforming compilers. Restore the intended block structure.
combat = read("combat.cpp")
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
if old_block not in combat:
    raise SystemExit("malformed attackerPlayer block not found in combat.cpp")
write("combat.cpp", combat.replace(old_block, new_block, 1))

# Straight source defects from the old fork.
replace_once(
    "condition.cpp",
    'propWrifream.ADD_VALUE(minb);',
    'propWriteStream.ADD_VALUE(minb);',
    "ConditionSpeed serialization typo",
)
replace_once(
    "configmanager.cpp",
    'getGlobalNumber(L, "noDamageToSameColors", 0)',
    'getGlobalNumber("noDamageToSameColors", 0)',
    "legacy ConfigManager helper signature",
)

# Newer Boost.Date_Time does not classify the unnamed timeout enum as an
# integral template argument. Keep the legacy values but make the type explicit.
connection = read("connection.cpp")
for old, new in {
    'boost::posix_time::seconds(Connection::readTimeout)':
        'boost::posix_time::seconds(static_cast<int>(Connection::readTimeout))',
    'boost::posix_time::seconds(Connection::writeTimeout)':
        'boost::posix_time::seconds(static_cast<int>(Connection::writeTimeout))',
}.items():
    if old not in connection:
        raise SystemExit(f"legacy Connection timeout expression not found: {old}")
    connection = connection.replace(old, new)
write("connection.cpp", connection)

# Modern GCC rejects false as an Item* sentinel.
replace_once(
    "game.cpp",
    '''Item* Game::findItemOfType(Cylinder* cylinder, uint16_t itemId,
\tbool depthSearch /*= true*/, int32_t subType /*= -1*/)
{
\tif(!cylinder)
\t\treturn false;''',
    '''Item* Game::findItemOfType(Cylinder* cylinder, uint16_t itemId,
\tbool depthSearch /*= true*/, int32_t subType /*= -1*/)
{
\tif(!cylinder)
\t\treturn NULL;''',
    "Game::findItemOfType null pointer return",
)
game = read("game.cpp")
count = game.count('case COMBAT_TESTDAMAGE:')
if count != 2:
    raise SystemExit(f"expected exactly 2 stale COMBAT_TESTDAMAGE cases in game.cpp, found {count}")
write("game.cpp", game.replace('case COMBAT_TESTDAMAGE:', 'case COMBAT_STEELDAMAGE:'))

# Boost.Filesystem removed directory_entry::leaf().
replace_once(
    "luascript.cpp",
    'std::string s = it->leaf();',
    'std::string s = it->path().filename().string();',
    "modern Boost.Filesystem directory entry name",
)

# A stray incomplete symbol was left between two Monster method definitions.
replace_once(
    "monster.cpp",
    '\nCreature::createCorpse\nvoid Monster::getPathSearchParams',
    '\nvoid Monster::getPathSearchParams',
    "orphan Creature::createCorpse token",
)

# Normalize the old TEST placeholder to the actual steel combat enum.
monsters = read("monsters.cpp")
old = 'else if(tmpName == "test")\n\t\t\tcombat->setParam(COMBATPARAM_COMBATTYPE, COMBAT_TESTDAMAGE);'
new = 'else if(tmpName == "test" || tmpName == "steel")\n\t\t\tcombat->setParam(COMBATPARAM_COMBATTYPE, COMBAT_STEELDAMAGE);'
if old not in monsters:
    raise SystemExit("legacy monster test/steel spell mapping not found")
monsters = monsters.replace(old, new, 1)
remaining = monsters.count('COMBAT_TESTDAMAGE')
if remaining != 1:
    raise SystemExit(f"expected exactly 1 remaining COMBAT_TESTDAMAGE in monsters.cpp, found {remaining}")
write("monsters.cpp", monsters.replace('COMBAT_TESTDAMAGE', 'COMBAT_STEELDAMAGE', 1))

# The logger builds the hex text in one stringstream and then incorrectly tries
# to stream the stringstream object itself into another stream. Emit its string.
replace_once(
    "protocolgame.cpp",
    's << player->getName() << " sent unknown byte: " << hex << std::endl;',
    's << player->getName() << " sent unknown byte: " << hex.str() << std::endl;',
    "ProtocolGame unknown-byte log stream",
)

print("[POKETAG-NATIVE] Compatibility patches applied successfully.")
