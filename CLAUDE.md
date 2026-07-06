# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose of this folder

A store of files that define agent behavior when standing up a new project. It is not a place for application source code; it holds templates and blueprints for agent configuration files.

Examples of what lives here:

- CLAUDE.md templates to distribute to new projects
- Blueprints for `.claude/` configuration (agents, skills, settings.json, hooks, etc.)

## Included templates

- `frameworks/pseudo-fable-lift/` — a context framework that brings Opus 4.8 / Sonnet 5 close to Fable 5-grade work discipline. Two layers: a resident core (`CLAUDE.template.md`, renamed to `CLAUDE.md` at the destination) + 5 on-demand skills (deep-plan / root-cause-debug / finish-gate / long-task-state / test-protocol). See that directory's README.md for installation and design rationale.
- `frameworks/pseudo-fable-orchestrate/` — a delegation-discipline framework that lifts Opus 4.8 as the lead: briefing and accepting work from subagents (Sonnet 5 / Codex) at Fable 5 grade. Sister of pseudo-fable-lift (lift = your own hands, orchestrate = the hands you direct). Lead core (`ORCHESTRATE.template.md`, appended to CLAUDE.md) + 2 skills (delegate / accept-work) + `AGENTS.template.md` for external agents such as Codex. v1.2 added Delegation-first (implementation is delegated by default; implement yourself only when all four hold — no design decisions, no deep dive, nobody waiting, low risk — and when in doubt, delegate), Sonnet-class brief tuning (delegate §3b), and the pre-send check (§3c). See that directory's README.md.
- `frameworks/pseudo-fable-blueprint/` — an upstream framework that lifts design, planning, and ticketing for a given spec to Fable 5 grade. Phase-gated (INTAKE → DESIGN → PLAN & TICKETS). Resident core (`BLUEPRINT.template.md`, appended to CLAUDE.md) + 3 skills (spec-interrogate / design-doc / ticketize). Tickets map 1:1 to pseudo-fable-orchestrate briefs. See that directory's README.md.

- `frameworks/pseudo-fable-team/` — a "team constitution" for mixed teams of Opus 4.8 (PL role) + Sonnet 5 / Codex (worker role). Condenses distilled versions of the family trilogy into a single `AGENTS.template.md` with built-in role dispatch (placed at the repo root as AGENTS.md; on the Claude side, put `@AGENTS.md` in CLAUDE.md). A superset of the worker-only minimal AGENTS.template.md bundled with orchestrate. See that directory's README.md.

