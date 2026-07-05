# pseudo-fable-incident

English | [日本語](README.ja.md)

The incident-response module — a live protocol for the moment production impact appears (**incident-response**) and a blameless **postmortem** after resolution. Adds to any framework configuration. Resident cost ~0.5K tokens.

## The idea — an incident is a different sport, not "debugging under pressure"

Every other framework is in "build" mode, where the objective function is correctness. An incident's objective function is **impact**, which inverts the priorities (mitigation before cause). Four typical lower-tier failures:

1. **Root-causing while bleeding** — digging for the root cause while user impact continues. → Non-negotiable #1, "**Mitigate before diagnose**" (rollback / flag off / failover first; hunt for the knife later)
2. **Irreversible experiments in production** — restarts, cache clears, data changes on a "might fix it", destroying the evidence. → "**Production state is evidence.** Photograph before you touch." "**Reversible, or approved.** Change one thing at a time."
3. **No timeline** — nothing recorded, "did we already try X?" is unanswerable, no postmortem can be written. → From minute one, log every action and observation with timestamps into an incident file (`.claude/state/incident-<date>-<slug>.md`)
4. **Premature all-clear** — closing on "it seems better". → "**Resolved means observed-healthy**": resolution requires measured symptom disappearance plus passing a monitoring window (proportional to detection lag, default 30–60 min). The incident doesn't close until the postmortem is written

## Structure

```
pseudo-fable-incident/
├── INCIDENT.template.md            ← resident core (~0.5K). Append to the end of the project's CLAUDE.md
└── .claude/skills/
    ├── incident-response/          ← TRIAGE → MITIGATE → DIAGNOSE → FIX → VERIFY&MONITOR → CLOSE
    └── postmortem/                 ← timeline reconstruction, the three durations, root cause vs. contributing factors, three-lens action items
```

## incident-response highlights

- **Entry check** — is there production impact right now? If not, back to the normal loop (root-cause-debug). "Don't run incident mode on a non-incident" is part of the discipline too.
- **TRIAGE capped at 5 minutes** — blast radius (still growing?) and "**what changed**" (deploys, config, dependencies, traffic, data, external services). Most incidents correlate with a recent change.
- **MITIGATE** — fastest reversible lever first: rollback > flag off > failover (after preserving state) > scaling. Confirm the effect in numbers. "Mitigated ≠ resolved."
- **DIAGNOSE** — run lift's root-cause-debug overlaid with production constraints (read-first; experiments reversible or approved).
- **FIX** — even in an emergency, finish-gate is not waived (an unverified hotfix is how you get tonight's second incident). Don't forget to grep for siblings of the same bug.
- **Without privileges** — when the agent lacks production access, it switches from "executing" to "directing": present the exact commands plus their reversibility; the user runs and approves. The protocol itself is unchanged.

## postmortem highlights

- **Blameless** — systems and processes fail, not people (or models). Not "who did it" but "why did the system allow it". An agent mistake = a check that was missing.
- **Three durations** (time to detect, to mitigate, to resolve), each measured as a separate improvement target.
- **Luck is a risk that didn't fire this time** — "we happened to get away with it" gets priced as a finding too.
- **Three-lens action items** — detect faster (monitoring) / kill the class (prevent recurrence of the class, not the instance) / stop faster (rollback means, runbooks). Action items are tickets, so there's no cap on their count. Only what becomes a **context rule** goes through retro's placement table and the "≤2 rules" constraint.
- They live in `docs/postmortems/` (permanent, human-visible documents). One page max — a postmortem nobody reads prevents nothing.

## Connections to the other frameworks

| Connects to | Relationship |
|---|---|
| lift `root-cause-debug` | the substance of the DIAGNOSE phase (hypothesis journal); incident overlays production constraints on top |
| lift `finish-gate` | not waived even in the FIX phase |
| retro | where postmortem lessons get placed (directly into CLAUDE.md if not installed) |
| session-bootstrap | incident files are picked up by OPEN/CLOSE as part of state |

Works standalone without them (diagnosis falls back to the essentials inside the skill).

## Installation

<details>
<summary>Windows (PowerShell)</summary>

```powershell
$storage = "C:\path\to\Pseudo-Fable-Agent-Framework\frameworks\pseudo-fable-incident"   # ← adjust to where you put this repo
$proj    = "C:\path\to\project"

# 1. Append the resident core to the end of CLAUDE.md
Get-Content "$storage\INCIDENT.template.md" -Encoding utf8 | Add-Content "$proj\CLAUDE.md" -Encoding utf8

# 2. Copy the skills (added under .claude/skills/)
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\.claude\skills\*" "$proj\.claude\skills\"
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
storage="/path/to/Pseudo-Fable-Agent-Framework/frameworks/pseudo-fable-incident"   # ← adjust to where you put this repo
proj="/path/to/project"

cat "$storage/INCIDENT.template.md" >> "$proj/CLAUDE.md"
mkdir -p "$proj/.claude/skills"
cp -R "$storage/.claude/skills/"* "$proj/.claude/skills/"
```

</details>

For combined installs with other frameworks, see the README.md at the repo root.

## Honest limits

- Projects without a monitoring stack (metrics, alerts) get weaker detection and effect measurement. The protocol is designed to treat that itself as "missing observability = the top-priority action item".
- Monitoring-window length runs on rules of thumb (proportional to detection lag).
- Text discipline is strong steering, not enforcement (family-wide). "Mitigate first" in particular breaks easily under time pressure, which is why it sits at the top of the non-negotiables.
