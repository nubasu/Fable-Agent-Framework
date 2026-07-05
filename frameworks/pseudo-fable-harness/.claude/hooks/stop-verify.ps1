# pseudo-fable-harness v1.2 (2026-07-05) -- Stop hook, optional strict mode: run the project's
# REAL check command and block completion on failure (closes the "ritual, not truth" gap
# for finish-gate Gate B).
# Opt-in: inert unless PSEUDO_FABLE_HARNESS_VERIFY_CMD is set (e.g. via the "env" block of
# .claude/settings.json). Runs only when the session has main-agent file edits newer than
# the last successful verify (per-session stamp in the OS temp dir). Gives up after two
# failed blocks per edit burst, so it can never loop forever. Fails open on any internal
# error. NOTE: keep this file ASCII-only -- Windows PowerShell 5.1 reads BOM-less scripts
# as ANSI. The command runs via Invoke-Expression; prefer plain native commands.

$ErrorActionPreference = 'Stop'
try {
    $raw = [Console]::In.ReadToEnd()

    $disable = (',' + "$env:PSEUDO_FABLE_HARNESS_DISABLE" + ',') -replace '\s', ''
    if ($disable -match ',(verify|all),') { exit 0 }

    $payload = $raw | ConvertFrom-Json
    if ($payload.stop_hook_active -eq $true) { exit 0 }

    $cmd = $env:PSEUDO_FABLE_HARNESS_VERIFY_CMD
    if (-not $cmd) { exit 0 }

    $transcript = $payload.transcript_path
    if (-not $transcript -or -not (Test-Path -LiteralPath $transcript)) { exit 0 }

    $sid = "$($payload.session_id)" -replace '[^A-Za-z0-9_-]', ''
    if (-not $sid) { $sid = 'default' }
    $stamp = Join-Path $env:TEMP "pseudo-fable-harness-verify-$sid"

    $lastEdit = 0; $n = 0
    $failLines = New-Object System.Collections.Generic.List[int]
    foreach ($line in [System.IO.File]::ReadLines($transcript)) {
        $n++
        if ($line -match '"type":"assistant"' -and $line -notmatch '"isSidechain":true') {
            # main-agent assistant entries only (subagent lines are sidechains)
            if ($line -match '"name":"(Write|Edit|MultiEdit|NotebookEdit)"') { $lastEdit = $n }
        }
        elseif ($line -match '\[pseudo-fable-harness\] Verify failed') {
            # this hook's own earlier feedback (arrives as a non-assistant entry)
            $failLines.Add($n)
        }
    }

    if ($lastEdit -eq 0) { exit 0 }                        # no edits this session
    $last = 0
    if (Test-Path -LiteralPath $stamp) {
        try { $last = [int]((Get-Content -LiteralPath $stamp -Raw).Trim()) } catch { $last = 0 }
    }
    if ($last -ge $lastEdit) { exit 0 }                    # nothing edited since the last pass
    $strikes = @($failLines | Where-Object { $_ -gt $lastEdit }).Count
    if ($strikes -ge 2) { exit 0 }                         # two strikes -> give up

    $root = $env:CLAUDE_PROJECT_DIR
    if (-not $root) { $root = (Get-Location).Path }
    $out = ''; $rc = 1
    Push-Location -LiteralPath $root
    try {
        $global:LASTEXITCODE = 0
        $out = (Invoke-Expression $cmd 2>&1 | Out-String)
        if ($null -ne $LASTEXITCODE) { $rc = $LASTEXITCODE }
        elseif ($?) { $rc = 0 } else { $rc = 1 }
    }
    catch { $out = $out + "`n" + $_.Exception.Message; $rc = 1 }
    finally { Pop-Location }

    if ($rc -eq 0) {
        try { Set-Content -LiteralPath $stamp -Value "$n" -NoNewline } catch { }
        exit 0
    }

    if ($out.Length -gt 1500) { $out = $out.Substring($out.Length - 1500) }
    [Console]::Error.WriteLine("[pseudo-fable-harness] Verify failed (exit $rc): $cmd")
    [Console]::Error.WriteLine($out)
    [Console]::Error.WriteLine('Fix the failures before completing - finish-gate Gate B is not satisfied. (This check runs because PSEUDO_FABLE_HARNESS_VERIFY_CMD is set; it re-runs on the next stop after new edits.)')
    exit 2
}
catch {
    # never let the harness break the session -- fail open
    exit 0
}
