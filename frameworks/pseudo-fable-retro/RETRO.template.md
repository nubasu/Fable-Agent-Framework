## Continuity — session rhythm and rule growth

<!-- pseudo-fable-retro v1.1 (2026-07-05) — cross-session continuity and the rule-growing
     v1.1: family renamed fable-* → pseudo-fable-*.
     flywheel. Append this section to the project CLAUDE.md. Composes with pseudo-fable-lift
     (long-task-state), pseudo-fable-orchestrate (delegations ledger), and pseudo-fable-blueprint
     (tickets); degrades gracefully when any of those are absent. -->

Chat evaporates between sessions; lessons evaporate between tasks. Two skills stop the leaks.

### Hard triggers

| Situation | Invoke |
|---|---|
| Session starts on work begun earlier | `session-bootstrap` OPEN — boot from files, never from memory |
| Session is ending, the user says done for now, or context is nearly full | `session-bootstrap` CLOSE — checkpoint so the next session boots in minutes |
| A milestone or task completed; a bounce, reclaim, or failed-fix spiral happened | `retro` — harvest ≤2 rules from what actually went wrong |
| ~Weekly, or every ~10 tasks | `retro` §4 — prune rules that never fire |

House rule: **rules are grown from recurred failures and pruned when they stop firing.** A rule that never changes behavior is pure context cost.
