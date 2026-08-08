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

print("[POKETAG-NATIVE] Follow-up compatibility patches applied successfully.")
