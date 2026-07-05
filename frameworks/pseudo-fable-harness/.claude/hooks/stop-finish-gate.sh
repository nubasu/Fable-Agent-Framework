#!/usr/bin/env bash
# pseudo-fable-harness v1.2 (2026-07-05) -- Stop hook: block completion without a finish-gate marker.
# v1.1: PSEUDO_FABLE_HARNESS_DISABLE kill switch (keys: stop, all).
# Blocks the stop (exit 2) when this session modified files (Write/Edit/MultiEdit/NotebookEdit)
# and no `[finish-gate: pass]` / `[finish-gate: n/a]` marker was printed after the last edit.
# Loop safety: honors stop_hook_active when present, and independently gives up after this
# hook has already blocked twice since the last edit. Fails open on any parsing problem.
# No dependencies beyond POSIX awk/sed. Kept ASCII-only in step with the .ps1 twin.

input=$(cat) || exit 0

case ",$(printf '%s' "${PSEUDO_FABLE_HARNESS_DISABLE:-}" | tr -d ' ')," in
  *,stop,*|*,all,*) exit 0 ;;
esac

case "$input" in
  *'"stop_hook_active":true'*) exit 0 ;;
esac

transcript=$(printf '%s' "$input" | sed -n 's/.*"transcript_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0

awk '
  {
    if ($0 ~ /"type":"assistant"/ && $0 !~ /"isSidechain":true/) {
      # main-agent assistant entries only (subagent lines are sidechains)
      if ($0 ~ /"name":"(Write|Edit|MultiEdit|NotebookEdit)"/) e = NR
      if ($0 ~ /\[finish-gate: (pass|n\/a)\]/)                 m = NR
    } else if ($0 ~ /\[pseudo-fable-harness\] Stop blocked/) {
      # this hook'"'"'s own earlier feedback (arrives as a non-assistant entry)
      b[++bn] = NR
    }
  }
  END {
    c = 0
    for (i = 1; i <= bn; i++) if (b[i] > e) c++
    if (e > 0 && e > m && c < 2) exit 3
    exit 0
  }
' "$transcript"
status=$?

if [ "$status" -eq 3 ]; then
  echo '[pseudo-fable-harness] Stop blocked: this session modified files, and no finish-gate marker follows the last edit. Run the finish gate now (skill `finish-gate`, or P3 in pseudo-fable-solo): contract coverage, build/tests actually run, adversarial diff re-read, blast radius. Then end the completion report with the literal line `[finish-gate: pass]`. If this stop is NOT a completion claim (blocked, awaiting user input, non-coding turn), give the one-line reason and end with `[finish-gate: n/a]`. Print a marker only when it is true.' >&2
  exit 2
fi
exit 0
