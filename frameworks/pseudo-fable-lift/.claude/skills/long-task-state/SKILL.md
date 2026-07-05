---
name: long-task-state
description: External working memory for long tasks — a state file holding the contract, decisions, learned facts, failed approaches, and the next action, kept current so work survives context compaction and session breaks. Use at the start of multi-hour or multi-session work, and immediately after any compaction.
---

# long-task-state — memory that survives

Context gets compacted and sessions end. The state file is the single source of truth for where the task stands. Trust it over your memory.

## Create
At task start, create `.claude/state/<task-slug>.md` (add `.claude/state/` to `.gitignore` unless the team wants it tracked):

```markdown
# <task title>                     (started: <date>)

## Contract
<numbered requirements, from UNDERSTAND>

## Constraints & decisions
<each with WHY, dated>

## Plan
<milestones as checkboxes; mark the current one>

## Learned facts
<`path:line — fact` — things expensive to rediscover>

## Failed approaches
<what was tried + why it failed — never retry these blind>

## Next action
<exactly one concrete step>
```

## Update — cadence
- After each milestone; after any surprising discovery; after any decision; before any risky operation. Roughly every 30 minutes of work.
- Keep it under ~150 lines. It is state, not a diary — prune completed noise; keep decisions and facts.

## Recover — after compaction or in a new session
1. Read the state file FIRST, before acting on anything you "remember".
2. Re-verify the top 3 load-bearing facts against the actual code — files drift, summaries are lossy.
3. If your memory and the file conflict → the file wins; investigate the discrepancy before proceeding.
4. Continue from `Next action`.

## Anti-patterns
- Narrating history into the file — keep it state-shaped.
- Updating the chat but not the file — the file is what survives.
- Trusting recollection over the file after compaction.
