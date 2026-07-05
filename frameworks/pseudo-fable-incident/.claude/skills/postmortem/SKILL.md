---
name: postmortem
description: Blameless postmortem after a resolved incident — reconstruct the timeline, compute time-to-detect / time-to-mitigate / time-to-resolve, separate root cause from contributing factors, mine what-went-well and what-was-lucky, produce action items through three lenses (detect faster / prevent the class / mitigate faster), and route lessons into rules via retro. Use after incident-response closes; the incident is not done until this exists.
---

# postmortem — the incident pays for itself here

Blameless means: systems and processes fail, not people — and not models. The question is always "why did the system allow this?", never "who screwed up?". An agent error is a missing check; find the check.

## 1. Reconstruct

From the incident file's timeline:

- Key timestamps: symptom start → detection → mitigation → diagnosis → resolution.
- The three durations that matter, each a separate improvement target:
  **time-to-detect** (start → detection) · **time-to-mitigate** (detection → mitigation) · **time-to-resolve** (detection → resolution).

## 2. Causes — root and contributing

- Root cause as a mechanism, concrete enough that the fix follows from it ("connection pool exhausted because retries lacked backoff" — not "high load").
- Contributing factors — there are usually ≥2 beyond the trigger: the latent weakness that made it possible, and the detection gap that let it grow. Ask "why" until the answers stop being actionable, then stop.
- What went well, and what was merely lucky. **Luck is a risk that didn't fire this time — price it as a finding.**

## 3. Action items — three lenses, every item concrete

| Lens | Question |
|---|---|
| Detect faster | What alert / log / metric would have caught this in minutes? (No observability at all? That IS the action item.) |
| Prevent the class | What kills the CLASS, not the instance? (validation, type, test, config guard — and grep for siblings now) |
| Mitigate faster | What would have stopped the bleeding sooner? (rollback tooling, feature flags, a runbook line) |

Each item: concrete action + destination (ticket / immediate fix / runbook) + priority. Action items are work items — there may be many; that is fine.

## 4. Route the lessons

- Context rules go through `retro`'s placement table and its ≤2-rules constraint: repo trap → Gotchas · process failure → project CLAUDE.md · generic → propose to the store.
- Operational mechanics ("how to roll back service X") → the project's runbook/docs, not CLAUDE.md.

## 5. Write it

`docs/postmortems/<date>-<slug>.md` — durable and human-visible (not `.claude/state/`):

```markdown
# <title>                      (date · severity · duration)
## Impact         — who / what / how long, in numbers
## Timeline       — timestamped, from the incident file
## Root cause     — the mechanism
## Contributing   — latent weakness · detection gap
## Went well / was lucky
## Action items   — lens / action / destination / priority
```

Keep it under a page. A postmortem nobody reads prevents nothing.
