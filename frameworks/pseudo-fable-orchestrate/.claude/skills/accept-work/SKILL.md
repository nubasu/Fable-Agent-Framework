---
name: accept-work
description: Acceptance protocol for returned subagent work — independent verification of every claim, full-diff read, then ACCEPT / PATCH / BOUNCE / RECLAIM with evidence-based feedback and a brief post-mortem. Use every time a subagent returns work, before integrating anything.
---

# accept-work — trust is not a merge strategy

A subagent report is testimony. Integration requires evidence you observed yourself.

## 1. Verify claims independently

- Run the brief's done-criteria commands yourself, or spawn a FRESH verifier agent — never the implementer. Compare actual output against reported output.
- Read the FULL diff. Hunt specifically for: contract coverage (every numbered item), non-goal violations (drive-by refactors, new dependencies, unrelated fixes), convention drift, leftovers (debug prints, TODOs, dead code).
- A test the report claims passes but you did not see pass → it did not pass.

## 2. Classify — decision tree

- **ACCEPT** — every contract item verified, no non-goal violations. Log to the ledger; integrate.
- **PATCH** — correct in substance, small defects (< ~10 min to fix): fix inline yourself and note it in the ledger — do not round-trip trivia. If the fix would pull you into real implementation (multi-file, a design judgment inside), send a patch-brief instead (defect / file / acceptance, ~5 lines, to the same worker). Patch-briefs do not count toward the bounce limit, but ≥3 on one task means your Done-means was under-specified — post-mortem the brief.
- **BOUNCE** — contract items unmet, or violations. Feedback must be evidence-based and specific:
  `Contract item 3 unmet: ran <cmd>, got <actual>, expected <expected>. Fix <X> in <file>.`
  Never bounce with "doesn't work, try again". Send bounces to the SAME worker when the harness supports continuation — it keeps its context and is cheapest. Hard limit: 2 bounces per task.
- **RECLAIM** — after 2 bounces, or on fundamental misunderstanding: take the task back (only if the Delegation-first criteria genuinely allow — reclaiming a large task destroys your PL context), or re-delegate a REWRITTEN brief to a FRESH worker — never the same session; its contaminated context is part of what you are escaping. If the rewrite is not clearly better than the last brief, the task itself is mis-scoped: split it or escalate to the user. Sunk cost is not a reason for bounce #3.

## 3. Post-mortem the brief (on every BOUNCE or RECLAIM)

- Which sentence, missing from the brief, would have prevented this failure? Add it — to this brief and to your standing brief habits.
- Wrong executor for the task shape? Update your routing.
- The same failure class across multiple tasks → the decomposition is wrong, not the agents.

## 4. Cross-model review (optional, for risky diffs)

- Give the brief + diff to a different model family (e.g. Codex reviews a Sonnet implementation) with an adversarial charter: "find reasons this diff should not merge".
- Disagreement between models is signal to look yourself — never resolve it by majority vote alone.

## 5. Integrate

- After parallel returns: merged build + full test suite, run by YOU on the combined state.
- Update the Delegations ledger: verdict, evidence location, follow-ups discovered.
