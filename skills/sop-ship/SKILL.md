---
name: sop-ship
description: >-
  Phase 5 of the sop workflow — release. Use when a change is green and ready to
  go out. It runs the release in gated order (verify → verify:cf → version bump →
  build → deploy), uses package.json.version as the single source of truth via
  bumpp (deploy:major|minor|patch), deploys to the project's target (Cloudflare
  Workers/Pages via wrangler, or cargo for Rust), refuses to tag on a red gate,
  notes the deploy:raw escape hatch without encouraging it, and updates CLAUDE.md's
  current phase after shipping. This is the release-governance phase.
metadata:
  version: 0.2.0
  last_updated: 2026-07-21
---

# sop-ship — release it

## What this phase solves / When to use

**Solves P4 (change governance) + P5 (trust / a agreed "released" state).** Shipping
is where version, gate, and deploy must line up so "what's live and why" stays
knowable. Use it when `sop-verify` is green and you intend to release.

## Prerequisites

- The gate is green (`sop-verify`). Do not proceed on a red gate.
- Working tree is committed (`git add`ed files are the release's contents — don't
  keep editing them mid-release).

## Steps

1. **Confirm the gate order.** The canonical release order is:
   **`verify → verify:cf → bump → build → deploy`**. The gate runs *before* the
   version bump so a failure never produces a tag. Many projects encode exactly
   this in their `deploy:*` scripts — read them rather than re-deriving.

2. **Bump the version.** `package.json.version` is the single source of truth,
   bumped with **bumpp** (creates the release commit + tag; does not push). Choose
   the level by change impact:
   - `deploy:patch` — fixes, no behavior change.
   - `deploy:minor` — additive, backward-compatible.
   - `deploy:major` — breaking.
   For non-JS projects, use the project's equivalent single-source version.

3. **Build for the real target and deploy.**
   - **Cloudflare Workers**: build under the Workers preset and `wrangler deploy`
     (bindings/KV come from `wrangler.jsonc`; secrets are set as Worker
     secrets/env, not committed).
   - **Cloudflare Pages**: `wrangler pages deploy <output>`.
   - **Rust tool/lib**: `cargo install --path ...` / `cargo publish` as appropriate.

4. **The escape hatch is a last resort.** A raw deploy that skips the gate
   (`deploy:raw` or equivalent) exists for emergencies only. Using it is a
   conscious risk — say so out loud; never make it the habit.

5. **Close the loop.** After a successful deploy:
   - Update `CLAUDE.md`'s "current phase" (what shipped, what's next).
   - For heavier projects, note the release in the changelog / settled decisions.
   - Push the tag/commit if the team's flow expects it (bumpp does not push).

## Where the result goes

- A version bump + tag in git (bumpp).
- The deployed artifact on the target platform.
- An updated `CLAUDE.md` current phase.

## Quality checklist / Gate

- [ ] Gate was green **before** the bump (no tag on red).
- [ ] Version bumped at the correct level; `package.json.version` is the source.
- [ ] Built for the real runtime target (Workers preset for Workers, not node).
- [ ] Secrets/bindings are configured on the platform, not committed.
- [ ] `deploy:raw` was NOT used (or, if it was, the risk was stated explicitly).
- [ ] `CLAUDE.md` current phase updated post-ship.

## Tailoring by project weight

- **Heavy**: gated `deploy:*` scripts + CI; changelog/settled-decisions updated;
  tag pushed per team flow.
- **Light**: the `deploy:*` scripts already chain verify → verify:cf → bump →
  deploy; run one command, then update `CLAUDE.md`.
- **Bare**: "ship" may just be `cargo install --path` or handing over the binary;
  still bump a version and note what changed.

## Done When

- [ ] Released to the target with a bumped, tagged version.
- [ ] `CLAUDE.md` current phase reflects the release.

## Next

Back to **`sop-workflow`** for the next cycle — pick the next feature
(`sop-specify`) or decision (`sop-design`), or a hotfix loop straight through
`sop-verify → sop-ship`.
