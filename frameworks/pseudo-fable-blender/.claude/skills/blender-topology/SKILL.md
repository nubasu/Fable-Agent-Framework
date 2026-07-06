---
name: blender-topology
description: Topology and shading discipline for Blender meshes — where quads are mandatory and n-gons are fine, subdivision-surface control (support loops, creases, poles), the bevel-vs-crease decision, boolean cleanup protocol, the shading toolbox (smooth-by-angle across versions, weighted normals), reading shading artifacts back to their topology cause, and polygon-budget allocation. Use when working curved surfaces, subdivision modeling, cleaning up after booleans, chasing shading artifacts, or preparing game/export topology.
---

# blender-topology — shading is topology made visible

Nobody sees edge flow in a beauty shot; everybody sees the shading it produces. Every "weird highlight", "lumpy surface", or "black facet" in a render is a topology or normal statement. This skill exists because scripted modeling tends to produce technically-valid meshes that shade badly — and shading quality is half of perceived model quality.

## The polygon policy — by curvature, not by dogma

| Surface | Policy |
|---|---|
| Curved, visible | quads, flowing along the curvature; poles (3- or 5-edge verts) pushed to flat or hidden areas |
| Flat caps and panels (hard-surface) | n-gons are FINE — one clean n-gon beats a fan of slivers |
| Deforming (rigged/bent later) | quads, edge loops perpendicular to the bend axis |
| Anything triangulated for export | triangulate LAST (modifier or at export), never model in tris |

Density follows visual importance: spend the budget where the camera looks (hero part ≈ half the budget), and keep density steps gradual — a dense patch next to a sparse one shades as a visible seam.

## Subdivision-surface control

SubD turns the cage into the surface; you model the cage. Control edge sharpness one of two ways, not both randomly:

- **Support loops** — a second loop close to the edge holds the curve tight. Loop distance = bevel radius. Best for game-less hero work and where wear/bevel shading matters.
- **Creases** — `edge.crease = 0.8–1.0` (via bmesh: the crease layer) is cheaper and scriptable; slightly more "CG-perfect" result. Fine for machined parts.

Rules that survive contact with SubD: never leave a triangle or pole on a curved visible surface (it pinches); keep the cage as light as possible (every extra loop is a steering wheel you now have to hold); check with level 2, render with the level the budget allows.

## The bevel-vs-crease-vs-both decision

| Want | Do |
|---|---|
| Realistic catch-light edges without SubD | Bevel modifier: limit by angle ~30°, 2 segments, clamp overlap ON, harden normals ON, width at real size (1–3 mm furniture) |
| SubD asset, tight machined edges | creases, or support loops where the edge should wear/catch light |
| SubD asset, soft industrial-design edges | wider support loops or a small real bevel in the cage |

Bevel width is a real-world number, not a ratio that "looks right" at one zoom level. Unapplied non-uniform scale corrupts every bevel width — `scale_applied` must be true before judging bevels (probe it).

## Boolean hygiene — a boolean is a loan, cleanup is the repayment

After every boolean that will be kept (not just probed):

1. Data probe: non-manifold edges introduced? (must return to 0)
2. Merge by distance at ~1e-5 m (bmesh `remove_doubles`) — kills coincident verts booleans love to leave.
3. Dissolve degenerate/sliver faces along the cut seam; check the seam under smooth shading in a probe render — boolean seams are where shading artifacts live.
4. Bevel crossing a boolean seam → harden normals on, and verify in the 3/4 probe; if it still pinches, the seam needs manual edge cleanup or the bevel needs to stop short.

Keep booleans live (modifier) until the form is approved; apply only when the detail pass needs the real geometry.

## Shading toolbox (version-gated — probe, don't recall)

- Shade smooth everything that isn't deliberately faceted; then angle-based hard edges: 4.1+ → `bpy.ops.object.shade_auto_smooth(angle=radians(30))` or the Smooth by Angle modifier; ≤4.0 → `mesh.use_auto_smooth = True` + `auto_smooth_angle`.
- Hard-surface with bevels → add a Weighted Normal modifier last in the stack (keep sharp on); it cleans the faceting that bevel + smooth-by-angle leave on large flats.
- Flipped normals: dark facets in workbench probes; scripted repair `bmesh.ops.recalc_face_normals(bm, faces=bm.faces)` before writing the mesh back.
- Custom split normals from imports: if shading disobeys the rules above, probe for them (`mesh.has_custom_normals`) and clear deliberately, not accidentally.

## Reading a shading artifact back to its cause

| Symptom in the probe | Cause | Fix |
|---|---|---|
| Black / inverted-looking facets | flipped normals | recalc normals outside |
| Banding across a curved face | missing smooth-by-angle, or angle too low | shading toolbox above |
| Pinching star at a point | pole or triangle on curvature | move the pole, requad locally |
| Wobbly highlight along an edge | uneven support loop distance / sliver faces | even the loop, dissolve slivers |
| Smeared diagonal streak on a flat | long thin triangles from an n-gon fan | one clean n-gon or a sane quad fill |
| Shadow acne / self-shadow stripes | doubled coincident faces | merge by distance, delete interior faces |

The wireframe probe (`blender-verify`) exists to confirm the diagnosis — first read the symptom in the shaded render, then look at the wires.

## Game / export targets

- Triangulate at export (or a Triangulate modifier last), never upstream.
- Apply transforms; real scale stays (engines assume meters too).
- Budget is the evaluated tri count — probe it, don't estimate it.
- Hard edges must be marked (smooth-by-angle or explicit sharp edges); baked normals are out of scripted scope — say so if the target needs them.
