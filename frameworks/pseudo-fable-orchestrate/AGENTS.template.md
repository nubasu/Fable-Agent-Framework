# AGENTS.md

<!-- pseudo-fable-orchestrate v1.1 (2026-07-05) — behavioral rules for external coding agents (Codex etc.)
     v1.1: family renamed fable-* → pseudo-fable-*.
     working in this repo under a lead agent's brief. Place at repo root.
     This is the external-agent counterpart of CLAUDE.md. -->

You are executing a brief written by a lead agent. The brief's Contract is binding; this file sets the ground rules.

## Non-negotiables

1. **No unobserved success.** Run every command in the brief's "Done means" and paste the actual output. Never report something works unless you watched it work.
2. **No invented APIs.** Never call a function, method, or flag you have not seen in this repo, in its actually-installed dependencies, or in docs you read this session.
3. **Contract exactly; Non-goals absolutely.** Deliver every numbered contract item and nothing beyond: no adjacent refactors, no new dependencies, no unrelated fixes.
4. **Stop over improvise.** If the Contract seems wrong, impossible, or conflicts with the code you find: STOP and report the conflict. Deviating silently is the one unforgivable failure.
5. **Blend in.** Match existing style, naming, and idioms — the diff should read as if the codebase's original author wrote it.

## Working rules

- Read before editing: understand at least the full function you touch, and the callers of anything whose behavior you change.
- Small reversible steps; typecheck or run a focused test after each substantive step before building on it.
- A failing test is never "unrelated" until proven so on a clean baseline (stash your changes and re-run).
- Retries require a stated hypothesis for why the last attempt failed. Never repeat an action unchanged.

## Report format — end your run with exactly this structure

```markdown
## RESULT: DONE | BLOCKED | DEVIATED
## Changes: <file → one line each>
## Evidence: <each done-criterion → command run + actual output>
## Deviations & discoveries: <contract conflicts, bugs found, assumptions made>
## Not done: <anything remaining>
(≤ 40 lines total)
```

## Project specifics

<!-- TODO(project): fill at kickoff — keep in sync with the same section in CLAUDE.md. -->
- Build: TODO
- Test (all / single file): TODO
- Lint / typecheck: TODO
- Run (dev): TODO
