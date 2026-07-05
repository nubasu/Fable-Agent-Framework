---
name: design-doc
description: Produce a decision-complete design from a requirements register — codebase recon, 2-3 materially different architectures with trade-offs, failure-mode analysis, pinned interface contracts, cross-cutting concerns, ADRs, and a pre-mortem. Use after spec-interrogate's gate passes; output is docs/plan/<slug>/02-design.md.
---

# design-doc — decide once, record forever

Goal: a design that downstream implementers can execute without re-opening decisions — because the decisions, and the rejected alternatives, are written down.

## 1. Recon (brownfield rule)

- Locate: the entry points affected, the nearest existing feature to imitate (name the file), infra and libraries already in the repo, conventions that constrain the design.
- Record each as `path:line`. Bar to clear: if you cannot name the files the design touches, recon is not done.

## 2. Alternatives — break the anchor

- Write 2–3 materially different designs (different mechanism, different layer, or buy-vs-build — not parameter tweaks of one idea). Your first idea is a candidate, not the winner.
- Score each against: requirement fit (by R-id), blast radius, reversibility, operational complexity, effort.
- Choose with a one-paragraph justification. When it is a close call, prefer the more reversible option.

## 3. The chosen design

- Components with single responsibilities; who owns which state.
- **Interface contracts** — data model, API signatures, schemas — pinned precisely. These become the frozen interfaces for parallel implementation later (pseudo-fable-orchestrate §4).
- Data flow for the main scenarios, write paths included.

## 4. Failure-mode analysis — mandatory, not polish

For each component and each integration point: what happens when it fails, times out, returns partial data, or is called twice? Cover: idempotency, retries, consistency, input trust boundaries (authn/z, validation), the scale envelope (expected load ×10), and migration of existing data.

## 5. Cross-cutting concerns — the "other necessary work"

Write a short position on each; "not needed because X" is a valid position, silence is not:
test strategy (which layer carries the risk) / observability (what you would need to debug this in prod) / rollout & rollback (flags? phases?) / data migration / docs.

## 6. Decision records (ADR)

Each significant decision as a mini-ADR: context / decision / alternatives rejected AND why / consequences. Rejected options are recorded precisely so that downstream agents do not re-litigate them.

## 7. Pre-mortem

"This shipped, then failed or was reverted. The three most likely reasons:" — write them; give each a mitigation that lands in the plan (a spike, a test, a milestone reordering).

## 8. Gate check

- Every R-id maps to a design element or an explicit deferral.
- Interfaces pinned; failure modes addressed; ADRs written.
- → Proceed to `ticketize`.
