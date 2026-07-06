# pseudo-fable-blender

English | [日本語](README.ja.md) · Day-to-day usage after installation: [HOWTOUSE.md](HOWTOUSE.md)

The Blender 3D-modeling **domain pack** — full-depth, quality-first discipline for agents that drive Blender through **bpy scripts (headless CLI)** or a **Blender MCP**. Deliberately token-heavy: the objective is the best model the agent can physically produce, not the cheapest session. Adds to any framework configuration or runs alone in a Blender-only repo; external agents get the whole pack via the AGENTS.md addendum. Resident core ~1.8K tokens + 7 on-demand skills.

## The idea — nobody reviews a diff here; looking at renders IS the review

Coding agents inherit their verification instincts from code: run it, tests pass, done. 3D modeling breaks every one of those instincts — a build script that exits 0 proves nothing, there is no test suite, and the only oracles are **the rendered image** and **the mesh data**. And passing a spec is not the same as being good: most agent-made models fail not on correctness but on quality — flat lighting, one scale of detail, plastic materials. The pack attacks both layers:

**Correctness failures** (the floor):

1. **Blind generation** — 300 lines of bpy, exit 0, success reported without ever rendering. → "**Never trust an unseen model**": a standard probe armory (4-view rig, clay pass, wireframe pass, data probes) plus the rule that a render nobody viewed verifies nothing.
2. **Details before proportions** — beveling a body whose proportions are wrong. → Blockout first, ended by a hard **silhouette gate**.
3. **Scene entropy** — `Cube.001` twins, unapplied scale, unreviewable outliner. → "**The scene is a codebase**": real scale, semantic names, idempotent rebuilds.
4. **Stale-API hallucination** — bpy recalled from 2.8x training data (`use_auto_smooth` died in 4.1, EEVEE id changed in 4.2). → "**bpy is a hostile API**": version probe, by-name references, `dir()` before guessing twice.

**Quality failures** (the ceiling — this is what the pack exists for):

5. **Verification theater** — one glance, "looks good", ship. → Fixed critical-reading order, the **name-the-flaws rule**, and a six-axis **rubric** (1–5, anchored) scored aloud with evidence at every gate.
6. **First-idea lock-in** — the first blockout becomes the model. → **Variant exploration** at hero tier: 2-3 proportion interpretations, rendered side by side, chosen with stated reasons.
7. **One-scale detail** — bare primitives or uniform greebles; either reads as CG. → The **three-scales rule** (primary/secondary/tertiary) with density following visual importance.
8. **Plastic materials** — uniform roughness, full-saturation colors, 0.5 metallic. → PBR value discipline (albedo ranges, binary metallic) and **roughness variation as the realism lever**.
9. **Presentation blindness** — default lamp, Standard view transform, floating on void. → Color management first (AgX/Filmic), scripted three-point rig, camera and composition rules.
10. **Stopping at spec-pass** — criteria met, potential unmet. → "**Spec-pass is not done**": the **excellence loop** re-critiques the renders as a senior artist (a different lens each pass) and implements the findings, at hero tier until two consecutive passes find only cosmetics.

The pack is spec-first (`blender-spec` turns "make a chair" into numbers, art direction, and measurable done-criteria before any geometry) and tiered: **draft / production / hero, hero being the default** — this pack assumes you want the best it can do.

## Structure

```
pseudo-fable-blender/
├── BLENDER.template.md             ← resident core (~1.8K): laws, quality tiers, rubric axes, triggers.
│                                      Append to the end of the project's CLAUDE.md
├── AGENTS.template.md              ← self-contained addendum for external agents (Codex etc.):
│                                      all seven protocols condensed. Append to AGENTS.md
├── settings.hooks.json             ← optional hook layer: hooks block to merge into .claude/settings.json
├── settings.hooks.powershell.json  ←   (PowerShell variant for Windows without Git Bash)
├── .claude/hooks/
│   ├── stop-blender-qa.sh/.ps1     ← Stop hook: bounce marker-less stops after Blender work
│   └── posttool-blender-probe.sh/.ps1 ← nudge after headless runs: read the renders, check PROBE lines
└── .claude/skills/
    ├── blender-spec/               ← request → identity features, art direction, tier, dimension NUMBERS,
    │                                  archetype proportion table, measurable done-criteria
    ├── blender-build-loop/         ← scene contract → blockout (+ hero variants) + silhouette gate →
    │                                  forms → three-scales detail; form-strategy table; bpy version rules
    ├── blender-topology/           ← quad/n-gon policy by curvature, SubD control, boolean cleanup,
    │                                  shading toolbox, artifact→cause table, export topology
    ├── blender-materials/          ← PBR values that read real, roughness-variation recipes, defensive
    │                                  node scripting, palette rules, clay-vs-beauty separation
    ├── blender-light-camera/       ← color management (AgX/Filmic), scripted 3-point rig, camera & 
    │                                  composition rules, engine-per-purpose, presentation sets
    ├── blender-scene/              ← camera-first layout, scale truth, quality budget by camera
    │                                  proximity, instancing & scatter, motivated lighting
    └── blender-verify/             ← the probe armory (4-view/clay/wire/turntable/close-up/data),
                                       the anchored rubric, the excellence loop, final QA gate
```

