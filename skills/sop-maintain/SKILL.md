---
name: sop-maintain
description: >-
  Act on feedback from inside the sop-kit package repo — read the open issues,
  change the skill or template they point at, bump the version correctly, commit,
  push, and tell users how to update. Use when working in the sop-kit repo to fix
  a reported problem, add guidance, or ship a new skill. Encodes the release gate
  and the critical gotcha that .claude-plugin/plugin.json's version must change or
  every user's /plugin update is a silent no-op. Pairs with sop-feedback, which
  files the issues from the consuming side.
metadata:
  version: 0.2.0
  last_updated: 2026-07-21
---

# sop-maintain — act on feedback, then release

## What this phase solves / When to use

**Solves P4 (change governance) + P6 (reproducibility) for the toolkit itself.**
Feedback only pays off if it reliably lands in the package *and* reaches users.
The failure mode here is silent: you edit a skill, push, and nobody's install
changes — because the version didn't move.

Use it inside the `sop-kit` repo when acting on an issue or making any change to
a skill, template, or the installer.

## Prerequisites

- You are in the `sop-kit` repo with push access.
- `gh` installed/authenticated for the smooth path (optional — fallbacks below).

## Steps

1. **Read the open issues.**
   ```bash
   gh issue list --repo gimwachan-git/sop-kit --state open
   gh issue view <N> --repo gimwachan-git/sop-kit
   ```
   Without `gh` (public repo, no auth needed):
   ```bash
   curl -s "https://api.github.com/repos/gimwachan-git/sop-kit/issues?state=open" \
     | python3 -c "import json,sys; [print(i['number'], i['title']) for i in json.load(sys.stdin) if 'pull_request' not in i]"
   ```

2. **Pick one issue and scope it.** Identify exactly which file it touches —
   `skills/<name>/SKILL.md`, a `templates/*.md`, `bin/*.sh`, or the README. If the
   issue really contains several problems, split it rather than fixing a blur.

3. **Make the change.** Hold the conventions the package is built on:
   - **English only** — the whole repo, no exceptions.
   - Keep the skill skeleton intact: *What this phase solves / Prerequisites /
     Steps / Where the artifact goes / Quality checklist / Tailoring by project
     weight / Done When / Next*.
   - Keep guidance concrete and earned — prefer a rule tied to a real failure over
     generic advice. Don't hard-code counts or machine-specific paths.
   - A change in what a skill *fundamentally does* is a decision → also record it
     (see step 6).

4. **Bump the version.** One command keeps all three places in sync:
   ```bash
   bin/bump.sh patch    # wording / clarification
   bin/bump.sh minor    # new guidance, section, or a whole new skill
   bin/bump.sh major    # breaking restructure (renamed skills, changed contracts)
   ```
   ⚠️ **The critical one is `.claude-plugin/plugin.json`.** Claude Code compares
   that version on `/plugin update`; if it doesn't change, users keep the cached
   copy and your fix never ships. `VERSION` (manual installer) and each skill's
   `metadata.version` must agree with it — `bin/bump.sh` does all three.

5. **Run the release gate** before pushing:
   ```bash
   python3 -m json.tool .claude-plugin/plugin.json      >/dev/null && echo ok
   python3 -m json.tool .claude-plugin/marketplace.json >/dev/null && echo ok
   grep -c '^name:' skills/*/SKILL.md                   # every skill has frontmatter
   diff <(sed -n 's/.*"version": "\(.*\)".*/\1/p' .claude-plugin/plugin.json) VERSION
   ```
   Plus: repo is still English-only, and every skill still parses (no stray `---`).

6. **Commit and push.** Reference the issue so GitHub closes it automatically on
   push to the default branch — this works even without `gh`:
   ```bash
   git commit -am "sop X.Y.Z: <what changed> (Fixes #N)"
   git push
   ```
   With `gh` you can instead close manually and leave a note:
   `gh issue close N --repo gimwachan-git/sop-kit --comment "Shipped in vX.Y.Z"`.

7. **Tell users how to get it:**
   ```
   /plugin marketplace update gimwa
   /plugin update sop@gimwa
   ```
   Manual installs: `git pull && bin/sop.sh upgrade`.

## Where the artifact goes

- The changed `skills/**` / `templates/**` / `bin/**` files.
- A version bump across `plugin.json`, `VERSION`, and every skill's frontmatter.
- A commit closing the issue; optionally an ADR for a structural decision.

## Quality checklist / Gate

- [ ] The change actually addresses what the issue reported (re-read it).
- [ ] `bin/bump.sh` run — `plugin.json` version **changed**.
- [ ] JSON manifests valid; `VERSION` and `plugin.json` agree.
- [ ] Repo still English-only; skill skeleton intact.
- [ ] Commit references the issue (`Fixes #N`) and is pushed.
- [ ] Update instructions communicated.

## Tailoring by project weight

The package is a **light**-weight project: no CI, no requirements docs. The gate
above *is* the process. Escalate only if it grows real collaborators — then add CI
running the release gate, and start `docs/adr/` for structural decisions
(renaming skills, dropping the manual installer, going multi-agent).

## Done When

- [ ] Issue addressed, version bumped, gate green, pushed, issue closed.
- [ ] Users told how to update.

## Next

Back to **`sop-workflow`**, or pick up the next issue.
