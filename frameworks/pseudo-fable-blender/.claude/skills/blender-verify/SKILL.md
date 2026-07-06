---
name: blender-verify
description: Verification and quality-gate protocol for Blender work — the probe armory (auto-framed 4-view rig, clay pass, wireframe pass, turntable, close-ups, data probes), the critical-reading order, the six-axis rubric with anchored scores per quality tier, the excellence loop (senior-artist critique passes until only cosmetics remain), and the final QA gate mapping every spec criterion to render or probe evidence. Use at every build-loop gate, whenever unsure the model is right, and always before reporting a modeling task done.
---

# blender-verify — eyes and instruments for a model you cannot unit-test

Two probe families, and verification means both: **renders** catch what numbers can't (a chair with perfect dimensions can still look wrong), **data probes** catch what eyes can't (a hidden non-manifold edge, an unapplied scale silently skewing every bevel). On top of both sits the rubric — the score sheet that keeps "better" measurable — and the excellence loop, which is where spec-pass becomes actual quality.

## Naming contract for probe machinery

Presentation rig objects are prefixed `Rig_` (lights, the ground plane `Rig_Ground`), probe cameras `Probe_`, wireframe duplicates `Wire_`. Framing math excludes all three prefixes; deliverable scenes contain none of them (final QA checks).

## The probe armory

All snippets are idempotent — safe to call after every step. Engines: Workbench renders anywhere; **EEVEE needs a GPU/display even in `--background`** — on a truly headless server, form-probe with Workbench and beauty-render with Cycles (CPU works).

