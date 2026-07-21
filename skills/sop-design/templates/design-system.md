<!--
  docs/design-system.md — the reference against which "visually broken" can be
  DETECTED. UI-heavy projects only. It exists because interaction behaviors die
  silently during dependency upgrades and pass every typecheck/build. Three parts:
  tokens, per-element state tables, and a checklist you run in a real browser.
-->

# Design System & UI Interaction Spec

## Design language

[One paragraph: the visual intent, and any layer split — e.g. "chrome" (monochrome
navigation) vs "content" (colorful, data-driven).]

## Tokens

| Token | Value | Used for |
|-------|-------|----------|
| ink | #333 | icon / line color on hover-active |
| state duration | 250ms ease-in-out | all chrome state transitions |
| press | scale(0.95) on :active | pressable feedback |
| [token] | [value] | [what it drives] |

## Interaction states (per element)

<!-- One small table per interactive element: button, link, card, menu item… -->

### [Element name]

| State | Behavior |
|-------|----------|
| Rest | [...] |
| Hover | [...] |
| Active | [press feedback, e.g. scale(0.98)] |
| Entrance | [timing, e.g. 200ms ease-out] |

> Content-layer contract: [e.g. "every timing is 200ms ease-out; every pressable
> gets :active → scale(0.98)."]

## Implementation rules (each one paid for in blood)

1. [Rule tied to a real past failure, e.g. "Icon color = currentColor inheritance
   only — casualty: hardcoded fills broke theme switching."]
2. [Rule …]

## UI interaction checklist

<!-- Run in a REAL browser (build + preview) after any style/interaction change,
     AND after every dependency upgrade. Automated smoke tests do NOT cover colors
     or hover states — this checklist does. -->

- [ ] [Element] hover / active / entrance behaves per its state table
- [ ] Navigation + back/forward leaves no broken state
- [ ] [Highest-stakes view, e.g. print layout] renders correctly
- [ ] Contrast meets WCAG on the key surfaces
