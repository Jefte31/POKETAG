#!/usr/bin/env python3
from pathlib import Path
import sys

if len(sys.argv) != 2:
    raise SystemExit("usage: patch-native-runtime.py <server-source-directory>")

work = Path(sys.argv[1])
if not work.is_dir():
    raise SystemExit(f"server source directory not found: {work}")

p = work / "luascript.cpp"
text = p.read_text(encoding="latin-1")

old = '''bool LuaScriptInterface::loadDirectory(const std::string& dir, Npc* npc/* = NULL*/)
{
\tStringVec files;
\tfor(boost::filesystem::directory_iterator it(dir), end; it != end; ++it)
'''
new = '''bool LuaScriptInterface::loadDirectory(const std::string& dir, Npc* npc/* = NULL*/)
{
\t// Several historical PokeTibia datapacks omit subsystem lib/ folders.
\t// Boost.Filesystem throws when directory_iterator is constructed for a
\t// missing path, which aborts the whole server before the map can load.
\t// BaseEvents already treats loadDirectory(false) as a warning, so return
\t// false cleanly and preserve the engine's intended optional-lib behavior.
\tboost::filesystem::path directory(dir);
\tif(!boost::filesystem::exists(directory) || !boost::filesystem::is_directory(directory))
\t\treturn false;

\tStringVec files;
\tfor(boost::filesystem::directory_iterator it(directory), end; it != end; ++it)
'''

if old not in text:
    raise SystemExit("LuaScriptInterface::loadDirectory pattern not found after base compatibility patches")

p.write_text(text.replace(old, new, 1), encoding="latin-1")
print("[POKETAG-NATIVE] Runtime-safety patches applied successfully.")
