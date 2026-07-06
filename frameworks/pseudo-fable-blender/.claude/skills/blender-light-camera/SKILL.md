---
name: blender-light-camera
description: Lighting, camera, and color-management discipline for Blender beauty renders — view transform first (AgX/Filmic, never Standard), a scripted three-point studio rig, HDRI and ground-plane setup, key/fill/rim ratios, camera focal length and composition rules, engine choice per purpose (workbench/EEVEE/Cycles), and exposure iteration. Use before any beauty render, whenever a render "looks flat or CG", and for the final presentation set (beauty, turntable, close-ups).
---

# blender-light-camera — half of perceived quality is presentation

The same mesh can look like a student exercise or a product shot; the difference is light, camera, and color management. Weak agents render with the default point lamp, a 50mm camera jammed too close, and the Standard view transform — three defaults that each cost more quality than a day of modeling. This skill replaces them.

## Color management FIRST — before judging any lit render

- View transform: **AgX** (Blender 4.0+) or **Filmic** (2.8x–3.x). `Standard` clips highlights and flattens color — beauty renders judged under it are judged wrong. Probe the enum if unsure: assigning an invalid name raises, and the error lists nothing — read `bpy.types.ColorManagedViewSettings.bl_rna.properties['view_transform']` or just try AgX→Filmic in order.

```python
import bpy
vs = bpy.context.scene.view_settings
vs.view_transform = 'AgX' if bpy.app.version >= (4, 0, 0) else 'Filmic'
vs.look = 'AgX - Base Contrast' if bpy.app.version >= (4, 0, 0) else 'Medium High Contrast'
vs.exposure = 0.0   # iterate: render, look, adjust in ±0.5 steps
```

- Exposure is iterated like everything else: render → histogram-by-eye (highlights not clipped, shadows not crushed) → adjust → re-render. Two rounds usually suffice.

## The scripted three-point rig (starting values — then iterate by render)

```python
import bpy
from mathutils import Vector

def rig_three_point(center, size):
    for old in [o for o in bpy.data.objects if o.name.startswith("Rig_")]:
        bpy.data.objects.remove(old, do_unlink=True)
    d = max(size)
    spots = {"Key":  (( 1.2, -1.0, 1.4), 4.0),   # position (×d), relative power
             "Fill": ((-1.4, -1.2, 0.6), 1.0),
             "Rim":  ((-0.5,  1.4, 1.1), 2.5)}
    for name, (off, power) in spots.items():
        ld = bpy.data.lights.new(f"Rig_{name}", 'AREA')
        ld.size = d * (1.5 if name == "Fill" else 0.8)
        ld.energy = 300 * power * d * d          # scales with subject size; iterate
        lo = bpy.data.objects.new(f"Rig_{name}", ld)
        bpy.context.scene.collection.objects.link(lo)
        lo.location = center + Vector(off) * d
        lo.rotation_euler = (center - lo.location).to_track_quat('-Z', 'Y').to_euler()
```

- Ratios: key : fill ≈ 3–4 : 1 (fill exists to open shadows, not to flatten); rim separates the silhouette from the background — check the 3/4 beauty for a readable edge light.
- Big soft lights (area size ≈ subject size) flatter forms; small hard lights dramatize and expose surface flaws — choose per art direction, say which.
- Ground: a plane ~10× the subject named `Rig_Ground` (the `Rig_` prefix keeps rig objects out of probe framing — see `blender-verify`), neutral gray albedo ~0.35–0.5, roughness ~0.6 — grounds the object with a real contact shadow. Floating objects on void backgrounds read as unfinished.
- HDRI alternative: if an .hdr/.exr exists in the project, World → Environment Texture beats hand rigs for realism (keep the rim light). Don't fake an HDRI from memory of one.
- Motivated light for scenes: pick the story source (window, lamp) as key; `blender-scene` owns scene-level composition.

## Camera discipline

- Focal length: 50–85 mm for products and subjects (default 50 mm is fine — the crime is distance, not lens). Wide (<35 mm) only for interiors/environments, and then watch verticals.
- Distance so the subject fills ~65–75% of frame height; headroom above, more space in front of the subject's "facing" direction than behind.
- Height: eye-level for neutral catalog reads, slightly below subject mid-height for heroic presence. Straight-on axis shots read as diagrams — the money shot is the 3/4.
- Composition: rule of thirds for off-center subjects; for symmetric hero shots, deliberate dead-center symmetry — pick one, don't drift between.
- Depth of field: OFF by default; a subtle f/2.8–f/4 for hero close-ups only, focus on the identity feature.

## Engine per purpose

| Purpose | Engine |
|---|---|
| Form/silhouette probes, wireframe | Workbench (fast, headless-safe, honest about shading) |
| Iteration beauty during material/light work | EEVEE (`BLENDER_EEVEE_NEXT` from 4.2, `BLENDER_EEVEE` before — version-gate it); enable AO |
| Final hero beauty + turntable | Cycles, 128–256 samples, denoise on (CPU works headless; GPU if available) |

```python
scene = bpy.context.scene
if hero_final:
    scene.render.engine = 'CYCLES'
    scene.cycles.samples = 256
    scene.cycles.use_denoising = True
else:
    scene.render.engine = 'BLENDER_EEVEE_NEXT' if bpy.app.version >= (4, 2, 0) else 'BLENDER_EEVEE'
```

Materials that need transmission/subsurface silently degrade in the wrong engine — final material judgment happens in the final engine. Caveat: **EEVEE needs a GPU/display even under `--background`**; on a truly headless server, form-probe with Workbench and do all beauty work in Cycles (CPU renders fine, just slower).

## Presentation set (what "done" renders are, per tier)

- production: lit 3/4 beauty at ≥1280px + the 4-view probe set.
- hero: the above + 8-step turntable + 2-3 close-ups of identity features/detail zones (snippets in `blender-verify`), all under the same rig and color management — a presentation set with inconsistent lighting reads as accident.

Then look at every image and score "lighting & presentation" on the rubric with named evidence (highlight clipping? silhouette separated from background? contact shadow present? composition rule stated?).
