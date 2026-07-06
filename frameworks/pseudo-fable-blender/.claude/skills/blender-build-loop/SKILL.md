---
name: blender-build-loop
description: Phase-gated Blender build protocol — scene contract (units, naming, idempotent rebuild), blockout with variant exploration and a hard silhouette gate, form and detail passes verified render-by-render, the three-scales-of-detail rule, form-strategy heuristics per shape family (including organic strategies), modifier-stack recipes, bpy rules that survive version drift, checkpoint saves, and an anti-thrash escalation rule. Use whenever building or editing geometry in Blender, after blender-spec has produced the spec.
---

# blender-build-loop — proportions, then forms, then details, verified at each step

Build order is not taste, it is risk management: an error in a phase invalidates everything built after it, so the cheap-to-fix phases come first and each phase ends at a gate. Never skip forward; never detail through a failing gate.

## Phase 0 — scene contract (before any geometry)

- Units: `scene.unit_settings.system = 'METRIC'`; model at real-world scale, 1 unit = 1 m.
- Naming from the spec's part list: `<Asset>_<Part>_<Instance>` (`Chair_Leg_FL`), one collection per assembly group. `Cube.001` surviving to a report is a naming-contract breach.
- Headless mode: ONE canonical build script; it wipes the scene first and rebuilds everything from parameters at the top of the file (the spec's numbers). Re-running the script is the undo system; version the script, not the .blend.
- MCP mode: create-or-replace by name — delete the old object before rebuilding it; never leave `.001` twins.
- Color-block: give each logical part a distinct flat material from the start, so parts stay legible in every probe render.

Scene wipe for idempotent headless builds:

```python
import bpy
for o in list(bpy.data.objects):
    bpy.data.objects.remove(o, do_unlink=True)
for coll in (bpy.data.meshes, bpy.data.materials, bpy.data.cameras, bpy.data.lights, bpy.data.curves):
    for block in list(coll):
        if block.users == 0:
            coll.remove(block)
```

## Phase 1 — blockout → SILHOUETTE GATE

- Primitives only (cube / cylinder / sphere / plane) at spec dimensions and true world positions. Symmetric subject → Mirror modifier from the first primitive; model half.
- **Variant exploration (hero tier, mandatory):** build 2-3 blockout variants that interpret the proportions differently — stance, taper, mass distribution — as sibling collections (`Variant_A/B/C`). Render each variant's 3/4 view, put them side by side, choose with 3 stated reasons, park the losers in a `Variants_Rejected` collection. The first idea is rarely the best one; this is where exploring costs one primitive set instead of a rebuild.
- Probe: `blender-verify` render set + dimension probe.
- **GATE: the silhouette reads as the subject in all 4 canonical views AND overall dims match spec.** Fail → fix proportions here, where it costs one line. Pass → checkpoint (`asset_p1_blockout.blend`, or commit the build script), then and only then continue.

## Phase 2 — form pass, one part at a time

- Refine each part's primary and secondary forms. After EVERY part: one probe render, and look. A change too big to judge in one render was too big a step.
- Stay non-destructive while iterating: modifier stacks instead of applied edits; curves with bevel depth for anything tubular; keep booleans live until QA.
- Typical hard-surface stack order: Mirror → Boolean → Bevel → Subdivision → Weighted Normal — order changes the result and is worth a render check. Bevel modifier: limit by angle, clamp overlap on, harden normals on (pair with the shading rules in `blender-topology`).
- Deviating from real proportions is allowed only deliberately (stylization per the art direction), stated aloud in the loop log — never by accident.

## Phase 3 — detail pass (only after Phase 2 renders pass)

- **Three scales of detail, in this order:** primary (the big forms — already done), secondary (structural features: frames, insets, seams, handles), tertiary (surface interest: panel lines, fasteners, chamfer highlights, wear). A model with only one scale of detail reads as CG regardless of count; a hero asset shows all three, and tertiary never fights the silhouette.
- Bevels: nothing in the real world has a razor edge. Every visible hard edge gets a bevel or crease at real-world size (furniture 1–3 mm, machined parts sub-mm) — visible as an edge highlight in the 3/4 probe. This is the single highest-yield realism move.
- Shading: smooth + smooth-by-angle (API moved in 4.1 — see version rules), Weighted Normal modifier for hard-surface. Read the probes for defects per `blender-topology`.
- Detail placement follows use: wear at contact points (handles, feet, edges people touch), fasteners where parts actually join. Decoration with no story reads as noise.

## Phase 4 — surface & presentation

- Materials per the part list → `blender-materials` (clay renders judge form; beauty renders judge materials — keep the two probes separate).
- Lighting, camera, color management for the beauty/turntable set → `blender-light-camera`.
- Then straight into `blender-verify` final QA and the excellence loop.

## Form-strategy heuristics — choose deliberately, say why

| Shape family | Build with |
|---|---|
| Hard-surface man-made (furniture, machines, buildings) | primitives + booleans + Bevel modifier |
| Tubes, cables, rails, trim, pipes | curves with bevel depth or a profile object |
| Repetition (stairs, fence, treads, columns) | Array/curve modifiers or instanced collections — never hand-copy |
| Symmetric anything | Mirror modifier from the start |
| Rocks, terrain, cloth-like, food | Remesh + Displace (noise texture) on a base form; Subdivision + procedural displacement for surfaces |
| Smooth organic (plush, bottles, ergonomic shells) | subdivision cage modeling — few faces, support loops/creases, let SubD do the smoothing |
| Limbs / branching (creatures, trees) | Skin modifier over an edge-skeleton, then Subdivision; or curve taper for branches |
| Characters, faces, sculpt-grade realism | out of scripted reach at realism — non-negotiable 5: flag it, offer stylized |
| Flat art, logos, text | text/curve objects, extrude + solidify |
| Scatter, foliage, debris fields | geometry nodes / particle instancing over a surface (`blender-scene`) |

## bpy that survives versions

- Probe `bpy.app.version` before the first API call you haven't run this session. Famous movers: `mesh.use_auto_smooth` removed in 4.1 (→ `bpy.ops.object.shade_auto_smooth(angle=...)` or the Smooth by Angle modifier); EEVEE engine id `BLENDER_EEVEE` → `BLENDER_EEVEE_NEXT` in 4.2; several Principled BSDF input names in 4.0. When an attribute errors, `dir()` the owner or `inputs.keys()` and read what exists — do not guess twice.
- Reference by name: `bpy.data.objects["Chair_Seat"]`, never `bpy.context.object` or live selection — headless has no meaningful "active object". Ops that truly need context get an explicit `temp_override`; prefer `bpy.data` / `bmesh`, which need none.
- Headless invocation: `blender --background --factory-startup --python-exit-code 1 --python build.py` — factory startup for a deterministic start state, exit-code so failures surface to the harness. Print structured probe output (see `blender-verify`); stdout is your only telemetry.
- A failed op, or a scene that looks "impossible", twice in a row → stop patching the live scene. Reload the last checkpoint / re-run the build script clean, then debug the SCRIPT with root-cause-debug discipline (state assumption? version drift? stale reference to a deleted datablock?). Never stack fix-ops onto a scene state you can't explain.

## The rhythm

change → probe render → look → name what's wrong, specifically and aloud ("back legs read too thin against the 60 mm spec") → fix → repeat. Gate passed → checkpoint + rubric scores stated. The same visual target failing after 3 distinct attempts → core rule 5: stop, show the renders, present options (different build strategy, need reference, stylize, cut scope). Quality-first also means knowing when the strategy, not the effort, is wrong.
