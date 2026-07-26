<!--
  CLAUDE.md — the entry point a memoryless agent reads every session.
  Keep it TRUE and CURRENT; a stale CLAUDE.md is worse than none. Update the
  "Current phase" section at the end of every phase. Prefer concrete commands and
  hard-won rules over generalities.
-->

# [PROJECT] — project context

## What this is

[One paragraph: what it does, who uses it, who develops it, where it deploys.]

## Stack & commands

- **Stack**: [framework, language, key libraries, hosting]
- **Run**: `[dev command]` · **Build**: `[build command]`
- **Gate**: `[the verify command(s), or the manual gate list]` — see sop-verify.
- **Ship**: `[deploy command]` — see sop-ship.
- [Any non-obvious command or env requirement, e.g. required secrets/env vars.]

## Current phase

[What is being worked on right now, on which branch, what's done, what's next.
This is the section that rots fastest — update it as you finish each phase.]

## Repo structure

- `docs/overview.md` — goal, project parameters, scope, open questions.
- `docs/adr/` — key decisions and why (see sop-design).
- [`docs/requirements/` — user stories + acceptance, if this project keeps them.]
- `[src layout]` — [e.g. FSD layers, or crate layout; note cross-boundary rules.]
- `[tests layout]` — [where tests live and what each layer asserts.]
- **Docs↔code binding**: [every sliced-layer `index.ts` carries
  `@domain <slug> [term]`, plus `@serves <doc> <ids>` where requirement docs
  exist. Same slug across every layer of one capability — that slug is the only
  name the capability has. Exempt: `shared/`, generated code, non-FSD trees.
  `sop-verify` step 4 fails the gate on a missing `@domain`. Delete this line if
  the project doesn't use a sliced architecture.]

## Business rules (easy to forget — obey these)

- [Invariant #1 with the reason it exists.]
- [Invariant #2. Prefer stating the failure it prevents.]

## Working conventions

- New decisions → add an ADR in `docs/adr/` (never edit an old one; supersede it).
- Finish a phase → update "Current phase" above.
- Don't invent file names / stray files; put artifacts in their existing home.
- [Language rules: e.g. code comments in X, commit messages in English,
  this file maintained in Y.]

## Boundaries (not doing now)

- [Deliberately-cut scope; changing it is a decision → ADR.]
