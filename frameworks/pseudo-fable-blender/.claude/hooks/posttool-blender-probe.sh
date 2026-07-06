#!/usr/bin/env bash
# pseudo-fable-blender v1.0 (2026-07-06) -- PostToolUse hook (matcher: Bash):
# after a headless Blender run, remind the agent to actually read the renders and probe output.
# Headless-specific by design: MCP screenshots land in context by themselves; PNGs on disk do not.
# Exit 2 feeds stderr back to the model as feedback; the tool result itself is untouched.
# Exits 0 silently when the Bash command was not a background Blender run.
# Kill switch: PSEUDO_FABLE_BLENDER_DISABLE (keys: probe, all). Kept ASCII-only.

input=$(cat) || exit 0

case ",$(printf '%s' "${PSEUDO_FABLE_BLENDER_DISABLE:-}" | tr -d ' ')," in
  *,probe,*|*,all,*) exit 0 ;;
esac

case "$input" in
  *'blender --background'*|*'blender -b '*) : ;;
  *) exit 0 ;;
esac

echo '[pseudo-fable-blender] A headless Blender run finished. Before the next change: Read every NEW image under renders/ and name the flaws (blender-verify reading order: squint test, proportions vs the spec numbers, grounding, shading defects, detail scales) - a render nobody viewed verifies nothing. If the run printed PROBE lines, check non_manifold / scale_applied / tris against the spec. If the run failed, read the WHOLE error before touching the script.' >&2
exit 2
