---
name: incident-response
description: Live incident protocol when production is impacted — triage blast radius and "what changed", mitigate first (rollback / flag / failover), preserve evidence before state-destroying actions, keep a timestamped timeline, diagnose production-safely, fix through normal gates, verify with a monitoring window. Use the moment production impact (users, data, money, security) is detected or imminent; not for ordinary bugs.
---

# incident-response — impact first, cause second

## 0. Entry check

Production impacted now, or imminent? **No** → this is a normal bug; use the normal loop (`root-cause-debug`). Do not run incident mode for non-incidents.
**Yes** → create `.claude/state/incident-<date>-<slug>.md` and start the timeline: `HH:MM — <action / observation>`. Every step below gets a line.

Note on authority: if you lack direct production access or the action is destructive, you direct rather than execute — propose the exact command, state its reversibility, and have the user run or approve it. The protocol is unchanged.

## 1. TRIAGE — ~5 minutes, not more

- Blast radius: who/what is affected, roughly how many, growing or stable? (Growing changes everything: mitigate cruder and faster.)
- **"What changed?"** — the highest-yield question. Sweep: deploys, config, dependency updates, traffic pattern, data shape, external services (status pages). Most incidents follow a recent change; the correlation of symptom-start vs change-events is your first hypothesis.
- Tell the user what you know in 3 lines: impact / suspected trigger / next action. Update on every state change (mitigated → cause found → resolved), not on a timer.

## 2. MITIGATE — stop the bleeding

- Choose the fastest REVERSIBLE lever, in order of preference:
  1. Roll back the suspicious recent change
  2. Feature-flag off the affected path
  3. Failover / restart — capture state first (see below)
  4. Scale up / rate-limit as a pressure valve
- Evidence before destruction: before any state-destroying action (restart, cache clear), capture logs, metric snapshots/exports, and process state into or alongside the incident file.
- One change at a time → observe → record the result. No stacking.
- Verify the mitigation actually reduced impact — numbers, not vibes. **Mitigated ≠ resolved**: the incident continues at lower urgency.
- No mitigation possible without diagnosis? Say so explicitly and timebox diagnosis in ~15-min sprints, re-checking for mitigation options after each.

## 3. DIAGNOSE — production-safe root-causing

- Run the `root-cause-debug` protocol (hypothesis journal, discriminating experiments) under production constraints:
  - Prefer read-only evidence: logs, metrics, traces, DB reads, reproduction in staging/local.
  - Any production experiment must be reversible or user-approved (non-negotiable 3).
  - Anchor on the timeline: earliest observed symptom, and what immediately preceded it.
- Resist tunnel vision: "the last deploy did it" is a hypothesis, not a verdict — confirm the mechanism before acting on it.

## 4. FIX — through the normal gates

- Fix at the cause. An incident does not excuse skipping `finish-gate` verification — unreviewed hotfixes are how you get the second incident tonight.
- Grep for the same class elsewhere before closing; the sibling bug is often live too.
- Stage the rollout if the platform allows; watch metrics during it.

## 5. VERIFY & MONITOR

- The original symptom is demonstrably gone — show the before/after observation.
- Metrics healthy through a monitoring window sized to the incident's detection latency (default ~30–60 min; an incident that took hours to notice needs a longer window).
- If mitigation was temporary (flag off, scaled up): restore normal state deliberately, one step at a time, watching after each.

## 6. CLOSE

- Timeline completed in the incident file. Final status to the user: impact summary / cause / fix / residual risk.
- Hand off to `postmortem`. The incident is not closed until it exists (false alarm → a 3-line note suffices).
