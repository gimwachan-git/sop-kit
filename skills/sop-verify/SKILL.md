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
  against the design system; a test must sit in the layer that can actually observe
  its risk — component vs E2E). It also checks the docs-to-code binding both ways
  — every sliced-layer public API declares its @domain, every @serves target still
  resolves, every requirement doc is claimed by some slice — so undocumented
  modules and built-nothing requirements surface here instead of never. A green
  gate is the Definition of Done.
metadata:
  version: 0.5.0
  last_updated: 2026-08-13
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
   - **#5 Match the test layer to the risk.** A detector aimed at the wrong layer
     doesn't just cost effort — it often *cannot* observe the thing. A pure
     component/composable concern (reactive state, a conditional render, a
     transient that exists only *before* a navigation) belongs in a
     **unit/component test**: mount it, mock the browser API (`window.location`,
     timers), assert the state flip. **Symptom you're in the wrong layer:** you are
     intercepting, aborting, or stalling a navigation just to observe the
     assertion — a pre-navigation spinner asserted in E2E either vanishes with the
     torn-down page (`route.abort()`) or hangs `click()` for 30s. **Inverse guard:**
     don't push hydration / print-media / real-layout checks *down* into
     jsdom-class unit tests — there is no real layout, paint, or SSR hydration
     there, so green is a false negative (that's what #2 and #4 are for).

4. **Check the docs ↔ code binding** (projects that keep requirement docs). The
   slice headers `sop-implement` writes are only worth something if something
   fails when they're absent: a convention of this shape that nobody enforces
   lands near 40% coverage, and a map with unmarked holes is worse than no map.
   Four greps, no tooling:

   ```bash
   # a. every sliced-layer public API declares its domain.
   #    Use find, not src/{pages,...}/*/index.ts — under zsh an unmatched glob
   #    aborts the whole check, and a layer with no slice dirs is normal (pages
   #    as plain files, or no features/ layer at all).
   for layer in pages widgets features entities; do
     find "src/$layer" -mindepth 2 -maxdepth 2 -name 'index.*' 2>/dev/null |
       while read -r f; do
         grep -q '@domain' "$f" || echo "no @domain: $f"
       done
   done
   # b. every @serves target still exists. This is the one that catches a review
   #    rule citing a docs directory that was moved or never existed.
   grep -rho '@serves *[^ ]*' src/ | awk '{print $2}' | sort -u |
     while read -r p; do [ -e "$p" ] || echo "dead @serves target: $p"; done
   # c. every requirement doc is claimed by some slice (skip the index file —
   #    README.md is a table of contents, not a requirement).
   find docs/requirements -name '*.md' ! -name 'README.md' 2>/dev/null |
     while read -r d; do
       grep -rq "$(basename "$d")" src/ 2>/dev/null || echo "nothing serves: $d"
     done
   # d. the glossary, derived rather than maintained
   grep -rh '@domain' src/ | sort -u
   ```

   Adjust the roots to the project (`packages/*/src`, a different layer set).
   **Exempt from (a)**: `shared/`, generated code, and trees outside FSD. **Not a
   finding**: a requirement with no `features/` slice — FSD v2.1 gives a feature
   its own slice only when it's reused across pages, so single-page stories live
   in `pages/` and that is correct.

5. **Do not hard-code counts.** Report pass/fail and the failing output, not
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
- [ ] Each failing/new check sits in the layer that can actually observe it — no
      E2E fighting navigation to see a transient, no jsdom test standing in for a
      hydration or layout check.
- [ ] Docs↔code binding checked both ways: no sliced-layer `index.ts` without
      `@domain`, no `@serves` pointing at a path that no longer exists, no
      requirement doc that nothing claims.

## Tailoring by project weight

- **Heavy**: full gate + CI enforcing lint / boundaries / typecheck; layered tests
  (unit / property / scenario) plus the smoke. Run step 4 in CI, and add `@rev`
  so a requirement that changed under a slice reports stale instead of silent.
- **Light**: local `verify` + `verify:cf` scripts chained; a single focused smoke
  suite is the whole test programme — make sure it covers the recurring failure mode.
  Step 4 runs locally; `@domain` + `@serves`, no `@rev`, no matrix.
- **Bare**: `cargo test` (or the one command that exists) + eyeballing fixtures.
  If there's no gate at all, that's the finding — propose the smallest useful one.
  Of step 4, keep only grep (a) and (d): `@domain` alone is nearly free and still
  buys the glossary, even in a project that cut requirement docs entirely.

Whether a missing check is worth adding is a P3 cost/benefit question — invoke
`first-principles-software-development` when unsure.

## Done When

- [ ] The discovered gate chain ran green (with the lessons applied).
- [ ] Failures, if any, reported with real output — not glossed over.

## Next

Hand off to **`sop-ship`**. If the gate is red, go back to `sop-implement` — do
not ship or tag on a red gate.
