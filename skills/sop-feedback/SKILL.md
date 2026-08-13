---
name: sop-feedback
description: >-
  File a requirement or a problem report against the sop workflow skills
  themselves. Use when a sop-* skill gave wrong, unclear, or incomplete guidance,
  when a step or template is missing, when a check should be added, or when you
  want a new capability — i.e. any "this skill should be different" moment while
  using the workflow in a real project. It turns the complaint into a well-formed
  GitHub issue on the skill package repo, using the gh CLI when available and a
  prefilled issue URL (no auth needed) when it isn't. Use sop-maintain to act on
  the issue from inside the package repo.
metadata:
  version: 0.5.0
  last_updated: 2026-08-13
---

# sop-feedback — turn a pain point into an issue

## What this phase solves / When to use

**Solves P6 (reproducibility) by closing the loop on the SOP itself.** A workflow
that can't absorb correction rots — exactly the drift these skills are meant to
prevent. When a skill misleads you, the fix belongs in the package, not in your
memory of "that skill is a bit wrong".

Use it the moment you think *"this skill should have told me X"*. Don't batch it;
the context is freshest now.

**Target repo**: `gimwachan-git/sop-kit` (override if you forked it).

## Prerequisites

None. You do not need `gh`, a token, or push access to file an issue.

## Steps

1. **Classify the feedback** — one issue per problem:
   - **Guidance bug** — the skill said something wrong or misleading.
   - **Gap** — a step, check, or failure mode the skill never mentions.
   - **Template fix** — a `templates/*.md` field is wrong, missing, or unused.
   - **Feature** — a new skill, phase, or capability.

2. **Capture concrete context while it's fresh.** Vague reports produce vague
   fixes. Record:
   - Which skill (`sop-verify`, `sop-design`, …) and the package **version**
     (from `.claude-plugin/plugin.json`, or `.sop-meta` for a manual install).
   - What you were doing (project type, phase).
   - **What the skill told you** — quote the line if you can.
   - **What actually happened / what you expected instead.**
   - **Proposed change** — the concrete wording or step you'd add. A proposal
     makes the issue actionable; a complaint doesn't.

3. **Draft the issue.**
   - Title: `[<skill>] <short problem>` — e.g. `[sop-verify] gate discovery misses cargo clippy`.
   - Body: use the sections in step 2, in that order.
   - Label suggestion: `guidance` · `gap` · `template` · `feature`.

4. **File it.**
   - **If `gh` is installed and authenticated:**
     ```bash
     gh issue create --repo gimwachan-git/sop-kit \
       --title "[sop-verify] ..." --body "..." --label gap
     ```
   - **If not (no auth required):** build a prefilled URL and give it to the user
     to open in a browser — GitHub fills the form from the query string:
     ```
     https://github.com/gimwachan-git/sop-kit/issues/new?title=<url-encoded>&body=<url-encoded>
     ```
     URL-encode both values. Keep the body short enough for a URL; if it's long,
     print the body for the user to paste instead.

5. **Report back** the issue number/URL so it can be referenced later
   (`sop-maintain` closes it with `Fixes #N`).

## Where the artifact goes

A GitHub issue on `gimwachan-git/sop-kit`. Nothing is written into your project —
this skill never edits the repo you're working in.

## Quality checklist / Gate

- [ ] One issue = one problem (split bundled complaints).
- [ ] Names the skill **and** the package version.
- [ ] Quotes or paraphrases what the skill actually said.
- [ ] States the expected behavior, not just the annoyance.
- [ ] Proposes a concrete change.

## Tailoring by project weight

Weight-independent — this is about the toolkit, not your project. But do favour
filing over silently working around a bad step: an undocumented workaround is the
same knowledge-loss failure (P1) the skills exist to prevent.

## Done When

- [ ] Issue filed (or the prefilled URL / body handed to the user).
- [ ] Issue number or URL reported.

## Next

Hand off to **`sop-maintain`** when you're ready to fix it inside the package repo.
