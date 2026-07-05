---
name: delegate
description: Decompose work and write executor-agnostic briefs for subagents (Claude subagents, Codex, other external agents) — granularity rules, executor routing, the 9-field brief format, Sonnet-class brief tuning, a pre-send check, and parallel fan-out rules (interface freeze, file isolation). Use before spawning any implementation subagent.
---

# delegate — brief like a great tech lead

A subagent's output quality is capped by your brief quality. The subagent cannot read your session — the brief carries everything.

## 1. Decompose

- Cut along interfaces, not along effort: each task = one coherent responsibility, file-disjoint from its siblings wherever possible.
- Right-size: one task ≈ 30 min – 3 h of focused work. Bigger → the subagent loses coherence; smaller → overhead dominates (under ~15 min: do it yourself per the Delegation-first criteria, or batch several into one brief).
- Build the dependency graph first. Serialize blockers; only genuinely independent tasks run in parallel.

## 2. Route

- Use the routing table in CLAUDE.md (Orchestration section).
- Judgment-heavy or ambiguous → do not delegate; decide first, then delegate the decided pieces.
- Verifier ≠ implementer: never let an agent verify its own work.

## 3. Write the brief — 9 fields, all mandatory

```markdown
# TASK <id>: <one line>
## Context      — why this exists, where it fits (2–4 lines max)
## Pointers     — path:line for every relevant site + the existing file to imitate
## Contract     — numbered, testable requirements
## Non-goals    — what NOT to do or touch (adjacent refactors, new deps, unrelated fixes)
## Constraints  — frozen interfaces (verbatim), conventions, allowed dependencies
## Gotchas      — traps you already know (flaky test X, module Y is generated, …)
## Done means   — exact commands + expected output the executor must run before reporting
## Escalation   — "If the Contract seems wrong, impossible, or conflicts with the code you
                   find: STOP and report. Do not improvise."
## Report back  — the required format (§5), with a hard length cap
```

- Litmus test: could a competent stranger with zero session context execute this brief? (For Codex, that is literally the situation.)
- Include decisions, exclude deliberation: state what was decided, never the debate that produced it.
- Pointers over pastes: reference `path:line`; paste verbatim only what is frozen (interfaces) or unreachable from the repo (external decisions).
- Gotchas are the highest-leverage field: every trap you already know and fail to pass on will be rediscovered at full price.

## 3b. Tuning for Sonnet-class executors

A Sonnet-class worker executes exactly what is legible to it. Completeness is necessary but not sufficient — the brief must also be lean and mechanical:

- **Lean over exhaustive.** Attention degrades with bulk: Context ≤4 lines, Pointers ≤~10 sites, only the Gotchas that apply. A 300-line brief performs worse than a 60-line brief carrying the same decisions.
- **Pre-decide everything decidable.** Anything left open gets resolved by silent guessing, not by asking — even when told to ask. If you catch yourself writing "choose a sensible approach for X", stop and decide X now.
- **Contract as tests, not prose.** The strongest contract language is concrete cases: exact input → expected output pairs, or the literal test(s) that must pass. One example outweighs a paragraph of description.
- **Fence with a file allowlist.** In Non-goals: "You may create/modify ONLY: <paths>. Needing any other file = DEVIATED — stop and report." A mechanical list holds where a conceptual non-goal slips.
- **Concrete escalation tripwires.** Abstract triggers ("if the contract seems wrong") under-fire on weaker models. Add mechanical ones: needs a file outside the allowlist / needs a new dependency / an interface in Constraints does not match reality / a Done-means command fails twice.
- **One objective per brief.** Bundled objectives get partially completed. Two goals = two briefs, or one brief with strictly ordered milestones and a check between them.
- **Enumerate ALL verification.** The worker runs what Done-means lists and nothing more. If it matters, list it — including negative checks ("existing suite X still passes", "no new lint errors").
- **Prefer S/M tasks.** Hand out L-size only with low uncertainty; L + high uncertainty is split, or preceded by a timeboxed spike brief whose deliverable is a findings report, not code.

## 3c. Pre-send check — gate your own brief

A brief with hallucinated paths or commands fails at full price. Before sending, verify against the repo:

- Every path in Pointers exists and you read it this session.
- Every Done-means command actually runs here (you ran it, or it is the project's documented command).
- Every interface pasted into Constraints matches the code as of now.
- No field contains "as appropriate", "sensible", or "etc." — those are undecided decisions in disguise.
- The stranger test (§3) passes.

## 4. Parallel fan-out — additional rules

- **Freeze shared interfaces first** — types, signatures, schemas, file ownership — and paste them verbatim into every brief. Changing a frozen interface mid-flight requires recalling every affected agent; treat it as an incident.
- **File isolation**: assign disjoint file sets per agent. If overlap is unavoidable, run each agent in its own worktree (Agent tool: `isolation: "worktree"`).
- **Integration is YOUR task, never delegated**: after the returns, run the merged build + full test suite yourself. Branches that pass in isolation can still conflict semantically.

## 5. Report format (embed in every brief)

```markdown
## RESULT: DONE | BLOCKED | DEVIATED
## Changes: <file → one line each>
## Evidence: <each done-criterion → command run + actual output>
## Deviations & discoveries: <contract conflicts, bugs found, assumptions made>
## Not done: <anything remaining>
(≤ 40 lines total)
```

Your context pays for every excess line — enforce the cap.

## 6. Transport

- **Claude subagent**: pass the brief as the Agent prompt, pinning the executor model explicitly (e.g. Agent `model: "sonnet"`); run implementation workers in the background to keep parallel streams moving. The project CLAUDE.md is inherited — do not repeat it in the brief. Keep the worker session addressable where the harness allows: bounces go back to the SAME worker (see `accept-work`).
- **Codex / external agent**: the brief must be fully self-contained, and `AGENTS.md` (see AGENTS.template.md) must exist at the repo root — external agents do not read CLAUDE.md. Invoke non-interactively (e.g. `codex exec "<brief>"` — verify the exact CLI form of the local install) and capture the output. No context is shared with you; the brief and AGENTS.md carry everything.
