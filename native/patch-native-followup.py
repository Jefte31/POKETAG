#!/usr/bin/env python3
from pathlib import Path
import sys

if len(sys.argv) != 2:
    raise SystemExit("usage: patch-native-followup.py <server-source-directory>")

work = Path(sys.argv[1])
if not work.is_dir():
    raise SystemExit(f"server source directory not found: {work}")


def replace_once(filename, old, new, description):
    p = work / filename
    text = p.read_text(encoding="latin-1")
    if old not in text:
        raise SystemExit(f"{description}: expected source pattern not found in {filename}")
    p.write_text(text.replace(old, new, 1), encoding="latin-1")


# The old fork tries to initialize every element of two std::string arrays from
# a scalar expression. That is not valid C++. Initialize the arrays normally and
# explicitly preserve the intended default command/parameter values.
replace_once(
    "talkaction.cpp",
    '\tstd::string cmdstring[TALKFILTER_LAST] = words, paramstring[TALKFILTER_LAST] = "";\n',
    '\tstd::string cmdstring[TALKFILTER_LAST], paramstring[TALKFILTER_LAST];\n'
    '\tfor(int32_t i = 0; i < TALKFILTER_LAST; ++i)\n'
    '\t{\n'
    '\t\tcmdstring[i] = words;\n'
    '\t\tparamstring[i] = "";\n'
    '\t}\n',
    "portable TalkActions filter array initialization",
)

# vocation.cpp already expects these Pokemon damage families, but this fork's
# CombatType_t stopped at VENOM. Give the missing types their own unused bitmask
# values instead of aliasing them to another type (which would make grouped
# absorb/reflect bonuses stack multiple times on the same damage family).
replace_once(
    "enums.h",
    '\tCOMBAT_VENOMDAMAGE\t= 1 << 19,\n\tCOMBAT_LAST\t\t= COMBAT_NONE\n',
    '\tCOMBAT_VENOMDAMAGE\t= 1 << 19,\n'
    '\tCOMBAT_GRASSDAMAGE\t= 1 << 20,\n'
    '\tCOMBAT_POISONDAMAGE\t= 1 << 21,\n'
    '\tCOMBAT_WATERDAMAGE\t= 1 << 22,\n'
    '\tCOMBAT_GHOSTDAMAGE\t= 1 << 23,\n'
    '\tCOMBAT_LAST\t\t= COMBAT_NONE\n',
    "missing Pokemon combat bitmasks",
)

# CombatType_t values are bitmasks, so using them as direct array indexes is
# unsafe (and COMBAT_LAST is intentionally not a dense count in this fork).
# Store vocation absorb/reflect values sparsely by combat key instead.
replace_once(
    "vocation.h",
    '\t\tint16_t getAbsorb(CombatType_t combat) const {return absorb[combat];}\n'
    '\t\tvoid increaseAbsorb(CombatType_t combat, int16_t v) {absorb[combat] += v;}\n\n'
    '\t\tint16_t getReflect(CombatType_t combat) const;\n'
    '\t\tvoid increaseReflect(Reflect_t type, CombatType_t combat, int16_t v) {reflect[type][combat] += v;}\n',
    '\t\tint16_t getAbsorb(CombatType_t combat) const;\n'
    '\t\tvoid increaseAbsorb(CombatType_t combat, int16_t v) {absorb[combat] += v;}\n\n'
    '\t\tint16_t getReflect(CombatType_t combat) const;\n'
    '\t\tvoid increaseReflect(Reflect_t type, CombatType_t combat, int16_t v) {reflect[type][combat] += v;}\n',
    "safe vocation absorb/reflect accessors",
)
replace_once(
    "vocation.h",
    '\t\tint16_t absorb[COMBAT_LAST + 1], reflect[REFLECT_LAST + 1][COMBAT_LAST + 1];\n',
    '\t\ttypedef std::map<CombatType_t, int16_t> CombatValueMap;\n'
    '\t\tCombatValueMap absorb, reflect[REFLECT_LAST + 1];\n',
    "sparse vocation combat storage",
)