```python
import bpy, os, math, json, bmesh
from mathutils import Vector

def scene_bbox():
    objs = [o for o in bpy.data.objects if o.type == 'MESH'
            and not o.name.startswith(("Probe_", "Wire_", "Rig_"))]
    pts = [o.matrix_world @ Vector(c) for o in objs for c in o.bound_box]
    lo = Vector([min(p[i] for p in pts) for i in range(3)])
    hi = Vector([max(p[i] for p in pts) for i in range(3)])
    return (lo + hi) / 2, hi - lo

def set_engine(kind):
    scene = bpy.context.scene
    if kind == 'WORKBENCH':
        scene.render.engine = 'BLENDER_WORKBENCH'
    elif kind == 'EEVEE':
        scene.render.engine = 'BLENDER_EEVEE_NEXT' if bpy.app.version >= (4, 2, 0) else 'BLENDER_EEVEE'
    else:
        scene.render.engine = 'CYCLES'
        scene.cycles.samples = 128
        scene.cycles.use_denoising = True

def _shoot(cam, path):
    scene = bpy.context.scene
    scene.camera = cam
    scene.render.filepath = os.path.abspath(path)
    bpy.ops.render.render(write_still=True)

def probe_renders(prefix, engine='WORKBENCH'):
    """The standard 4-view set: front/right/top ortho + 3/4 perspective."""
    for old in [o for o in bpy.data.objects if o.name.startswith("Probe_")]:
        bpy.data.objects.remove(old, do_unlink=True)
    center, size = scene_bbox()
    d = max(size) * 2.5
    set_engine(engine)
    scene = bpy.context.scene
    scene.render.resolution_x = scene.render.resolution_y = 1280
    os.makedirs("renders", exist_ok=True)
    views = {"front": (0, -d, 0), "right": (d, 0, 0),
             "top": (0, 0, d), "quarter": (d * .8, -d * .8, d * .6)}
    for name, off in views.items():
        cam_data = bpy.data.cameras.new(f"Probe_{name}")
        if name != "quarter":
            cam_data.type = 'ORTHO'
            cam_data.ortho_scale = max(size) * 1.3
        cam = bpy.data.objects.new(f"Probe_{name}", cam_data)
        scene.collection.objects.link(cam)
        cam.location = center + Vector(off)
        cam.rotation_euler = (center - cam.location).to_track_quat('-Z', 'Y').to_euler()
        _shoot(cam, f"renders/{prefix}_{name}.png")

def probe_clay(prefix):
    """Uniform gray pass — judge FORM without material noise. Needs the light rig."""
    clay = bpy.data.materials.get("Probe_Clay") or bpy.data.materials.new("Probe_Clay")
    clay.use_nodes = True
    bsdf = next(n for n in clay.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
    for sock, val in (("Base Color", (0.5, 0.5, 0.5, 1.0)), ("Roughness", 0.6)):
        s = bsdf.inputs.get(sock)
        if s is not None:
            s.default_value = val
    stash = {}
    for o in [o for o in bpy.data.objects if o.type == 'MESH'
              and not o.name.startswith(("Probe_", "Wire_", "Rig_"))]:
        stash[o.name] = list(o.data.materials)
        o.data.materials.clear()
        o.data.materials.append(clay)
    probe_renders(prefix + "_clay", engine='EEVEE')
    for name, mats in stash.items():
        me = bpy.data.objects[name].data
        me.materials.clear()
        for m in mats:
            me.materials.append(m)

def probe_wireframe(prefix):
    """Topology pass — dark wires overlaid via duplicate + Wireframe modifier."""
    wire_mat = bpy.data.materials.get("Wire_Mat") or bpy.data.materials.new("Wire_Mat")
    wire_mat.diffuse_color = (0.02, 0.02, 0.02, 1.0)
    dups = []
    for o in [o for o in bpy.data.objects if o.type == 'MESH'
              and not o.name.startswith(("Probe_", "Wire_", "Rig_"))]:
        dup = o.copy()
        dup.data = o.data.copy()
        dup.name = f"Wire_{o.name}"
        bpy.context.scene.collection.objects.link(dup)
        mod = dup.modifiers.new("Wire", 'WIREFRAME')
        mod.thickness = max(o.dimensions) * 0.002 + 1e-5
        mod.use_replace = True   # wires only — the original underneath provides the body
        dup.data.materials.clear()
        dup.data.materials.append(wire_mat)
        dups.append(dup)
    try:
        bpy.context.scene.display.shading.color_type = 'MATERIAL'
    except AttributeError:
        pass   # attribute location differs in some builds — wires still read by shading
    probe_renders(prefix + "_wire")
    for dup in dups:
        me = dup.data
        bpy.data.objects.remove(dup, do_unlink=True)
        bpy.data.meshes.remove(me)

def probe_turntable(prefix, steps=8, engine='EEVEE'):
    """Hero presentation — orbit at 3/4 elevation under the current rig."""
    for old in [o for o in bpy.data.objects if o.name.startswith("Probe_")]:
        bpy.data.objects.remove(old, do_unlink=True)
    center, size = scene_bbox()
    d = max(size) * 2.5
    set_engine(engine)
    cam_data = bpy.data.cameras.new("Probe_turn")
    cam = bpy.data.objects.new("Probe_turn", cam_data)
    bpy.context.scene.collection.objects.link(cam)
    for i in range(steps):
        a = 2 * math.pi * i / steps
        cam.location = center + Vector((math.cos(a) * d, math.sin(a) * d, d * 0.5))
        cam.rotation_euler = (center - cam.location).to_track_quat('-Z', 'Y').to_euler()
        _shoot(cam, f"renders/{prefix}_turn{i}.png")

def probe_closeup(prefix, object_name, engine='EEVEE'):
    """Detail-zone inspection — 85mm perspective framed on one object."""
    o = bpy.data.objects[object_name]
    pts = [o.matrix_world @ Vector(c) for c in o.bound_box]
    lo = Vector([min(p[i] for p in pts) for i in range(3)])
    hi = Vector([max(p[i] for p in pts) for i in range(3)])
    center, size = (lo + hi) / 2, hi - lo
    d = max(max(size), 1e-3) * 2.2
    set_engine(engine)
    cam_data = bpy.data.cameras.new("Probe_close")
    cam_data.lens = 85
    cam = bpy.data.objects.new("Probe_close", cam_data)
    bpy.context.scene.collection.objects.link(cam)
    cam.location = center + Vector((d * .7, -d * .7, d * .45))
    cam.rotation_euler = (center - cam.location).to_track_quat('-Z', 'Y').to_euler()
    _shoot(cam, f"renders/{prefix}_close_{object_name}.png")
    bpy.data.objects.remove(cam, do_unlink=True)

def probe_data():
    """Numbers pass — one PROBE json line; parse, don't recall."""
    out, deps = {}, bpy.context.evaluated_depsgraph_get()
    for o in bpy.data.objects:
        if o.type != 'MESH' or o.name.startswith(("Probe_", "Wire_", "Rig_")):
            continue
        o_eval = o.evaluated_get(deps)
        me = o_eval.to_mesh()
        tris = sum(len(p.vertices) - 2 for p in me.polygons)
        o_eval.to_mesh_clear()
        bm = bmesh.new()
        bm.from_mesh(o.data)
        out[o.name] = {
            "dims_m": [round(v, 4) for v in o_eval.dimensions],
            "tris_evaluated": tris,
            "non_manifold_edges": sum(1 for e in bm.edges if not e.is_manifold and not e.is_boundary),
            "boundary_edges": sum(1 for e in bm.edges if e.is_boundary),
            "loose_verts": sum(1 for v in bm.verts if not v.link_edges),
            "scale_applied": all(abs(s - 1) < 1e-4 for s in o.scale),
            "modifiers": [m.type for m in o.modifiers],
            "materials": [m.name for m in o.data.materials if m],
        }
        bm.free()
    print("PROBE " + json.dumps(out))
    return out
```

MCP mode: the screenshot/viewport tool substitutes for `probe_renders` (same four directions — the angles are the contract, the mechanism is free); run the data probe and the clay/wire passes as `execute-code` calls with the same snippets.

**Then look.** Open/Read every image. A render nobody viewed verifies nothing.

## Reading a render critically — in this order