## The quality machinery (what "quality-first" means concretely)

- **Tiers** — draft / production / hero, declared in the spec, hero default. Tier sets the rubric floor (≥3 / ≥4 on all six axes) and the deliverables (hero: turntable, close-ups, color-managed beauty).
- **Rubric** — six axes (silhouette & proportion · topology & shading · detail · material realism · lighting & presentation · spec fidelity), anchored descriptions for 2 and 4, scored aloud with evidence at every gate; an axis may never regress without a stated reason.
- **Excellence loop** — after done-criteria pass: fresh probes → senior-artist critique in rotating personas (form purist / materials nerd / photographer) → exactly 5 ranked findings, classified → all non-cosmetic findings implemented → re-scored. Hero exits only when two consecutive passes yield cosmetics only.
- **Variant exploration** — hero blockouts try 2-3 proportion interpretations before committing; the first idea is rarely the best and this is the cheapest moment to find that out.
- **Probe armory** — idempotent snippets shipped in `blender-verify`: auto-framed 4-view rig, clay pass (form without material noise), wireframe pass (topology made visible), 8-step turntable, 85mm close-ups, and a `PROBE {json}` data probe (evaluated tris, dims, non-manifold, scale_applied).

## Drive modes

Declared at task start, recipes in `blender-verify`:

- **MCP** — live Blender with an MCP server; its screenshot/viewport tools double as the render probe, code probes run via execute-code. Create-or-replace by name keeps the live scene idempotent.
- **Headless CLI** — `blender --background --factory-startup --python-exit-code 1 --python build.py`; one canonical, parameterized build script is the artifact under version control, probe renders land in `renders/` as PNGs the agent then reads. (EEVEE needs a GPU/display even headless; pure servers form-probe with Workbench and beauty-render with Cycles CPU.)

The full loop assumes the agent can view images (Claude Code reads PNGs; most MCP setups return screenshots). An image-blind agent degrades to data probes plus a human reading the renders — the pack makes it say so instead of pretending.

## Optional hook layer — mechanical guardrails for the two failure modes text can't fully close

Same philosophy as pseudo-fable-harness (guardrails enforce the ritual, not the truth), scoped to this domain — the generic harness watches file edits and cannot see Blender work done through bash or an MCP:

- **`stop-blender-qa` (Stop hook)** — when the session did Blender work (headless `blender --background` runs, edits containing `import bpy`, or `mcp__*blender*` tool calls) and no `[blender-qa: pass]` / `[blender-qa: n/a]` marker follows the last activity, the stop bounces with the QA instruction. Loop-safe (honors `stop_hook_active`, gives up after two bounces), fails open on any parsing problem, and only counts tool_use lines — prose that merely mentions bpy doesn't trip it.
- **`posttool-blender-probe` (PostToolUse hook, matcher: Bash)** — fires only after a headless Blender run: "Read every NEW image under `renders/` and name the flaws; check the PROBE lines." Deliberately headless-only: MCP screenshots enter context by themselves, PNGs on disk do not — this hook exists for exactly that gap.
- Kill switch: `PSEUDO_FABLE_BLENDER_DISABLE=qa,probe|all` (own variable — independent of `PSEUDO_FABLE_HARNESS_*`).
- Coexists with pseudo-fable-harness: merge both `hooks` blocks into `.claude/settings.json`; each Stop hook bounces independently and at most twice. Restart the session after installing, then check `/hooks`.

Install (optional, after the base install below):

<details>
<summary>Windows (PowerShell)</summary>

