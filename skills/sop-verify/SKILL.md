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
  modules and built-nothing requirements surface here instead of never. And it
  checks the UI design doc (an OOUI object/view model, a screen map, the page
  table in design-system.md) against the user stories and the screens actually
  shipped, so a design doc that silently fell behind the UI is caught. A green
  gate is the Definition of Done.
metadata:
  version: 0.9.1
  last_updated: 2026-10-24
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

5. **Check the UI design ↔ stories ↔ code binding** (projects that keep a UI
   design doc — an OOUI object/view model, a screen map, or the page-structure
   table in `docs/design-system.md`). A UI design doc rots faster than a
   requirement doc: owner feedback arrives as "make this screen simpler", the code
   changes in minutes, and nothing points back at the doc. Real failure: six UI
   commits — a simplified preview, a back-button confirm, an accordion, new
   actions on two objects — landed after the OOUI doc's last edit; the doc still
   described screens that no longer existed, and nothing flagged it until the
   owner asked "was this synced?". Four checks:

   ```bash
   # a. freshness — UI commits made after the design doc last changed.
   #    Adjust both path lists to the project (Nuxt: pages/ components/;
   #    Expo Router: app/; FSD: src/pages src/widgets). Paths are written out,
   #    not kept in a variable: zsh does not word-split "$var", so a
   #    space-separated list silently becomes one path that matches nothing.
   #    Check each design doc on its own: one doc keeping pace does not cover
   #    another (real failure: design-system.md was updated with every change,
   #    the OOUI doc was not, and a combined check reported "fresh").
   for doc in docs/design/ooui.md docs/design-system.md; do
     [ -e "$doc" ] || continue
     last=$(git log -1 --format=%H -- "$doc")
     echo "== UI commits since $doc last changed:"
     git log --oneline ${last:+$last..}HEAD -- app src/pages src/widgets
   done
   # b. stories → design — every user story is covered by the design's task /
   #    object analysis (OOUI step 1) or marked deferred / retired there.
   grep -ho '^## US-[0-9]*' docs/requirements/*.md | awk '{print $2}' | sort -u |
     while read -r us; do
       grep -rqw "$us" docs/design docs/design-system.md 2>/dev/null ||
         echo "no design for: $us"
     done
   # c. design ↔ code, by id (sop-design step 6, sop-implement step 3).
   #    Adjust doc and roots. `later:` ids are skipped by the patterns.
   doc=docs/design/ooui.md; t=$(mktemp -d)
   grep -o '`@view [a-z0-9.-]*`' "$doc" | tr -d '`' | awk '{print $2}' | sort -u > "$t/vd"
   grep -rhoE '@view +[a-z0-9.-]+' app src 2>/dev/null | awk '{print $2}' | sort -u > "$t/vc"
   comm -23 "$t/vd" "$t/vc" | sed 's/^/view no screen renders: /'
   comm -13 "$t/vd" "$t/vc" | sed 's/^/screen claims undesigned view: /'
   find app src/pages -name '*.tsx' ! -name '_layout*' 2>/dev/null |
     while read -r f; do grep -q '@view' "$f" || echo "screen without @view: $f"; done
   el='[a-z][a-z0-9-]*\.[a-z0-9.-]+#[a-z0-9-]+'
   grep -oE "\`$el\`" "$doc" | tr -d '`' | sort -u > "$t/ed"
   grep -rhoE "\"$el\"" app src 2>/dev/null | tr -d '"' | sort -u > "$t/ec"
   comm -23 "$t/ed" "$t/ec" | sed 's/^/promised, not on any screen: /'
   comm -13 "$t/ed" "$t/ec" | sed 's/^/on screen, not in the design: /'
   while read -r id; do                       # one view, one implementation
     n=$(grep -rlF "\"$id\"" app src 2>/dev/null | wc -l)
     [ "$n" -gt 1 ] && echo "drawn in $n files: $id"
   done < "$t/ec"
   # d. what ids can't express — open each view row and its route side by side:
   #    sections and their order, empty states, wording. By hand.
   ```

   Without ids, (c) falls back to listing the routes and matching them to view
   rows by hand — and then everything in (d) is by hand too. That fallback is
   what let the failure below through; once a design doc has a view table, give
   it ids. Put (c) in a script the `verify` chain runs, so it is a gate and not a
   reminder.

   - **(a) non-empty is not automatically red** — read each listed commit. Either
     the design doc gets the change (OOUI: the object's attributes / actions, the
     view table, navigation constraints) or the commit is a pure refactor with no
     design meaning. Red is a listed commit nobody has looked at.
   - **(b) a story with no screen** (an importer, a background sync) or one that
     is retired / deferred gets one line in the design doc's task table saying
     so. That is cheaper than an exemption list, and it tells the next reader the
     story was considered rather than forgotten.
   - **A UI change that contradicts an acceptance criterion is a spec change.**
     Revise the AC in place (dated, with the reason) in the same change, or the
     gate is red: the doc says "group by section", the screen no longer does, and
     both can't be the contract.
   - **OOUI specifics**: every action the UI exposes appears on its object (on the
     collection or the single view); actions in the model that the UI does not
     have yet are marked as later, not silently missing.
   - **(c) and (d) are the code-behind-the-design direction** — (a) catches
     the doc behind the code, (c)/(d) catch the code behind the doc. Real failure: the
     OOUI view table said the exercise library has "search and muscle filters at
     the top"; the picker screen (the same collection view, used for selecting)
     had them, the library screen did not, and (a)–(c) were all green because the
     route existed and the doc was fresh. The owner found it by using the app.
     With ids, that is `promised, not on any screen: exercise.collection#search`.
     Each promised element is either on screen or marked `later:` in the row.
   - **A grep proves the id is in the code, not that it renders.** Rendering is
     an E2E question (an id-driven Maestro / Playwright flow) or the device
     checklist (#4); the ids are what those tools aim at.
   - **One view, one implementation.** When two routes render the same view
     (OOUI: a collection shown for browsing and again for picking), they share
     the component that draws it — search bar, filters, row. Two hand-written
     copies drift; that drift is the failure above. With ids it is mechanical:
     an element id written in more than one source file is red.

6. **Do not hard-code counts.** Report pass/fail and the failing output, not
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
- [ ] UI design doc (if any) is not behind the code: every UI commit since its
      last edit was reviewed, every user story is covered or marked deferred,
      every route maps to a view, every view row's promised controls, sections
      and actions are on its screen (or marked later), routes that render the same
      view share its component, and no screen contradicts an AC that wasn't
      revised.

## Tailoring by project weight

- **Heavy**: full gate + CI enforcing lint / boundaries / typecheck; layered tests
  (unit / property / scenario) plus the smoke. Run step 4 in CI, and add `@rev`
  so a requirement that changed under a slice reports stale instead of silent.
  Run step 5 (a) and (b) in CI as warnings and (c) as a failure; (d) stays a
  human review.
- **Light**: local `verify` + `verify:cf` scripts chained; a single focused smoke
  suite is the whole test programme — make sure it covers the recurring failure mode.
  Step 4 runs locally; `@domain` + `@serves`, no `@rev`, no matrix.
  Step 5 runs locally whenever a UI change landed since the last gate; (c) as
  a script inside `verify`.
- **Bare**: `cargo test` (or the one command that exists) + eyeballing fixtures.
  If there's no gate at all, that's the finding — propose the smallest useful one.
  Of step 4, keep only grep (a) and (d): `@domain` alone is nearly free and still
  buys the glossary, even in a project that cut requirement docs entirely.
  Step 5 applies only if a UI design doc exists; then keep (a) — it is one command.

Whether a missing check is worth adding is a P3 cost/benefit question — invoke
`first-principles-software-development` when unsure.

## Done When

- [ ] The discovered gate chain ran green (with the lessons applied).
- [ ] Failures, if any, reported with real output — not glossed over.

## Next

Hand off to **`sop-ship`**. If the gate is red, go back to `sop-implement` — do
not ship or tag on a red gate.
