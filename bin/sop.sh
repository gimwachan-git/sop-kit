#!/usr/bin/env bash
#
# sop.sh — install / upgrade / uninstall / list the sop-* workflow skills.
#
# The package is copy-installed (not symlinked) into an agent's skills
# directory so it works across machines and supports version upgrades.
#
# Usage:
#   bin/sop.sh install   [--target DIR | --project] [--force]
#   bin/sop.sh upgrade   [--target DIR | --project] [--force]
#   bin/sop.sh uninstall [--target DIR | --project]
#   bin/sop.sh list      [--target DIR | --project]
#
# Targets:
#   (default)        ~/.claude/skills            (global Claude Code skills)
#   --project        ./.claude/skills            (per-project skills)
#   --target DIR     any skills directory        (other agents / custom)
#   env SOP_TARGET   overrides the default target
#
set -euo pipefail

PKG_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$PKG_ROOT/skills"
VERSION="$(tr -d '[:space:]' < "$PKG_ROOT/VERSION")"

# ---- args ------------------------------------------------------------------
CMD="${1:-}"; shift || true
TARGET="${SOP_TARGET:-$HOME/.claude/skills}"
FORCE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --project) TARGET="$(pwd)/.claude/skills"; shift ;;
    --force) FORCE=1; shift ;;
    *) echo "sop: unknown option '$1'" >&2; exit 2 ;;
  esac
done

# ---- helpers ---------------------------------------------------------------
skill_dirs() {                       # list packaged skill names (dirs with a SKILL.md)
  for d in "$SKILLS_SRC"/*/; do
    [ -f "$d/SKILL.md" ] && basename "$d"
  done
}

installed_version() {                # $1=skill name -> prints installed version or ""
  local meta="$TARGET/$1/.sop-meta"
  [ -f "$meta" ] && sed -n 's/^version=//p' "$meta" || true
}

stamp_meta() {                       # $1=skill name -> write .sop-meta
  local now; now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  cat > "$TARGET/$1/.sop-meta" <<EOF
version=$VERSION
installed_at=$now
source=$PKG_ROOT
EOF
}

copy_skill() {                       # $1=skill name -> fresh copy into target
  rm -rf "${TARGET:?}/$1"
  mkdir -p "$TARGET/$1"
  cp -R "$SKILLS_SRC/$1/." "$TARGET/$1/"
  stamp_meta "$1"
}

# ---- commands --------------------------------------------------------------
do_install() {
  mkdir -p "$TARGET"
  local n=0
  for s in $(skill_dirs); do
    local cur; cur="$(installed_version "$s")"
    if [ -n "$cur" ] && [ "$cur" = "$VERSION" ] && [ "$FORCE" -eq 0 ]; then
      echo "  = $s ($cur) already current"
    else
      copy_skill "$s"
      echo "  + $s -> $VERSION${cur:+ (was $cur)}"
      n=$((n+1))
    fi
  done
  echo "sop $VERSION: installed/updated $n skill(s) into $TARGET"
}

do_upgrade() {
  local any=0
  for s in $(skill_dirs); do
    local cur; cur="$(installed_version "$s")"
    if [ -z "$cur" ]; then
      echo "  ! $s not installed (run 'install' first) — skipping" ; continue
    fi
    if [ "$cur" != "$VERSION" ] || [ "$FORCE" -eq 1 ]; then
      copy_skill "$s"; echo "  ^ $s $cur -> $VERSION"; any=1
    else
      echo "  = $s ($cur) already current"
    fi
  done
  [ "$any" -eq 0 ] && echo "sop $VERSION: nothing to upgrade in $TARGET" || echo "sop: upgrade complete in $TARGET"
}

do_uninstall() {
  local n=0
  for s in $(skill_dirs); do
    if [ -d "$TARGET/$s" ]; then rm -rf "${TARGET:?}/$s"; echo "  - $s"; n=$((n+1)); fi
  done
  echo "sop: removed $n skill(s) from $TARGET"
}

do_list() {
  echo "package version: $VERSION   target: $TARGET"
  printf '  %-16s %-10s %s\n' "SKILL" "INSTALLED" "STATUS"
  for s in $(skill_dirs); do
    local cur; cur="$(installed_version "$s")"
    local status="not installed"
    if [ -n "$cur" ]; then
      [ "$cur" = "$VERSION" ] && status="current" || status="upgradable -> $VERSION"
    fi
    printf '  %-16s %-10s %s\n' "$s" "${cur:--}" "$status"
  done
}

case "$CMD" in
  install)   do_install ;;
  upgrade)   do_upgrade ;;
  uninstall) do_uninstall ;;
  list)      do_list ;;
  ""|-h|--help|help)
    sed -n '2,26p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//' ;;
  *) echo "sop: unknown command '$CMD' (try: install|upgrade|uninstall|list)" >&2; exit 2 ;;
esac
