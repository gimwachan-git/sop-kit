<!--
  docs/traceability.md — makes AC → code → test → status auditable by a human,
  not just a green/red CI signal. One row per acceptance criterion. Keep the
  status column HONEST: a behavior that exists but has no test is a gap (❌), not
  a pass. Heavy projects keep this; light/bare projects usually cut it.
  Do NOT hard-code a total test count anywhere — counts drift.

  DERIVE the Implementation column; do not type it. The slices that serve this
  spec are `grep -rl '@serves.*<this file>' src/`. A hand-written column stops
  matching the code without anyone noticing — and an out-of-date matrix is
  trusted exactly as much as a current one, which is what makes it dangerous.
-->

# Traceability

Requirement (spec body) ↔ implementation ↔ verifying test ↔ status.

| Requirement | Implementation (derived from `@serves`) | Test | Status |
|-------------|----------------------------------------|------|--------|
| US-1 AC1 [short] | `features/<slice>` | `tests/.../name (US-1 AC1)` | ✅ |
| US-1 AC2 [short] | `shared/lib/<mod>` ⚠ business rule in shared | `tests/.../name` | ⚠️ api-level only, UI untested |
| US-2 AC1 [short] | `pages/<slice>` (no feature slice — single-page story) | — | ❌ behavior exists, no explicit test |

## Gaps (honest)

- [US-x AC-y] — [what is unverified and why it's acceptable for now, or the plan to close it.]

## Orphans (the other direction)

<!-- From sop-verify step 4. Both lists should normally be empty; a non-empty
     entry is either work nobody specified or a spec nobody built. -->

- **Code nothing claims**: [`features/<slice>` — no `@serves`, and no doc mentions it.]
- **Spec nothing serves**: [`docs/requirements/<file>.md` — no slice cites it.]

<!--
  Status legend:
  ✅ implemented and asserted by a test
  ⚠️ partially verified (note exactly what is / isn't covered)
  ❌ gap — behavior may exist but nothing asserts it
-->