- `frameworks/pseudo-fable-solo/` — a one-file CLAUDE.md that lifts a solo Opus 4.8 session to Fable 5 grade. Inlines lift's five skills (§P1–P5, zero trigger risk) and targets the Opus→Fable residual gap (premature convergence, eloquence bias, verification depth, long-horizon drift, taste) with dedicated sections. ~3K resident tokens. See that directory's README.md.
- `frameworks/pseudo-fable-retro/` — the ongoing-operations module (addable to any configuration). Two skills — a cross-session restore ritual (session-bootstrap: OPEN/CLOSE) and a retrospective that grows rules from failures (retro: harvest → missing sentence → placement table → inventory) — plus resident triggers (`RETRO.template.md`, appended to CLAUDE.md). Turns "add from recurring failures, delete rules that never fire" from advice into protocol. See that directory's README.md.
- `frameworks/pseudo-fable-incident/` — the incident-response module (addable to any configuration). Two skills — a live protocol for production impact (incident-response: strict mitigate-before-diagnose ordering, evidence preservation, timeline, monitoring window) and a blameless postmortem (postmortem: three durations, three-lens action items) — plus a resident core (`INCIDENT.template.md`, appended to CLAUDE.md). See that directory's README.md.
- `frameworks/pseudo-fable-harness/` — the enforcement module (addable to any configuration). Claude Code hooks that turn the family's text discipline into mechanical guardrails: a Stop hook that blocks completion without a finish-gate marker, a PostToolUse nudge to run accept-work after every subagent return, a SessionStart hook that injects `.claude/state/` into context (with a stale warning), and an opt-in strict-verify Stop hook (`PSEUDO_FABLE_HARNESS_VERIFY_CMD`) that runs the project's real check command and blocks on failure. Hook scripts as .sh/.ps1 twins (ASCII-only, zero dependencies) + a settings hooks block + a small CLAUDE.md addendum (`HARNESS.template.md`, the marker contract). `PSEUDO_FABLE_HARNESS_DISABLE` silences hooks at runtime. v1.1 added strict verify, the kill switch, and the stale-state warning. See that directory's README.md.
- `frameworks/pseudo-fable-blender/` — the Blender 3D-modeling **domain pack** (the family's first; a third category besides bases and modules — deep, quality-first, addable to any configuration or standalone in a Blender-only repo). Injects Fable-grade modeling discipline into agents driving Blender via bpy scripts (headless CLI) or a Blender MCP. Correctness floor: the render and the mesh data are the only sources of truth ("never trust an unseen model"), proportions before details (blockout with a hard silhouette gate), the scene as a codebase (real scale, semantic names, idempotent rebuilds), bpy as a hostile API (version probe, by-name references, data API over ops). Quality ceiling: tiers draft/production/hero (hero default), blockout variant exploration, a six-axis anchored rubric scored with evidence at every gate, and the excellence loop ("spec-pass is not done") that re-critiques renders in rotating senior-artist personas until only cosmetic findings remain. Resident core (`BLENDER.template.md`, ~1.8K, appended to CLAUDE.md) + 7 skills (blender-spec / blender-build-loop / blender-topology / blender-materials / blender-light-camera / blender-scene / blender-verify, the last shipping an idempotent probe armory: 4-view rig, clay, wireframe, turntable, close-ups, data probes) + an `AGENTS.template.md` addendum appended to AGENTS.md for external agents (Codex etc. — all seven protocols condensed inline, not a third AGENTS.md variant) + an optional hook layer (2 hook twins + settings block, harness-style: `stop-blender-qa` bounces stops that did Blender work but lack the `[blender-qa: pass|n/a]` marker, `posttool-blender-probe` nudges "read the renders" after headless runs; kill switch `PSEUDO_FABLE_BLENDER_DISABLE`; coexists with pseudo-fable-harness by merging hooks blocks). See that directory's README.md.

Family pipeline: spec → pseudo-fable-blueprint (design, plan, tickets) → pseudo-fable-orchestrate (delegation, acceptance) → pseudo-fable-lift (execution discipline). The one-sheet options are pseudo-fable-team (mixed-team distillation) and pseudo-fable-solo (solo Opus, full depth). pseudo-fable-retro (session restore & rule cultivation), pseudo-fable-incident (incident response), and pseudo-fable-harness (hook-based mechanical guardrails) can each be added to any configuration, as can the pseudo-fable-blender domain pack (Blender 3D modeling, quality-first).

Installation for new projects (choosing a configuration, exclusivity rules, PowerShell/bash commands, common finishing steps) is covered in the README.md at the repo root.

## Store-local skills (tooling, not templates)

Repo-root `.claude/skills/` holds the store's own tooling — skills that run in a session opened in THIS repo and operate on an external target project:

- `agent-framework-setup` — guided installer: configuration interview, exclusivity enforcement, ordered idempotent assembly (components are detected via their `<!-- pseudo-fable-<name> vX.Y` header comments), then an agent-framework-doctor pass.
- `agent-framework-doctor` — static health check of an installed configuration: signature inventory, duplicate appends, skills placement, harness wiring, version drift against the store.

These are not templates — never copy them into target projects. Keep their component/skill tables in step with the frameworks they describe (adding a framework or renaming a skill means updating both SKILL.md files), and keep them free of personal paths like everything else here.

## Working notes

- Not a code project: there are no build, lint, or test commands.
- Files here are templates meant to be copied into new projects. Do not write project-specific content into them (absolute paths, hard-coded project names, etc.).
- This repository is published on GitHub. Do not write personal-environment information (absolute paths containing usernames, email addresses, etc.) into any file. Use placeholder paths in instructions (`C:\path\to\...` on Windows, `/path/to/...` on macOS/Linux).
- READMEs are bilingual: `README.md` (English) is the primary, and each has a Japanese mirror `README.ja.md`. When changing one, update the other to match.
- The family was renamed `fable-*` → `pseudo-fable-*` on 2026-07-05 (all template versions bumped). Installs made before then carry `<!-- fable-<name>` signatures and `FABLE_HARNESS_*` env vars; the store skills treat those as the same components. "Fable 5" in prose refers to the model as a quality benchmark and is intentionally not renamed.
