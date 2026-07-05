# pseudo-fable-lift

English | [日本語](README.ja.md)

A context framework that lifts Opus 4.8 / Sonnet 5 toward Fable 5-grade *ways of working*.

## The idea

The practical performance gap between model tiers is not just raw reasoning — much of it shows up as a gap in **work discipline**:

- Reporting "done" without verifying (claiming unexecuted code works)
- Retrying the same thing on error without a hypothesis / stacking patches on top of a failed fix
- Calling APIs that don't exist; fabricating numbers and paths from memory
- Forgetting decisions made early in a long task and contradicting itself
- Doing 2 of the 3 requested items and calling it complete
- Going along with the user's incorrect diagnosis

Higher-tier models avoid these as **implicit habits**. pseudo-fable-lift closes the gap by writing those habits down and imposing them on lower-tier models as **protocols with trigger conditions**.

### Honest label

- **What improves**: verification discipline, report accuracy, systematic debugging, scope control, long-task consistency — the areas that account for most real-world agent failures.
- **What doesn't**: raw reasoning and knowledge. Novel algorithm design and subtle architectural trade-offs still favor the higher tier. Make the important decisions on a higher-tier model (see hybrid operation below).

## Structure — two-layer architecture

Resident tokens compete with task context, so the always-loaded part is minimized in a two-layer design.

```
pseudo-fable-lift/
├── CLAUDE.template.md              ← resident core (~1.2K tokens). Place as CLAUDE.md in the project root
└── .claude/skills/                 ← on-demand protocols (loaded only when they fire, ~700 tokens each)
    ├── deep-plan/                  ← pre-work design: contract, alternative comparison, pre-mortem
    ├── root-cause-debug/           ← root-cause debugging: hypothesis journal, discriminating experiments
    ├── finish-gate/                ← completion gate: mandatory checks before saying "done" (most important)
    ├── long-task-state/            ← external working memory: survives compaction & session breaks
    └── test-protocol/              ← test quality: fail-first, minimal mocking, mandatory boundary & error paths (v1.1)
```

- The **core** is designed to work on its own (behavior improves even if no skill fires).
- **Skills** are triggered explicitly by the trigger-condition table inside the core. Lower-tier models are weak at spontaneous skill selection, so the conditions are mechanical ("3+ files → deep-plan", "right before declaring completion → finish-gate").

## Installation (new project)

For combined installs with other frameworks (the recommended full stack, etc.), see the README.md at the repo root.

<details>
<summary>Windows (PowerShell)</summary>

```powershell
$storage = "C:\path\to\Pseudo-Fable-Framework\frameworks\pseudo-fable-lift"   # ← adjust to where you put this repo
$proj    = "C:\path\to\new-project"

Copy-Item "$storage\CLAUDE.template.md" "$proj\CLAUDE.md"
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\.claude\skills\*" "$proj\.claude\skills\"
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
storage="/path/to/Pseudo-Fable-Framework/frameworks/pseudo-fable-lift"   # ← adjust to where you put this repo
proj="/path/to/new-project"

cp "$storage/CLAUDE.template.md" "$proj/CLAUDE.md"
mkdir -p "$proj/.claude/skills"
cp -R "$storage/.claude/skills/"* "$proj/.claude/skills/"
```

</details>

Then, in the new project:

1. Run `/init` and merge the generated content into the **Project specifics** section at the end of `CLAUDE.md` (keep the framework part).
2. For an existing project, **append** the core to the existing CLAUDE.md and copy `.claude/skills/` over.

## Per-model tuning

- **Sonnet 5**: small instruction-following attention budget. Don't pile project-specific rules on top of the core (keep Project specifics to a list of commands and entry points). The larger the total rule count, the lower the per-rule compliance.
- **Opus 4.8**: more tolerant of added rules. Raising extended thinking / effort settings amplifies deep-plan and root-cause-debug.
- **Hybrid operation (recommended)**: make design decisions (deep-plan's alternative comparison) in a Fable/higher-tier session, write the plan into a `long-task-state` state file, and run implementation on Sonnet with this framework installed. The higher tier guarantees plan quality; this framework guarantees execution discipline.

## Operating rules (growing the framework itself)

- **Add rules by working backward from failures.** Only add a rule for a failure pattern that actually recurred. One rule = resident cost. Don't add speculative "good habits".
- **Delete rules that never fire.** A rule that hasn't changed behavior across several projects is pure cost.
- Update the version comment (file header) and leave a one-line reason for the change.

## Why the contents are in English

Model-facing files (core & skills) are in English for token efficiency and instruction-following accuracy. The core includes a "follow the user's language" rule, so conversation quality in Japanese is unaffected. READMEs are for humans and come in both English (this file) and Japanese ([README.ja.md](README.ja.md)).

## Related frameworks

- `frameworks/pseudo-fable-orchestrate/` — the sister framework: this one covers the discipline of *moving your own hands*; orchestrate covers directing and accepting work from subagents (Sonnet 5 / Codex). Recommended together in lead sessions.
- `frameworks/pseudo-fable-blueprint/` — the upstream framework that turns a spec into design, plan, and tickets. This framework's `deep-plan` is the lightweight single-task version; when working from a full spec, use blueprint.
- `frameworks/pseudo-fable-team/` — a team constitution condensing distilled versions of the family trilogy into one role-dispatching sheet (AGENTS.md). For a lightweight start before full installation, or for unifying across vendors including Codex.
- `frameworks/pseudo-fable-solo/` — a single-file, solo-Opus-only version with this framework's skills inlined (~3K resident, zero trigger risk). If Sonnet also runs, use this framework; Opus alone, use solo.
- `frameworks/pseudo-fable-retro/` — the ongoing-operations module for cross-session restore and rule cultivation. This framework's `long-task-state` defines the state file *format*; retro's `session-bootstrap` defines the session start/end *ritual* that reads and writes it. Recommended together.

## Known limits and future extensions

- Text-based discipline is strong steering, not enforcement. Mechanical enforcement (e.g., a Stop hook that blocks completion when finish-gate wasn't run) is available as the optional `frameworks/pseudo-fable-harness/` module — kept separate because hook scripts introduce OS dependence.
- Compliance can degrade after compaction. On long tasks, the long-task-state file is the practical insurance.
