# pseudo-fable-blender — How to use

English | [日本語](HOWTOUSE.ja.md)

Day-to-day operation after installation. For design rationale and install steps, see [README.md](README.md). This pack activates when the task is 3D modeling in Blender — via bpy scripts (headless) or a Blender MCP — and stays out of the way otherwise. It is quality-first: unless you say "quick", it will assume **hero tier** and spend renders and refinement passes freely.

## What changes once it's installed

- Before any geometry, the agent posts a **spec block**: subject and identity features, art direction, quality tier, target use, real-world dimensions as numbers, budget, and 5-10 measurable done-criteria. You get one veto pass.
- Building happens in **gated phases**: blockout (hero: 2-3 rendered variants to choose from) → silhouette gate → forms → three-scales detail → materials → light & camera. No detailing while the blockout gate fails.
- After every meaningful change the agent renders and reads probe images, naming concrete flaws instead of saying "looks good". Form is judged on **clay renders**, topology on **wireframe renders**, materials only on lit **beauty renders** with real color management.
- Every gate comes with **rubric scores** — six axes, 1–5, each with named evidence — and scores may not silently regress.
- Meeting the spec is not the end: the **excellence loop** critiques the renders like a senior artist (a different lens each pass) and implements the findings — at hero tier until two consecutive passes find only cosmetic items.
- "Done" is a **QA gate**: every criterion mapped to a render file or probe number, hygiene checks (non-manifold = 0, scale applied, no probe/rig leftovers), the full render set attached.

## Kicking off a task well

Give the five highest-yield facts in the first message:

> "Model a **two-seat park bench**, **weathered mid-century** (worn wood, cast iron), for a **still render**, roughly **1.5 m wide** — **hero quality**."

Subject, art direction, target use, size, tier. Everything else can default. If you have reference images and the agent can see them, hand them over at kickoff — for materials and lighting especially, one reference beats a paragraph of adjectives. Say "quick draft" when you only want a blockout-grade result; otherwise expect hero-tier effort (dozens of renders, several refinement passes) by design.

## Your part

| Moment | What you do |
|---|---|
| Spec posted | Sanity-check numbers, art direction, tier, and done-criteria — this is the contract the QA gate uses. Veto now, not at the beauty render. |
| Blockout variants (hero) | You'll get 2-3 grey blockouts rendered side by side with the agent's pick and reasons. Override freely — this is the cheapest steering moment in the whole build. |
| Blockout gate | 4 probe renders of grey primitives. Judge proportions only — ugliness is on schedule here. |
| During form/detail passes | Expect a render after each part, plus rubric scores at each gate. If a change arrives without a render, ask for the probe set. |
| Excellence passes | Expect "senior-artist critique" lists (5 findings, ranked) and the fixes. If it exits early, ask for the pass log — hero needs two consecutive cosmetics-only passes. |
| "Done" claimed | Expect the coverage table, rubric scores with evidence, the excellence log, and the full render set (hero: turntable + close-ups). A criterion without evidence isn't met. |
| Model beyond the medium | "This needs sculpt-grade organic work" is the pack working — pick an option (stylize, provide reference, cut scope) rather than pushing a fourth retry. |

## The protocol at a glance

1. **SPEC** (`blender-spec`) — request → numbers + art direction + tier + done-criteria; assumptions marked; one batch of questions at most.
2. **SCENE CONTRACT** — metric real scale, naming plan, idempotent rebuild, color-blocked parts.
3. **BLOCKOUT → GATE** (`blender-build-loop`) — hero: variants; silhouette must read in all 4 views before anything else happens.
4. **FORMS → DETAILS** — one part at a time, render after each; three scales of detail; bevels on every visible edge; topology per `blender-topology`.
5. **MATERIALS** (`blender-materials`) — clay pass first, then PBR with roughness variation; judged on beauty renders.
6. **LIGHT & CAMERA** (`blender-light-camera`) — AgX/Filmic, three-point rig or HDRI, composed camera; scenes go camera-first via `blender-scene`.
7. **VERIFY & EXCELLENCE** (`blender-verify`) — rubric with evidence, excellence passes until the tier's exit, final QA with the full render set.

## Steering phrases

- "Show me the 4-view probe set." (any time a change went unverified)
- "Show me the variants before you commit." (hero blockout)
- "Blockout gate first — don't detail yet."
- "What are the three flaws in this render?" (when "looks good" appears)
- "Clay render, please — I can't judge the form under those materials."
- "Wireframe pass — that highlight is wobbling."
- "Run the data probe — non-manifold? scale applied? tris vs budget?"
- "Score the rubric and show your evidence."
- "Run another excellence pass — that's not senior-artist clean yet."
- "That's drifting from the spec numbers — seat height was 0.45."
- "This looks beyond scripted fidelity — give me options." (invokes non-negotiable 5)

## Artifacts to watch

- The **spec block** in the conversation (and in `.claude/state/` where long-task-state is installed) — the contract.
- `renders/` — `<prefix>_front|right|top|quarter.png` per iteration, plus `*_clay_*`, `*_wire_*`, `*_turn0..7`, `*_close_*` sets, and the beauty shot(s).
- The **build script** (headless mode) — parameterized, re-runnable, the real deliverable next to the .blend.
- `PROBE {…}` lines — per-object tris, dims, non-manifold counts, scale_applied.
- **Rubric scores** at each gate and the **excellence-pass log** (what each pass changed).
- Checkpoints — `asset_p1_blockout.blend` etc. at each passed gate; `Variants_Rejected` collection for the road not taken.

## With the optional hook layer installed

- Completion reports for Blender work end with the literal line `[blender-qa: pass]` (or `[blender-qa: n/a]` + reason for non-completion stops). If the agent tries to stop without one after Blender activity, the stop bounces with the QA instruction — that's the `stop-blender-qa` hook working, not an error.
- After every headless `blender --background` run you'll see a probe reminder in the feed ("Read every NEW image under renders/ …") — the pack nudging the agent to look, not a failure.
- Silence it per-hook or entirely with `PSEUDO_FABLE_BLENDER_DISABLE=qa,probe|all`; verify registration with `/hooks` after a session restart.
- A `[blender-qa: pass]` without the coverage table and renders behind it is a false marker — call it out; the marker contract makes printing an untrue marker a non-negotiable violation.

## When it misbehaves

- **Ships without rendering** → "Never trust an unseen model — show the probe set." Rhythm is non-negotiable 1.
- **Detailing on wrong proportions** → invoke the blockout gate; details on a failing silhouette are rework by definition.
- **Judging materials and form in one render** → demand the clay pass; that separation exists for a reason.
- **"Looks good" with no findings, repeatedly** → name-the-flaws rule: zero findings twice in a row means it isn't looking.
- **Rubric scores inflate** (a 4 with banding visible) → point at the anchor table in `blender-verify`; scores need evidence, and an axis may not regress silently.
- **Stops right after criteria pass on hero** → "Spec-pass is not done" — demand the excellence passes and the log.
- **`Cube.001` in the outliner / duplicates after a re-run** → scene contract breach; demand semantic names and an idempotent rebuild.
- **bpy AttributeError loops** → "Probe `bpy.app.version` and `dir()` the owner — don't guess twice."
- **Flat, gray, floating renders** → color management + rig + ground plane (`blender-light-camera`); never judge beauty under the Standard transform.
- **Endless retries at an organic shape** → three failed gates at one target triggers options-not-retries; hold it to that.
