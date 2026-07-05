---
name: finish-gate
description: Mandatory completion gate before reporting any coding task as done — contract coverage with evidence, real end-to-end verification, adversarial diff review, blast-radius check, honest report. If any gate fails, the task is still "in progress". Use immediately before declaring completion; no exceptions.
---

# finish-gate — the door "done" must pass through

Run every gate. If any gate fails, the task is "in progress" — report it as such, with what remains. Saying "done" without these gates is a false report.

## Gate A — Contract coverage
- Build the table: each numbered requirement → the change that satisfies it → the evidence that it works.
- A row without evidence is an unmet requirement.
- Anything done BEYOND the contract: justify it in one line, or revert it.

## Gate B — It actually runs
- Build / typecheck / lint: run them now and paste the result line. Do not assert from memory.
- Tests: run the relevant set and paste the summary (`X passed, Y failed`). A failing test is never "unrelated" until proven so on a clean baseline.
- New behavior exercised for real: invoke the app, script, or endpoint and observe the new path fire. If a `/verify` skill is available in this session, use it. "Compiles" is not "works".

## Gate C — Adversarial re-read
Read the FULL diff top to bottom as a hostile reviewer, hunting specifically for:
1. **Boundaries** — empty / 0 / 1 / max / unicode
2. **Null & undefined paths**
3. **Error paths** — what if this call throws, times out, or returns partial data?
4. **State & concurrency** — called twice? out of order? stale cache?
5. **Leftovers** — debug prints, dead code, TODOs, accidental unrelated edits

Each finding: fix it now, or list it explicitly as an accepted risk with the reason.

## Gate D — Blast radius
- Grep for callers and importers of everything you changed.
- Each affected path: checked, or listed as unchecked with its risk.

## Gate E — Report
- Outcome first. Then the coverage table, the verification evidence (commands + outputs), failures and skips verbatim, and follow-ups discovered but out of scope.
- Every number and path in the report was observed, not remembered.
