---
name: sop-specify
description: >-
  Phase 1 of the sop workflow — turn a feature idea into a specification. Use when
  "what should it do" has multiple readings, when acceptance is fuzzy, or before
  building anything non-trivial that more than one person (or a future you) must
  agree on. It writes docs/requirements/<feature>.md as prioritized user stories
  with acceptance criteria (NOT Gherkin) that double as the spec body, keeps a
  docs/traceability.md matrix (AC ↔ implementation ↔ test ↔ status), and runs a
  short clarify loop for genuine ambiguities. Cut this phase for single-developer
  projects where rules live in CLAUDE.md.
metadata:
  version: 0.1.0
  last_updated: 2026-07-21
---

# sop-specify — specify the feature

## What this phase solves / When to use

**Solves P2 (alignment), with P1.** It builds a shared, referenceable statement of
*what the system must do* so intent equals understanding. The acceptance criteria
**are the spec body** — tests assert them directly.

Use it when a feature has real ambiguity or must be agreed by more than the person
typing. **Skip it** when participants = 1 and the blast radius is low: put the few
rules in `CLAUDE.md` and go straight to design/implement (this is a deliberate,
recorded cut, not forgetfulness).

## Prerequisites

- `docs/overview.md` exists (run `sop-charter` first) so scope and parameters are set.

## Steps

1. **Parse the feature** into actors, actions, data, constraints. Reuse the goal
   and scope from `overview.md`; do not restate them.

2. **Write prioritized user stories.** Each is an independently testable slice:
   - Heading `## US-N <title>`, priority-ordered (P1 = most critical MVP slice).
   - A blockquote story: *"As a [role], I want [capability], so that [value]."*
   - A `**Acceptance Criteria**` block of `- ACn ...` bullets. Each AC is
     concrete and testable (given input → expected outcome / rejection message).
     Keep the Given-When-Then *thinking* (arrange → act → assert); do **not** write
     `.feature` files or step glue (see the no-Gherkin rule below).

3. **Clarify loop (light).** Scan for ambiguity that would change architecture,
   data shape, test design, or UX. Ask **at most 3–5** targeted questions, each
   answerable by a short choice or ≤5 words. Fold each answer back into the
   relevant AC. Skip questions with a reasonable default — record the default as
   an assumption instead of asking.

4. **Update `docs/traceability.md`** (heavy projects): one row per AC —
   `requirement ↔ implementation location ↔ verifying test ↔ status` — with honest
   status markers (✅ done / ⚠️ partial / ❌ gap). New ACs start as gaps.

5. **Point tests at the ACs.** Tests name their source (`US-N AC-m`) so the link is
   auditable. The spec, the code, and the test stay traceable to one another.

## Where the artifact goes

- `docs/requirements/<feature>.md` — the user stories + acceptance criteria.
- `docs/requirements/README.md` — index of feature files (one line each).
- `docs/traceability.md` — the AC ↔ code ↔ test ↔ status matrix (if kept).

## No Gherkin (an evidence-based cut)

Do not introduce Gherkin/`.feature` files or step-definition glue. Plain
acceptance-criteria bullets, asserted directly by ordinary tests, cost less and
drift less for a small team. Keep only the arrange→act→assert habit. (This mirrors
the reference project that tried Gherkin and retreated — record the same reasoning
in an ADR if a teammate proposes it again.)

## Quality checklist / Gate

- [ ] Each user story is independently testable and priority-ordered.
- [ ] Every AC is concrete, testable, and unambiguous (a tester couldn't argue it).
- [ ] No `[NEEDS CLARIFICATION]` markers left unresolved (or ≤3, flagged).
- [ ] Success is measurable and technology-agnostic (no framework names in the AC).
- [ ] Traceability rows added for new ACs (heavy projects), gaps marked honestly.

## Tailoring by project weight

- **Heavy**: full `docs/requirements/` + `traceability.md` with a gap table; ACs
  cite ADRs where a decision shaped them.
- **Light**: often **cut entirely** — a handful of rules in `CLAUDE.md` is enough
  for a single dev. If kept, one short file, no traceability matrix.
- **Bare**: cut. Revisit only when a second person or real acceptance risk appears.

When unsure whether the spec is worth its cost, invoke
`first-principles-software-development` (this is a P2 question).

## Done When

- [ ] `docs/requirements/<feature>.md` written and passes the checklist.
- [ ] Clarify loop closed (answers folded in, or defaults recorded).
- [ ] Traceability updated (if kept).

## Next

Hand off to **`sop-design`** if the feature needs real design decisions, or
**`sop-implement`** if the path is obvious. Update `CLAUDE.md`'s current phase.
