# Fable-Agent-Framework — fable framework installation guide

English | [日本語](README.ja.md)

Recipes for installing the fable family — a set of context frameworks for agent work discipline — into a new project. For each framework's design rationale and details, see the README.md in its directory.

## Included frameworks

| Framework | Role | Form |
|---|---|---|
| `fable-solo` | Execution discipline for a solo Opus session (full version with protocols inlined) | Single CLAUDE.md |
| `fable-lift` | Two-layer execution discipline. General-purpose for Opus/Sonnet; **also used to uplift workers** | CLAUDE.md core + 5 skills |
| `fable-orchestrate` | Delegation & acceptance discipline for the PL (Opus); delegation-first | CLAUDE.md append + 2 skills + minimal AGENTS.md for Codex |
| `fable-blueprint` | Upstream discipline: spec → design → plan → tickets | CLAUDE.md append + 3 skills |
| `fable-team` | Distilled single file for a mixed PL + worker team (built-in role dispatch) | Single AGENTS.md |
| `fable-retro` | Ongoing operations: cross-session restore (session-bootstrap) + rule cultivation (retro) | CLAUDE.md append + 2 skills |
| `fable-incident` | Incident response: mitigate-first live protocol (incident-response) + blameless postmortem (postmortem) | CLAUDE.md append + 2 skills |

## Pick a configuration first

| Mode of operation | What to install | Approx. resident tokens |
|---|---|---|
| Solo Opus does everything | fable-solo | ~3K |
| Solo, lightweight two-layer (Sonnet runs too) | fable-lift | ~1.2K + skills on demand |
| **Opus = PL, Sonnet = implementation (recommended full stack)** | fable-lift + fable-orchestrate | ~2.1K |
| …plus spec-driven upstream work | + fable-blueprint | ~3.1K |
| …plus Codex workers | + AGENTS.md (minimal version bundled with orchestrate) | same |
| Try a single file first (mixed team) | fable-team | ~1.5K |
| + ongoing operations (session restore & rule cultivation; add to any setup) | + fable-retro | +~0.3K |
| + incident response (if you operate production; add to any setup) | + fable-incident | +~0.5K |

**Exclusivity rules (no duplicate installs):**

- The CLAUDE.md base is **either solo or lift, never both**. solo needs no skills (they are already inlined), so don't combine it with the skills either.
- Only one AGENTS.md at the repo root: **either the team version or the orchestrate minimal version** (the team version is a superset of the minimal one).

**Growth path:** start with solo (or team) → move to lift + orchestrate when you start running workers → add blueprint when larger feature development begins. fable-retro is small and compatible with every setup, so multi-session operations can include it from day one. Add fable-incident once you operate production.

## Installation

Clone this repo anywhere (or unzip a download), then set the shared variables to match your environment (used by every snippet below). Each scenario shows the Windows PowerShell commands first, then the macOS / Linux (bash) equivalent.

Windows (PowerShell):

```powershell
$storage = "C:\path\to\Fable-Agent-Framework\frameworks"   # ← where you put this repo
$proj    = "C:\path\to\new-project"                        # ← the target project
```

macOS / Linux (bash):

```bash
storage="/path/to/Fable-Agent-Framework/frameworks"   # ← where you put this repo
proj="/path/to/new-project"                           # ← the target project
```

### A. Solo Opus (shortest path)

```powershell
Copy-Item "$storage\fable-solo\CLAUDE.template.md" "$proj\CLAUDE.md"
```

```bash
# macOS / Linux
cp "$storage/fable-solo/CLAUDE.template.md" "$proj/CLAUDE.md"
```

### B. Recommended full stack (Opus = PL, Sonnet = implementation)

```powershell
# 1) Assemble CLAUDE.md (base = lift, append orchestrate)
Copy-Item "$storage\fable-lift\CLAUDE.template.md" "$proj\CLAUDE.md"
Get-Content "$storage\fable-orchestrate\ORCHESTRATE.template.md" -Encoding utf8 |
  Add-Content "$proj\CLAUDE.md" -Encoding utf8

# 2) Copy all the skills together (7 total)
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\fable-lift\.claude\skills\*"        "$proj\.claude\skills\"
Copy-Item -Recurse -Force "$storage\fable-orchestrate\.claude\skills\*" "$proj\.claude\skills\"
```

```bash
# macOS / Linux
cp "$storage/fable-lift/CLAUDE.template.md" "$proj/CLAUDE.md"
cat "$storage/fable-orchestrate/ORCHESTRATE.template.md" >> "$proj/CLAUDE.md"

mkdir -p "$proj/.claude/skills"
cp -R "$storage/fable-lift/.claude/skills/"*        "$proj/.claude/skills/"
cp -R "$storage/fable-orchestrate/.claude/skills/"* "$proj/.claude/skills/"
```

