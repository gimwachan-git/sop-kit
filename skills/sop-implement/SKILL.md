---
name: sop-implement
description: >-
  Phase 3 of the sop workflow — write the code. Use once the decision is made and
  you're ready to build a feature or slice. It breaks work into dependency-ordered
  tasks by user story (MVP first), holds the architecture's boundaries (e.g. FSD:
  cross-slice access only via a slice's public index.ts, explicit imports), keeps
  the three pillars alive (short feedback loop, externalize decisions, maintain
  alignment), and obeys the project's business rules. Adapts to the stack (Nuxt/TS,
  Rust workspace, etc.). Ends by handing off to sop-verify.
metadata:
  version: 0.1.0
  last_updated: 2026-07-21
---

# sop-implement — build it

## What this phase solves / When to use

This is **construction** — the one activity that isn't itself a detector, so it
must stay tethered to the detectors around it (the spec it satisfies, the gate it
must pass). Use it when the decision is settled and code is the next step.

## Prerequisites

- The relevant decision is recorded (`sop-design`) if it was non-trivial.
- For heavy projects, the acceptance criteria exist (`sop-specify`) so you know
  what "done" means before writing code.

## Steps

1. **Break work into tasks, by user story, MVP first.** Order by dependency;
   deliver the P1 story as a complete, testable slice before starting P2. Mark
   tasks that can run in parallel (different files, no shared dependency). You do
   not need a separate `tasks.md` artifact for small work — an inline checklist is
   fine; keep one only if the breakdown is large or shared.

2. **Hold the architecture boundaries.** Match the surrounding code's structure.
   For FSD projects:
   - Respect layer direction (`app → pages → widgets → features → entities → shared`).
   - Cross-slice access **only** through a slice's public `index.ts`; import
     explicitly (don't rely on framework auto-import for cross-slice symbols).
   - A component used by exactly one widget belongs *inside* that widget's slice,
     not in a shared bucket.
   - Shared contract types go in the agreed shared location, exported explicitly —
     no ambient global interfaces that bypass the boundary.
   Run the boundary linter as you go if the project has one (`sop-verify` enforces it).

3. **Keep the three pillars alive while coding:**
   - **Short feedback loop (P3/A6):** get something runnable in front of reality
     early; don't pile all verification to the end.
   - **Externalize decisions (P1):** if you make a real choice mid-implementation,
     leave an ADR (even one line) — don't bury it in a diff.
   - **Maintain alignment (P2):** point at the shared reference (interface
     contract, running prototype) rather than prose when syncing intent.

4. **Obey the business rules.** Re-read the invariants in `CLAUDE.md` /
   `overview.md` before touching rule-bearing code (money is a positive integer,
   month attribution by date, soft-delete not hard-delete, data-shape evolves
   additively, PII never enters the client bundle, etc.). These are the rules that
   pass every typecheck and still ship a bug.

5. **Write code that reads like its neighbors.** Match naming, comment density, and
   idiom of the surrounding files. Follow the project's comment-language and
   commit-message conventions from `CLAUDE.md`.

## Where the work goes

Into the source tree, in the layer/slice decided in `sop-design`. Tests (if the
project keeps them) go in the project's `tests/` layout, named to cite their
acceptance criterion (`US-N AC-m`) so traceability holds.

## Quality checklist / Gate

- [ ] Each user story landed as an independently testable slice (MVP first).
- [ ] Architecture boundaries respected (public API only; correct layer direction).
- [ ] Business-rule invariants upheld in rule-bearing code.
- [ ] Any mid-flight decision externalized as an ADR.
- [ ] New behavior has an asserting test where the project keeps tests.

## Tailoring by project weight

- **Heavy**: tests-first where requested; every AC gets an assertion; boundary lint
  in the loop; traceability updated as slices land.
- **Light**: build the slice, add the one smoke assertion that would catch its
  recurring failure mode; skip layered tests.
- **Bare**: write the code and an inline unit test next to it (Rust `#[cfg(test)]`
  module, or a quick script); lean on `examples/` fixtures as the visual check.

## Done When

- [ ] The slice runs and satisfies its acceptance criteria (or stated intent).
- [ ] Boundaries and business rules hold.
- [ ] Ready to run the gate.

## Next

Hand off to **`sop-verify`** — do not treat "it compiles" or "it works on my
machine" as done. Update `CLAUDE.md`'s current phase.
