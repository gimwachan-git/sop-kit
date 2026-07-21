---
name: sop-design
description: >-
  Phase 2 of the sop workflow — record a design decision. Use whenever a real,
  hard-to-reverse choice is on the table: tech/library selection, architecture or
  boundary changes, data-shape decisions, a major dependency bump, or a decision
  that reverses an earlier one. It writes docs/adr/NNNN-<slug>.md (Context /
  Decision / Consequences), enforces the supersession discipline (never edit an
  old ADR — add a new one that supersedes it), decides where code lands under the
  architecture (e.g. FSD slice), and for UI-heavy work consults or creates
  design-system.md. This is the change-governance phase.
metadata:
  version: 0.1.0
  last_updated: 2026-07-21
---

# sop-design — record the decision

## What this phase solves / When to use

**Solves P1 (externalize the "why") + P2 (a shared reference) + P4 (change
governance).** A decision you can't reconstruct in six months is a decision you'll
relitigate. The ADR captures *what was chosen and why* so change stays knowable.

Use it for any non-trivial, costly-to-reverse choice. Skip a formal ADR for
reversible, local choices — but when in doubt, one 15-line ADR is cheap insurance.

## Prerequisites

- `docs/overview.md` exists. For a feature-driven decision, its
  `docs/requirements/<feature>.md` helps frame the context (heavy projects).

## Steps

1. **Name the decision** as a short action-title. Find the next number by scanning
   `docs/adr/` (zero-padded, e.g. `0007`). One decision per file.

2. **Write the ADR** from `templates/adr.md`:
   - `# NNNN — Title`
   - `Status: Accepted | Superseded by NNNN | Deferred` · `Date: YYYY-MM-DD`
   - `## Context` — the forces and the problem (fold in the rationale here).
   - `## Decision` — what we will do, concretely.
   - `## Consequences` — what this makes easy, hard, or obliges. Include the cost.
   - Optional `## Rationale` if the "why" is subtle enough to deserve its own section.

3. **Supersession discipline (critical).** Never edit or delete an old ADR. To
   change a past decision, write a **new** ADR that:
   - names the old number and **which part** it replaces (`Supersedes ADR-000X (the "…" part)`), and
   - flip the old ADR's status line to `Superseded by NNNN`.
   The log is append-only; the history of *why it changed* is the point.

4. **Place the code under the architecture.** Decide which layer/slice/module the
   change belongs to and state it in Consequences (e.g. FSD: which of
   `app/pages/widgets/features/entities/shared`; cross-slice access only via the
   slice's public `index.ts`). A boundary decision is itself ADR-worthy.

5. **UI work → design system.** If the change touches visual/interaction design,
   consult `docs/design-system.md` (tokens, per-element state tables, the
   "paid in blood" implementation rules, the UI checklist). Create it from
   `templates/design-system.md` if the project is UI-heavy and lacks one.

6. **Update the ADR index** (`docs/adr/README.md`) — a one-line entry; carry the
   supersedes/superseded relationship in the status column/annotation.

## Where the artifact goes

- `docs/adr/NNNN-<slug>.md` — the decision record.
- `docs/adr/README.md` — the index with cross-references.
- `docs/design-system.md` — UI tokens + interaction rules + checklist (UI projects).

## Quality checklist / Gate

- [ ] Exactly one decision in the file, titled as an action.
- [ ] Context states the real forces, not just the conclusion.
- [ ] Consequences name the costs and obligations, not only the benefits.
- [ ] If it reverses a past decision: old ADR marked `Superseded by NNNN`, new one
      names the old number and the superseded part. No old ADR was edited in place.
- [ ] Index updated; cross-references present.

## Tailoring by project weight

- **Heavy**: an ADR per meaningful decision; a table index carrying supersedes /
  revises / integrates relationships; ADRs cite the requirements they serve.
- **Light**: ADRs for the *key* decisions only (stack, deploy target, big bumps);
  a bullet index; "backfilled" ADRs are fine — mark ones reconstructed from
  code/git history rather than recorded at the time.
- **Bare**: no ADR log yet — but the first time you make a choice you'd have to
  reverse-engineer later, start one. A repo whose only doc is a README that has
  drifted from the code is the failure mode this phase prevents.

When unsure how formal to be, invoke `first-principles-software-development`
(this is a P1+P4 question).

## Done When

- [ ] `docs/adr/NNNN-*.md` written and passes the checklist.
- [ ] Any superseded ADR re-statused; index updated.
- [ ] Code placement (layer/slice) decided and recorded.

## Next

Hand off to **`sop-implement`**. Update `CLAUDE.md`'s current phase and, for
heavy projects, the "Settled Key Decisions" digest in `overview.md`.
