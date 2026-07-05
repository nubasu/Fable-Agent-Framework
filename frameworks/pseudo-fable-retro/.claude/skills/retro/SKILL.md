---
name: retro
description: Harvest lessons and grow the rule set — after a milestone, a bounce, or a failed-fix spiral, extract what failed or dragged, identify the missing sentence that would have prevented it, route it to the narrowest effective home (Gotchas / project CLAUDE.md / store templates / memory / nowhere), and periodically prune rules that never fire. Use at milestone completion, after any bounce or reclaim, after an incident, and ~weekly for rule inventory.
---

# retro — rules are grown from failures, not ideas

The family's premise: every rule must earn its context cost. This skill is the mechanism that adds the ones that will, and removes the ones that stopped.

## 1. Harvest — what actually went wrong or dragged?

Scan the just-finished work for:

- **Failures** — bounces, reverts, finish-gate findings, assumptions that survived too long before being falsified.
- **Drag** — anything that took ≥2 attempts; rediscovery of a trap somebody (possibly you) already knew; questions whose answers existed somewhere unread.
- **Surprises** — "I didn't expect X". A surprise is an unpriced risk; price it now.

For each: one line — what happened, and the moment it became inevitable.

## 2. The missing sentence

For each item, ask the family's question: **which single sentence, present in which document, would have prevented this?**

- If you cannot phrase the sentence, you have not understood the failure yet — dig once more (root-cause thinking applies to process failures too).
- If the sentence would not actually have been read at the moment it was needed, it is the wrong sentence or the wrong home — fix that, not the wording.

## 3. Route — the placement table

Default to the **narrowest** scope that still catches the recurrence; a rule in too broad a home is noise for everyone else.

| Lesson scope | Home |
|---|---|
| This repo's concrete trap (flaky test, generated file, odd build step) | Project CLAUDE.md / AGENTS.md — **Gotchas** or Project specifics |
| A trap delegated workers keep hitting | The PL's standing brief Gotchas (pseudo-fable-orchestrate `delegate` §3) |
| This project's recurring process failure | Project CLAUDE.md — as a rule WITH a trigger |
| Generic — would recur in any project | The store's framework templates: **propose the edit to the user** (the store is shared across projects — never edit it silently), bump the version comment |
| About the user's preferences or workflow | Agent memory, if the harness provides one |
| One-off, unlikely to recur | **Nowhere.** Not every lesson deserves a rule — note it in the task report and let it go. |

## 4. Prune — rules must keep earning their place (periodic inventory)

- Walk the project CLAUDE.md rules and Gotchas. For each: has it changed behavior recently?
- Never fired since added, and ≥~10 tasks have passed → delete, or demote to a comment.
- Fired wrongly (overhead without catching anything) → rewrite the trigger, or delete.
- Unsure? Keep a rough tally in the state file: `rule → last fired: <task/date>`, and decide next inventory.

## 5. Constraints — retro's own failure mode is rule inflation

- **Add at most 2 rules per retro.** Harvested five lessons? Keep the two with the highest recurrence-probability × cost; report the rest as observations.
- Every added rule ships with: a trigger (when it fires), an action, and the failure it prevents (one line, as a comment or ledger note).
- Deleting a rule is as valuable as adding one. A retro that only ever adds is broken.
