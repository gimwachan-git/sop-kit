# 0001 — Bind docs to code with in-slice annotations, not a registry file

- Status: Accepted
- Date: 2026-07-26

## Context

The workflow told projects to write `docs/requirements/<feature>.md` and to place
code under Feature-Sliced Design, but never defined how the two bind. "Feature"
means a user-visible capability in the docs and a layer of action-slices in the
code; `entities/ widgets/ pages/ shared/` had no documented counterpart at all.
Nothing was traceable in either direction.

**FSD does not solve this, and the gap is structural rather than an oversight.**
Searched against the full official corpus (`feature-sliced.design/llms-full.txt`,
fetched 2026-07): `traceab*`, `user story`, `acceptance`, `epic`, `ticket` and
`naming convention` return **zero hits**, in the docs and in GitHub Discussions
alike. Slice names are explicitly not standardized — *"The names of slices are
not standardized because they are directly determined by the business domain of
your application."* "Business domain" is used 13 times and never defined.
Decisively, **there is no cross-layer grouping concept**: slice groups are
within-layer, and the reference states they are "not a slice", have no
`index.ts`, and must not share code. A capability spanning page + widget +
features + entities therefore has **no name in FSD**, and the import rule makes
that cohesion impossible to express in the filesystem. The one place FSD tells
you to write prose about structure is cross-imports; the one place it asks for a
README is `shared/lib` — the opposite of where business meaning lives.

Two official pages also disagree on what a feature is. `understanding/needs-driven`
(v1-era, still published) says one feature equals one user-valuable capability.
`reference/layers` (v2.1) says *"not everything needs to be a feature… A good
indicator that something needs to be a feature is the fact that it is reused on
several pages."* Under v2.1 a single-page user story correctly has **no**
`features/` slice. Any binding must treat that as normal rather than as a gap.

Surveying six real FSD projects showed what the gap costs. A 57-slice enterprise
app carried 236 screen-design documents related many-to-many to slices with no
key recorded anywhere: two whole business groups had no code, ~20 slices appeared
in no document, the docs used kanji while slices used romaji with no glossary,
and a code-review rule instructed reviewers to read a `.docs/` directory that did
not exist. A smaller project had a slice that re-points transactions, sums budgets
and soft-deletes a category, with zero mentions anywhere under `docs/`; its
hand-written traceability matrix had no row for it, none for auth, and a header
still claiming the project was undeployed months after release.

Two mechanisms were considered: a **registry file** (one table mapping domain →
docs → slices, à la Backstage's catalog or a DDD context map), or **annotations
inside each slice** (à la OpenFastTrace tags, Doorstop references, Tessl
front-matter `targets`).

## Decision

**Each slice declares its own binding in its `index.ts`; no registry file is
created.**

```ts
/**
 * @domain  import               // same slug on every layer of one capability
 * @serves  docs/requirements/import.md US-I1..US-I4
 * @rev     3                    // heavy projects only
 */
```

The slug is the cross-layer name FSD lacks. A second token carries the business's
own word when docs and code use different languages, which makes
`grep -rh '@domain' src/ | sort -u` the glossary — derived, not maintained.
`docs/traceability.md`'s implementation column becomes derived the same way.

**`sop-verify` step 4 fails the gate on a missing `@domain`.** This is part of the
decision, not a follow-up: the evidence is that unenforced ID conventions reach
roughly 42% completeness across 1,078 projects (7.4% in one large case), 81% of
developers report linking "only sometimes", and only 13–20% of code changes touch
a comment. The mechanisms that hold — Rust's `#![deny(missing_docs)]`, Eclipse
Ankaios' OFT tags — hold because absence is a build failure, not a request.

Exempt: `shared/` (FSD: "business domains do not exist in Shared"), generated
code, and trees outside FSD such as a Nitro `server/`.

## Consequences

**Makes easy.** The link moves with the file it describes, so refactoring doesn't
strand it — the failure mode of doc→code paths, of which ~10% of links in source
comments are already dead. No new document to keep current, which matches the
"only the docs that are necessary" constraint and avoids repeating the rot
already observed in a hand-maintained matrix. Both orphan directions become
greppable with no tooling. The glossary and the matrix are outputs rather than
obligations.

**Makes hard.** There is no single place to read the whole map; you reconstruct it
with a grep. Domain slugs can drift apart across layers with nothing but the gate
to catch it. `@rev` only works if the requirement side carries revisions, so it is
restricted to heavy projects.

**Obliges.** Every new slice costs two lines. Requirement ids become an interface:
renumbering `US-N`/`AC-m` breaks every citation, so `sop-specify` now requires
append-only ids and in-place strikethrough for retired stories. Projects that cut
requirement docs entirely still keep `@domain`, since it is nearly free and buys
the glossary alone.

**Cost accepted knowingly.** Requirement→module tracing costs roughly a third of
requirement→function, and value-based selection roughly a third of tracing
everything; the binding is deliberately kept coarse for that reason. The payoff
side is measured: with traceability available, maintenance tasks ran 24% faster
and correct-solution rates went from 50% to 74% (Mäder & Egyed, 71 subjects, 461
tasks).

**Note on the acronym.** In the first-principles knowledge base, FSD means
Functional Specification Document. Here it means Feature-Sliced Design.
