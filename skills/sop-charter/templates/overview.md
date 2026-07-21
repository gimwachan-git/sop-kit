<!--
  docs/overview.md — the project charter.
  Keep it short. Mandatory sections: Goal, Project Parameters, Scope, Out of Scope,
  Open Questions. The others are OPTIONAL and pulled in only for heavier projects
  (see each section's note). Delete sections you don't use — don't leave "N/A".
-->

# [PROJECT] — Overview

## Goal (one sentence)

[What this does, for whom. If you can't say it in one sentence, resolve that first.]

## Project Parameters (why the process is this weight)

<!-- These six drive how heavy every later phase is. State each explicitly. -->

- **Participants / co-location**: [e.g. single dev + AI agent; or 4 devs, 2 orgs]
- **Feedback loop**: [change one line → see effect in: seconds / minutes / a deploy]
- **Failure cost**: [toy / internal tool / money / medical / aviation]
- **Regulation / contract**: [none / internal policy / audited / regulated]
- **Lifetime & scale**: [throwaway / years, N users, expected growth]

> Consequences of these parameters for our process:
> [e.g. "single dev, low blast radius → no requirements docs, no full test
> programme, no review ceremony; local verify gate instead of CI."]

## Scope (in)

- [Feature / capability in scope]
- [**Bold** items = recently pulled into scope]

## Business Rules *(optional — heavy projects; otherwise keep these in CLAUDE.md)*

- [Invariant that is easy to forget and must always hold, e.g. "amount = positive
  integer; reject 0/negative/decimal", "month attribution by transaction date".]

## Data Model *(optional — heavy projects with real persistence)*

- [Concrete paths / field schemas, e.g. `transactions/{id} = { date, type, amount, ... }`]

## Out of Scope (for now)

<!-- Each line is a DECISION, not a silent omission. -->

- [Deferred capability] — each is a decision; **write an ADR first** to change it.
- [Deferred capability] — revocable, not permanent.

## Settled Key Decisions *(optional — heavy projects; digest, full record in ADRs)*

- [One-line digest] → [ADR-000N](adr/000N-....md)

## Open Questions (to decide)

- [Unresolved decision, or "none yet"]
