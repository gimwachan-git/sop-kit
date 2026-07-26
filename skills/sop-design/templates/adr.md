<!--
  docs/adr/NNNN-<slug>.md — one decision per file, numbered, zero-padded.
  Short: aim for 10–30 lines. Never edit an accepted ADR later; supersede it with
  a new one and flip this one's Status to "Superseded by NNNN".
  If reconstructed from code/git history rather than recorded at the time, say so
  ("backfilled").
-->

# NNNN — [Decision title, as an action]

- Status: Accepted <!-- | Superseded by NNNN | Deferred
     "Deferred" = we chose NOT to choose yet: Decision names the abstraction you're
     hiding behind plus the candidate shortlist. Supersede it when the real choice
     lands. -->
- Date: YYYY-MM-DD
<!-- when this reverses an earlier decision, add:
- Supersedes: ADR-000X (the "…" part)
     and set ADR-000X's Status line to "Superseded by NNNN".
     For a related-but-not-superseding link, use:
- Related: ADR-000X (how it relates)
-->

## Context

[The forces at play and the problem to solve. Fold the rationale in here: why this
is a real decision, what constraints bound it, what alternatives exist. Written so
a future reader understands *why*, not just *what*.

Research that fed this decision belongs here — stamped with the date it was
verified ("rates checked 2026-07 against the official pricing pages"), because
external facts go stale and a future reader needs to know how much to trust them.]

## Decision

[What we will do, concretely. Name the choice and the boundaries it sets — e.g.
which layer/slice owns the code, which library, which pattern.]

## Consequences

[What this makes easy, what it makes hard, and what it obliges. State the cost
honestly (build size, migration, new constraint), not only the upside.]
