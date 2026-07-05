---
name: session-bootstrap
description: Session start and end rituals for multi-session projects — boot "where were we" from the state file, delegations ledger, tickets, and git in minutes; verify drift before resuming; end each session with a checkpoint the next session can boot from. Use at the start of any session that continues earlier work, and before ending a work session (or when context is nearly full).
---

# session-bootstrap — sessions boot from files, not memory

Chat history evaporates between sessions and summaries are lossy; the project's durable state lives in files. This is the boot and shutdown sequence.

## OPEN — starting a session that continues earlier work

1. **Read the state, in this order** (skip what doesn't exist):
   - `.claude/state/<task-slug>.md` — active task state (pseudo-fable-lift `long-task-state`)
   - `.claude/state/delegations.md` — in-flight delegated work (pseudo-fable-orchestrate ledger)
   - `docs/plan/<slug>/03-tickets.md` — ticket statuses and traceability (pseudo-fable-blueprint)
   - `git log --oneline -15` and `git status` — what actually changed vs. what the files claim
2. **Verify drift** — the files were true when written, not necessarily now:
   - Re-verify the top ~3 load-bearing facts against the actual code (files move; teammates commit).
   - Dirty `git status` not mentioned in the state file → investigate before continuing; someone (possibly a previous you) left uncommitted work.
   - In-flight delegations: check whether workers finished or died; reconcile the ledger before spawning anything new.
3. **Restate before resuming** — one short message: where the task stands (X/Y), the next single action, anything that drifted. This is the contract check; the user can correct it before you burn tokens.
4. Continue from `Next action`. Do **not** re-plan what is already planned — re-planning finished plans is how sessions lose their first hour.

## CLOSE — ending the session (or the user says "done for now", or context is nearly full)

1. Update the state file(s): plan checkboxes, learned facts, failed approaches — and **Next action, exactly one concrete step**. That line is the single most valuable thing you leave for the next session.
2. Update ticket statuses and the delegations ledger: verdicts, in-flight items and what to check on them.
3. **Park the working tree deliberately** — commit or stash with a message the next session can read; never leave silent dirty state. If you are not authorized to commit, report exactly what is uncommitted and why.
4. If anything bounced, reverted, or dragged this session → run a micro-`retro` (≤2 min, ≤2 rules).
5. Close with a 3-line handoff in chat: done today / next action / open risks.

## Anti-patterns

- Booting from your memory of the last session ("I remember we were...") — memory is the lossy copy; the files are the original.
- Re-reading the whole codebase at session start — the state file's Learned facts exist to make recon cheap. Verify them; don't re-derive them.
- Ending a session with the plan only in chat — chat is not a handoff.
- Treating OPEN as optional after compaction — a compacted context is a new session in disguise.
