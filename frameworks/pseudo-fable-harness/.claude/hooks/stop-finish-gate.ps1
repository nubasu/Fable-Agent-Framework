# pseudo-fable-harness v1.2 (2026-07-05) -- Stop hook: block completion without a finish-gate marker.
# v1.1: PSEUDO_FABLE_HARNESS_DISABLE kill switch (keys: stop, all).
# Blocks the stop (exit 2) when this session modified files (Write/Edit/MultiEdit/NotebookEdit)
# and no `[finish-gate: pass]` / `[finish-gate: n/a]` marker was printed after the last edit.
# Loop safety: honors stop_hook_active when present, and independently gives up after this
# hook has already blocked twice since the last edit. Fails open on any parsing problem.
# NOTE: keep this file ASCII-only -- Windows PowerShell 5.1 reads BOM-less scripts as ANSI.

$ErrorActionPreference = 'Stop'
try {
    $raw = [Console]::In.ReadToEnd()

    $disable = (',' + "$env:PSEUDO_FABLE_HARNESS_DISABLE" + ',') -replace '\s', ''
    if ($disable -match ',(stop|all),') { exit 0 }

    $payload = $raw | ConvertFrom-Json

    if ($payload.stop_hook_active -eq $true) { exit 0 }

    $transcript = $payload.transcript_path
    if (-not $transcript -or -not (Test-Path -LiteralPath $transcript)) { exit 0 }

    $editPattern   = '"name":"(Write|Edit|MultiEdit|NotebookEdit)"'
    $markerPattern = '\[finish-gate: (pass|n/a)\]'
    $blockPattern  = '\[pseudo-fable-harness\] Stop blocked'
    $lastEdit = 0; $lastMarker = 0; $n = 0
    $blockLines = New-Object System.Collections.Generic.List[int]

    foreach ($line in [System.IO.File]::ReadLines($transcript)) {
        $n++
        if ($line -match '"type":"assistant"' -and $line -notmatch '"isSidechain":true') {
            # main-agent assistant entries only (subagent lines are sidechains)
            if ($line -match $editPattern)   { $lastEdit = $n }
            if ($line -match $markerPattern) { $lastMarker = $n }
        }
        elseif ($line -match $blockPattern) {
            # this hook's own earlier feedback (arrives as a non-assistant entry)
            $blockLines.Add($n)
        }
    }

    $blocksSinceEdit = @($blockLines | Where-Object { $_ -gt $lastEdit }).Count

    if ($lastEdit -gt 0 -and $lastEdit -gt $lastMarker -and $blocksSinceEdit -lt 2) {
        [Console]::Error.WriteLine('[pseudo-fable-harness] Stop blocked: this session modified files, and no finish-gate marker follows the last edit. Run the finish gate now (skill `finish-gate`, or P3 in pseudo-fable-solo): contract coverage, build/tests actually run, adversarial diff re-read, blast radius. Then end the completion report with the literal line `[finish-gate: pass]`. If this stop is NOT a completion claim (blocked, awaiting user input, non-coding turn), give the one-line reason and end with `[finish-gate: n/a]`. Print a marker only when it is true.')
        exit 2
    }
    exit 0
}
catch {
    # never let the harness break the session -- fail open
    exit 0
}
