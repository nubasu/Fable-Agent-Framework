## Blender 3D modeling — rules for this repo's modeling work

<!-- pseudo-fable-blender v1.0 (2026-07-06) — full-depth, quality-first Blender discipline for
     external agents (Codex etc.) that read AGENTS.md and have no skills mechanism. Self-contained:
     condensed versions of all seven skill protocols (spec / build-loop / topology / materials /
     light-camera / scene / verify) are inlined. Append this section to the repo's AGENTS.md; if the
     repo has none, use it as the AGENTS.md body (add a Project specifics section) — do not install
     a second AGENTS.md file. -->

When the task is 3D modeling in Blender, these rules override generic coding instincts. 3D work has two sources of truth, and neither is your intention: **the rendered image** and **the mesh data**. A build script that exits 0 has proven nothing. This pack is quality-first: iteration cost is never a reason to skip a probe, a variant, or a refinement pass.

### Non-negotiables

1. **Never trust an unseen model.** After every meaningful change, render (or screenshot) and actually look, or probe the data. Every claim about the model traces to a render viewed or a number probed this session.
2. **Proportions before details.** Blockout first; no detailing until the blockout silhouette reads as the subject from all four canonical views. Detail on wrong proportions is rework, not progress.
3. **The scene is a codebase.** Metric, 1 unit = 1 m, real-world scale. Semantic names (`Chair_Leg_FL`, never `Cube.001`). Collections as modules. Idempotent rebuilds — re-running your build never duplicates objects.
4. **bpy is a hostile API.** Reference objects by name, never `bpy.context.object`; prefer `bpy.data`/`bmesh` over `bpy.ops`. Probe `bpy.app.version` before any call you haven't run this session — memorized API is stale (auto-smooth moved in 4.1, the EEVEE id in 4.2, Principled input names in 4.0); on AttributeError, `dir()` the owner, don't guess twice.
5. **Honesty about the medium.** Scripted modeling is weak at sculpt-grade organics. When the target exceeds the medium — or the same gate fails three times — stop, show the renders, present options. Never silently ship a bad model.
6. **Spec-pass is not done.** Meeting the done-criteria ends the build, not the task; the excellence loop below runs until a senior-artist critique of the renders stops finding non-cosmetic improvements.

### Quality tiers — hero is the default when unstated

draft (user said quick): one pass, 4-view + data probes. · production: all phases, rubric ≥3 everywhere, 1 excellence pass. · **hero** (default): blockout variants, rubric ≥4 everywhere, excellence passes until 2 consecutive find only cosmetics, turntable + close-ups, color-managed beauty.

### 1 — SPEC before geometry

Post a spec block: subject + the 3-5 identity features; art direction (3-5 style words and what they imply); quality tier; target use (render / game / print — drives budget, topology, units strictness); real-world dimensions as NUMBERS (reference if reachable, else typical values: chair seat 0.45 m, table 0.74, door 2.0×0.9, mug 95×80 mm, sedan 4.5×1.8×1.45, human 1.7); tri budget (render ≤500k, game prop 2–20k, print: watertight over count); materials plan. Mark every guess `assumed`; ask only what cannot be defaulted, in one batch. Then 5-10 **measurable done-criteria** (silhouette reads in 4 views; dims ±5%; 0 non-manifold; parts named; identity features visible; rubric floor for the tier). "Looks nice" is not a criterion.

### 2 — BUILD in gated phases

- **P0 scene contract:** metric units; naming plan; one canonical build script that wipes and rebuilds from parameters (`blender --background --factory-startup --python-exit-code 1 --python build.py`); color-block parts with distinct flat materials.
- **P1 blockout → GATE:** primitives at spec dims (Mirror modifier from the start when symmetric). Hero: build 2-3 proportion variants, render 3/4 of each, choose with 3 stated reasons. Gate: silhouette reads in all 4 views AND dims match spec — then checkpoint, then continue.
- **P2 forms:** one part at a time, a probe render after every part. Non-destructive stacks (typical order Mirror → Boolean → Bevel → Subdivision → Weighted Normal); curves for tubes; arrays/instances for repetition — never hand-copy.
- **P3 details — three scales:** secondary (frames, insets, seams, handles) then tertiary (panel lines, fasteners, wear at contact points). One-scale models read as CG regardless of polycount; tertiary never fights the silhouette. Bevel/crease every visible hard edge at real size (furniture 1–3 mm) — the single highest-yield realism move.
- **P4 surface & presentation:** materials, then lighting/camera, then verify (digests below).
- Anti-thrash: an unexplainable scene state twice in a row → reload checkpoint / re-run the build clean and debug the SCRIPT; never stack fix-ops. Same visual target failing 3 attempts → non-negotiable 5.

### 3 — TOPOLOGY: shading is topology made visible

Quads on curved/deforming surfaces (poles and triangles pinch there); one clean n-gon beats a sliver fan on hard-surface flats; triangulate only at export. SubD: light cages, support loops or creases (not randomly both) to hold edges. Booleans are a loan — repay with: merge by distance ~1e-5, dissolve slivers along the seam, re-probe non-manifold = 0, check the seam under smooth shading. Shade smooth + smooth-by-angle (4.1+: `shade_auto_smooth` op / Smooth by Angle modifier; ≤4.0: `mesh.use_auto_smooth`); Weighted Normal modifier last for hard-surface. Symptom → cause: black facets = flipped normals (`bmesh.ops.recalc_face_normals`); banding = missing smooth-by-angle; pinching star = pole on curvature; wobbly edge highlight = uneven support loops; smeared flat = sliver triangles.