1. **Squint test** — does the silhouette alone read as the subject?
2. **Proportions** — check 2-3 part-to-whole ratios against the spec numbers, not against feel.
3. **Grounding** — sits on Z=0? Parts floating, or intersecting at joints? Contact shadow present in lit passes?
4. **Shading defects** — black facets, banding, pinching, wobbling highlights → diagnose via the `blender-topology` symptom table, confirm in the wire pass.
5. **Detail scales** — are primary/secondary/tertiary all present, and does density follow visual importance?
6. **Name the flaws.** State the top 2-3 concrete differences from spec/reference and fix or explicitly defer each. "Looks good" with zero findings, twice in a row, means you are not looking — name what you would improve with one more hour.

## Data probe interpretation

| Signal | Healthy | When it isn't |
|---|---|---|
| `non_manifold_edges` | 0 | interior faces / bad booleans — find and delete; blocks 3D print outright |
| `boundary_edges` | 0 for solids | fine only for deliberately open meshes — justify or close |
| `loose_verts` | 0 | leftovers from deleted geometry — clean |
| `scale_applied` | true before bevel/boolean judgments and at QA | non-uniform scale silently skews bevel widths and modifier math — `transform_apply` |
| `tris_evaluated` | ≤ budget, distributed by visual importance | over budget → reduce subdivision/detail, don't renegotiate the spec silently |
| `dims_m` | within spec tolerance | fix the model, not the criterion |

## The rubric — six axes, 1–5, anchored

Score aloud at every gate, each score with its evidence (which render, which number). Anchors for 2 and 4; 1/3/5 interpolate, and 5 is reserved for "a senior artist would praise it, not just pass it".

| Axis | A 2 looks like | A 4 looks like |
|---|---|---|
| Silhouette & proportion | subject identifiable only with the caption; ratios off vs spec | a stranger names the subject unprompted from any of the 4 views; dims probe within tolerance |
| Topology & shading | banding/pinching visible at normal viewing distance | shading clean at final-render distance; defects findable only in close-ups, and diagnosed |
| Detail (three scales) | one scale only — bare primitives or uniform noise | primary+secondary+tertiary present; tertiary respects the silhouette; density follows the eye |
| Material realism | uniform roughness, full-sat colors, 0.5 metallic everywhere | albedo in range, highlight breakup from roughness variation, parts separated by value |
| Lighting & presentation | default lamp, Standard transform, subject floating on void | AgX/Filmic, readable key/fill/rim, contact shadow, composed camera with the rule stated |
| Spec fidelity | ≥1 done-criterion unmet or unproven | every criterion evidenced; assumptions honored; deliverables complete |

Tier floors: draft = no floor (probes still run) · production = ≥3 on every axis · hero = ≥4 on every axis. An axis may never regress between gates without a stated reason.

## The excellence loop — where spec-pass becomes quality (production: 1 pass · hero: until dry)

1. **Fresh probes** — re-render the full set (4-view, clay, wire, beauty; hero adds turntable + close-ups of the 2-3 identity/detail zones). No judging stale renders.
2. **Critique in persona** — review the renders as a senior artist of the relevant discipline, a different lens each pass (form purist → materials nerd → photographer). List exactly 5 improvements ranked by visual impact; classify each: `structural` (form/proportion) / `surface` (topology/material) / `presentation` (light/camera) / `cosmetic`.
3. **Implement** every non-cosmetic item unless it conflicts with the spec or art direction — a deferral needs a stated reason, and effort is not a reason (this pack is quality-first).
4. **Re-probe and re-score** the rubric. No axis may regress.
5. **Exit**: production exits after one pass; hero repeats until **two consecutive passes produce only cosmetic items**. Report the pass count and what each pass changed.

## Final QA gate — before any "done"

1. **Spec coverage table** — every done-criterion from `blender-spec` → the render file or probe number that proves it. A row without evidence is an unmet criterion, and the task is still "in progress".
2. **Hygiene defaults** (even if the spec forgot them): semantic names everywhere, scale applied, 0 non-manifold, budget respected, collections organized, no `Probe_*`/`Wire_*`/`Rig_*` leftovers in the deliverable scene (presentation rigs ship only if the spec includes the lighting setup).
3. **Deliverables listing** — the files that exist now: .blend and/or build script, the probe sets, beauty render(s), turntable and close-ups at hero, the probe JSON.
4. **Honest report** — outcome first; then the coverage table, rubric scores with evidence, excellence-pass log (what each pass changed), assumptions and deliberate stylizations, known limitations (what a human artist would still improve), and follow-up options. Renders attached/linked — the user judges pictures, not adjectives.
5. **Marker** — end the report with the literal line `[blender-qa: pass]`. It is this gate's signature: print it only when steps 1–4 are actually true (the pack's optional hook layer enforces its presence; only you enforce its truth). Non-completion stops use `[blender-qa: n/a]` + a one-line reason instead.

Where pseudo-fable-lift is installed this gate feeds `finish-gate` (it is the domain half of Gate B/C evidence); it never replaces it.
