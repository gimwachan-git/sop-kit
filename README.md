# sop — a phased development workflow, packaged as skills

`sop` is a set of **Standard Operating Procedure** skills that drive a program
from idea to shipped, one phase at a time. Each phase is one skill with its own
templates, quality gate, and hand-off to the next. The set is distilled from
three real projects and is meant to be **installed and upgraded across projects
and agents**.

It is the *execution layer*. The *governance layer* — deciding **how much** of
each phase a given project needs — lives in the
the companion `first-principles-software-development`
skill (axioms → root problem → six sub-problems **P1–P6** → tailoring). `sop`
tells you *how* to do a phase; first-principles tells you *why* and *how heavy*.

## The flow

```
sop-workflow ── router / "which phase am I in?" ──────────────────────────┐
                                                                          │
sop-charter  → sop-specify → sop-design → sop-implement → sop-verify → sop-ship
  overview      requirements    ADRs        code (FSD +     gates /       bumpp +
  + params      + traceability  + design    3 pillars)      DoD           deploy
  (P1/P2)       (P2)            (P1/P2/P4)   (build)         (P3/P5)       (P4/P5)
```

Every phase maps to a first-principles sub-problem and can be **tailored or cut**
based on project weight. It is normal to skip phases: a one-person read-only site
skips `sop-specify` entirely; a bare prototype may run only `sop-charter` +
`sop-verify`.

## Tailoring by project weight

The same SOP set collapses to different shapes depending on project parameters.
The three reference projects span the range:

| | heavy | light | bare |
|---|---|---|---|
| requirements (US+AC) + traceability | ✅ full | ⛔ cut (single dev) | ⛔ cut |
| ADR log | ✅ every decision | ✅ key decisions | ⛔ none yet |
| verify gate | manual gates + CI | `verify` + `verify:cf` scripts | `cargo test` only |
| tests | unit/property/scenario | one smoke suite | inline unit + fixtures |

Read a phase's **"Tailoring by project weight"** section to decide which shape you
are in. When in doubt about how heavy to go, invoke `first-principles-software-development`.

## Install

### As a Claude Code plugin (recommended)

This repo is a Claude Code plugin *and* a single-plugin marketplace. From any
machine with Claude Code — macOS, Linux, or Windows, no bash required:

```
/plugin marketplace add gimwachan-git/sop-kit  # add this repo (GitHub owner/repo, git URL, or local path)
/plugin install sop@gimwa             # install the plugin
```

The seven skills are then available (auto-triggered by their descriptions, and
explicitly as `/sop:sop-charter`, `/sop:sop-verify`, …). Team-wide, commit an
`.claude/settings.json` with `extraKnownMarketplaces` + `enabledPlugins` so
collaborators are prompted to install on trust.

### Manual install (alternative, any skills dir)

For a non-plugin install (e.g. into a custom skills directory) the bundled bash
installer copies the skills directly:

```bash
bin/sop.sh install            # copy skills into ~/.claude/skills (global)
bin/sop.sh install --project  # copy into ./.claude/skills (this repo only)
bin/sop.sh install --target /path/to/skills
bin/sop.sh list | upgrade | uninstall
```

Copy-based (not a symlink); each installed skill carries a `.sop-meta` version
stamp. Note: the plugin route above supersedes this for Claude Code — don't run
both, or you'll have duplicate copies of each skill.

## Releasing / upgrading

On every change, bump the version in **`.claude-plugin/plugin.json`** (and keep
`VERSION` + each skill's `metadata.version` in sync), commit, and push.

- Plugin users update with `/plugin marketplace update gimwa` then `/plugin update sop@gimwa`.
- Manual users update with `git pull && bin/sop.sh upgrade`.

⚠️ If you change a skill but **don't bump `plugin.json`'s `version`**, plugin
users keep the cached copy and see no update. Always bump it (or omit it to make
every commit a new version).

## What's in the box

```
.claude-plugin/
  plugin.json       # plugin manifest (name, version) — drives /plugin install & updates
  marketplace.json  # makes this repo its own marketplace (source: "./")
bin/sop.sh          # optional manual installer for non-plugin use
bin/bump.sh         # maintainer: bump the version everywhere it must stay in sync
skills/
  sop-workflow/   router + tailoring entry point
  sop-charter/    docs/overview.md (goals + project parameters) + seed CLAUDE.md
  sop-specify/    docs/requirements/<feature>.md (US + acceptance) + traceability.md
  sop-design/     docs/adr/NNNN-*.md + FSD placement + optional design-system.md
  sop-implement/  task breakdown + FSD boundaries + the three pillars
  sop-verify/     run the gate chain = Definition of Done
  sop-ship/       version bump + build + deploy, in gated order
  sop-feedback/   file an issue when a skill misleads you (from any project)
  sop-maintain/   read issues, fix the skill, bump, release (inside this repo)
```

## Feedback loop

The workflow is meant to absorb correction. When a skill gives you bad or missing
guidance, don't work around it silently:

1. **`sop-feedback`** turns the pain point into a well-formed issue (uses `gh` when
   available, otherwise a prefilled issue URL — no auth needed).
2. **`sop-maintain`**, run inside this repo, reads the open issues, changes the
   skill, runs `bin/bump.sh`, and pushes with `Fixes #N`.
3. Users pick it up with `/plugin marketplace update gimwa && /plugin update sop@gimwa`.

Issues can also be filed by hand — `.github/ISSUE_TEMPLATE/` carries the same structure.

Skills are self-contained: SKILL.md plus any `templates/`. They reference the
projects only as calibration examples, never as dependencies.
