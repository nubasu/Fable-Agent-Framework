---
name: deep-plan
description: Plan a non-trivial change before writing code — requirements contract, recon of the actual code, 2-3 materially different approaches, verifiable milestones, and a pre-mortem. Use when a task touches 3+ files, involves a design decision, or looks longer than ~30 minutes.
---

# deep-plan — think before you build

Run the steps in order and produce each output. Then start milestone 1.

## 1. Contract
- Number every explicit requirement in the user's request.
- Add implicit requirements that clearly apply (backward compatibility, performance envelope, stability of existing APIs).
- Write 2–3 **non-goals**: adjacent things you will NOT do. This is what prevents scope drift later.

## 2. Recon — read before deciding
- Locate: the entry points you will touch, the nearest existing feature similar to what you are building (you will copy its shape — name the file), and the data flow through the affected area.
- Record each key site as `path:line` — these anchor the milestones.
- Bar to clear: if you cannot name the file each change goes into, recon is not done.

## 3. Alternatives — break the anchor
- Write 2–3 **materially different** approaches: different mechanism or different layer, not parameter tweaks of one idea. Your first idea is a candidate, not the winner.
- For each: essence in one line / main risk / blast radius / rough effort.
- Choose with a one-sentence justification tied to the contract. When two are close, prefer the one that is easier to revert.

## 4. Milestones
- Slice the work so every milestone ends in an observable state: a command to run plus what you expect to see.
- Order by uncertainty: spike the riskiest unknown first, polish last.

## 5. Pre-mortem
- "This change shipped and caused an incident / got reverted. The three most likely reasons are:" — write them, and attach a mitigation or a concrete check to each (usually a specific test, or a milestone reordering).

## 6. Output
- Present: contract, chosen approach and why (including what you rejected), milestones, pre-mortem risks.
- Long task? Write the plan into the `long-task-state` file, not chat alone.
- Then begin milestone 1.
