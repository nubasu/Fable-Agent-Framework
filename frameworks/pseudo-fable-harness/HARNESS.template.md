## Harness — mechanical guardrails

<!-- pseudo-fable-harness v1.2 (2026-07-05) — hook-based guardrails for the pseudo-fable frameworks.
     v1.1: optional strict verify + kill switch note.
     v1.2: family renamed fable-* → pseudo-fable-* (env vars now PSEUDO_FABLE_HARNESS_*).
     Append this section to the project CLAUDE.md; pair it with the .claude/hooks/ scripts
     and the hooks block merged into .claude/settings.json. The hooks enforce the ritual,
     not the truth — the framework sections above still define WHAT to do. -->

Hooks in this project mechanically reinforce the framework. They are guardrails, not the protocol — and they verify the ritual, not the truth. Printing a marker that is not true is a non-negotiable violation.

- **Finish marker (Stop hook).** When the finish gate passes (skill `finish-gate`, or §P3 in solo setups), end the completion report with the literal line `[finish-gate: pass]`. When a turn ends WITHOUT a completion claim (blocked, awaiting user input, non-coding turn), end with a one-line reason plus `[finish-gate: n/a]`. The hook blocks stops that modified files but carry no marker after the last edit.
- **Subagent returns (PostToolUse hook).** Every subagent result is followed by an acceptance nudge: run `accept-work` (where installed) — verify independently before integrating.
- **Session start (SessionStart hook).** Files under `.claude/state/` are injected into context automatically; boot from them, not from memory. A stale-state warning means the file may predate recent work — re-verify before trusting it.
- **Strict verify (where enabled).** If `PSEUDO_FABLE_HARNESS_VERIFY_CMD` is configured, the Stop hook also runs the project's real check command after edits and blocks completion while it fails. Fix the failures — never work around the check.
