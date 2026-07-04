# fable-blueprint

English | [日本語](README.ja.md)

A context framework that gets Opus 4.8 doing Fable 5-grade design, planning, ticketing, and whatever other upstream work a given spec requires.

The third piece of the fable family, covering the top of the pipeline:

```
spec ──▶ fable-blueprint ──▶ fable-orchestrate ──▶ fable-lift
       (design, plan, tickets)  (delegate, accept)    (execution discipline)
```

- **fable-blueprint** — turns specs into tickets (turns what's in your head into documents)
- **fable-orchestrate** — turns tickets into briefs, delegates, and accepts
- **fable-lift** — discipline for the hands doing the work

The ticket format maps 1:1 onto orchestrate's 9-field brief (ticketize §6), so discipline runs through every hop from spec to verified code.

## The idea — lower-tier upstream failures boil down to five things

1. **Taking the spec at face value** — designing without hunting the ambiguities, contradictions, gaps, and unstated non-functionals. **A spec is a claim, not the truth.**
2. **Anchoring on the first idea** — running with the first architecture without comparing alternatives.
3. **Greenfield delusion** — designs that ignore the realities of the existing codebase (conventions, infrastructure, data). **Recon before design.**
4. **Happy-path design** — failure modes, edge cases, migration, and rollback first surface mid-implementation.
5. **Dropping things silently** — requirements vanish without landing in tickets; the "other necessary work" (test strategy, migration, observability, docs) leaks away. → **A mandatory traceability matrix and forgotten-work checklist.**

### Honest label

- **What improves**: requirement drop rate, recorded design decisions (prevents relitigating them downstream), when risks get discovered (at planning instead of integration), ticket executability.
- **What doesn't**: the depth of each individual design judgment (protocol can force breadth of exploration; judgment quality stays model-bound). For the most critical ADRs we recommend a hybrid operation: decide them in a higher-tier (Fable) session.
- Versus fable-lift's `deep-plan`: deep-plan is the lightweight pre-task version for a single task. When starting from a full spec, use this framework.

## Structure

```
fable-blueprint/
├── BLUEPRINT.template.md           ← resident core (~1.0K tokens). Append to the end of the project's CLAUDE.md
└── .claude/skills/                 ← per-phase protocols (loaded only when they fire)
    ├── spec-interrogate/           ← INTAKE: interrogate the spec → testable requirements register, question/assumption triage
    ├── design-doc/                 ← DESIGN: recon → alternative comparison → failure-mode analysis → ADRs → pre-mortem
    └── ticketize/                  ← PLAN: walking skeleton, risk-first ordering, dependency graph, tickets, matrix
```

Design highlights:

- **Phase gates** — INTAKE → DESIGN → PLAN & TICKETS. You don't enter the next phase with a gate still open (blocks "designing before requirements settle" and "ticketing with design decisions unrecorded").
- **Questions batched into one round** — ask only what is "high-impact and hard to change later" (guideline ≤5 questions, each with a recommended default). Everything else goes into an assumption ledger with impact assessments. Prevents both question barrages and silent assumptions.
- **Deliverables are files, not chat** — `docs/plan/<slug>/01-requirements.md / 02-design.md / 03-tickets.md`. Chat evaporates; files can be consumed by downstream agents.
- **Spec changes get delta re-interrogation** — when a change arrives, don't edit the tickets directly; re-apply spec-interrogate to the delta and propagate it through the traceability matrix.

## Installation

For combined installs with other frameworks (the recommended full stack, etc.), see the README.md at the repo root.

<details>
<summary>Windows (PowerShell)</summary>

```powershell
$storage = "C:\path\to\Fable-Agent-Framework\frameworks\fable-blueprint"   # ← adjust to where you put this repo
$proj    = "C:\path\to\project"

# 1. Copy the skills (added under .claude/skills/)
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\.claude\skills\*" "$proj\.claude\skills\"

# 2. Append the resident core to the end of CLAUDE.md
Get-Content "$storage\BLUEPRINT.template.md" -Encoding utf8 | Add-Content "$proj\CLAUDE.md" -Encoding utf8
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
storage="/path/to/Fable-Agent-Framework/frameworks/fable-blueprint"   # ← adjust to where you put this repo
proj="/path/to/project"

mkdir -p "$proj/.claude/skills"
cp -R "$storage/.claude/skills/"* "$proj/.claude/skills/"
cat "$storage/BLUEPRINT.template.md" >> "$proj/CLAUDE.md"
```

</details>

Filing to an external tracker such as GitHub Issues is optional (externally visible, so user confirmation is required; the files remain the source of truth).

## Operating rules (growing it)

- Family-wide: **add rules by working backward from recurring failures; delete rules that never fire.**
- The highest-value accumulation points: spec-interrogate's hunt lenses (add the patterns of holes you actually missed) and design-doc §5's cross-cutting list (add the concerns your domain needs every single time).

## Known limits

- Text-based discipline is strong steering, not enforcement (family-wide).
- When the implementer is an agent, read estimates (size/uncertainty) as proxies for context consumption and round-trip count rather than wall-clock time. Not trusting point estimates is already built into the protocol (ranges + confidence).
