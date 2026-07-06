#!/usr/bin/env bash
# pseudo-fable-blender v1.0 (2026-07-06) -- Stop hook: block completion without a blender-qa marker.
# Blocks the stop (exit 2) when this session did Blender work (headless `blender --background`
# runs, edits to bpy scripts, or Blender MCP tool calls) and no `[blender-qa: pass]` /
# `[blender-qa: n/a]` marker was printed after the last Blender activity.
# Loop safety: honors stop_hook_active when present, and independently gives up after this
# hook has already blocked twice since the last activity. Fails open on any parsing problem.
# Kill switch: PSEUDO_FABLE_BLENDER_DISABLE (keys: qa, all).
# No dependencies beyond POSIX awk/sed. Kept ASCII-only in step with the .ps1 twin.

input=$(cat) || exit 0

case ",$(printf '%s' "${PSEUDO_FABLE_BLENDER_DISABLE:-}" | tr -d ' ')," in
  *,qa,*|*,all,*) exit 0 ;;
esac

case "$input" in
  *'"stop_hook_active":true'*) exit 0 ;;
esac

transcript=$(printf '%s' "$input" | sed -n 's/.*"transcript_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0

awk '
  {
    if ($0 ~ /"type":"assistant"/ && $0 !~ /"isSidechain":true/) {
      # main-agent assistant entries only; require a tool_use on the line so prose
      # that merely MENTIONS bpy or blender does not count as activity
      if ($0 ~ /"name":"Bash"/ && $0 ~ /blender --background|blender -b /)                 a = NR
      if ($0 ~ /"name":"(Write|Edit|MultiEdit|NotebookEdit)"/ && $0 ~ /import bpy/)        a = NR
      if ($0 ~ /"name":"mcp__[A-Za-z0-9_-]*blender/)                                       a = NR
      if ($0 ~ /\[blender-qa: (pass|n\/a)\]/)                                              m = NR
    } else if ($0 ~ /\[pseudo-fable-blender\] Stop blocked/) {
      # this hook'"'"'s own earlier feedback (arrives as a non-assistant entry)
      b[++bn] = NR
    }
  }
  END {
    c = 0
    for (i = 1; i <= bn; i++) if (b[i] > a) c++
    if (a > 0 && a > m && c < 2) exit 3
    exit 0
  }
' "$transcript"
status=$?

if [ "$status" -eq 3 ]; then
  echo '[pseudo-fable-blender] Stop blocked: this session did Blender work, and no blender-qa marker follows the last Blender activity. Run blender-verify final QA now: fresh probe set actually viewed (a render nobody viewed verifies nothing), data probe clean (non-manifold, scale_applied, budget), rubric scored with evidence, spec coverage table. Then end the completion report with the literal line `[blender-qa: pass]`. If this stop is NOT a completion claim (mid-build status, awaiting user input, spec veto pending), give the one-line reason and end with `[blender-qa: n/a]`. Print a marker only when it is true.' >&2
  exit 2
fi
exit 0
