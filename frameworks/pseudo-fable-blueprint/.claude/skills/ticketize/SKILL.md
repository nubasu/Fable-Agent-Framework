---
name: ticketize
description: Turn a design into a risk-first milestone plan and executable tickets — walking skeleton, dependency graph, sized tickets with testable acceptance criteria, a forgotten-workstreams sweep, and a requirements-to-tickets traceability matrix. Use after design-doc's gate passes; output is docs/plan/<slug>/03-tickets.md.
---

# ticketize — plans that survive contact with implementation

Goal: tickets an implementer (human or agent) can execute without access to your head — sequenced so the riskiest unknowns surface first, not at integration time.

## 1. Milestones — risk-first, demoable

- M1 is a **walking skeleton**: the thinnest end-to-end slice that proves the architecture against reality. Not the easiest piece — the most load-bearing one.
- Order the rest by uncertainty: riskiest unknowns earliest (as spike tickets where needed); polish last.
- Every milestone ends observable: something runs, a demo is possible, a gate command passes.
- Draw the MVP line explicitly: which milestone ships value, and what is deliberately after it.

## 2. Dependency graph

- Per ticket: `depends-on` / `blocks`. The graph must be acyclic; name the critical path.
- Mark parallel-safe groups (file-disjoint, interfaces frozen) — these are the fan-out candidates for pseudo-fable-orchestrate. An interface-freeze ticket gates every parallel group.

## 3. Ticket format

```markdown
T<id> — <verb phrase>                      [M<n>] [size: S|M|L] [uncertainty: low|high]
Why:        satisfies R<ids>
Pointers:   path:line of the sites to touch + the existing file to imitate
Acceptance: numbered, testable criteria — with the verification command where one exists
Non-goals:  what this ticket must NOT touch
Depends on: T<ids> / Blocks: T<ids>
```

- Stranger test (family litmus): executable by a competent implementer with zero access to this session.
- Size: S <2 h, M ≤1 day, L ≤3 days. L + high uncertainty → split it, or precede it with a spike ticket.
- Totals are ranges with a stated confidence, never point estimates.

## 4. Forgotten-workstreams sweep — mandatory

For each item: ticketed, folded into a named ticket, or excluded with a written reason. Silence is not allowed:
tests beyond unit / data migration / rollout & rollback mechanics / observability / docs / security review / performance validation.

## 5. Traceability matrix — close the loop

- `R<id> → T<ids>` for every requirement. An R with no T is a dropped requirement; a T with no R is scope creep or infrastructure — justify it.
- High-impact assumptions (A-ids): name the ticket that validates each one earliest.

## 6. Handoff

- Files are the source of truth. Filing to an external tracker (`gh issue create`) is externally visible — confirm with the user first.
- Tickets map 1:1 onto pseudo-fable-orchestrate briefs:
  `Why → Context` / `Pointers → Pointers` / `Acceptance → Contract + Done means` / `Non-goals → Non-goals` / `design ADRs & frozen interfaces → Constraints` / `known traps from recon → Gotchas`.
