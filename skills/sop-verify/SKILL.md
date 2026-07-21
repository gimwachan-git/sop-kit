---
name: sop-verify
description: >-
  Phase 4 of the sop workflow — run the gate that defines "done". Use before
  calling any change complete and always before shipping. It discovers the
  project's gate chain instead of assuming one (verify / verify:cf / lint:fsd /
  typecheck / test / test:e2e for JS projects; cargo test/clippy/fmt for Rust),
  runs them in order, and applies the project's hard-won verification lessons
  (node-preset builds can't catch Cloudflare workerd incompatibilities; hydration
  bugs only reproduce on production builds; PII must not leak into the client
  bundle; changed interactions and dependency upgrades need a real-browser check
  against the design system). A green gate is the Definition of Done.
metadata:
  version: 0.1.0
  last_updated: 2026-07-21
---

# sop-verify — run the gate (Definition of Done)

## What this phase solves / When to use

**Solves P3 (detect deviation before it gets expensive) + P5 (make "done"
observable and agreeable).** The gate turns "I think it works" into a shared,
repeatable signal. Run it before declaring a change done and before every ship.

## Prerequisites

- Code exists (`sop-implement`). Nothing else — the gate adapts to what's there.

## Steps

1. **Discover the gate — don't assume it.** Inspect the project first:
   - **JS/TS**: read `package.json` scripts. Prefer a composed script if present
     (`verify`), else run the individual tools that exist, in this order:
     `typecheck` → `lint` → `format:check` → `lint:fsd` (steiger) → `build` →
     `test` / `test:e2e`. Not every project has a `verify` script — some run the
     same steps by hand or in CI. Run what exists; report what's missing.
   - **Cloudflare Workers target**: also run `verify:cf` (or the equivalent
     `NITRO_PRESET=cloudflare-module build` + workerd smoke). See lesson #1.
   - **Rust**: `cargo test` (workspace) → `cargo clippy` → `cargo fmt --check`,
     whichever the project uses. Eyeball rendered `examples/` fixtures if the
     project uses them as visual checks.

2. **Run the chain in order and stop at the first failure.** Report the failing
   command's real output — never soften or skip it. A gate that fails and is
   waved through isn't a gate.

3. **Apply the verification lessons** (they pass typecheck/build and still ship bugs):
   - **#1 Node-preset builds hide workerd incompatibilities.** A dependency that
     reaches for a Node built-in can build and pass Node-based tests yet 500 in
     production on Cloudflare. Server code touching Node built-ins **must** pass
     the `verify:cf` (real-workerd) smoke, not just `build`.
   - **#2 Hydration bugs only reproduce on the production build.** Run hydration /
     navigation smoke against the built output (`.output`/preview), never the dev
     server. Back/forward navigation is a recurring failure mode — assert zero
     console errors and zero hydration warnings.
   - **#3 PII must not enter the client bundle.** If any data is access-gated,
     scan the built client output to prove it isn't statically embedded (a page
     that imports gated JSON leaks it past every route guard). Keep this as a
     regression assertion.
   - **#4 Changed interaction or upgraded dependency → real-browser check.** Four
     interactions once died silently during a dependency upgrade with everything
     green. After any interaction change or dep bump, walk the
     `docs/design-system.md` UI checklist in a real browser.

4. **Do not hard-code counts.** Report pass/fail and the failing output, not
   "N tests pass" — test counts drift across docs and lock nothing down.

## Where the result goes

Nowhere persistent by default — the gate is a live signal. If a *new class* of
check is added (a new smoke test, a new gate step), that expansion is a decision:
record it with an ADR and update `CLAUDE.md` / `overview.md`'s check list.

## Quality checklist / Gate

- [ ] Every gate step that exists was actually run (not assumed).
- [ ] The chain is green end to end, on the **production build** where relevant.
- [ ] Cloudflare targets passed the real-workerd smoke, not just `build`.
- [ ] Hydration / navigation smoke ran on the built output.
- [ ] PII-not-in-bundle assertion holds (if any data is gated).
- [ ] UI checklist walked in a real browser after interaction/dependency changes.

## Tailoring by project weight

- **Heavy**: full gate + CI enforcing lint / boundaries / typecheck; layered tests
  (unit / property / scenario) plus the smoke.
- **Light**: local `verify` + `verify:cf` scripts chained; a single focused smoke
  suite is the whole test programme — make sure it covers the recurring failure mode.
- **Bare**: `cargo test` (or the one command that exists) + eyeballing fixtures.
  If there's no gate at all, that's the finding — propose the smallest useful one.

Whether a missing check is worth adding is a P3 cost/benefit question — invoke
`first-principles-software-development` when unsure.

## Done When

- [ ] The discovered gate chain ran green (with the lessons applied).
- [ ] Failures, if any, reported with real output — not glossed over.

## Next

Hand off to **`sop-ship`**. If the gate is red, go back to `sop-implement` — do
not ship or tag on a red gate.
