---
name: spec-interrogate
description: Turn a raw specification into a testable requirements register — hunt ambiguities, contradictions, gaps, and unstated non-functionals; triage open points into one batched round of user questions vs. recorded assumptions. Use immediately upon receiving any spec, PRD, or feature request; never design from a raw spec.
---

# spec-interrogate — the spec is a claim, not the truth

Goal: a requirements register solid enough to design against, plus an explicit record of everything still uncertain.

## 1. Read fully, then recon reality

- Read the whole spec before judging any part of it.
- Recon the repo: does something adjacent already exist? Which conventions, infra, or data models does the spec implicitly touch — or contradict? A spec that ignores the existing system is a finding to raise, not an instruction to rebuild.

## 2. Extract — the requirements register

Build the table in `01-requirements.md`:

`R<id> | requirement (testable form) | source (spec §) | kind (functional / non-functional) | priority (must / should / later)`

- Rewrite vague language into pass/fail form; keep the original wording in "source" so drift stays visible.
  Example: "fast" → "p95 < 300 ms at 100 rps". Propose a number when the spec has none — a wrong number gets corrected; "fast" never does.
- Sweep for unstated non-functionals: performance, security/authz, availability, data migration, backward compatibility, i18n, cost, observability. Where the spec is silent: propose (register it + record the assumption) or raise (question).

## 3. Hunt — what specs hide

Run each lens over the spec and log every hit:

- **Ambiguity** — a sentence with two defensible readings. Write both readings down.
- **Contradiction** — internal (spec vs. spec) and external (spec vs. existing code and data).
- **Gaps** — error cases, empty states, permissions, concurrency, limits/quotas, lifecycle (create is specified — what about edit, delete, expiry?).
- **Edge sweep** per user-facing behavior: empty / 0 / 1 / max / duplicate / concurrent / unauthorized / partial failure.

## 4. Triage — ask little, assume explicitly

Every open point becomes exactly one of:

- **Question** — to the user, in ONE batched round, aim ≤5. Only for points that are load-bearing AND expensive to change later. Each question ships with why-it-matters and your recommended default, so a busy user can reply "yes to all defaults".
- **Assumption** — register: `A<id> | assumption | impact if wrong | how we would notice`. If a wrong guess is cheap to fix later, assume and record — do not ask.
- **Out-of-scope candidate** — proposed explicitly. Silence is not descoping.

## 5. Gate check

- Register complete; every R testable; priorities set.
- No load-bearing question left open.
- → Proceed to `design-doc`.