vocation = work / "vocation.cpp"
voc = vocation.read_text(encoding="latin-1")
anchor = 'Vocation Vocations::defVoc = Vocation();\n'
combat_catalog = '''Vocation Vocations::defVoc = Vocation();

static const CombatType_t POKETAG_COMBAT_TYPES[] =
{
\tCOMBAT_PHYSICALDAMAGE, COMBAT_ENERGYDAMAGE, COMBAT_EARTHDAMAGE,
\tCOMBAT_FIREDAMAGE, COMBAT_UNDEFINEDDAMAGE, COMBAT_LIFEDRAIN,
\tCOMBAT_MANADRAIN, COMBAT_HEALING, COMBAT_DROWNDAMAGE,
\tCOMBAT_ICEDAMAGE, COMBAT_HOLYDAMAGE, COMBAT_DEATHDAMAGE,
\tCOMBAT_STEELDAMAGE, COMBAT_ELECTRICDAMAGE, COMBAT_ROCKDAMAGE,
\tCOMBAT_FLYDAMAGE, COMBAT_BUGDAMAGE, COMBAT_FIGHTDAMAGE,
\tCOMBAT_DRAGONDAMAGE, COMBAT_VENOMDAMAGE, COMBAT_GRASSDAMAGE,
\tCOMBAT_POISONDAMAGE, COMBAT_WATERDAMAGE, COMBAT_GHOSTDAMAGE
};
static const size_t POKETAG_COMBAT_TYPE_COUNT =
\tsizeof(POKETAG_COMBAT_TYPES) / sizeof(POKETAG_COMBAT_TYPES[0]);
'''
if anchor not in voc:
    raise SystemExit("vocation combat catalog insertion point not found")
voc = voc.replace(anchor, combat_catalog, 1)

loop_replacements = {
    '''\t\t\t\tfor(int32_t i = COMBAT_FIRST; i <= COMBAT_LAST; i++)
\t\t\t\t\tvoc->increaseAbsorb((CombatType_t)i, intValue);''':
    '''\t\t\t\tfor(size_t i = 0; i < POKETAG_COMBAT_TYPE_COUNT; ++i)
\t\t\t\t\tvoc->increaseAbsorb(POKETAG_COMBAT_TYPES[i], intValue);''',
    '''\t\t\t\tfor(int32_t i = COMBAT_FIRST; i <= COMBAT_LAST; i++)
\t\t\t\t\tvoc->increaseReflect(REFLECT_PERCENT, (CombatType_t)i, intValue);''':
    '''\t\t\t\tfor(size_t i = 0; i < POKETAG_COMBAT_TYPE_COUNT; ++i)
\t\t\t\t\tvoc->increaseReflect(REFLECT_PERCENT, POKETAG_COMBAT_TYPES[i], intValue);''',
    '''\t\t\t\tfor(int32_t i = COMBAT_FIRST; i <= COMBAT_LAST; i++)
\t\t\t\t\tvoc->increaseReflect(REFLECT_CHANCE, (CombatType_t)i, intValue);''':
    '''\t\t\t\tfor(size_t i = 0; i < POKETAG_COMBAT_TYPE_COUNT; ++i)
\t\t\t\t\tvoc->increaseReflect(REFLECT_CHANCE, POKETAG_COMBAT_TYPES[i], intValue);''',
}
for old, new in loop_replacements.items():
    if old not in voc:
        raise SystemExit("vocation COMBAT_LAST loop pattern not found")
    voc = voc.replace(old, new, 1)

old_reset = '''\tmemset(absorb, 0, sizeof(absorb));
\tmemset(reflect[REFLECT_PERCENT], 0, sizeof(reflect[REFLECT_PERCENT]));
\tmemset(reflect[REFLECT_CHANCE], 0, sizeof(reflect[REFLECT_CHANCE]));'''
new_reset = '''\tabsorb.clear();
\tfor(int32_t i = REFLECT_FIRST; i <= REFLECT_LAST; ++i)
\t\treflect[i].clear();'''
if old_reset not in voc:
    raise SystemExit("vocation combat storage reset pattern not found")
voc = voc.replace(old_reset, new_reset, 1)

