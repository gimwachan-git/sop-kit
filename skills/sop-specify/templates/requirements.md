<!--
  docs/requirements/<feature>.md
  The acceptance criteria below ARE the spec body — tests assert them directly.
  No Gherkin / no .feature files (see ADR on plain-tests-over-Gherkin). Keep the
  arrange→act→assert habit only. One heading per user story, priority-ordered.
-->

# Requirements: [FEATURE]

> The acceptance criteria here are the **spec body**; asserted directly by `tests/`
> (unit / property / scenario). Not Gherkin.

## US-1 [short title]  (Priority: P1)

> As a [role], I want [capability], so that [value].

**Acceptance Criteria**

- AC1 [Given concrete input, the expected outcome / exact rejection message.]
- AC2 [Boundary / invalid input → specific handling.]
- AC3 [Interaction or state rule, referencing another feature file if relevant.]

## US-2 [short title]  (Priority: P2)

> As a [role], I want [capability], so that [value].

**Acceptance Criteria**

- AC1 [...]
- AC2 [...]

<!-- Add more user stories as needed, each independently testable, priority-ordered.
     Note where a decision shaped an AC, e.g. "(ADR-0021)". -->
