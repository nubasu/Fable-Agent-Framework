# pseudo-fable-harness

English | [日本語](README.ja.md)

The enforcement module — every pseudo-fable framework README admits the same limit: "text discipline is strong steering, not enforcement". This module adds the missing mechanical layer: three always-on Claude Code hooks guarding the places where steering leaks the most, plus an opt-in **strict-verify** hook that runs your project's real checks at the finish line. Adds to any framework configuration. Resident cost ~0.25K tokens (the CLAUDE.md addendum); the hook scripts themselves live outside the context window.

## The idea — from steering to guardrails

Three failure modes survive even a well-steered session, because each strikes exactly where attention is weakest — the finish line, the integration point, the restart:

1. **"Done" without the gate** — the session edits files, then reports completion without running finish-gate. → The **Stop hook** blocks the stop until a finish-gate marker follows the last edit.
2. **Integrating on the subagent's word** — accept-work exists, but nothing fires it. → The **PostToolUse hook** injects an acceptance nudge after every subagent return.
3. **Resuming from memory** — the state file exists, but the new session never reads it. → The **SessionStart hook** injects `.claude/state/` into context before the first token of work.

### Honest label

- **What it enforces: the ritual.** A gate marker must follow edits; a nudge follows every subagent; state is always in context. "Forgot" stops being possible.
- **What it cannot enforce: the truth.** A model can print `[finish-gate: pass]` without honestly running the gates — the hook cannot tell. The value is converting silent omission into active lying, which the non-negotiables (and the CLAUDE.md addendum) prohibit in writing.
- **Fail-open by design.** Any internal error in a hook lets the session proceed; the harness must never break work.

## Structure

```
pseudo-fable-harness/
├── HARNESS.template.md              ← CLAUDE.md addendum (~0.25K): the marker contract
├── settings.hooks.json              ← hooks block, bash commands (default for ALL OSes — see Installation)
├── settings.hooks.powershell.json   ← alternative for Windows WITHOUT Git Bash
└── .claude/hooks/                   ← hook scripts (each as .sh + .ps1 twin; ASCII-only; zero dependencies)
    ├── stop-finish-gate.(sh|ps1)        ← Stop: block "done" that has no finish-gate marker
    ├── stop-verify.(sh|ps1)             ← Stop, opt-in strict mode: run the real check command, block on failure
    ├── posttool-accept-work.(sh|ps1)    ← PostToolUse (Task|Agent): acceptance nudge
    └── sessionstart-bootstrap.(sh|ps1)  ← SessionStart: inject .claude/state/ into context
```

## The hooks

| Hook | Fires on | Behavior | Enforces |
|---|---|---|---|
| `stop-finish-gate` | Stop (end of turn) | If the session modified files (Write/Edit/MultiEdit/NotebookEdit) and no `[finish-gate: pass]` / `[finish-gate: n/a]` marker follows the last edit → exit 2 blocks the stop and feeds the gate instruction back to the model | lift `finish-gate` / solo §P3 |
| `stop-verify` (opt-in) | Stop (end of turn) | Inert unless `PSEUDO_FABLE_HARNESS_VERIFY_CMD` is set. When the session has edits newer than its last successful pass, runs the command from the project root; on failure → exit 2 blocks the stop with the output tail | finish-gate Gate B — the *truth*, not just the ritual |
| `posttool-accept-work` | PostToolUse, matcher `Task\|Agent` | Injects a one-line acceptance nudge after each subagent result (non-blocking) | orchestrate `accept-work` |
| `sessionstart-bootstrap` | SessionStart (startup / resume / clear / compact) | If `.claude/state/` has files: lists them and inlines the newest one (60 lines / 4KB cap) into context; warns when the newest file is >60 min old (likely stale); silent when empty | retro `session-bootstrap` OPEN / lift `long-task-state` |

Loop safety on the blocking hooks: they honor `stop_hook_active` when present, and independently stop insisting once they have already blocked twice since the last edit — worst case is two nudges each, never an infinite loop. `stop-verify` additionally skips entirely when nothing changed since its last successful run (per-session stamp in the OS temp dir).

## Strict mode and runtime switches

**Strict verify (opt-in).** Set `PSEUDO_FABLE_HARNESS_VERIFY_CMD` to your project's real check command — the cleanest place is the `env` block of `.claude/settings.json`:

```json
{
  "env": { "PSEUDO_FABLE_HARNESS_VERIFY_CMD": "npm run typecheck && npm test -- --bail" }
}
```

After edits, the Stop hook runs the command (bash variant via `sh -c`, PowerShell variant via `Invoke-Expression`, both from the project root, 300s timeout in the shipped settings) and blocks completion while it fails, feeding back the last 1500 characters of output. This mechanically closes the harness's own biggest limit — "ritual, not truth" — for Gate B: a marker can be faked, a failing typecheck cannot.

