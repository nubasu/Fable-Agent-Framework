# pseudo-fable-retro

English | [日本語](README.ja.md)

The ongoing-operations module — two skills, a **learning rhythm (retro)** and a **session rhythm (session-bootstrap)**, plugging the two big leaks of long-running operation. Adds to any framework configuration and works standalone. Resident cost ~0.3K tokens.

1. **Lessons evaporate** — every framework README says "add rules from recurring failures, delete rules that never fire", but no protocol or trigger existed to actually do it. Advice is not a mechanism. retro turns that cultivation rule into a protocol.
2. **Context evaporates** — every new session either burns its first 30 minutes on "where were we?" or resumes from memory and causes a drift accident. session-bootstrap pins down the opening and closing rituals.

## Structure

```
pseudo-fable-retro/
├── RETRO.template.md            ← resident triggers (~0.3K). Append to the end of the project's CLAUDE.md
└── .claude/skills/
    ├── retro/                   ← harvest → "which sentence would have prevented it" → placement table → inventory
    └── session-bootstrap/       ← OPEN (restore from files, verify drift) / CLOSE (checkpoint)
```

## retro — grow rules from failures (the mechanism version)

Fires: at milestone completion / on a bounce, reclaim, or fix spiral / weekly (or every 10 tasks) for inventory.

1. **Harvest** — one line each for failures (bounces, rejections, long-lived wrong assumptions), friction (anything that took 2+ attempts, rediscovering known traps), and surprises (= risks that hadn't been priced in).
2. **The missing sentence** — "which single sentence in which document would have prevented this?" If you can't phrase it, you don't understand the failure yet.
3. **Placement table** — route each lesson to the **narrowest home** its scope allows: a repository trap → Gotchas / a trap workers keep stepping in → the PL's standard-brief Gotchas / a project-specific process failure → the project CLAUDE.md / generic and recurring across projects → **the store templates (propose the edit to the user** — they are shared across all projects**)** / a user trait → agent memory / one-off → **write it nowhere**.
4. **Inventory** — delete or demote rules that never fire; rewrite ones that misfire. "Pruning is worth as much as adding. A retro that only adds is broken."
5. **Restraint** — add **at most 2 rules** per retro. Rule inflation is retro's own failure mode.

## session-bootstrap — sessions boot from files

**OPEN** (at the start of any session continuing earlier work): read state → delegations ledger → tickets → `git log`/`git status`, in that order → re-verify the top 3 critical facts against the code (drift detection) → declare "position X/Y, next move, drift or none" in one message before resuming. **No re-planning what's already planned** (the classic way a session loses its first hour).

**CLOSE** (at session end, or when context is nearly full): update state (**Next action must be one concrete move**) → update tickets/ledger → park the working tree deliberately (if you can't commit, report the uncommitted contents precisely) → a micro-retro if anything went wrong this session → a 3-line handoff (done today / next move / open risks).

Resuming after compaction also runs OPEN, as a "new session in disguise" (stated in the anti-patterns).

## Division of labor with the other frameworks

| | What it defines |
|---|---|
| lift's `long-task-state` | the state file **format** (what to write) |
| `session-bootstrap` | the **ritual** that reads/writes it (what to do at session start and end) |
| orchestrate's `accept-work` §3 | per-bounce brief post-mortems (individual) |
| `retro` | **placement and inventory** of all lessons (where to write them, when to prune them) |

Works even in setups without state files or a ledger (restore from git log and docs; lessons go into the project CLAUDE.md).

## Installation

<details>
<summary>Windows (PowerShell)</summary>

```powershell
$storage = "C:\path\to\Pseudo-Fable-Framework\frameworks\pseudo-fable-retro"   # ← adjust to where you put this repo
$proj    = "C:\path\to\project"

# 1. Append the resident triggers to the end of CLAUDE.md
Get-Content "$storage\RETRO.template.md" -Encoding utf8 | Add-Content "$proj\CLAUDE.md" -Encoding utf8

# 2. Copy the skills (added under .claude/skills/)
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\.claude\skills\*" "$proj\.claude\skills\"
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
storage="/path/to/Pseudo-Fable-Framework/frameworks/pseudo-fable-retro"   # ← adjust to where you put this repo
proj="/path/to/project"

cat "$storage/RETRO.template.md" >> "$proj/CLAUDE.md"
mkdir -p "$proj/.claude/skills"
cp -R "$storage/.claude/skills/"* "$proj/.claude/skills/"
```

</details>

For combined installs with other frameworks, see the README.md at the repo root.

## Honest limits

- retro quality depends on self-awareness (you can't harvest a failure you didn't recognize as yours). That's why **observable events** — bounces, rejections, test failures — are the primary triggers: to shrink that weakness.
- Inventory's "fire log" can't be tracked rigorously (it runs on rules of thumb). Judge roughly by "has this rule changed behavior recently?".
- Pushing lessons back into the store templates requires user approval, so the human is the bottleneck for generic lessons (deliberate design — safer than unapproved edits to shared assets).
