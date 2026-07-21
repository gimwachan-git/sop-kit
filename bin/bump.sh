#!/usr/bin/env bash
#
# bump.sh — raise the package version everywhere it must stay in sync.
#
# The version lives in three places; only the first one actually drives
# `/plugin update`, but all three must agree or the repo starts lying:
#   1. .claude-plugin/plugin.json   -> what Claude Code compares on update  (CRITICAL)
#   2. VERSION                      -> what bin/sop.sh compares on manual upgrade
#   3. skills/*/SKILL.md            -> metadata.version + last_updated
#
# Usage:
#   bin/bump.sh patch      # 0.1.0 -> 0.1.1   wording / clarification
#   bin/bump.sh minor      # 0.1.0 -> 0.2.0   new guidance, section, or skill
#   bin/bump.sh major      # 0.1.0 -> 1.0.0   breaking restructure
#   bin/bump.sh 1.2.3      # set explicitly
#
# Requires python3 (maintainer-side only; end users never run this).
set -euo pipefail

PKG_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LEVEL="${1:-}"
TODAY="$(date +%F)"

if [ -z "$LEVEL" ]; then
  sed -n '2,22p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit 2
fi

python3 - "$PKG_ROOT" "$LEVEL" "$TODAY" <<'PY'
import json, pathlib, re, sys

root, level, today = pathlib.Path(sys.argv[1]), sys.argv[2], sys.argv[3]
manifest = root / ".claude-plugin" / "plugin.json"

data = json.loads(manifest.read_text())
old = data.get("version", "0.0.0")

if re.fullmatch(r"\d+\.\d+\.\d+", level):
    new = level
else:
    major, minor, patch = (int(p) for p in old.split("."))
    if level == "major":   major, minor, patch = major + 1, 0, 0
    elif level == "minor": minor, patch = minor + 1, 0
    elif level == "patch": patch += 1
    else:
        sys.exit(f"bump: unknown level '{level}' (use patch|minor|major|X.Y.Z)")
    new = f"{major}.{minor}.{patch}"

if new == old:
    sys.exit(f"bump: version already {new} — nothing to do")

# 1. plugin.json — targeted line edit so formatting is preserved
text = manifest.read_text()
text, n = re.subn(r'("version"\s*:\s*")[^"]+(")', rf'\g<1>{new}\g<2>', text, count=1)
if n != 1:
    sys.exit("bump: could not find a version field in plugin.json")
manifest.write_text(text)

# 2. VERSION
(root / "VERSION").write_text(new + "\n")

# 3. every skill's frontmatter (version + last_updated), first block only
skills = 0
for skill in sorted((root / "skills").glob("*/SKILL.md")):
    src = skill.read_text()
    parts = src.split("---", 2)
    if len(parts) < 3:
        continue
    fm = parts[1]
    fm = re.sub(r"(?m)^(\s+version:\s*).*$", rf"\g<1>{new}", fm)
    fm = re.sub(r"(?m)^(\s+last_updated:\s*).*$", rf"\g<1>{today}", fm)
    skill.write_text(parts[0] + "---" + fm + "---" + parts[2])
    skills += 1

print(f"bumped {old} -> {new}")
print(f"  .claude-plugin/plugin.json  (drives /plugin update)")
print(f"  VERSION")
print(f"  {skills} skill(s) metadata.version + last_updated={today}")
print()
print("next: commit (use 'Fixes #N' to auto-close the issue), push, then users run:")
print("  /plugin marketplace update gimwa && /plugin update sop@gimwa")
PY
