---
name: blender-spec
description: Turn a vague modeling request ("make a chair") into a buildable, gradeable spec — subject and identity features, art direction, quality tier (hero by default), target use, real-world dimensions from reference or the archetype table, budgets, topology and material requirements, deliverables, and measurable done-criteria that blender-verify gates against. Use at the start of any Blender modeling task, before creating any geometry.
---

# blender-spec — decide what "right" looks like before making anything

A model can only be verified against a spec, and only be excellent against a direction. "Make a chair" has neither a failure condition nor a taste target — this protocol gives it both. Output: a spec block posted to the user (and into the state file where long-task-state is installed).

## 1. Extract the spec — fill every row, mark guesses `assumed`

| Field | Question | Default when unstated |
|---|---|---|
| Subject & identity features | What is it? Which 3-5 features make it read as this subject and not something else? | name them explicitly (a mug is: cylinder body, one handle, open top, flat bottom) |
| Art direction | 3-5 style words + what they imply (e.g. "mid-century, warm, worn" → tapered legs, wood + brass, edge wear) | "clean contemporary" — and say so, it is a choice |
| Quality tier | draft / production / hero | **hero** — this pack is quality-first; downgrade only if the user says quick |
| Style | realistic / stylized-clean / low-poly faceted | stylized-clean unless art direction implies realism |
| Target use | still render / game asset / 3D print / scene prop | still render |
| Dimensions | real-world size of the whole and of key parts | archetype table below, or look it up; write the NUMBERS into the spec |
| Poly budget | tri limit, evaluated (modifiers applied)? | render ≤500k · game prop 2–20k · print: watertight matters, count doesn't |
| Topology | quads-for-subdiv? n-gons acceptable? | per `blender-topology` policy: quads on curvature, n-gons on flats |
| Materials | PBR realism or flat colors? palette? | PBR per `blender-materials` at production/hero; flat color-block at draft |
| Deliverables | what files count as done? | 4-view probe set + lit 3/4 beauty; hero adds turntable (8 views) + 2-3 close-ups; plus .blend or build script |

Target use drives everything downstream: game → budget + quads + applied transforms; print → manifold watertight, wall thickness, exact units; render → silhouette, shading, and presentation above all. If target use is genuinely unknowable from the request, it is the one question worth asking.

## 2. Reference before geometry — numbers and looks

- Web/image access available → collect 2-3 reference views of the subject AND 1-2 material/lighting references (what does "worn brass" actually look like?). Extract proportions as NUMBERS.
- No reference access → write the proportion sheet from knowledge anyway, numeric, before modeling. A wrong number visible in the spec gets corrected in review; a wrong shape discovered at the beauty render gets rebuilt.
- Specific named subjects (a brand product, a known character) you cannot look at → say you are interpreting freely, or ask for an image. Never imply likeness you cannot check.

Archetype proportions (starting numbers when the user gives none — override with reference):

| Archetype | Numbers |
|---|---|
| Human (scale anchor) | 1.7 m tall, ~7.5 heads; eye level 1.6 m |
| Chair | seat 0.45 h × 0.45 d, back top 0.8–1.0, legs 30–60 mm thick |
| Table / desk | top 0.74 h, 25–40 mm thick; dining 1.6×0.9 |
| Door | 2.0 × 0.9; handle at 1.0 |
| Mug | 95 h × 80 ⌀, wall 4 mm, handle clears 25–30 mm |
| Sedan car | 4.5 × 1.8 × 1.45; wheels ⌀ 0.65, at corners not under body |
| Room | ceiling 2.4–2.7; counter 0.9; walkway ≥0.8 |

## 3. Assumptions and the one batch of questions

Ask only what changes the build and cannot be defaulted (target use for ambiguous requests; exact dimensions for prints; art direction when the subject is style-defining). One batch, not a drip. Everything else: pick the table default and record it marked `assumed` — the user vetoes the spec, not a questionnaire.

## 4. Done-criteria — measurable or it isn't a criterion

Write 5-10, each checkable by a specific render or probe. Shape:

- Silhouette reads as <subject> in all 4 canonical views (probe-render set)
- Overall dims within ±5% of <W×D×H> m; <key part> within ±10% (dimension probe)
- ≤ <N> evaluated tris; 0 non-manifold edges (0 boundary edges too, if printing)
- Every object semantically named; scale applied; one material per part-list entry
- <identity feature 1..n> present and visible in the 3/4 view
- <art-direction cue 1..2> visible in the beauty render (e.g. edge wear on handle corners)
- Rubric floor for the tier: production ≥3 all axes / hero ≥4 all axes (`blender-verify`)

"Looks nice" is not a criterion. "Handle clears the body by ≥ 25 mm so a finger fits" is. For hero, also state the excellence exit: two consecutive critique passes with only cosmetic findings.

## 5. Post it

Post the spec block (subject, art direction, tier, use, dimension sheet, budget, materials plan, deliverables, assumptions, done-criteria). If the user is present, give them one chance to veto; silence = the spec stands, and deviations from it are now deviations, not preferences.
