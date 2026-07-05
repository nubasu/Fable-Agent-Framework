---
name: root-cause-debug
description: Systematic root-cause debugging — reset to clean state, exact reproduction, full-evidence reading, differential hypotheses with discriminating experiments, fix at the cause, before/after proof. Use when a bug survives the first fix attempt, when behavior seems impossible or "weird", or before fixing anything you cannot yet explain.
---

# root-cause-debug — evidence over instinct

The goal is not "make the error go away". The goal is "explain the failure, then let the explanation force the fix".

## 0. Reset to clean state
If failed patches are already stacked: revert them (`git stash` / `git checkout`) before anything else. Debugging on top of your own failed fixes contaminates every observation.

## 1. Reproduce
- Capture the exact command and the exact output. No reliable reproduction → stop and build one first; without it you can never know the bug is fixed.
- Intermittent? Run it N times and record the failure rate — that number is data (it suggests timing or state dependence).

## 2. Read ALL the evidence
- The full stack trace, the full log section, the actual runtime values — add prints or a debugger; never reason about a value you could simply look at.
- Quote the decisive line into your notes.
- Forbidden: matching the error to a familiar pattern and applying its usual fix ("looks like a CORS thing") without confirming it applies to THIS case.

## 3. Localize
- Shrink until the failing unit is small: `git bisect` for regressions; early-return or comment-out to isolate the code path; minimize the failing input.
- Prefer the cut that rules out the most search space at once.

## 4. Differential diagnosis — keep a journal
- Write at least two competing hypotheses. For each: what observation would discriminate it from the others?
- Run the cheapest discriminating experiment first.
- Journal format, updated every cycle and kept visible in your notes:
  `H1: <suspected cause> — test: <experiment> → <result> ✗/✓`
- A hypothesis you cannot test is a hunch — sharpen it until it predicts something observable.
- The journal is what prevents circular retries: if a new idea matches a struck-out entry, it is already dead.

## 5. Fix at the cause
- Fix where the invariant broke, not where the symptom surfaced.
- Then ask: why was this bug possible, and does the same class exist elsewhere? Grep for the pattern; fix or report per the scope rules.

## 6. Prove it
- The captured reproduction now passes — show before/after output.
- Surrounding tests still pass. State both explicitly.

## 7. Escalate honestly
- After ~45–60 minutes without the hypothesis space narrowing: write a stuck-report — ruled out (with evidence), still possible, the sharpest next experiment, and what you would need (info, access) to proceed. Present it. A good stuck-report is a deliverable, not a failure.
