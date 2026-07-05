# Pseudo-Fable-Agent-Framework — pseudo-fable framework installation guide

English | [日本語](README.ja.md)

Recipes for installing the pseudo-fable family — a set of context frameworks for agent work discipline — into a new project. For each framework's design rationale and details, see the README.md in its directory.

## Included frameworks

| Framework | Role | Form |
|---|---|---|
| `pseudo-fable-solo` | Execution discipline for a solo Opus session (full version with protocols inlined) | Single CLAUDE.md |
| `pseudo-fable-lift` | Two-layer execution discipline. General-purpose for Opus/Sonnet; **also used to uplift workers** | CLAUDE.md core + 5 skills |
| `pseudo-fable-orchestrate` | Delegation & acceptance discipline for the PL (Opus); delegation-first | CLAUDE.md append + 2 skills + minimal AGENTS.md for Codex |
| `pseudo-fable-blueprint` | Upstream discipline: spec → design → plan → tickets | CLAUDE.md append + 3 skills |
| `pseudo-fable-team` | Distilled single file for a mixed PL + worker team (built-in role dispatch) | Single AGENTS.md |
| `pseudo-fable-retro` | Ongoing operations: cross-session restore (session-bootstrap) + rule cultivation (retro) | CLAUDE.md append + 2 skills |
| `pseudo-fable-incident` | Incident response: mitigate-first live protocol (incident-response) + blameless postmortem (postmortem) | CLAUDE.md append + 2 skills |
| `pseudo-fable-harness` | Mechanical guardrails via hooks: finish-gate stop-block, accept-work nudge, state auto-injection, opt-in strict verify | hook scripts (.sh/.ps1) + settings hooks block + CLAUDE.md append |

## Pick a configuration first

| Mode of operation | What to install | Approx. resident tokens |
|---|---|---|
| Solo Opus does everything | pseudo-fable-solo | ~3K |
| Solo, lightweight two-layer (Sonnet runs too) | pseudo-fable-lift | ~1.2K + skills on demand |
| **Opus = PL, Sonnet = implementation (recommended full stack)** | pseudo-fable-lift + pseudo-fable-orchestrate | ~2.1K |
| …plus spec-driven upstream work | + pseudo-fable-blueprint | ~3.1K |
| …plus Codex workers | + AGENTS.md (minimal version bundled with orchestrate) | same |
| Try a single file first (mixed team) | pseudo-fable-team | ~1.5K |
| + ongoing operations (session restore & rule cultivation; add to any setup) | + pseudo-fable-retro | +~0.3K |
| + incident response (if you operate production; add to any setup) | + pseudo-fable-incident | +~0.5K |
| + mechanical guardrails (hooks; add to any setup) | + pseudo-fable-harness | +~0.25K |

**Exclusivity rules (no duplicate installs):**

- The CLAUDE.md base is **either solo or lift, never both**. solo needs no skills (they are already inlined), so don't combine it with the skills either.
- Only one AGENTS.md at the repo root: **either the team version or the orchestrate minimal version** (the team version is a superset of the minimal one).

**Growth path:** start with solo (or team) → move to lift + orchestrate when you start running workers → add blueprint when larger feature development begins. pseudo-fable-retro is small and compatible with every setup, so multi-session operations can include it from day one. Add pseudo-fable-incident once you operate production.

## Installation

Clone this repo anywhere (or unzip a download). Two ways in: let the store's own skills drive the install, or run the manual snippets.

### Skill-assisted install

The store ships two skills of its own (repo-root `.claude/skills/` — tooling for this repo, not templates to copy out). Open Claude Code at the root of this repo and ask in plain words:

- **`agent-framework-setup`** — e.g. *"set up the agent framework in /path/to/new-project"*. Interviews you for a configuration, enforces the exclusivity rules, assembles CLAUDE.md / AGENTS.md / skills / hooks in the correct order, folds an existing CLAUDE.md into Project specifics instead of overwriting it, skips components that are already installed (safe to re-run), and finishes with an agent-framework-doctor check.
- **`agent-framework-doctor`** — e.g. *"check the agent framework install in /path/to/project"*. Static health check of any install, fresh or aged: exclusivity violations, duplicate appends, misplaced skills, harness wiring, version drift against the store. Useful after manual installs and upgrades too.

### Manual install

Set the shared variables to match your environment (used by every snippet below). Each snippet comes in two collapsed variants — expand the one for your OS.

<details>
<summary>Windows (PowerShell)</summary>

```powershell
$storage = "C:\path\to\Pseudo-Fable-Agent-Framework\frameworks"   # ← where you put this repo
$proj    = "C:\path\to\new-project"                        # ← the target project
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
storage="/path/to/Pseudo-Fable-Agent-Framework/frameworks"   # ← where you put this repo
proj="/path/to/new-project"                           # ← the target project
```

</details>

### A. Solo Opus (shortest path)

<details>
<summary>Windows (PowerShell)</summary>