Sonnet workers (Claude subagents) inherit the project's CLAUDE.md, so the lift part becomes the workers' execution discipline as-is (PL brief quality multiplied by worker execution discipline).

### C. Add spec-driven upstream work (on top of B)

```powershell
Get-Content "$storage\fable-blueprint\BLUEPRINT.template.md" -Encoding utf8 |
  Add-Content "$proj\CLAUDE.md" -Encoding utf8
Copy-Item -Recurse -Force "$storage\fable-blueprint\.claude\skills\*" "$proj\.claude\skills\"
```

```bash
# macOS / Linux
cat "$storage/fable-blueprint/BLUEPRINT.template.md" >> "$proj/CLAUDE.md"
cp -R "$storage/fable-blueprint/.claude/skills/"* "$proj/.claude/skills/"
```

### D. Add Codex workers (on top of B/C)

```powershell
Copy-Item "$storage\fable-orchestrate\AGENTS.template.md" "$proj\AGENTS.md"
```

```bash
# macOS / Linux
cp "$storage/fable-orchestrate/AGENTS.template.md" "$proj/AGENTS.md"
```

- Check the non-interactive CLI form (`codex exec`, etc.) with your local `codex --help`.
- Sync the Project specifics at the end of AGENTS.md with the CLAUDE.md side (Codex needs the build/test commands too).

### E. Lightweight single-file start (mixed team)

```powershell
Copy-Item "$storage\fable-team\AGENTS.template.md" "$proj\AGENTS.md"
```

```bash
# macOS / Linux
cp "$storage/fable-team/AGENTS.template.md" "$proj/AGENTS.md"
```

- Claude-side bridge: add a single `@AGENTS.md` line near the top of the project's CLAUDE.md (unnecessary if your Claude Code reads AGENTS.md natively — verify the actual behavior).

### F. Add the ongoing-operations module (compatible with every scenario)

```powershell
Get-Content "$storage\fable-retro\RETRO.template.md" -Encoding utf8 |
  Add-Content "$proj\CLAUDE.md" -Encoding utf8
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\fable-retro\.claude\skills\*" "$proj\.claude\skills\"
```

```bash
# macOS / Linux
cat "$storage/fable-retro/RETRO.template.md" >> "$proj/CLAUDE.md"
mkdir -p "$proj/.claude/skills"
cp -R "$storage/fable-retro/.claude/skills/"* "$proj/.claude/skills/"
```

- Cross-session restore (session-bootstrap) and rule cultivation (retro). Recommended from day one for real multi-session work.
- Works with scenario E (single fable-team file) too: append it to the CLAUDE.md that carries the `@AGENTS.md` bridge line.

### G. Add the incident-response module (for projects that operate production; compatible with every scenario)

```powershell
Get-Content "$storage\fable-incident\INCIDENT.template.md" -Encoding utf8 |
  Add-Content "$proj\CLAUDE.md" -Encoding utf8
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\fable-incident\.claude\skills\*" "$proj\.claude\skills\"
```

```bash
# macOS / Linux
cat "$storage/fable-incident/INCIDENT.template.md" >> "$proj/CLAUDE.md"
mkdir -p "$proj/.claude/skills"
cp -R "$storage/fable-incident/.claude/skills/"* "$proj/.claude/skills/"
```

- A live protocol for the moment production impact appears (strict mitigate-before-diagnose ordering, evidence preservation, timeline) and a blameless postmortem after resolution. Diagnosis plugs into lift's root-cause-debug and lesson placement into retro (works standalone without them).

## Common finishing steps (all scenarios)

1. **Fill in Project specifics** — open Claude Code in the new project and run `/init`. Merge the generated build/test/architecture info into the "Project specifics" section of CLAUDE.md (don't delete the framework sections). If AGENTS.md exists, sync its section of the same name too. Because of append order the Project specifics section may end up mid-file; this doesn't affect behavior.
2. **Add to .gitignore** — `.claude/state/` (home of long-task-state state files and the delegations ledger).
3. **Smoke test** — open a new session and check that (a) in a skills setup, "list the available skills" shows the fable ones (deep-plan / finish-gate / delegate, etc.), and (b) one small task triggers finish-gate (§P3 for solo) before the completion report.
4. **Tune the effect** — after a few tasks, delete rules that never fire and turn recurring failures into rules (see "Growing it" in each framework README). If an improvement is worth pushing back into the templates, update the files in this store too and bump the version comment in the file header.

## Troubleshooting

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
