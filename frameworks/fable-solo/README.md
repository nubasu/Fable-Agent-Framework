# fable-solo

English | [日本語](README.ja.md)

A **single-file** context framework that lifts a **solo Opus 4.8 session** to Fable 5-grade work. No team, no skills directory. Just place `CLAUDE.template.md` in the project root as `CLAUDE.md` and it works.

## vs. fable-lift (both uplift a single agent)

| | fable-lift | fable-solo |
|---|---|---|
| Structure | Two layers (resident core ~1.2K + 5 skills loaded on demand) | One sheet (~3K resident; protocols §P1–P5 inlined) |
| Target | Opus / Sonnet, general-purpose | **Opus-only** tuning |
| Skill-trigger risk | Present (a protocol that isn't invoked does nothing) | **Zero** (always in context) |
| Install | Copy CLAUDE.md + .claude/skills/ | Copy one file |
| Best for | Environments that also run Sonnet; minimal residency | Solo Opus operation; certainty first; simplicity first |

Rule of thumb: if Sonnet gets the same discipline, use lift (3K resident is heavy for Sonnet's attention budget). **Opus alone: use solo** — Opus digests the 3K residency fine, and closing the skill-misfire hole in the protocol is worth more.

## The idea — target the Opus→Fable "residual gap" directly

Unlike the Sonnet→Fable gap (missing basic discipline), Opus 4.8's residual gap shows up in the quality of behavior. This file names and targets five:

1. **Premature convergence** — anchoring on the first plausible hypothesis or design. → Default decision behavior: "produce 2–3 materially different candidates before evaluating any" (§How to spend intelligence #1).
2. **Eloquence bias** — believing elaborate reasoning because it is elaborate. → "**Evidence outranks eloquence**": premises verified against the repository, conclusions verified by execution; until both ends connect, reasoning is hypothesis (#2).
3. **Shallow verification** — running the immediate checks but missing second-order impact (callers, state, concurrency). → Blast radius and an adversarial re-read pinned into the finish gate (§P3 C/D).
4. **Long-horizon drift** — hour-three quality decay, endgame "probably fine". → "**Finish at full strength**" + §P4's external state (#5).
5. **Taste (overengineering)** — pre-emptive abstraction, defensive complexity. → §Taste: "a new abstraction without two callers today is a defect", "a clever solution that doesn't match the codebase's altitude is a wrong answer".

One more solo-specific device: with no reviewer's fresh eyes available, the order is fixed to **run finish-gate's Gate B (build & tests) first, then re-read the diff**, inserting a time gap between "the you who just wrote it" and "the you re-reading it" (§P3 C — self-supplied fresh eyes).

## Structure

```
fable-solo/
├── CLAUDE.template.md   ← the whole framework (~3K resident tokens). Rename to CLAUDE.md at the destination
└── README.md            ← this file (for humans; Japanese version: README.ja.md)
```

Skeleton of the contents: 5 non-negotiables (the family-wide constants) → How to spend intelligence (Opus-specific) → the work loop → §P1 deep plan / §P2 root-cause debug / §P3 finish gate / §P4 long-task state / §P5 test protocol (condensed inline versions of lift's five skills) → Taste → trigger table.

## Installation

<details>
<summary>Windows (PowerShell)</summary>

```powershell
$storage = "C:\path\to\Fable-Agent-Framework\frameworks\fable-solo"   # ← adjust to where you put this repo
$proj    = "C:\path\to\project"

Copy-Item "$storage\CLAUDE.template.md" "$proj\CLAUDE.md"
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
storage="/path/to/Fable-Agent-Framework/frameworks/fable-solo"   # ← adjust to where you put this repo
proj="/path/to/project"

cp "$storage/CLAUDE.template.md" "$proj/CLAUDE.md"
```

</details>

Then run `/init` in the new project and merge the output into **Project specifics** at the end (keep the framework part).

## Place in the family

- **fable-solo** — solo session, one sheet, full depth (this framework)
- **fable-lift** — two-layer single-agent uplift (Opus/Sonnet, general-purpose)
- **fable-team** — distilled one-sheet for mixed teams (PL + workers) (AGENTS.md)
- **fable-blueprint / fable-orchestrate** — upstream work / delegation & acceptance (combined with solo/lift when running a team)

The natural growth path: start with solo, and when it's time to add workers (Sonnet/Codex), move to team or orchestrate.

## Honest limits

- ~3K resident tokens is a per-session cost. If your work is mostly small tasks, lift's two layers are lighter.
- Raw reasoning and knowledge don't change (family-wide). What this file changes is *what happens between the steps*.
- Text discipline is strong steering, not enforcement (family-wide).

## Growing it

- Family-wide: **add from recurring failures, delete rules that never fire.**
- solo-specific accumulation points: §Taste (overengineering patterns that actually appeared in your codebase) and §P3 C's hunt list (bug classes you actually missed).
