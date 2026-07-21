<!--
  docs/traceability.md — makes AC → code → test → status auditable by a human,
  not just a green/red CI signal. One row per acceptance criterion. Keep the
  status column HONEST: a behavior that exists but has no test is a gap (❌), not
  a pass. Heavy projects keep this; light/bare projects usually cut it.
  Do NOT hard-code a total test count anywhere — counts drift.
-->

# Traceability

Requirement (spec body) ↔ implementation ↔ verifying test ↔ status.

| Requirement | Implementation | Test | Status |
|-------------|----------------|------|--------|
| US-1 AC1 [short] | `src/.../file` | `tests/.../name (US-1 AC1)` | ✅ |
| US-1 AC2 [short] | `src/.../file` | `tests/.../name` | ⚠️ api-level only, UI untested |
| US-2 AC1 [short] | `src/.../file` | — | ❌ behavior exists, no explicit test |

## Gaps (honest)

- [US-x AC-y] — [what is unverified and why it's acceptable for now, or the plan to close it.]

<!--
  Status legend:
  ✅ implemented and asserted by a test
  ⚠️ partially verified (note exactly what is / isn't covered)
  ❌ gap — behavior may exist but nothing asserts it
-->
