---
name: sop-charter
description: >-
  Phase 0 of the sop workflow — charter a project. Use this when starting a new
  repo, when a repo has code but no docs/overview.md or CLAUDE.md, or when goals,
  scope, and "how heavy should our process be" have never been written down. It
  produces docs/overview.md (one-sentence goal + project parameters + scope + out
  of scope + open questions) and seeds/updates CLAUDE.md so a memoryless agent can
  pick the project up. This is where project parameters are fixed, which every
  later phase reads to decide its own weight.
metadata:
  version: 0.5.0
  last_updated: 2026-08-13
---

# sop-charter — charter the project

## What this phase solves / When to use

**Solves P1 (externalize knowledge) + P2 (alignment), and fixes the project
parameters** that every later phase uses to tailor itself. Software is invisible
and memory is lossy (agents reset every session); the charter is the persistent,
transferable statement of *what we're building, why, and how heavy the process
should be*.

Use it when: a new repo; or an existing repo with no `docs/overview.md` / no
`CLAUDE.md`; or goals/scope have drifted and need a reset.

## Prerequisites

None. This is the entry phase. If a `README.md` exists, mine it for the goal and
layout first (but treat it as possibly stale — see the grigri lesson below).

## Steps

1. **Extract the one-sentence goal.** What does this do, for whom? If you can't
   say it in one sentence, that is the first finding — resolve it before moving on.

2. **Fix the six project parameters** (this is the load-bearing step; later phases
   read these):
   - **Participants** & whether they are **co-located / same org** (raises P2/P5).
   - **Feedback-loop length**: change one line → see the effect in how long?
     (sets P3 gate weight).
   - **Failure cost**: toy / internal tool / money-medical-aviation (raises P3/P5/P6).
   - **Regulatory / contractual strength** (raises P5/P6; makes artifacts "count").
   - **Expected lifetime & scale evolution** (raises P4/P6).
   - If any parameter is unclear and it changes the process weight, ask **one**
     crisp question; otherwise record a reasonable default in Open Questions.

3. **Write `docs/overview.md`** from `templates/overview.md`. Keep it short.
   Every "Out of scope" line ends with *"— each is a decision; write an ADR first."*

4. **Seed or update `CLAUDE.md`** from `templates/claude-md.md`: what it is, stack
   & commands, current phase, repo structure, business rules, working conventions,
   boundaries. This is the agent's entry point; keep it current or it rots.

5. **Decide the doc architecture and cut list.** Using project parameters, state
   which later phases this project will run heavy / light / cut (e.g. "single dev
   → no `docs/requirements/`; rules live in CLAUDE.md"). Record cuts in overview's
   Out-of-scope / Open-questions so the omission is visible, not silent.

## Where the artifact goes

- `docs/overview.md` — goal, parameters, scope, out-of-scope, open questions
  (and, for heavier projects, business rules + data model + settled decisions).
- `CLAUDE.md` at repo root — the memoryless-agent entry point.

## Quality checklist / Gate

- [ ] Goal expressible in one sentence.
- [ ] All six project parameters stated (or defaulted with a note).
- [ ] Scope and out-of-scope are explicit and bounded.
- [ ] Every out-of-scope item flagged as a decision, not a silent omission.
- [ ] `CLAUDE.md` lets a fresh agent build, test, and find the rules.
- [ ] The phase cut-list (what we will/won't do later) is written down.

## Tailoring by project weight

- **Heavy**: overview carries extra sections — **Business Rules** (invariants),
  **Data Model** (concrete paths/schemas), **Settled Key Decisions** (digest →
  ADRs). Parameters justify the ceremony.
- **Light**: overview justifies *why the process is light* ("single dev →
  no requirements docs, no full test programme, no review ceremony"); business
  rules live in `CLAUDE.md` instead of a separate section.
- **Bare**: even a 10-line overview beats none. The cautionary case is a repo with
  only a README that has drifted out of sync with the code — that is exactly what
  the absence of this phase produces. Write the goal + parameters + layout, stop.

When unsure how heavy to go, invoke `first-principles-software-development`.

## Done When

- [ ] `docs/overview.md` written and validated against the checklist.
- [ ] `CLAUDE.md` seeded/updated.
- [ ] Project parameters and the phase cut-list are on record.

## Next

Hand off to **`sop-specify`** if "what it should do" needs alignment, or straight
to **`sop-design`** if the first real decision is already on the table (light/bare
projects often skip specify). Update `CLAUDE.md`'s "current phase" as you go.
