# fable-orchestrate

English | [日本語](README.ja.md)

A context framework that lifts Opus 4.8 as the lead: briefing and accepting work from subagents (Sonnet 5 / Codex, etc.) at Fable 5 grade.

Sister framework of `fable-lift`. Division of labor:

- **fable-blueprint** — discipline for turning a spec into design, plan, and tickets (upstream; its tickets map 1:1 to this framework's briefs)
- **fable-lift** — discipline for your own hands (verification, debugging, reporting)
- **fable-orchestrate** — discipline for getting work done through others (agents): delegation, acceptance, integration

Install both in the lead session. It works without fable-lift, but the references to `deep-plan` and `long-task-state` pay off fully when combined.

There is also `frameworks/fable-team/`, a team constitution (AGENTS.md form) that distills the whole family into one role-dispatching sheet. Since the repo root can hold only one AGENTS.md: use the fable-team version to run a mixed team (PL + workers) off a single sheet, or this framework's bundled minimal `AGENTS.template.md` when the lead context lives entirely in CLAUDE.md and you only need ground rules for external workers (the fable-team version is a superset of the minimal one).

## The idea — lower-tier orchestration failures boil down to three things

1. **Vague briefs** — tossing over "implement auth" and inviting subagent guesswork and drift. **Brief quality is the ceiling on output quality**; the prime suspect in any failure is the brief.
2. **Taking reports at face value** — subagents (lower tiers especially) over-report success. **A report is testimony, not evidence.** Integrating without independent verification is how accidents happen.
3. **Unplanned parallelism** — fanning out without freezing interfaces, then semantic collisions at merge time. **Freeze, then parallelize; integration is your own job.**

Higher-tier models avoid all three implicitly. This framework writes that down and imposes it as protocols with trigger conditions.

### Honest label

- **What improves**: delegated-task success rate, rework count, integration-accident rate, and the lead's own context efficiency.
- **What doesn't**: the subagents' own capability (that's the job of fable-lift / AGENTS.md on each agent's side). Nor does it make inherently undelegatable work (vague requirements, cross-cutting design) delegatable — the routing table exists largely to say "don't delegate this".

## Structure

```
fable-orchestrate/
├── ORCHESTRATE.template.md         ← lead's resident core (~0.9K tokens). Append to the end of the project's CLAUDE.md
├── AGENTS.template.md              ← ground rules for external agents like Codex. Place at the repo root as AGENTS.md
└── .claude/skills/                 ← on-demand protocols (loaded only when they fire)
    ├── delegate/                   ← decomposition, routing, the 9-field brief, parallelization rules
    └── accept-work/                ← acceptance: independent verification → ACCEPT/PATCH/BOUNCE/RECLAIM
```

Design highlights:

- **Briefs are executor-agnostic** — the same 9-field format works for Claude subagents (the Agent tool) and for Codex (`codex exec`). The litmus test: "could a competent stranger with zero session context execute this?" (Codex literally is one).
- **Acceptance is a 4-way verdict** — ACCEPT / PATCH (fix trivia yourself instead of a round trip) / BOUNCE (evidence-backed, specific, max 2) / RECLAIM (a third bounce is forbidden — rewrite the brief and re-delegate, or take the work back).
- **A brief post-mortem on every bounce** — identify "which single sentence was missing" and add it. This is the flywheel that raises delegation quality.
- **Cross-model review** — have a different model family (Codex ↔ Claude) adversarially review high-risk diffs. Disagreement between models is a "look at it yourself" signal.
- **Sonnet-class brief tuning (v1.1, delegate §3b)** — when the receiver is Sonnet, require not just completeness but machine readability: brevity first (for the same decisions, 60 lines beat 300) / decide everything decidable up front (open points get filled by silent guesses, not questions) / contracts as tests, not prose (one input/output example beats a paragraph of explanation) / fence with a file allowlist / mechanical escalation conditions ("needs a file outside the allowlist", not "if the contract seems off").
- **Pre-send check (v1.1, delegate §3c)** — the PL inspects their own brief before sending: do the Pointers paths exist, do the Done-means commands actually run, is any "as appropriate" / "etc." left in? A brief with hallucinated paths fails at full price.

## Installation

For combined installs with other frameworks (the recommended full stack, etc.), see the README.md at the repo root.

<details>
<summary>Windows (PowerShell)</summary>

```powershell
$storage = "C:\path\to\Fable-Agent-Framework\frameworks\fable-orchestrate"   # ← adjust to where you put this repo
$proj    = "C:\path\to\project"

# 1. Copy the skills (added under .claude/skills/)
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\.claude\skills\*" "$proj\.claude\skills\"

# 2. Append the lead core to the end of CLAUDE.md
Get-Content "$storage\ORCHESTRATE.template.md" -Encoding utf8 | Add-Content "$proj\CLAUDE.md" -Encoding utf8

# 3. Only if using Codex: place the external-agent rules
Copy-Item "$storage\AGENTS.template.md" "$proj\AGENTS.md"
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
storage="/path/to/Fable-Agent-Framework/frameworks/fable-orchestrate"   # ← adjust to where you put this repo
proj="/path/to/project"

mkdir -p "$proj/.claude/skills"
cp -R "$storage/.claude/skills/"* "$proj/.claude/skills/"
cat "$storage/ORCHESTRATE.template.md" >> "$proj/CLAUDE.md"
cp "$storage/AGENTS.template.md" "$proj/AGENTS.md"   # only if using Codex
```

</details>

Afterwards, sync the Project specifics at the end of AGENTS.md with the CLAUDE.md side (external agents need the build/test commands too).

## Codex integration notes

- Codex does not read CLAUDE.md. The delegate skill is written on the assumption that **only the brief + AGENTS.md** are shared.
- The non-interactive CLI form (`codex exec`, etc.) can change across versions — check your local `codex --help` at the destination (the delegate skill carries the same note).
- The execution environment may differ from the lead's (sandboxes, etc.), so always re-verify during acceptance in the lead's environment.

## Delegation-first (v1.2) — implementation goes to workers by default; a judgment, not a ban

Not a hard "Opus never implements" prohibition, but a written-down version of the judgment a Fable-grade lead actually applies (v1.1's hands-on / hands-off mode switch was retired in favor of this principle). **Delegate implementation by default**; move your own hands only when **all four** conditions hold:

1. Speccing it would cost more than doing it (roughly: mechanical work under 15 minutes with no design decision inside)
2. It doesn't pull you deep into implementation context (delegate if you'd need to hold more than 2–3 files in your head)
3. No worker or parallel stream is currently waiting on you
4. Low-risk and reversible (not on a frozen interface, not on the critical path)

**When in doubt, delegate** (the PL's context is the scarcest resource in the system). Bundle accumulated micro-tasks into one brief instead of context-switching for each. Verification and integration are always the PL's job (verification is not implementation — accept-work makes it mandatory, in fact).

The same judgment applies on the acceptance side: PATCH means inline fixes as a rule (round-tripping trivia is the bigger waste), but if it involves multiple files or design decisions and pulls you deep into the implementation, send it back to the implementer as a patch brief. For a session you want to run strictly "no implementation at all", override by user instruction (user instructions always take precedence).

The aim is leverage: reinvest the tokens not spent on implementation into speccing and verification (thicker Gotchas, contracts hardened as tests, deeper acceptance, more parallel streams). To uplift the implementation side, we strongly recommend putting fable-lift into the CLAUDE.md that workers inherit (Claude subagents read the project's CLAUDE.md).

## Operating rules (growing it)

- Same as fable-lift: **add rules by working backward from recurring failures; delete rules that never fire.**
- The highest-value accumulation points: the standing-trap list in the delegate skill's Gotchas field, and the "missing sentence" found by accept-work's post-mortems. Promote frequent project-specific items into the standard brief template rather than Project specifics.

## Known limits

- Text-based discipline is strong steering, not enforcement (same as fable-lift). Mechanical reinforcement of acceptance (a PostToolUse nudge after every subagent return) is available in the optional `frameworks/fable-harness/` module.
- Parallel fan-out costs real money. Just honoring the routing table's "under ~15 minutes: do it yourself" removes most of the waste.
