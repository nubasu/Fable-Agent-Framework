## Blender 3D modeling — the render is the arbiter

<!-- pseudo-fable-blender v1.0 (2026-07-06) — full-depth, quality-first Blender modeling discipline
     for agents driving bpy scripts (headless CLI) or a Blender MCP. Domain pack: composes with any
     pseudo-fable configuration, or runs alone in a Blender-only repo. Deliberately token-heavy —
     quality is the objective; the depth lives in 7 on-demand skills, this resident core carries the
     laws, the quality tiers, and the triggers. External agents (Codex etc.): append this pack's
     AGENTS.template.md to the repo's AGENTS.md instead — it inlines condensed skill protocols. -->

3D work has two sources of truth, and neither is your intention: **the rendered image** and **the mesh data**. Nobody reviews a diff here — looking at renders IS the review, and a build script that exits 0 has proven nothing about the model. This pack is quality-first: token or iteration cost is never a valid reason to skip a probe, a variant, or a refinement pass.

### Non-negotiables of 3D work

1. **Never trust an unseen model.** After every meaningful change: render (or screenshot via MCP) and actually look, or probe the data. Every claim about the model — "the legs are attached", "it's to scale" — traces to a render viewed or a number probed this session. "The script ran" is not "the model is right".
2. **Proportions before details.** Blockout first: primitives at spec dimensions and positions. No detailing until the blockout silhouette reads as the subject from all four canonical views (front / right / top / 3/4). Detail on wrong proportions is rework, not progress.
3. **The scene is a codebase.** Metric units at real-world scale (1 unit = 1 m). Semantic names (`Chair_Leg_FL` — a scene full of `Cube.001` is unreviewable). Collections as modules. Non-destructive modifiers while iterating. Rebuilds are idempotent: re-running a build never duplicates objects.
4. **bpy is a hostile API.** No implicit context in scripts — reference objects by name, prefer `bpy.data`/`bmesh` over `bpy.ops`, and never trust memorized API: probe `bpy.app.version` and verify any call you haven't run this session (auto-smooth, the EEVEE engine id, Principled input names all moved across 2.8x→4.x).
5. **Honesty about the medium.** Scripted modeling is strong at hard-surface / procedural / stylized work and weak at sculpt-grade organics. When the target exceeds the medium — or the same gate fails three times — stop, show the renders, offer options (stylize, need reference, cut scope). Never silently ship a potato.
6. **Spec-pass is not done.** Meeting the done-criteria ends the build, not the task. The excellence loop (`blender-verify`) then runs — a senior-artist critique of the renders, top findings implemented, re-scored — until it stops producing non-cosmetic findings. First-pass output is a draft by definition.

### Quality tiers — declared in the spec; hero is the default

| Tier | When | Mandates |
|---|---|---|
| draft | user said quick/throwaway | single pass, 4-view probes + data probe, no materials beyond color-block |
| production | user said "usable asset" | all phases, rubric ≥3 on every axis, 1 excellence pass |
| **hero** (default when unstated) | "best possible" is this pack's default | blockout variants (2-3, rendered, chosen with reasons), rubric ≥4 on every axis, excellence passes until 2 consecutive passes find only cosmetics, turntable + close-ups, lit beauty render with real color management |

### Phase map — each phase ends at a gate; a failing gate sends you back, never forward

SPEC (`blender-spec`) → BLOCKOUT + silhouette gate, with variants at hero (`blender-build-loop`) → FORMS → TOPOLOGY & DETAIL (`blender-topology`) → MATERIALS (`blender-materials`) → LIGHT & CAMERA (`blender-light-camera`) → VERIFY & EXCELLENCE (`blender-verify`). Multi-asset scenes wrap this per-asset loop in `blender-scene` (camera-first layout, quality budget by camera proximity).

### The rubric — six axes, scored 1–5 aloud at every gate (anchors in `blender-verify`)

silhouette & proportion · topology & shading · detail (three scales) · material realism · lighting & presentation · spec fidelity. Scores come with evidence (which render, which number). An axis may never regress between gates without a stated reason.

### Drive mode

Declare at task start which you are in: **MCP** (live scene; its screenshot/viewport tool is the render probe) or **headless CLI** (one canonical build script: `blender --background --factory-startup --python-exit-code 1 --python build.py`; render probes to PNG, then read the image files). Recipes live in `blender-verify`.

### QA marker

End a completion report for Blender work with the literal line `[blender-qa: pass]` — printed only when `blender-verify`'s final QA truly passed. A stop that is NOT a completion claim (mid-build status, awaiting the user's spec veto, blocked) ends with a one-line reason plus `[blender-qa: n/a]`. Printing a marker that is not true is a non-negotiable violation. (The pack's optional hook layer bounces marker-less stops after Blender work; the ritual holds with or without it.)

### Hard triggers

| Situation | Invoke |
|---|---|
| New modeling task, or the request fits in one vague sentence | `blender-spec` — spec, references, quality tier, measurable done-criteria |
| Starting to build; entering blockout / form / detail phases | `blender-build-loop` — phase-gated build, variants, form strategies |
| Curved surfaces misbehaving, subdiv work, boolean cleanup, shading artifacts | `blender-topology` — edge flow, ngon policy, boolean hygiene, shading toolbox |
| Assigning any material beyond color-block | `blender-materials` — PBR realism rules, roughness variation, clay/beauty split |
| Any beauty render; lighting or framing decisions | `blender-light-camera` — color management, light rigs, camera & composition |
| Multiple assets / an environment / "make a scene" | `blender-scene` — camera-first layout, scale truth, instancing, quality budget |
| Every phase gate, any "does it look right?", and before reporting done | `blender-verify` — probe armory, rubric, excellence loop, final QA |
| A build-script bug survives its first fix | `root-cause-debug` where installed — scene state is evidence too |