```powershell
Copy-Item "$storage\pseudo-fable-solo\CLAUDE.template.md" "$proj\CLAUDE.md"
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
cp "$storage/pseudo-fable-solo/CLAUDE.template.md" "$proj/CLAUDE.md"
```

</details>

### B. Recommended full stack (Opus = PL, Sonnet = implementation)

<details>
<summary>Windows (PowerShell)</summary>

```powershell
# 1) Assemble CLAUDE.md (base = lift, append orchestrate)
Copy-Item "$storage\pseudo-fable-lift\CLAUDE.template.md" "$proj\CLAUDE.md"
Get-Content "$storage\pseudo-fable-orchestrate\ORCHESTRATE.template.md" -Encoding utf8 |
  Add-Content "$proj\CLAUDE.md" -Encoding utf8

# 2) Copy all the skills together (7 total)
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\pseudo-fable-lift\.claude\skills\*"        "$proj\.claude\skills\"
Copy-Item -Recurse -Force "$storage\pseudo-fable-orchestrate\.claude\skills\*" "$proj\.claude\skills\"
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
cp "$storage/pseudo-fable-lift/CLAUDE.template.md" "$proj/CLAUDE.md"
cat "$storage/pseudo-fable-orchestrate/ORCHESTRATE.template.md" >> "$proj/CLAUDE.md"

mkdir -p "$proj/.claude/skills"
cp -R "$storage/pseudo-fable-lift/.claude/skills/"*        "$proj/.claude/skills/"
cp -R "$storage/pseudo-fable-orchestrate/.claude/skills/"* "$proj/.claude/skills/"
```

</details>

Sonnet workers (Claude subagents) inherit the project's CLAUDE.md, so the lift part becomes the workers' execution discipline as-is (PL brief quality multiplied by worker execution discipline).

### C. Add spec-driven upstream work (on top of B)

<details>
<summary>Windows (PowerShell)</summary>

```powershell
Get-Content "$storage\pseudo-fable-blueprint\BLUEPRINT.template.md" -Encoding utf8 |
  Add-Content "$proj\CLAUDE.md" -Encoding utf8
Copy-Item -Recurse -Force "$storage\pseudo-fable-blueprint\.claude\skills\*" "$proj\.claude\skills\"
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
cat "$storage/pseudo-fable-blueprint/BLUEPRINT.template.md" >> "$proj/CLAUDE.md"
cp -R "$storage/pseudo-fable-blueprint/.claude/skills/"* "$proj/.claude/skills/"
```

</details>

### D. Add Codex workers (on top of B/C)

<details>
<summary>Windows (PowerShell)</summary>

```powershell
Copy-Item "$storage\pseudo-fable-orchestrate\AGENTS.template.md" "$proj\AGENTS.md"
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
cp "$storage/pseudo-fable-orchestrate/AGENTS.template.md" "$proj/AGENTS.md"
```

</details>

- Check the non-interactive CLI form (`codex exec`, etc.) with your local `codex --help`.
- Sync the Project specifics at the end of AGENTS.md with the CLAUDE.md side (Codex needs the build/test commands too).

### E. Lightweight single-file start (mixed team)

<details>
<summary>Windows (PowerShell)</summary>

```powershell
Copy-Item "$storage\pseudo-fable-team\AGENTS.template.md" "$proj\AGENTS.md"
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
cp "$storage/pseudo-fable-team/AGENTS.template.md" "$proj/AGENTS.md"
```

</details>

- Claude-side bridge: add a single `@AGENTS.md` line near the top of the project's CLAUDE.md (unnecessary if your Claude Code reads AGENTS.md natively — verify the actual behavior).

### F. Add the ongoing-operations module (compatible with every scenario)

<details>
<summary>Windows (PowerShell)</summary>

```powershell
Get-Content "$storage\pseudo-fable-retro\RETRO.template.md" -Encoding utf8 |
  Add-Content "$proj\CLAUDE.md" -Encoding utf8
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\pseudo-fable-retro\.claude\skills\*" "$proj\.claude\skills\"
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
cat "$storage/pseudo-fable-retro/RETRO.template.md" >> "$proj/CLAUDE.md"
mkdir -p "$proj/.claude/skills"
cp -R "$storage/pseudo-fable-retro/.claude/skills/"* "$proj/.claude/skills/"
```

</details>

- Cross-session restore (session-bootstrap) and rule cultivation (retro). Recommended from day one for real multi-session work.
- Works with scenario E (single pseudo-fable-team file) too: append it to the CLAUDE.md that carries the `@AGENTS.md` bridge line.

### G. Add the incident-response module (for projects that operate production; compatible with every scenario)

<details>
<summary>Windows (PowerShell)</summary>

