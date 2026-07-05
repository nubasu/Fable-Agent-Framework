---
name: agent-framework-setup
description: Guided initial installation of the pseudo-fable framework family into a target project — inspect the target first, interview for a configuration, enforce the exclusivity rules, assemble CLAUDE.md / AGENTS.md / skills / hooks in the correct order with idempotent signature checks, then verify with agent-framework-doctor. Use when asked to install, set up, or add the agent framework (the pseudo-fable family, or any of its frameworks/modules) to a new or existing project.
---

# agent-framework-setup — install the family without breaking the target

This skill runs in the Pseudo-Fable-Framework store and writes into a target project. `frameworks/` is the source of truth; the root README carries the same recipes for humans — this skill adds what raw snippets cannot: inspection before writing, merging instead of overwriting, and verification at the end.

## 0. Gather inputs (ask only for what the request didn't say)

- **$storage** — this store's `frameworks/` directory. If the session is not running inside the store (skill installed user-level), ask where the clone lives.
- **$proj** — the target project root. Must exist; warn if it is not a git repo (still installable).
- **Configuration** — if the user named one, take it. Otherwise ask, presenting the bases as one choice and the modules as a multi-select. Recommend lift + orchestrate for PL + worker operation, solo for a single always-Opus session. Token costs live in the store README's configuration table — quote them when asking.

| Base (pick one) | Modules (any, on top of any base) |
|---|---|
| solo — single Opus does everything | retro — session restore + rule growth |
| lift — two-layer execution discipline | incident — production incident response |
| lift + orchestrate — PL + workers (recommended) | harness — hook guardrails |
| lift + orchestrate + blueprint — plus spec-driven upstream | Codex AGENTS.md (requires orchestrate) |
| team — single AGENTS.md, mixed team | |

## 1. Inspect the target BEFORE writing anything

Read what exists: `CLAUDE.md`, `AGENTS.md`, `.claude/skills/`, `.claude/hooks/`, `.claude/settings.json`, `.gitignore`.

Inventory installed pseudo-fable components: every template announces itself with an HTML comment `<!-- pseudo-fable-<name> vX.Y` in its first lines — grep CLAUDE.md and AGENTS.md for `<!-- pseudo-fable-`. Three modes fall out:

- **Fresh** — no pseudo-fable signatures anywhere.
- **Add-on** — some components present; install only the missing part of the selection, never re-append.
- **Conflict** — the selection violates an exclusivity rule against what is installed → stop and put the choice to the user. Never install both sides "to be safe".

Legacy: installs made before the 2026-07-05 rename carry `<!-- fable-<name>` signatures — count them as the same components (treat as installed; never append the pseudo-fable version on top of them).

## 2. Exclusivity rules (hard constraints)

- CLAUDE.md base: **solo XOR lift** — never both.
- solo inlines all protocols → do not install any pseudo-fable skills alongside it.
- One AGENTS.md at the root: **team XOR orchestrate-minimal** (team is the superset).
- Modules (retro / incident / harness) compose with every base, including team.

## 3. Assemble — correct order, idempotent, encoding-safe

What each selection contributes:

| Selection | CLAUDE.md | `.claude/skills/` | Other files |
|---|---|---|---|
| solo | base ← `pseudo-fable-solo/CLAUDE.template.md` | — (inlined) | — |
| lift | base ← `pseudo-fable-lift/CLAUDE.template.md` | deep-plan, finish-gate, long-task-state, root-cause-debug, test-protocol | — |
| orchestrate | append `ORCHESTRATE.template.md` | delegate, accept-work | optional Codex `AGENTS.md` ← orchestrate `AGENTS.template.md` |
| blueprint | append `BLUEPRINT.template.md` | spec-interrogate, design-doc, ticketize | — |
| team | bridge line `@AGENTS.md` near the top | — | `AGENTS.md` ← `pseudo-fable-team/AGENTS.template.md` |
| retro | append `RETRO.template.md` | retro, session-bootstrap | — |
| incident | append `INCIDENT.template.md` | incident-response, postmortem | — |
| harness | append `HARNESS.template.md` | — | `.claude/hooks/` (4 script twins, `.sh`+`.ps1`) + hooks block in `.claude/settings.json` |

Rules:

- **Append order**: base (solo/lift) → orchestrate → blueprint → retro → incident → harness. Verbatim concatenation — no headers or commentary of your own.
- **Idempotency**: before appending a component, grep the target file for its `<!-- pseudo-fable-<name>` signature; if present, skip it and say so in the report. Upgrading an older installed version in place is manual work, not this skill's.
- **Existing CLAUDE.md** (fresh install over a real project): the pseudo-fable base becomes the file; the previous content moves under its `## Project specifics` section. Keep the original as `CLAUDE.md.bak` until agent-framework-doctor passes, then delete it.
- **Assemble markdown with Read + Write file tools**, not shell redirection — Windows PowerShell 5.1 defaults to UTF-16/BOM and mojibakes the templates.
- **Copy skills and hooks with recursive copy commands** (`cp -R` / `Copy-Item -Recurse`), store → target only. Never edit files under `frameworks/` during an install; template improvements go through the normal contribution flow afterwards.
- `.sh` hook scripts must keep LF endings — copy them, don't rewrite them.
- No store paths inside any target file — the installed project must not depend on where this repo lives.

## 4. Module specifics

- **harness** — `settings.json` absent → copy `settings.hooks.json` whole. Present → merge only its `"hooks"` block into the existing JSON (preserve every other key; re-parse to validate). On Windows without Git Bash use `settings.hooks.powershell.json`; with Git Bash the bash default is correct everywhere. Offer strict verify — `PSEUDO_FABLE_HARNESS_VERIFY_CMD` in the settings `env` block set to the project's real check command — only with explicit consent, since hooks execute it with shell privileges.
- **team** — if the target has no CLAUDE.md, create one holding just the `@AGENTS.md` bridge line; the bridge is unnecessary only where Claude Code reads AGENTS.md natively (tell the user to verify).
- **Codex AGENTS.md / team** — after copying, sync the `Project specifics` section with CLAUDE.md's. CLAUDE.md is the source of truth.

## 5. Finish and verify

1. `.gitignore`: ensure `.claude/state/` is listed (create the file if missing; no duplicate entries).
2. Offer to fill `## Project specifics` now by scanning the target (build / test / lint commands, layout) — the README's `/init` merge, done in place. Sync AGENTS.md if present.
3. Run **agent-framework-doctor** against the target (invoke the skill). Fix what it FAILs, then delete `CLAUDE.md.bak`.
4. If the target is a git repo, offer a single install commit so future local growth stays diffable against the baseline.
5. Report: components installed vs skipped-as-existing (table), files written, resident-token estimate — and the manual steps only the user can do: open a NEW session in the target, check the pseudo-fable skills are listed, for harness run `/hooks` and confirm the four hooks, then run one small task and watch finish-gate (solo: §P3) fire before the completion report.

## Anti-patterns

- Appending without the signature check — the double-appended section is the most common broken install.
- Overwriting an existing CLAUDE.md instead of folding it into Project specifics — that deletes the project's own rules.
- Installing solo and lift together because the request mentioned both — put the exclusivity choice to the user instead.
- Assembling markdown through the shell on Windows — encoding roulette.
- Reporting "installed" without an agent-framework-doctor pass, or without telling the user what static checks cannot prove (hook registration needs a session restart; skills discovery has its own runtime rules).