old_reflect = '''int16_t Vocation::getReflect(CombatType_t combat) const
{
\tif(reflect[REFLECT_CHANCE][combat] < random_range(0, 100))
\t\treturn reflect[REFLECT_PERCENT][combat];

\treturn 0;
}'''
new_reflect = '''int16_t Vocation::getAbsorb(CombatType_t combat) const
{
\tCombatValueMap::const_iterator it = absorb.find(combat);
\treturn it != absorb.end() ? it->second : 0;
}

int16_t Vocation::getReflect(CombatType_t combat) const
{
\tCombatValueMap::const_iterator chanceIt = reflect[REFLECT_CHANCE].find(combat);
\tconst int16_t chance = chanceIt != reflect[REFLECT_CHANCE].end() ? chanceIt->second : 0;
\tif(chance < random_range(0, 100))
\t{
\t\tCombatValueMap::const_iterator percentIt = reflect[REFLECT_PERCENT].find(combat);
\t\treturn percentIt != reflect[REFLECT_PERCENT].end() ? percentIt->second : 0;
\t}

\treturn 0;
}'''
if old_reflect not in voc:
    raise SystemExit("vocation reflect getter pattern not found")
voc = voc.replace(old_reflect, new_reflect, 1)
vocation.write_text(voc, encoding="latin-1")

# Make the generic combat-name helpers understand the restored Pokemon types.
tools = work / "tools.cpp"
t = tools.read_text(encoding="latin-1")
old_names = '\t{"bug",\t\tCOMBAT_BUGDAMAGE}\n};'
new_names = ('\t{"bug",\t\tCOMBAT_BUGDAMAGE},\n'
             '\t{"grass",\t\tCOMBAT_GRASSDAMAGE},\n'
             '\t{"poison",\t\tCOMBAT_POISONDAMAGE},\n'
             '\t{"water",\t\tCOMBAT_WATERDAMAGE},\n'
             '\t{"ghost",\t\tCOMBAT_GHOSTDAMAGE}\n};')
if old_names not in t:
    raise SystemExit("combatTypeNames insertion point not found")
t = t.replace(old_names, new_names, 1)
old_get_name = '''\t\tcase COMBAT_BUGDAMAGE:
\t\t\treturn "bug";
\t\tdefault:'''
new_get_name = '''\t\tcase COMBAT_BUGDAMAGE:
\t\t\treturn "bug";
\t\tcase COMBAT_GRASSDAMAGE:
\t\t\treturn "grass";
\t\tcase COMBAT_POISONDAMAGE:
\t\t\treturn "poison";
\t\tcase COMBAT_WATERDAMAGE:
\t\t\treturn "water";
\t\tcase COMBAT_GHOSTDAMAGE:
\t\t\treturn "ghost";
\t\tdefault:'''
if old_get_name not in t:
    raise SystemExit("getCombatName insertion point not found")
tools.write_text(t.replace(old_get_name, new_get_name, 1), encoding="latin-1")

# Monster XML attack definitions should be able to request the same types.
monsters = work / "monsters.cpp"
m = monsters.read_text(encoding="latin-1")
old_attack = '''\t\telse if(tmpName == "poison" || tmpName == "earth")
\t\t\tcombat->setParam(COMBATPARAM_COMBATTYPE, COMBAT_EARTHDAMAGE);
\t\telse if(tmpName == "ice")'''
new_attack = '''\t\telse if(tmpName == "poison")
\t\t\tcombat->setParam(COMBATPARAM_COMBATTYPE, COMBAT_POISONDAMAGE);
\t\telse if(tmpName == "earth")
\t\t\tcombat->setParam(COMBATPARAM_COMBATTYPE, COMBAT_EARTHDAMAGE);
\t\telse if(tmpName == "grass")
\t\t\tcombat->setParam(COMBATPARAM_COMBATTYPE, COMBAT_GRASSDAMAGE);
\t\telse if(tmpName == "water")
\t\t\tcombat->setParam(COMBATPARAM_COMBATTYPE, COMBAT_WATERDAMAGE);
\t\telse if(tmpName == "ghost")
\t\t\tcombat->setParam(COMBATPARAM_COMBATTYPE, COMBAT_GHOSTDAMAGE);
\t\telse if(tmpName == "ice")'''
if old_attack not in m:
    raise SystemExit("monster Pokemon combat-name mapping point not found")
monsters.write_text(m.replace(old_attack, new_attack, 1), encoding="latin-1")

print("[POKETAG-NATIVE] Follow-up compatibility patches applied successfully.")
