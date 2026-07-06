---
name: agent-framework-doctor
description: Static health check for an agent framework (pseudo-fable family) installation in a target project — component inventory by version signature, exclusivity violations, duplicate appends, skills placement and frontmatter mismatches, harness hooks / settings / line-ending checks, version drift against the store. Reports PASS/WARN/FAIL with a one-line fix each, then the manual smoke-test checklist. Use after agent-framework-setup, after a manual install or upgrade, or when an install misbehaves (skills not listed, hooks not firing).
---

# agent-framework-doctor — verify the install, don't trust it

Static checks prove the files are right, not that the session behaves — the manual checklist at the end covers the rest. Report findings first; apply fixes only when asked.

## 0. Locate

**$proj** = the project to examine (ask if not given). **$storage** = this store's `frameworks/` directory, used for drift checks — skip drift gracefully when the store isn't reachable. The store itself is not an install; if pointed at it, say so instead of inventing findings.

## 1. Inventory

Every pseudo-fable component announces itself with an HTML comment `<!-- pseudo-fable-<name> vX.Y` in its first lines. Grep `CLAUDE.md` and `AGENTS.md` for `<!-- pseudo-fable-` → the component list with versions and per-file counts. Also list `.claude/skills/*/SKILL.md`, `.claude/hooks/`, and the `hooks` block of `.claude/settings.json`.

Pre-rename installs (before 2026-07-05) carry `<!-- fable-<name>` signatures and `FABLE_HARNESS_*` env vars — inventory them as the same components; report the old naming under C7 as drift.

## 2. Checks

| # | Check | Verdict when it trips |
|---|---|---|
| C1 | Base exclusivity: exactly one of `pseudo-fable-solo` / `pseudo-fable-lift` in CLAUDE.md. Neither is fine when AGENTS.md carries `pseudo-fable-team` (team-file setup) — otherwise it is a module-only install: legal, but the family's core discipline is absent. | both → FAIL; neither & no team → WARN |
| C2 | No duplicate appends: each signature appears at most once per file. | duplicate → FAIL (delete the extra section) |
| C3 | Skills complete and well-placed: for each installed module its skills exist at `<proj>/.claude/skills/<name>/SKILL.md` with frontmatter `name:` equal to the directory name. Expected sets — lift: deep-plan, finish-gate, long-task-state, root-cause-debug, test-protocol · orchestrate: delegate, accept-work · blueprint: spec-interrogate, design-doc, ticketize · retro: retro, session-bootstrap · incident: incident-response, postmortem · blender: blender-spec, blender-build-loop, blender-topology, blender-materials, blender-light-camera, blender-scene, blender-verify. Extra non-pseudo-fable skills are the project's own business. | missing / mismatched → FAIL |
| C4 | solo base with pseudo-fable skills installed — solo inlines the protocols; the combination breaks the exclusivity rule. | WARN (remove the skills) |
| C5 | AGENTS.md base variant identified: team (`<!-- pseudo-fable-team`) XOR orchestrate-minimal (`<!-- pseudo-fable-orchestrate`). Module addenda appended after the base (currently `<!-- pseudo-fable-blender`) are legal, not a variant conflict — check them under C2/C3. An AGENTS.md holding only addenda (no base) is legal in external-agent-only setups. team without an `@AGENTS.md` bridge line in CLAUDE.md works only where Claude Code reads AGENTS.md natively. | both base signatures → FAIL; missing bridge → WARN; addenda-only → WARN (worker ground rules absent) |
| C6 | Hook wiring (per installed hook layer — harness: 4 script twins / blender pack: 2 script twins): expected scripts in `.claude/hooks/`; `settings.json` parses as JSON; its hook commands point at files that exist and use one variant consistently (bash or PowerShell, not a mix); `.sh` files contain no CR bytes (CRLF breaks bash); `.claude/state/` is gitignored (harness). | broken wiring → FAIL; gitignore missing → WARN |
| C7 | Version drift: installed `vX.Y` older than the store template's → point at the store diff. Do NOT diff section content — installed copies are supposed to grow local rules (that is the family's whole point); only the version header signals template drift. | older → WARN |
| C8 | Finishing steps done: `## Project specifics` is filled (not empty boilerplate), and the AGENTS.md copy of it does not materially diverge from CLAUDE.md's. | WARN (step skipped / sync missed) |

## 3. Report

One table: check · verdict · finding · one-line fix. FAIL = will not work or violates an exclusivity rule; WARN = works but degraded or drifting. Add INFO notes sparingly (e.g. `stop-verify` stays inert until `PSEUDO_FABLE_HARNESS_VERIFY_CMD` is set).

Close with the manual checklist statics cannot cover:

- New session in the target: the pseudo-fable skills appear when asked to "list the available skills".
- Hooks: `/hooks` lists the installed set (harness: 4, blender pack: 2; registration loads at session start — a restart is required after install); a trivial edit (harness) or a marker-less stop after Blender work (blender pack) bounces with the gate instruction, at most twice.
- One small task triggers finish-gate (solo: §P3) before its completion report.

Offer to fix the FAILs; touch nothing until the user says yes.

## Anti-patterns

- "The files look right, so it works" — skills discovery and hook registration both have runtime rules statics cannot see; that is what the manual checklist is for.
- Re-running a full install to fix one finding — re-appending onto a duplicate makes triplicates. Fix the specific finding.
- Flagging locally grown rules as drift — the family wants installs to evolve (retro exists for that). Version headers, not content, define drift.
