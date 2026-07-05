# pseudo-fable-team

English | [日本語](README.ja.md)

A "team constitution" template that runs a mixed team — Opus 4.8 (PL role) + Sonnet 5 / Codex (worker role) — at Fable 5-grade discipline off **a single AGENTS.md**.

It condenses distilled versions of the pseudo-fable trilogy (blueprint / orchestrate / lift) into one file with **built-in role dispatch**. Everyone reads the same sheet and follows only their own role's section.

## When to use it

1. **One sheet across vendors** — AGENTS.md is the standard file Codex reads. Claude reads the same sheet via an `@AGENTS.md` line in CLAUDE.md. Eliminates double-maintained discipline (CLAUDE.md and AGENTS.md drifting apart).
2. **Lightweight start** — begin with one sheet before installing the full family (3 resident cores + 9 skills).
3. **Explicitly assigned PL/worker division** — the Opus = PL, Sonnet/Codex = worker split this file assumes (written into §1 as the standard assignment).

## How it works — role dispatch (§1)

Role determination is mechanical, so even weaker models can't get lost:

- The prompt contains a `# TASK` brief → **Worker** (follow §4)
- You receive raw requirements from the user and can direct other agents → **PL** (follow §3)
- Neither (a solo session) → treat the user's request as the Contract and operate under Worker discipline
- An explicit `Role:` line overrides everything

The header also prescribes the reading order — everyone reads §1–2 → your own role's section → §5 (shared formats) only — to protect the workers' (Sonnet-class) attention budget. The interface between roles is pinned to §5's 9-field brief / 5-field report (same format as pseudo-fable-orchestrate).

## Section highlights

- **§2 Five non-negotiables for every role** — no reporting unobserved success / no fabricating facts / no retrying without a hypothesis / the code is the final arbiter (stop and report contradictions instead of silently working around them) / blend into the existing code
- **§3 PL** — testable contracts from requirements and one batched question round (distilled blueprint) / freeze interfaces → parallelize, routing table, mandatory briefs (distilled orchestrate) / "a report is a claim, not a fact" acceptance: ACCEPT/PATCH/BOUNCE (max 2)/RECLAIM / after every bounce, "which sentence was missing"
- **§4 Worker** — the Contract is absolute, Non-goals are absolute / **Stop over improvise** (contract-vs-code contradictions and dead ends are reported BLOCKED immediately; silent deviation is the one unforgivable failure) / execution evidence and an adversarial diff re-read before declaring DONE (distilled lift)
- **§5 Shared formats** — the brief and report templates. This is the contract between roles, so changes here affect everyone

## Relation to the full family

- This file is the **distilled version**. Deep protocols (root-cause-debug's hypothesis journal, design-doc's ADRs and failure-mode analysis, the traceability matrix, etc.) are not included. Where skills are installed, **the skills are the deep-dive side and this file is the constant side** (the division is stated in the file's header comment too). For serious upstream work from a full spec, combine with blueprint.
- A **superset** of the worker-only minimal `AGENTS.template.md` bundled with pseudo-fable-orchestrate. Since the repo root can hold only one AGENTS.md: run a mixed team off one sheet → this file / the lead context lives entirely in CLAUDE.md and you only want ground rules for external workers (Codex) → orchestrate's minimal version.
- For **solo Opus** with no team, even among the single-file options, `frameworks/pseudo-fable-solo/` (a solo full-depth CLAUDE.md) fits better than this file. This file's distillation assumes role division.

## Installation

<details>
<summary>Windows (PowerShell)</summary>

```powershell
$storage = "C:\path\to\Pseudo-Fable-Agent-Framework\frameworks\pseudo-fable-team"   # ← adjust to where you put this repo
$proj    = "C:\path\to\project"

Copy-Item "$storage\AGENTS.template.md" "$proj\AGENTS.md"
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
storage="/path/to/Pseudo-Fable-Agent-Framework/frameworks/pseudo-fable-team"   # ← adjust to where you put this repo
proj="/path/to/project"

cp "$storage/AGENTS.template.md" "$proj/AGENTS.md"
```

</details>

Then:

1. **Claude Code bridge**: add a single `@AGENTS.md` line near the top of the project's CLAUDE.md (unnecessary if your installed version reads AGENTS.md natively — verify the actual behavior).
2. Fill in **§6 Project specifics** at the end (if duplicated on the CLAUDE.md side, keep them in sync).
3. **Codex**: reads the repo-root AGENTS.md automatically. Check the non-interactive CLI form (`codex exec`, etc.) with your local `codex --help`.

## Honest limits

- It's distilled to fit one sheet, so it lacks the full versions' coverage (cross-model review and pre-mortems appear only in outline).
- Text discipline is strong steering, not enforcement (family-wide). Workers' execution environments (Codex sandboxes especially) can differ from the PL's, so the design requires acceptance re-verification in the PL's environment (§3 Economy).

## Growing it

- Family-wide: **add from recurring failures, delete rules that never fire.**
- Two accumulation points in particular: the Worker's BLOCKED conditions (promote patterns where you actually got silent deviation) and the PL's standing Gotchas list (project-specific traps may also go in §6).
