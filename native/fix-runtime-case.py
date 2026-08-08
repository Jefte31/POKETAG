#!/usr/bin/env python3
"""Create Linux case-compatibility aliases in an isolated PokeTibia datapack.

Historical datapacks were authored for Windows and frequently reference
`foo/bar.lua` while the actual entry is `Foo/Bar.lua`.  The original files are
left untouched; this script only adds symlinks with the exact spelling used by
XML registries in the staged runtime tree.
"""

from pathlib import Path
import os
import re
import sys

if len(sys.argv) != 2:
    raise SystemExit("usage: fix-runtime-case.py <runtime-data-directory>")

data = Path(sys.argv[1])
if not data.is_dir():
    raise SystemExit(f"runtime data directory not found: {data}")

REFERENCE_RE = re.compile(
    r'''(?:file|value|script)\s*=\s*["']([^"']+\.(?:lua|xml))["']''',
    re.IGNORECASE,
)


def casefold_match(directory: Path, wanted: str):
    try:
        matches = [p for p in directory.iterdir() if p.name.casefold() == wanted.casefold()]
    except (FileNotFoundError, NotADirectoryError, PermissionError):
        return None
    if len(matches) == 1:
        return matches[0]
    return None


def can_resolve_case_insensitive(base: Path, rel: Path) -> bool:
    current = base
    for part in rel.parts:
        exact = current / part
        if exact.exists() or exact.is_symlink():
            current = exact
            continue
        match = casefold_match(current, part)
        if match is None:
            return False
        current = match
    return True


def create_alias_path(base: Path, rel: Path) -> bool:
    """Create per-segment symlinks so `base/rel` exists with exact spelling."""
    current = base
    changed = False

    for part in rel.parts:
        exact = current / part
        if exact.exists() or exact.is_symlink():
            current = exact
            continue

        match = casefold_match(current, part)
        if match is None:
            return False

        # Link by sibling basename so aliases remain relocatable with runtime.
        os.symlink(match.name, exact)
        changed = True
        current = exact

    return changed or current.exists() or current.is_symlink()


def candidate_bases(registry: Path):
    # Typical TFS layouts:
    #   monster/monsters.xml -> monster/pokes/foo.xml
    #   actions/actions.xml  -> actions/scripts/foo.lua
    # plus a few registries that already include scripts/ in the value.
    bases = [registry.parent, registry.parent / "scripts", data]

    # If the registry is nested, its subsystem root is often the first
    # directory under data (actions, spells, raids, ...).
    try:
        rel = registry.relative_to(data)
        if rel.parts:
            subsystem = data / rel.parts[0]
            bases.extend([subsystem, subsystem / "scripts"])
    except ValueError:
        pass

    seen = set()
    for base in bases:
        key = str(base)
        if key not in seen and base.exists():
            seen.add(key)
            yield base


created = []
unresolved = []
checked = 0

for registry in sorted(data.rglob("*.xml")):
    try:
        text = registry.read_text(encoding="latin-1", errors="ignore")
    except OSError:
        continue

    for raw in REFERENCE_RE.findall(text):
        # Registry values use forward slashes even on Windows. Ignore absolute
        # paths and URL-like values; they are not datapack-local references.
        raw = raw.replace("\\", "/").strip()
        rel = Path(raw)
        if not raw or rel.is_absolute() or "://" in raw or ".." in rel.parts:
            continue

        checked += 1
        resolved = False
        for base in candidate_bases(registry):
            exact = base / rel
            if exact.exists() or exact.is_symlink():
                resolved = True
                break
            if can_resolve_case_insensitive(base, rel):
                if create_alias_path(base, rel):
                    created.append(str(exact.relative_to(data)))
                    resolved = True
                    break

        if not resolved:
            unresolved.append((str(registry.relative_to(data)), raw))

print(f"[POKETAG-RUNTIME] Case scan checked {checked} XML file references.")
print(f"[POKETAG-RUNTIME] Created {len(created)} case-compatibility aliases.")
for item in created[:80]:
    print(f"  + {item}")
if len(created) > 80:
    print(f"  ... and {len(created) - 80} more")

# Missing files are a datapack-quality warning, not a staging failure. Print a
# bounded report so they can be fixed deliberately without blocking unrelated
# systems from starting.
unique_unresolved = []
seen_unresolved = set()
for item in unresolved:
    if item not in seen_unresolved:
        seen_unresolved.add(item)
        unique_unresolved.append(item)

if unique_unresolved:
    print(f"[POKETAG-RUNTIME] WARNING: {len(unique_unresolved)} referenced files could not be resolved:")
    for registry, raw in unique_unresolved[:60]:
        print(f"  ! {registry}: {raw}")
    if len(unique_unresolved) > 60:
        print(f"  ... and {len(unique_unresolved) - 60} more")
