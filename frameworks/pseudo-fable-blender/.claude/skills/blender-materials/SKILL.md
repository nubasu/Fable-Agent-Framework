---
name: blender-materials
description: PBR material discipline for Blender — Principled BSDF values that read as real (albedo ranges, binary metallic, roughness variation as the realism lever), defensive node scripting across API versions, procedural roughness/wear recipes, palette rules, clay-vs-beauty probe separation, and when UVs are actually needed. Use when assigning any material beyond flat color-blocking, when a render "looks like plastic CG", or when the spec's art direction names surface qualities (worn, brushed, matte, lacquered).
---

# blender-materials — realism is mostly roughness, not color

Untrained material work has one smell: every surface is a single uniform value, so everything reads as fresh-from-the-factory plastic. Real surfaces vary — mostly in roughness. This skill turns art-direction words ("worn brass", "matte lacquer") into node-level decisions, and keeps material judgment separate from form judgment.

## Clay first, beauty second

Form is judged on **clay renders** (uniform gray override — snippet in `blender-verify`); materials are judged on **beauty renders** under the real light rig. Never debug both at once: a render that looks wrong is first split into "form problem or surface problem?" by comparing the clay and beauty probes of the same view.

## Principled BSDF values that read as real

| Rule | Numbers |
|---|---|
| Albedo has a floor and a ceiling | nothing below ~0.03 (charcoal) or above ~0.85 (fresh snow); "black" plastic ≈ 0.03–0.05, "white" paint ≈ 0.7–0.8. Pure 0/1 kills light transport |
| Metallic is binary | 0 or 1; the 0.5 middle exists only for dusty/painted metal masks. Metal color lives in Base Color (gold ≈ (1.0, 0.75, 0.35)) |
| Roughness is the king | judge every material first by its roughness story; see variation below |
| IOR | leave ~1.45 for dielectrics; glass 1.52, water 1.33. Don't sculpt specular response with the specular slider — that's IOR's job |
| Saturation restraint | realistic albedo saturation is lower than instinct (most real objects < 0.6); full-sat colors read as toy plastic |
| Subsurface / transmission | only with a reason (skin, wax, food, glass) and only in Cycles or configured EEVEE — verify in a render, these settings silently no-op in wrong engines |

## Roughness variation — the single highest-yield realism move

Uniform roughness = CG. Recipe (values are starting points):

- Base roughness by material (polished metal 0.15, brushed 0.35, wood satin 0.4, matte paint 0.6, rubber 0.8).
- Add a Noise Texture (scale ≈ 4–8 relative to object size) → ColorRamp squeezed narrow (e.g. stops at 0.45/0.55) → into Roughness, remapped to ±0.05–0.15 around the base. Subtle: visible as broken-up highlights, not as dirt.
- Wear at contact points (art direction permitting): lighter/rougher (or darker/smoother — decide per material story) on edges people touch. Cheap proxy without UVs: a second noise masked by Geometry→Pointiness through a ColorRamp — Cycles only; in EEVEE, bevel-edge highlights carry most of the effect alone.

## Defensive node scripting (input names drift across versions)

```python
import bpy

def make_pbr(name, base=(0.5, 0.5, 0.5, 1.0), rough=0.5, metal=0.0):
    mat = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    mat.use_nodes = True
    bsdf = next(n for n in mat.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
    def set_in(sock, val):
        s = bsdf.inputs.get(sock)
        if s is not None:
            s.default_value = val
        else:
            print(f"PROBE material_input_missing {name}:{sock} -> {list(bsdf.inputs.keys())}")
    set_in("Base Color", base)
    set_in("Roughness", rough)
    set_in("Metallic", metal)
    return mat

def add_roughness_variation(mat, base_rough=0.4, amount=0.1, scale=6.0):
    nt = mat.node_tree
    bsdf = next(n for n in nt.nodes if n.type == 'BSDF_PRINCIPLED')
    noise = nt.nodes.new('ShaderNodeTexNoise')
    noise.inputs["Scale"].default_value = scale
    ramp = nt.nodes.new('ShaderNodeValToRGB')
    ramp.color_ramp.elements[0].position = 0.45
    ramp.color_ramp.elements[1].position = 0.55
    ramp.color_ramp.elements[0].color = (base_rough - amount,) * 3 + (1.0,)
    ramp.color_ramp.elements[1].color = (base_rough + amount,) * 3 + (1.0,)
    nt.links.new(noise.outputs["Fac"], ramp.inputs["Fac"])
    nt.links.new(ramp.outputs["Color"], bsdf.inputs["Roughness"])
    return mat
```

`inputs.get()` + the printed fallback is the pattern: name drift becomes a visible probe line, not a silent no-op or a crash. Missing-input prints get resolved by reading the printed key list, not by guessing again.

## Palette discipline

- 60-30-10: one dominant material family, one secondary, one accent. A part list where every part got its own loud color reads as a toy.
- Separate parts by VALUE (light/dark) first, hue second — value contrast survives lighting changes and grayscale probes; hue contrast doesn't.
- The color-block materials from the build phase are placeholders — replace them by the part list, don't decorate them.

## UVs — only when something needs them

Procedural (noise/pointiness-driven) needs no UVs. You need UVs when: image textures are supplied, text/logos must land exactly, or the target is a game engine (then: Smart UV Project is acceptable for props — probe for stretching in a checker render; hand-seamed UVs are beyond scripted fidelity for complex organic shapes, say so). For tileables without exact placement, box mapping (Texture Coordinate→Object + Mapping node) avoids UVs entirely.

## Verify hooks

Every material lands in the next beauty probe: check highlight breakup (roughness variation visible?), value separation between parts, metals actually reading as metal (dark environments make metals black — that's a lighting note for `blender-light-camera`, not a material bug). Rubric axis "material realism" scores against these, with the render as evidence.
