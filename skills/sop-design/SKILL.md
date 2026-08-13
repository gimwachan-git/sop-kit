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
  design-system.md. Also owns where investigation/research results live — in a made
  decision's Context, in a Deferred ADR when the choice is postponed, or in
  docs/research/<yyyy-mm>-<topic>.md when no decision is on the table yet — so use
  it when asking "where do survey or comparison findings go". This is the
  change-governance phase.
metadata:
  version: 0.5.0
  last_updated: 2026-08-13
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
   - `Status: Proposed | Accepted | Superseded by NNNN | Deferred` · `Date: YYYY-MM-DD`
   - `## Context` — the forces and the problem (fold in the rationale here).
   - `## Decision` — what we will do, concretely.
   - `## Consequences` — what this makes easy, hard, or obliges. Include the cost.
   - Optional `## Rationale` if the "why" is subtle enough to deserve its own section.

   **The consent gate (critical).** An ADR records the *owner's* decision, not the
   agent's. Write `Accepted` only when the owner has explicitly stated or confirmed
   the decision — including its load-bearing details (names, boundaries, renames,
   topology). Anything inferred, extrapolated, or filled in by the agent starts as
   `Status: Proposed`: present the decision back to the owner and wait for a yes.
   A `Proposed` ADR is a draft — correct it **in place** as understanding improves;
   the append-only rule below binds only from `Accepted` onward. This was paid for
   in a real project: an agent transcribed its own misreading as `Accepted`, the
   owner corrected it the same day, and the "fix" had to be a superseding ADR —
   the log filled with supersession chains for decisions nobody ever made, which
   is P4 pollution, not history.

3. **Place the research.** Investigation is perishable evidence — always stamp the
   date it was verified. Where it lands depends on whether a decision is on the table:
   - **Decision made** → it belongs in that ADR's `## Context`. Don't leave it in a
     separate file the ADR merely gestures at.
   - **Decision deliberately deferred** → the deferral *is* the decision. Write the
     ADR with `Status: Deferred`: Decision = the abstraction you're hiding behind
     plus the candidate shortlist; the research goes in its Context. Supersede it
     when the real choice lands.
   - **No decision on the table yet** (a pure survey — "three ways to deploy X",
     a vendor/fee comparison with nothing to pick between yet) → **you don't need
     an ADR**. Write `docs/research/<yyyy-mm>-<topic>.md`, link it from
     `overview.md`'s Open Questions, and cite it from the ADR that eventually
     consumes it.

   The failure mode this prevents: a survey that cost real effort dies with the
   chat session, or gets smuggled into an ADR for a decision nobody actually made.

4. **Supersession discipline (critical).** Never edit or delete an old ADR. To
   change a past decision, write a **new** ADR that:
   - names the old number and **which part** it replaces (`Supersedes ADR-000X (the "…" part)`), and
   - flip the old ADR's status line to `Superseded by NNNN`.
   The log is append-only; the history of *why it changed* is the point.
   This discipline governs **accepted** decisions — a real change of mind leaves a
   trace. A `Proposed` draft the owner corrects is not a change of mind; fix it in
   place instead of minting a new number.

5. **Place the code under the architecture, and name its domain.** Decide which
   layer/slice/module the change belongs to and state it in Consequences (e.g.
   FSD: which of `app/pages/widgets/features/entities/shared`; cross-slice access
   only via the slice's public `index.ts`). A boundary decision is itself
   ADR-worthy.

   Then decide the **`@domain` slug** the new code carries. A capability normally
   spans several layers — a page, a widget, one or two features, an entity — and
   FSD has **no concept for that grouping**: slice groups are within-layer, and
   nothing in the spec names a cross-layer capability. The slug is that missing
   name, and it is the only thing tying the slice back to the document that
   justifies it. Reuse an existing slug if the change extends a known domain;
   coining a new one is itself a small decision worth a line in Consequences.
   `sop-implement` writes it into `index.ts`; `sop-verify` fails the gate if it's
   missing.

6. **UI work → design system.** If the change touches visual/interaction design,
   consult `docs/design-system.md` (tokens, per-element state tables, the
   "paid in blood" implementation rules, the UI checklist). Create it from
   `templates/design-system.md` if the project is UI-heavy and lacks one.

7. **Update the ADR index** (`docs/adr/README.md`) — a one-line entry; carry the
   supersedes/superseded relationship in the status column/annotation.

## Where the artifact goes

- `docs/adr/NNNN-<slug>.md` — the decision record.
- `docs/adr/README.md` — the index with cross-references.
- `docs/research/<yyyy-mm>-<topic>.md` — dated investigation with no decision on
  the table yet; linked from `overview.md`'s Open Questions.
- `docs/design-system.md` — UI tokens + interaction rules + checklist (UI projects).

## Quality checklist / Gate

- [ ] Exactly one decision in the file, titled as an action.
- [ ] `Accepted` only with the owner's explicit statement or confirmation of the
      decision **and** its load-bearing details; anything agent-inferred is still
      `Proposed`.
- [ ] Context states the real forces, not just the conclusion.
- [ ] Consequences name the costs and obligations, not only the benefits.
- [ ] If it reverses a past decision: old ADR marked `Superseded by NNNN`, new one
      names the old number and the superseded part. No old ADR was edited in place.
- [ ] Any research is stamped with the date it was verified, and has a home — this
      ADR's Context, or `docs/research/` linked from Open Questions. None of it
      exists only in the chat.
- [ ] Index updated; cross-references present.

## Tailoring by project weight

- **Heavy**: an ADR per meaningful decision; a table index carrying supersedes /
  revises / integrates relationships; ADRs cite the requirements they serve.
- **Light**: ADRs for the *key* decisions only (stack, deploy target, big bumps);
  a bullet index; "backfilled" ADRs are fine — mark ones reconstructed from
  code/git history rather than recorded at the time.
- **Bare**: no ADR log yet — but the first time you make a choice you'd have to
  reverse-engineer later, start one. A repo whose only doc is a README that has
  drifted from the code is the failure mode this phase prevents. Research is the
  exception that survives the cut: a 10-line dated `docs/research/` note is always
  cheaper than running the investigation again.

When unsure how formal to be, invoke `first-principles-software-development`
(this is a P1+P4 question).

## Done When

- [ ] `docs/adr/NNNN-*.md` written and passes the checklist.
- [ ] Any superseded ADR re-statused; index updated.
- [ ] Research placed and dated (ADR Context, Deferred ADR, or `docs/research/`).
- [ ] Code placement (layer/slice) decided and recorded, and its `@domain` slug
      named — reused from an existing domain, or coined deliberately.

## Next

Hand off to **`sop-implement`**. Update `CLAUDE.md`'s current phase and, for
heavy projects, the "Settled Key Decisions" digest in `overview.md`.
