# pseudo-fable-blender v1.0 (2026-07-06) -- Stop hook: block completion without a blender-qa marker.
# Blocks the stop (exit 2) when this session did Blender work (headless `blender --background`
# runs, edits to bpy scripts, or Blender MCP tool calls) and no `[blender-qa: pass]` /
# `[blender-qa: n/a]` marker was printed after the last Blender activity.
# Loop safety: honors stop_hook_active when present, and independently gives up after this
# hook has already blocked twice since the last activity. Fails open on any parsing problem.
# Kill switch: PSEUDO_FABLE_BLENDER_DISABLE (keys: qa, all).
# NOTE: keep this file ASCII-only -- Windows PowerShell 5.1 reads BOM-less scripts as ANSI.

$ErrorActionPreference = 'Stop'
try {
    $raw = [Console]::In.ReadToEnd()

    $disable = (',' + "$env:PSEUDO_FABLE_BLENDER_DISABLE" + ',') -replace '\s', ''
    if ($disable -match ',(qa|all),') { exit 0 }

    $payload = $raw | ConvertFrom-Json

    if ($payload.stop_hook_active -eq $true) { exit 0 }

    $transcript = $payload.transcript_path
    if (-not $transcript -or -not (Test-Path -LiteralPath $transcript)) { exit 0 }

    $bashPattern   = '"name":"Bash"'
    $runPattern    = 'blender --background|blender -b '
    $editPattern   = '"name":"(Write|Edit|MultiEdit|NotebookEdit)"'
    $bpyPattern    = 'import bpy'
    $mcpPattern    = '"name":"mcp__[A-Za-z0-9_-]*blender'
    $markerPattern = '\[blender-qa: (pass|n/a)\]'
    $blockPattern  = '\[pseudo-fable-blender\] Stop blocked'
    $lastAct = 0; $lastMarker = 0; $n = 0
    $blockLines = New-Object System.Collections.Generic.List[int]

    foreach ($line in [System.IO.File]::ReadLines($transcript)) {
        $n++
        if ($line -match '"type":"assistant"' -and $line -notmatch '"isSidechain":true') {
            # main-agent assistant entries only; require a tool_use on the line so prose
            # that merely MENTIONS bpy or blender does not count as activity
            if ($line -match $bashPattern -and $line -match $runPattern) { $lastAct = $n }
            if ($line -match $editPattern -and $line -match $bpyPattern) { $lastAct = $n }
            if ($line -match $mcpPattern)                                { $lastAct = $n }
            if ($line -match $markerPattern)                             { $lastMarker = $n }
        }
        elseif ($line -match $blockPattern) {
            # this hook's own earlier feedback (arrives as a non-assistant entry)
            $blockLines.Add($n)
        }
    }

    $blocksSinceAct = @($blockLines | Where-Object { $_ -gt $lastAct }).Count

    if ($lastAct -gt 0 -and $lastAct -gt $lastMarker -and $blocksSinceAct -lt 2) {
        [Console]::Error.WriteLine('[pseudo-fable-blender] Stop blocked: this session did Blender work, and no blender-qa marker follows the last Blender activity. Run blender-verify final QA now: fresh probe set actually viewed (a render nobody viewed verifies nothing), data probe clean (non-manifold, scale_applied, budget), rubric scored with evidence, spec coverage table. Then end the completion report with the literal line `[blender-qa: pass]`. If this stop is NOT a completion claim (mid-build status, awaiting user input, spec veto pending), give the one-line reason and end with `[blender-qa: n/a]`. Print a marker only when it is true.')
        exit 2
    }
    exit 0
}
catch {
    # never let the harness break the session -- fail open
    exit 0
}