```powershell
Get-Content "$storage\pseudo-fable-incident\INCIDENT.template.md" -Encoding utf8 |
  Add-Content "$proj\CLAUDE.md" -Encoding utf8
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\pseudo-fable-incident\.claude\skills\*" "$proj\.claude\skills\"
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
cat "$storage/pseudo-fable-incident/INCIDENT.template.md" >> "$proj/CLAUDE.md"
mkdir -p "$proj/.claude/skills"
cp -R "$storage/pseudo-fable-incident/.claude/skills/"* "$proj/.claude/skills/"
```

</details>

- A live protocol for the moment production impact appears (strict mitigate-before-diagnose ordering, evidence preservation, timeline) and a blameless postmortem after resolution. Diagnosis plugs into lift's root-cause-debug and lesson placement into retro (works standalone without them).

### H. Add the enforcement harness (hooks; compatible with every scenario)

<details>
<summary>Windows (PowerShell)</summary>

```powershell
New-Item -ItemType Directory -Force "$proj\.claude\hooks" | Out-Null
Copy-Item -Force "$storage\pseudo-fable-harness\.claude\hooks\*" "$proj\.claude\hooks\"
if (Test-Path "$proj\.claude\settings.json") { Write-Host "settings.json exists - merge the hooks block manually" }
else { Copy-Item "$storage\pseudo-fable-harness\settings.hooks.json" "$proj\.claude\settings.json" }
Get-Content "$storage\pseudo-fable-harness\HARNESS.template.md" -Encoding utf8 |
  Add-Content "$proj\CLAUDE.md" -Encoding utf8
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
mkdir -p "$proj/.claude/hooks"
cp "$storage/pseudo-fable-harness/.claude/hooks/"* "$proj/.claude/hooks/"
if [ -f "$proj/.claude/settings.json" ]; then echo "settings.json exists - merge the hooks block manually"
else cp "$storage/pseudo-fable-harness/settings.hooks.json" "$proj/.claude/settings.json"; fi
cat "$storage/pseudo-fable-harness/HARNESS.template.md" >> "$proj/CLAUDE.md"
```

</details>

- Three always-on hooks turn the family's text discipline into mechanical guardrails: a Stop hook that blocks "done" without a finish-gate marker, an acceptance nudge after every subagent return, and automatic `.claude/state/` injection at session start. Restart the session, then verify with `/hooks`.
- Optional strict mode: set `PSEUDO_FABLE_HARNESS_VERIFY_CMD` (e.g. in the settings `env` block) and the Stop hook also runs your real check command after edits, blocking completion while it fails. `PSEUDO_FABLE_HARNESS_DISABLE=stop,accept,session,verify|all` silences individual hooks.
- On Windows the default (bash) settings are correct whenever Git Bash is installed; use `settings.hooks.powershell.json` otherwise. Details and honest limits: the pseudo-fable-harness README.

## Common finishing steps (all scenarios)

1. **Fill in Project specifics** — open Claude Code in the new project and run `/init`. Merge the generated build/test/architecture info into the "Project specifics" section of CLAUDE.md (don't delete the framework sections). If AGENTS.md exists, sync its section of the same name too. Because of append order the Project specifics section may end up mid-file; this doesn't affect behavior.
2. **Add to .gitignore** — `.claude/state/` (home of long-task-state state files and the delegations ledger).
3. **Smoke test** — open a new session and check that (a) in a skills setup, "list the available skills" shows the pseudo-fable ones (deep-plan / finish-gate / delegate, etc.), and (b) one small task triggers finish-gate (§P3 for solo) before the completion report.
4. **Tune the effect** — after a few tasks, delete rules that never fire and turn recurring failures into rules (see "Growing it" in each framework README). If an improvement is worth pushing back into the templates, update the files in this store too and bump the version comment in the file header.

## Troubleshooting

- **Not sure what's broken** → open Claude Code in this store and run the `agent-framework-doctor` skill against the project — it inventories the installed components and flags duplicate appends, misplaced skills, and harness wiring issues, each with a fix.
- **Skills don't show up in the list** → they must live at `<project-root>\.claude\skills\<name>\SKILL.md`. Check for a directory name that doesn't match the frontmatter `name:`, or nesting that's too deep.
- **CLAUDE.md feels heavy** → the full stack (lift + orchestrate + blueprint) is ~3.1K resident tokens. For projects running Sonnet alone, keep Project specifics minimal (see per-model tuning in the lift README).
- **AGENTS.md and CLAUDE.md disagree** → typically a missed Project specifics sync. CLAUDE.md is the source of truth; copy changes over to AGENTS.md.

## Contributing

Issues and PRs are welcome — bug reports, translation fixes, and template improvements alike. A few house rules, matching the family's own philosophy:

- **Add rules from failures that actually recurred.** When proposing an addition to a template, include the failure it would have prevented ("which sentence was missing"). Speculative "good habits" are usually declined — every resident rule costs tokens.
- **Deletions are as valuable as additions.** "This rule never fires" is a welcome contribution too.
- Keep the bilingual READMEs in sync (`README.md` / `README.ja.md`), and bump the version comment at the top of any template you change.

## License

MIT — see [LICENSE](LICENSE).
