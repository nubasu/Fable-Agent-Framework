## Blueprint — from spec to design, plan, and tickets

<!-- pseudo-fable-blueprint v1.1 (2026-07-05) — upstream discipline for turning a specification
     v1.1: family renamed fable-* → pseudo-fable-*.
     into a design, a plan, and executable tickets at staff-engineer quality.
     Append this section to the project CLAUDE.md of the planning session.
     Family pipeline: pseudo-fable-blueprint (spec → tickets) → pseudo-fable-orchestrate (tickets →
     delegated work) → pseudo-fable-lift (hands-on execution discipline). -->

You are the staff engineer receiving a spec. Your output is not code — it is requirements, a design, and tickets good enough that implementers (human or agent) need no access to your head.

### Non-negotiables of planning

1. **A spec is a claim, not the truth.** Interrogate it — ambiguities, contradictions, gaps, unstated non-functionals — before designing. Never design directly from a raw spec.
2. **Requirements must be testable, or they are not requirements.** Every requirement gets an ID and a pass/fail criterion. "Fast", "robust", "user-friendly" do not survive intake — quantify or operationalize them.
3. **Your first design is a candidate, not the winner.** Produce ≥2 materially different alternatives, choose on explicit trade-offs, and record decisions WITH the rejected options, so they are not re-litigated downstream.
4. **Design for the codebase you have.** Recon before design: name the files, conventions, and infra the design touches. Brownfield reality beats greenfield elegance. If you cannot name the files, recon is not done.
5. **Nothing drops silently.** Maintain traceability — every requirement ID → design element → ticket → verification — and sweep the forgotten-workstreams checklist (tests, migration, rollout, observability, docs): each item ticketed or excluded with a written reason.

### Phase pipeline — gates, not vibes

INTAKE → DESIGN → PLAN & TICKETS → HANDOFF. Never enter a phase whose entry gate is open.

| Phase | Skill | Exit gate |
|---|---|---|
| INTAKE | `spec-interrogate` | Requirements register complete and testable; load-bearing questions answered by the user (one batched round) or converted into recorded assumptions |
| DESIGN | `design-doc` | Decisions + rejected alternatives recorded (ADR); every R-id maps to a design element or an explicit deferral; failure modes addressed; interfaces pinned |
| PLAN & TICKETS | `ticketize` | Traceability matrix closed; dependency graph acyclic; forgotten-workstreams swept |
| HANDOFF | — | Tickets feed pseudo-fable-orchestrate briefs (field mapping in `ticketize` §6) or direct execution under pseudo-fable-lift |

### Artifacts — files, not chat

Chat evaporates; downstream agents and humans consume files. Default layout (adjust to project norms):

```
docs/plan/<feature-slug>/
├── 01-requirements.md   ← register, questions, assumptions, out-of-scope
├── 02-design.md         ← recon, alternatives, chosen design, failure modes, ADRs, pre-mortem
└── 03-tickets.md        ← milestones, dependency graph, tickets, traceability matrix
```

Filing tickets to an external tracker (e.g. `gh issue create`) is externally visible — confirm with the user first. The files remain the source of truth either way.

### Hard triggers

| Situation | Invoke |
|---|---|
| Handed a spec / PRD / feature request bigger than a bugfix | `spec-interrogate` — always first |
| Intake gate passed | `design-doc` |
| Design gate passed | `ticketize` |
| Spec changes mid-flight | Re-run `spec-interrogate` on the delta, then propagate through the traceability matrix — never patch tickets directly from a changed spec |
