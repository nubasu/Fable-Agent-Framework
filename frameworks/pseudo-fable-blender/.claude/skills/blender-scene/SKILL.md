---
name: blender-scene
description: Multi-asset scene assembly in Blender — camera-first composition (dress what the camera sees), scale truth against human-metric anchors, layout order from architecture to scatter, clearance rules, instancing over copying, a quality budget graded by camera proximity, density gradients toward the focal point, and motivated lighting. Use when the task is an environment, a room, a diorama, or any request involving multiple assets in one shot.
---

# blender-scene — scenes are shots, not worlds

A scene request ("a cozy reading corner") is not N asset requests; it is ONE image request that happens to contain N assets. Everything follows from that inversion: compose the camera first, then build and dress exactly what it sees, at the quality its distance from the lens deserves.

## Camera first

Before building anything: place the camera per `blender-light-camera` (interior: 24–35 mm; diorama/tabletop: 50 mm+), block the composition with proxy cubes, and render the empty framing. The camera defines three zones — **hero** (focal point, near), **mid** (supporting, visible), **background** (context, far/edge) — and those zones are the quality budget:

| Zone | Build depth |
|---|---|
| hero asset(s) | full `blender-build-loop` at the spec's tier — this is where the excellence loop spends |
| mid props | forms + basic materials (production floor, no tertiary detail) |
| background | blockout + color + correct scale; detail here is invisible and unpaid |

Spending hero effort on a barely-visible bookshelf is the scene-scale version of detailing before proportions. State the zone assignment in the scene spec.

## Scale truth — one wrong prop breaks the whole shot

Humans read scenes through built-in metric anchors; violate one and everything looks miniature or gigantic:

- door 2.0 × 0.9 · ceiling 2.4–2.7 · seat 0.45 · table 0.74 · counter 0.9 · stair riser 0.18 · book 0.20–0.28 tall · mug 0.095.
- Every asset gets a dimension probe on entry to the scene; imported/reused assets especially (probe, apply scale).
- Keep a hidden 1.7 m human-silhouette proxy in the file and render it once against the set — the fastest full-scene scale audit there is. Delete it from deliverables.

## Layout order (mirrors the build loop's phases)

1. **Architecture / ground** — floor, walls, large planes at true dimensions. Blockout gate: the empty room framing reads.
2. **Hero placement** — the focal asset(s) at the composition's power position (thirds intersection or motivated center).
3. **Functional props** — things whose placement tells the story (the open book ON the chair, the lamp NEXT TO it). Function first: someone lives here, nothing floats or intersects.
4. **Clearances** — walkway ≥ 0.8, chair pull-out 0.75, door swing arc empty. A probe render from human eye height (1.6 m) catches what the beauty camera hides.
5. **Scatter / tertiary** — debris, books, cables, foliage via instanced collections / geometry-node or particle scatter. Never hand-copy 20 objects — instance them (`Alt`-less scripting: `collection instances` or linked object data), then break uniformity: vary rotation/scale per instance (±10–20%), because perfectly-aligned repeats read as CG instantly.

## Density gradient and negative space

Visual density rises toward the focal point and thins at the frame edges — that's what steers the eye. Empty space is a feature: the instinct to fill every shelf produces noise, not richness. Rule of thumb: if the squint test doesn't land on the hero first, the dressing is fighting the shot — remove, don't add.

## Motivated lighting

Scenes don't get abstract studio rigs — light comes from something in the world: the window is the key, practicals (lamps, screens) are accents, one dominant direction everything obeys. Sun/window through-light: a Sun lamp angled 15–40° for long readable shadows beats noon. Interior night: practicals as emitters + one soft ambient fill so shadows don't die to black. Same color-management and exposure iteration as `blender-light-camera`.

## Scene-level verification

- The probe set runs **from the final camera** (that's the deliverable) plus one orbit view and the eye-height clearance render — off-camera chaos is fine, on-camera chaos isn't; say which is which.
- Data probes still apply per asset (scale_applied, budgets summed across the scene, instance counts vs object counts — 500 real copies where 500 instances belong is a probe finding).
- The rubric scores the SHOT: silhouette axis becomes composition-reads, detail axis becomes density-gradient, spec fidelity includes the story props the request named.
- The excellence loop critiques the image like an art director: what does the eye hit first / second / where does it get stuck / what breaks scale or story — then fixes in zone-priority order (hero → mid → background).
