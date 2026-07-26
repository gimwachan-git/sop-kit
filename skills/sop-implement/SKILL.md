---
name: sop-implement
description: >-
  Phase 3 of the sop workflow — write the code. Use once the decision is made and
  you're ready to build a feature or slice. It breaks work into dependency-ordered
  tasks by user story (MVP first), holds the architecture's boundaries (e.g. FSD:
  cross-slice access only via a slice's public index.ts, explicit imports),
  declares what each slice serves with @domain / @serves headers in that public
  API so docs and code stay traceable in both directions, keeps the three pillars
  alive (short feedback loop, externalize decisions, maintain alignment), and
  obeys the project's business rules. Adapts to the stack (Nuxt/TS, Rust
  workspace, etc.). Ends by handing off to sop-verify.
metadata:
  version: 0.4.0
  last_updated: 2026-07-26
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

3. **Declare what the slice serves, in its `index.ts`.** FSD gives you no way to
   say that a page, a widget, two features and an entity are *one capability*:
   slice groups are within-layer only, and the spec has no cross-layer grouping
   concept at all. So that capability has no name unless you write one. Put it in
   the public API file FSD already requires — it is the slice's contract, this
   just extends it upward:

   ```ts
   // src/features/import-transaction/index.ts
   /**
    * @domain  import
    * @serves  docs/requirements/import.md US-I1..US-I4
    */
   ```

   - **`@domain <slug> [term]`** — the *same slug on every slice of that domain,
     across every layer*. That slug is the missing concept. Add the business's
     own word as a second token when the docs and the code don't speak the same
     language (`@domain syuuan weekly-lesson-plan`) — then
     `grep -rh '@domain' src/ | sort -u` **is** the glossary, and nobody has to
     maintain one.
   - **`@serves <doc-path> [ids]`** — whatever unit the project's docs already
     use: `US-I1..US-I4`, a screen id, a range. Don't invent an ID scheme; the
     pointer only has to resolve.
   - **`@rev N`** — heavy projects only. Bump it when the requirement changes, so
     citations of the old revision are detectable instead of silently stale.
   - **Exempt**: `shared/*` (FSD: "business domains do not exist in Shared"),
     generated code, and trees outside FSD (a Nitro `server/`, a separate API
     package). Wanting to write `@serves` on something in `shared/` is a
     placement smell — move it, or keep it and let the annotation record the
     exception. Don't leave it silent.
   - **A requirement with no `features/` slice is normal, not a gap.** FSD v2.1
     says a feature earns its own slice by being reused across pages, so a
     single-page story lives in `pages/`. Annotate the page and move on.

   Write it when you create the slice, not afterwards — `sop-verify` fails the
   gate on a missing `@domain`, because a convention of this shape that isn't
   enforced lands around 40% coverage and is then worse than nothing (you trust
   a map with holes in it).

4. **Keep the three pillars alive while coding:**
   - **Short feedback loop (P3/A6):** get something runnable in front of reality
     early; don't pile all verification to the end. Put each asserting test in the
     layer that matches its risk — if you find yourself fighting the harness
     (stalling a navigation to observe a transient), you picked the wrong layer and
     just lengthened the loop you were shortening. `sop-verify` #5 is the full rule.
   - **Externalize decisions (P1):** if you make a real choice mid-implementation,
     leave an ADR (even one line) — don't bury it in a diff.
   - **Maintain alignment (P2):** point at the shared reference (interface
     contract, running prototype) rather than prose when syncing intent.

5. **Obey the business rules.** Re-read the invariants in `CLAUDE.md` /
   `overview.md` before touching rule-bearing code (money is a positive integer,
   month attribution by date, soft-delete not hard-delete, data-shape evolves
   additively, PII never enters the client bundle, etc.). These are the rules that
   pass every typecheck and still ship a bug.

6. **Write code that reads like its neighbors.** Match naming, comment density, and
   idiom of the surrounding files. Follow the project's comment-language and
   commit-message conventions from `CLAUDE.md`.

## Where the work goes

Into the source tree, in the layer/slice decided in `sop-design`. Tests (if the
project keeps them) go in the project's `tests/` layout, named to cite their
acceptance criterion (`US-N AC-m`) so traceability holds. That citation and the
slice's `@serves` header are the two links that survive refactoring — a test name
is re-read on every CI run, and a header moves with the file it describes.

## Quality checklist / Gate

- [ ] Each user story landed as an independently testable slice (MVP first).
- [ ] Architecture boundaries respected (public API only; correct layer direction).
- [ ] Every new/touched slice's `index.ts` carries `@domain` (and `@serves` where
      the project keeps requirement docs); `shared/` and generated code exempt.
- [ ] Business-rule invariants upheld in rule-bearing code.
- [ ] Any mid-flight decision externalized as an ADR.
- [ ] New behavior has an asserting test where the project keeps tests, in the layer
      that can actually observe it (`sop-verify` #5).

## Tailoring by project weight

- **Heavy**: tests-first where requested; every AC gets an assertion; boundary lint
  in the loop; traceability updated as slices land.
- **Light**: build the slice, add the one smoke assertion that would catch its
  recurring failure mode; skip layered tests.
- **Bare**: write the code and an inline unit test next to it (Rust `#[cfg(test)]`
  module, or a quick script); lean on `examples/` fixtures as the visual check.

## Done When

- [ ] The slice runs and satisfies its acceptance criteria (or stated intent).
- [ ] Boundaries and business rules hold; the slice declares its `@domain`.
- [ ] Ready to run the gate.

## Next

Hand off to **`sop-verify`** — do not treat "it compiles" or "it works on my
machine" as done. Update `CLAUDE.md`'s current phase.