```powershell
New-Item -ItemType Directory -Force "$proj\.claude\hooks" | Out-Null
Copy-Item -Force "$storage\.claude\hooks\*" "$proj\.claude\hooks\"
if (Test-Path "$proj\.claude\settings.json") { Write-Host "settings.json exists - merge the hooks block manually" }
else { Copy-Item "$storage\settings.hooks.json" "$proj\.claude\settings.json" }
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
mkdir -p "$proj/.claude/hooks"
cp "$storage/.claude/hooks/"* "$proj/.claude/hooks/"
if [ -f "$proj/.claude/settings.json" ]; then echo "settings.json exists - merge the hooks block manually"
else cp "$storage/settings.hooks.json" "$proj/.claude/settings.json"; fi
```

</details>

On Windows the bash variant is correct whenever Git Bash is installed; use `settings.hooks.powershell.json` otherwise (same rule as pseudo-fable-harness).

## Connections to the other frameworks

| Connects to | Relationship |
|---|---|
| lift `finish-gate` | blender-verify's QA gate supplies the domain half of Gate B/C evidence; finish-gate is not replaced |
| lift `root-cause-debug` | build-script bugs that survive a fix; scene state counts as evidence |
| lift `long-task-state` | multi-session builds keep spec, phase, rubric history, and checkpoint inventory in the state file |
| orchestrate `delegate` | a modeling ticket is a brief whose contract is the blender-spec output (numbers + tier + done-criteria) |
| retro | recurring scene mistakes (naming, forgotten scale, skipped clay pass) become project rules via the placement table |

Works standalone without any of them — the pack carries its own gates.

## Installation

<details>
<summary>Windows (PowerShell)</summary>

```powershell
$storage = "C:\path\to\Pseudo-Fable-Framework\frameworks\pseudo-fable-blender"   # ← adjust to where you put this repo
$proj    = "C:\path\to\project"

# 1. Append the resident core to the end of CLAUDE.md
Get-Content "$storage\BLENDER.template.md" -Encoding utf8 | Add-Content "$proj\CLAUDE.md" -Encoding utf8

# 2. Copy the skills (7, added under .claude/skills/)
New-Item -ItemType Directory -Force "$proj\.claude\skills" | Out-Null
Copy-Item -Recurse -Force "$storage\.claude\skills\*" "$proj\.claude\skills\"

# 3. Optional — external agents (Codex etc.): append the addendum to AGENTS.md
Get-Content "$storage\AGENTS.template.md" -Encoding utf8 | Add-Content "$proj\AGENTS.md" -Encoding utf8
```

</details>

<details>
<summary>macOS / Linux (bash)</summary>

```bash
storage="/path/to/Pseudo-Fable-Framework/frameworks/pseudo-fable-blender"   # ← adjust to where you put this repo
proj="/path/to/project"

cat "$storage/BLENDER.template.md" >> "$proj/CLAUDE.md"
mkdir -p "$proj/.claude/skills"
cp -R "$storage/.claude/skills/"* "$proj/.claude/skills/"

# Optional — external agents (Codex etc.)
cat "$storage/AGENTS.template.md" >> "$proj/AGENTS.md"
```

</details>

The AGENTS.md addendum appends to whichever AGENTS.md base is installed (team or orchestrate-minimal); in an external-agent-only Blender repo it can stand alone as the AGENTS.md body. For combined installs with other frameworks, see the README.md at the repo root.

## Honest limits

- Text discipline is strong steering, not enforcement (family-wide). The gates and the rubric bind exactly as well as the model follows instructions — the rubric's anchors exist to make self-scoring hard to inflate, not impossible.
- Sculpt-grade organics stay out of reach of scripted modeling; the pack's contribution is making the agent say that at spec time and offer stylized alternatives, not overcoming it.
- Material and lighting taste is the weakest link of agent-driven modeling. The pack encodes the highest-yield rules (roughness variation, color management, three-point ratios), which raise the floor substantially — they do not replace an art director's eye. Supplying reference images remains the single best thing the user can do.
- The bundled snippets stick to bpy APIs that have been stable across 2.8x–4.x, but Blender moves; the real defense is the discipline itself (probe the version, verify before use), not the snippet freezing.
- Agents that cannot view images lose half the verification loop (see Drive modes).
- hero tier is genuinely expensive (dozens of renders, multiple excellence passes). That is by design — use draft/production when you don't want it.
- The hook layer verifies the ritual (a marker exists, a nudge fired), never the truth (that the renders were honestly judged). A model that prints a false `[blender-qa: pass]` defeats it — which is why the marker contract calls that a non-negotiable violation.