**Kill switch.** `PSEUDO_FABLE_HARNESS_DISABLE` silences hooks without editing settings.json — a comma-separated list of `stop`, `accept`, `session`, `verify`, or `all` (e.g. `PSEUDO_FABLE_HARNESS_DISABLE=accept,verify`).

## Installation

On Windows, Claude Code runs hook commands under **Git Bash when available** (PowerShell otherwise) — so the default bash setup below is correct for macOS, Linux, **and** most Windows machines. Reach for `settings.hooks.powershell.json` only where Git Bash is unavailable.

<details>
<summary>Windows (PowerShell)</summary>

```powershell
$storage = "C:\path\to\Pseudo-Fable-Agent-Framework\frameworks\pseudo-fable-harness"   # ← adjust to where you put this repo
$proj    = "C:\path\to\project"

# 1. Copy the hook scripts
New-Item -ItemType Directory -Force "$proj\.claude\hooks" | Out-Null
Copy-Item -Force "$storage\.claude\hooks\*" "$proj\.claude\hooks\"

# 2. Register the hooks (no settings.json yet -> copy; otherwise merge the "hooks" block by hand)
if (Test-Path "$proj\.claude\settings.json") { Write-Host "settings.json exists - merge the hooks block manually" }
else { Copy-Item "$storage\settings.hooks.json" "$proj\.claude\settings.json" }

# 3. Append the marker contract to CLAUDE.md
Get-Content "$storage\HARNESS.template.md" -Encoding utf8 | Add-Content "$proj\CLAUDE.md" -Encoding utf8
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
storage="/path/to/Pseudo-Fable-Agent-Framework/frameworks/pseudo-fable-harness"   # ← adjust to where you put this repo
proj="/path/to/project"

mkdir -p "$proj/.claude/hooks"
cp "$storage/.claude/hooks/"* "$proj/.claude/hooks/"
if [ -f "$proj/.claude/settings.json" ]; then echo "settings.json exists - merge the hooks block manually"
else cp "$storage/settings.hooks.json" "$proj/.claude/settings.json"; fi
cat "$storage/HARNESS.template.md" >> "$proj/CLAUDE.md"
```

</details>

Afterwards: **restart the session** (hook registration loads at startup) and run `/hooks` to confirm the four harness hooks are listed (`stop-verify` stays inert until `PSEUDO_FABLE_HARNESS_VERIFY_CMD` is configured). Smoke test: make a trivial file edit and let the turn end without a completion report — the stop should bounce exactly once with the gate instruction.

## Design notes

- **Transcript detection is heuristic.** The Stop hook substring-matches the session transcript (JSONL): non-sidechain assistant entries for file-tool uses and for the markers. The transcript schema is not officially documented; the patterns match the format observed in current Claude Code, and the hook fails open if the format ever shifts.
- **The `.ps1` files are ASCII-only, deliberately.** Windows PowerShell 5.1 reads BOM-less scripts as ANSI, so any non-ASCII character would mojibake on non-English Windows. Keep them ASCII when editing.
- **Marker contract**: `[finish-gate: pass]` after the gate passes; `[finish-gate: n/a]` plus a one-line reason for stops that are not completion claims. Defined in HARNESS.template.md and repeated inside the block message, so the Stop hook still works even without the addendum installed.

## Honest limits

- **Ritual, not truth** — a false marker passes the hook (see the label above); honesty stays a written non-negotiable, not a mechanical one.
- File changes made through shell commands (the Bash tool: `sed`, `git apply`, generated scripts) are not detected as edits — the gate only sees the file tools. If your sessions routinely edit via shell, extend the pattern at the cost of noise.
- The acceptance nudge fires for every subagent, including read-only scouts — the message tells the model to wave those through, but it is still one line per return. Delete the PostToolUse block from settings if it grates.
- The marker counts anywhere in an assistant entry — a model *quoting* it (including inside extended thinking) satisfies the check without a real report.
- `stop_hook_active` is absent from the current hooks documentation; the built-in two-block limit is the load-bearing loop protection.
- Hooks merge across settings levels (user + project both run), and registration changes need a session restart.
- Strict verify executes an arbitrary command with your shell privileges — treat `PSEUDO_FABLE_HARNESS_VERIFY_CMD` like any build script and review it before enabling. The PowerShell variant runs it via `Invoke-Expression`; prefer plain native commands there.
- The two Stop hooks run independently; when both block, both messages arrive and their order is not guaranteed.

## Growing it

- Family rule: grow from recurred failures, prune what never fires. If edits keep slipping past the gate via shell commands, add Bash detection; if the accept-work nudge never changes behavior, delete that block.
- The block/nudge messages live inside the scripts — tune their wording the way you tune CLAUDE.md rules, and keep the `.sh` / `.ps1` twins in step.
