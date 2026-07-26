---
name: sop-workflow
description: >-
  Router and map for the sop-* development workflow. Use this FIRST when you are
  about to drive a piece of development but are not sure which phase you are in,
  when someone asks "how should we build this / what's our process", when a task
  spans several phases (spec + design + build + ship), or when you need to decide
  how heavy the process should be for a given project. It routes to the right
  phase skill (sop-charter / sop-specify / sop-design / sop-implement / sop-verify
  / sop-ship), points at sop-feedback / sop-maintain when the workflow itself needs
  fixing, and hands the "how much" question to first-principles-software-development.
metadata:
  version: 0.4.0
  last_updated: 2026-07-26
---

# sop-workflow — the workflow router

## What this is

`sop` is a phased development workflow. Each phase is a separate skill with its
own template, gate, and hand-off. This skill is the **map**: it tells you which
phase you are in, routes you there, and reminds you that every phase is
**tailorable** — you do only as much as the project's stakes justify.

Two layers work together:

- **`sop-*` (this set) = HOW.** Concrete, opinionated procedures and templates.
- **`first-principles-software-development` = WHY / HOW MUCH.** Decides the weight
  of each phase from project parameters (P1–P6). Invoke it whenever you catch
  yourself doing a phase "because the process says so" instead of because it
  reduces a real risk.

## The phases

| Phase | Skill | Solves | Produces |
|-------|-------|--------|----------|
| 0 · Charter | `sop-charter` | P1 externalize · P2 align · sets project parameters | `docs/overview.md` + seeded `CLAUDE.md` |
| 1 · Specify | `sop-specify` | P2 alignment (+P1) | `docs/requirements/<feature>.md` + `docs/traceability.md` |
| 2 · Design | `sop-design` | P1 + P2 + P4 change governance | `docs/adr/NNNN-*.md` (+ `docs/research/` for undecided surveys, + optional `design-system.md`) |
| 3 · Implement | `sop-implement` | construction | code under FSD boundaries + `@domain`/`@serves` headers + the three pillars |
| 4 · Verify | `sop-verify` | P3 early detection · P5 trust | the gate chain runs green (incl. the docs↔code binding check) = Definition of Done |
| 5 · Ship | `sop-ship` | P4 + P5 | version bump + build + deploy, in gated order |

```
sop-charter → sop-specify → sop-design → sop-implement → sop-verify → sop-ship
      ↑___________________________ next cycle ___________________________|
```

## How to route

Pick the phase from what the user actually has in hand:

- **No `docs/overview.md`, no `CLAUDE.md`, fuzzy goals** → `sop-charter`.
- **Goals clear, but "what should it do" is vague / multiple readings** → `sop-specify`.
- **What is clear, but a real decision is open** (tech choice, architecture, big
  dependency bump, data shape) → `sop-design` (write an ADR).
- **You ran an investigation and don't know where the findings go** (a vendor/fee
  comparison, "three ways to do X", anything dated and perishable) → also
  `sop-design`: its "place the research" step routes it to an ADR's Context, a
  `Deferred` ADR, or `docs/research/<yyyy-mm>-<topic>.md` when no decision is on
  the table yet. Research that only exists in the chat session is P1 loss.
- **Decision made, ready to write code** → `sop-implement`.
- **Code written, need to know if it's actually done/safe** → `sop-verify`.
- **"Which requirement does this module serve?" has no answer** (docs and slices
  drifted apart, or a module turns up that nothing specified) → `sop-verify`
  step 4 names the orphans; `sop-design` decides the `@domain` slug for what's
  missing; `sop-implement` writes the headers. FSD deliberately has no cross-layer
  concept, so this binding is something the project must supply — it will not
  emerge from the folder structure.
- **Green and ready to release** → `sop-ship`.

Do not force a strict march. Jump straight to `sop-verify` for a hotfix; loop
`specify → design → implement → verify` for one feature; run only `charter`
for a spike. The router exists so you *choose* the phase, not skip thinking.

## Improving the workflow itself

Two more skills close the loop on the SOP, so a bad step gets fixed instead of
worked around:

- **`sop-feedback`** — from *any* project: a phase skill misled you, missed a
  step, or you want a new capability → file it as an issue on the package.
- **`sop-maintain`** — inside the `sop-kit` repo: read the open issues, fix the
  skill, bump the version, release it to users.

If you find yourself silently compensating for a skill's bad advice, that's the
signal to run `sop-feedback` — an undocumented workaround is the same knowledge
loss (P1) these skills exist to prevent.

## Tailoring by project weight (the whole point)

The same set collapses differently by project. Calibrate against three real shapes:

- **Heavy** (multi-stakeholder / higher failure cost / long-lived): full
  requirements + traceability, an ADR per decision, layered tests, CI. *Do every phase.*
- **Light** (single dev, low blast radius, read-mostly): **cut `sop-specify`**
  (rules live in `CLAUDE.md`), keep ADRs for key decisions, one smoke suite,
  local `verify` gate instead of CI. *Charter → design → implement → verify → ship.*
- **Bare** (prototype / spike): `sop-charter` (even a 10-line overview) +
  `sop-verify` (whatever `test` exists). Add phases only when a real risk appears.

> The cut itself is a decision. When you drop a phase, say so — ideally as a
> one-line note in `overview.md` ("Out of scope: ... — each is a decision, write
> an ADR first"). Silent omission is how a project drifts.

When the weight is genuinely unclear, stop and invoke
**`first-principles-software-development`**: it turns project parameters
(participants, co-location, feedback-loop length, failure cost, regulation,
lifetime/scale) into a per-phase weight, so you neither gold-plate a toy nor run
a high-stakes system naked.

## Done When

- [ ] You have named the current phase and opened its skill, **or**
- [ ] You have consciously cut a phase and recorded why.

## Next

Open the phase skill you routed to. Each one ends with its own hand-off back here
or to the following phase.
