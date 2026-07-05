---
name: agent-framework-doctor
description: Static health check for an agent framework (fable family) installation in a target project — component inventory by version signature, exclusivity violations, duplicate appends, skills placement and frontmatter mismatches, harness hooks / settings / line-ending checks, version drift against the store. Reports PASS/WARN/FAIL with a one-line fix each, then the manual smoke-test checklist. Use after agent-framework-setup, after a manual install or upgrade, or when an install misbehaves (skills not listed, hooks not firing).
---

# agent-framework-doctor — verify the install, don't trust it

Static checks prove the files are right, not that the session behaves — the manual checklist at the end covers the rest. Report findings first; apply fixes only when asked.

## 0. Locate

**$proj** = the project to examine (ask if not given). **$storage** = this store's `frameworks/` directory, used for drift checks — skip drift gracefully when the store isn't reachable. The store itself is not an install; if pointed at it, say so instead of inventing findings.

## 1. Inventory

Every fable component announces itself with an HTML comment `<!-- fable-<name> vX.Y` in its first lines. Grep `CLAUDE.md` and `AGENTS.md` for `<!-- fable-` → the component list with versions and per-file counts. Also list `.claude/skills/*/SKILL.md`, `.claude/hooks/`, and the `hooks` block of `.claude/settings.json`.

## 2. Checks

| # | Check | Verdict when it trips |
|---|---|---|
| C1 | Base exclusivity: exactly one of `fable-solo` / `fable-lift` in CLAUDE.md. Neither is fine when AGENTS.md carries `fable-team` (team-file setup) — otherwise it is a module-only install: legal, but the family's core discipline is absent. | both → FAIL; neither & no team → WARN |
| C2 | No duplicate appends: each signature appears at most once per file. | duplicate → FAIL (delete the extra section) |
| C3 | Skills complete and well-placed: for each installed module its skills exist at `<proj>/.claude/skills/<name>/SKILL.md` with frontmatter `name:` equal to the directory name. Expected sets — lift: deep-plan, finish-gate, long-task-state, root-cause-debug, test-protocol · orchestrate: delegate, accept-work · blueprint: spec-interrogate, design-doc, ticketize · retro: retro, session-bootstrap · incident: incident-response, postmortem. Extra non-fable skills are the project's own business. | missing / mismatched → FAIL |
| C4 | solo base with fable skills installed — solo inlines the protocols; the combination breaks the exclusivity rule. | WARN (remove the skills) |
| C5 | AGENTS.md variant identified: team (`<!-- fable-team`) XOR orchestrate-minimal (`<!-- fable-orchestrate`). team without an `@AGENTS.md` bridge line in CLAUDE.md works only where Claude Code reads AGENTS.md natively. | both signatures → FAIL; missing bridge → WARN |
| C6 | Harness wiring: 4 script twins (8 files) in `.claude/hooks/`; `settings.json` parses as JSON; its hook commands point at files that exist and use one variant consistently (bash or PowerShell, not a mix); `.sh` files contain no CR bytes (CRLF breaks bash); `.claude/state/` is gitignored. | broken wiring → FAIL; gitignore missing → WARN |
| C7 | Version drift: installed `vX.Y` older than the store template's → point at the store diff. Do NOT diff section content — installed copies are supposed to grow local rules (that is the family's whole point); only the version header signals template drift. | older → WARN |
| C8 | Finishing steps done: `## Project specifics` is filled (not empty boilerplate), and the AGENTS.md copy of it does not materially diverge from CLAUDE.md's. | WARN (step skipped / sync missed) |

## 3. Report

One table: check · verdict · finding · one-line fix. FAIL = will not work or violates an exclusivity rule; WARN = works but degraded or drifting. Add INFO notes sparingly (e.g. `stop-verify` stays inert until `FABLE_HARNESS_VERIFY_CMD` is set).

Close with the manual checklist statics cannot cover:

- New session in the target: the fable skills appear when asked to "list the available skills".
- Harness: `/hooks` lists the four hooks (registration loads at session start — a restart is required after install); a trivial edit followed by ending the turn bounces exactly once with the gate instruction.
- One small task triggers finish-gate (solo: §P3) before its completion report.

Offer to fix the FAILs; touch nothing until the user says yes.

## Anti-patterns

- "The files look right, so it works" — skills discovery and hook registration both have runtime rules statics cannot see; that is what the manual checklist is for.
- Re-running a full install to fix one finding — re-appending onto a duplicate makes triplicates. Fix the specific finding.
- Flagging locally grown rules as drift — the family wants installs to evolve (retro exists for that). Version headers, not content, define drift.
