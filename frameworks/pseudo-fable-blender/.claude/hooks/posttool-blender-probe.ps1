# pseudo-fable-blender v1.0 (2026-07-06) -- PostToolUse hook (matcher: Bash):
# after a headless Blender run, remind the agent to actually read the renders and probe output.
# Headless-specific by design: MCP screenshots land in context by themselves; PNGs on disk do not.
# Exit 2 feeds stderr back to the model as feedback; the tool result itself is untouched.
# Exits 0 silently when the Bash command was not a background Blender run.
# Kill switch: PSEUDO_FABLE_BLENDER_DISABLE (keys: probe, all).
# NOTE: keep this file ASCII-only -- Windows PowerShell 5.1 reads BOM-less scripts as ANSI.

$ErrorActionPreference = 'Stop'
try {
    $raw = [Console]::In.ReadToEnd()

    $disable = (',' + "$env:PSEUDO_FABLE_BLENDER_DISABLE" + ',') -replace '\s', ''
    if ($disable -match ',(probe|all),') { exit 0 }

    if ($raw -notmatch 'blender --background|blender -b ') { exit 0 }

    [Console]::Error.WriteLine('[pseudo-fable-blender] A headless Blender run finished. Before the next change: Read every NEW image under renders/ and name the flaws (blender-verify reading order: squint test, proportions vs the spec numbers, grounding, shading defects, detail scales) - a render nobody viewed verifies nothing. If the run printed PROBE lines, check non_manifold / scale_applied / tris against the spec. If the run failed, read the WHOLE error before touching the script.')
    exit 2
}
catch {
    # never let the harness break the session -- fail open
    exit 0
}