### 4 — MATERIALS: realism is mostly roughness, not color

Judge form on clay (uniform gray override pass), materials on beauty — never both in one render. Principled values: albedo 0.03–0.85 (never pure 0/1), saturation < 0.6 for realism; metallic binary 0/1 with the metal's color in Base Color; IOR ~1.45 dielectrics. **Uniform roughness = CG plastic** — every material gets subtle roughness variation (Noise Texture scale 4–8 → narrow ColorRamp → Roughness, ±0.05–0.15 around the base: polished metal 0.15, brushed 0.35, wood satin 0.4, matte paint 0.6). Set inputs defensively: `bsdf.inputs.get("Roughness")` — on None, print the actual `inputs.keys()` and use what exists. Parts separate by VALUE first, hue second; 60-30-10 palette. UVs only when image textures / exact placement / game export demand them; otherwise procedural or box mapping.

### 5 — LIGHT & CAMERA: half of perceived quality is presentation

Color management BEFORE judging any lit render: `view_settings.view_transform = 'AgX'` (4.0+) or `'Filmic'` (older) — never `Standard`; iterate exposure in ±0.5 steps. Three-point rig scaled to the subject: key area light at 45° up-left, fill ~1/3–1/4 of key opposite, rim behind for silhouette separation; ground plane (~10× subject, gray 0.4) for the contact shadow — prefix all rig objects `Rig_` and the plane `Rig_Ground`. Camera 50–85 mm for subjects (wide only for interiors), subject ~65-75% of frame height, 3/4 view is the money shot, DOF off by default. Engines: Workbench = form probes; EEVEE = iteration beauty (id version-gated; needs a GPU/display even in `--background`); Cycles = final hero (128–256 samples + denoise; CPU works headless).

### 6 — SCENES are shots, not worlds

Compose the camera FIRST (proxy-block the framing), then dress what it sees. Quality budget by camera proximity: hero asset = full loop; mid props = forms + basic materials; background = blockout + color at correct scale. Scale truth via human-metric anchors (door 2.0, ceiling 2.4–2.7, seat 0.45, counter 0.9) — one wrong prop breaks the shot; render a hidden 1.7 m human proxy once as the audit. Layout order: architecture → hero at the power position → functional props (placement tells a story) → clearances (walkway ≥0.8, chair pull-out 0.75, nothing intersects) → instanced scatter with ±10-20% rotation/scale variation. Density gradient toward the focal point; empty space is a feature. Motivated light: the window/lamp is the key, one dominant direction.

### 7 — VERIFY with renders and numbers, then the excellence loop

**Probe renders** — standard 4-view set, identical rig every time: FRONT (−Y), RIGHT (+X), TOP (+Z) orthographic + 3/4 perspective; cameras auto-framed on the scene bbox (exclude `Probe_/Wire_/Rig_` prefixes from framing), created as `Probe_*` (delete-and-recreate = idempotent), aimed with `(target - cam.location).to_track_quat('-Z','Y')`, Workbench engine, ≥1280 px, saved under `renders/`. Variants: clay pass (stash materials → assign gray clay → render → restore), wireframe pass (duplicate each mesh as `Wire_*` + Wireframe modifier, dark material), hero turntable (8 orbit steps), close-ups (85 mm on each identity feature). **Open every image** — a render nobody viewed verifies nothing. Read in order: squint test → proportion ratios vs spec numbers → grounding/contact shadow → shading defects → detail scales; name the top 2-3 flaws each round and fix or defer each explicitly; zero findings twice in a row means you are not looking.

**Data probe** — one `PROBE {json}` line per run; per mesh (skip `Probe_/Wire_/Rig_`): evaluated tris (`evaluated_get(depsgraph)` + `to_mesh()`), `dims_m`, non-manifold edges (bmesh: `not e.is_manifold and not e.is_boundary` — 0, or it blocks print/QA), boundary edges (0 for solids), loose verts (0), `scale_applied` (`obj.scale == 1,1,1` — apply before trusting bevels), modifiers, materials.

**Rubric** — six axes scored 1–5 aloud with evidence at every gate: silhouette & proportion · topology & shading · detail (three scales) · material realism · lighting & presentation · spec fidelity. A 4 means: stranger names the subject unprompted / shading clean at render distance / all three detail scales present / highlight breakup + value separation / AgX + readable key-fill-rim + contact shadow / every criterion evidenced. Floors: production ≥3, hero ≥4, no axis regresses between gates without a stated reason.

**Excellence loop** — after criteria pass: fresh full probe set → critique the renders as a senior artist (rotate the lens each pass: form purist → materials nerd → photographer), list exactly 5 improvements ranked by visual impact, classify structural/surface/presentation/cosmetic → implement all non-cosmetic (deferrals need a reason; effort is not one) → re-probe, re-score, no axis regresses. Production: one pass. Hero: repeat until two consecutive passes yield only cosmetics.

### Report format — end your run with exactly this structure

```markdown
## RESULT: DONE | BLOCKED | DEVIATED
## Spec coverage: <each done-criterion → the render file / probe number that proves it>
## Rubric: <six scores + one-line evidence each>
## Excellence log: <passes run → what each changed>
## Renders: <paths: 4-view set, clay/wire, beauty; hero: turntable + close-ups>
## Probe summary: <tris, dims vs spec, non-manifold, scale_applied — numbers pasted, not recalled>
## Deviations & assumptions: <stylization choices, spec conflicts, API surprises>
## Not done: <anything remaining>
(≤ 60 lines total)
```
