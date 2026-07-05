#!/usr/bin/env bash
# pseudo-fable-harness v1.2 (2026-07-05) -- Stop hook, optional strict mode: run the project's
# REAL check command and block completion on failure (closes the "ritual, not truth" gap
# for finish-gate Gate B).
# Opt-in: inert unless PSEUDO_FABLE_HARNESS_VERIFY_CMD is set (e.g. via the "env" block of
# .claude/settings.json). Runs only when the session has main-agent file edits newer than
# the last successful verify (per-session stamp in the OS temp dir). Gives up after two
# failed blocks per edit burst, so it can never loop forever. Fails open on any internal
# error. No dependencies beyond POSIX awk/sed. Kept ASCII-only in step with the .ps1 twin.

input=$(cat) || exit 0

case ",$(printf '%s' "${PSEUDO_FABLE_HARNESS_DISABLE:-}" | tr -d ' ')," in
  *,verify,*|*,all,*) exit 0 ;;
esac

case "$input" in
  *'"stop_hook_active":true'*) exit 0 ;;
esac

cmd="${PSEUDO_FABLE_HARNESS_VERIFY_CMD:-}"
[ -n "$cmd" ] || exit 0

transcript=$(printf '%s' "$input" | sed -n 's/.*"transcript_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0

sid=$(printf '%s' "$input" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | tr -cd 'A-Za-z0-9_-')
[ -n "$sid" ] || sid=default
stamp="${TMPDIR:-/tmp}/pseudo-fable-harness-verify-$sid"

# e = last main-agent edit line, c = this hook's failure feedbacks after e, n = total lines
set -- $(awk '
  {
    if ($0 ~ /"type":"assistant"/ && $0 !~ /"isSidechain":true/) {
      if ($0 ~ /"name":"(Write|Edit|MultiEdit|NotebookEdit)"/) e = NR
    } else if ($0 ~ /\[pseudo-fable-harness\] Verify failed/) {
      b[++bn] = NR
    }
  }
  END { c = 0; for (i = 1; i <= bn; i++) if (b[i] > e) c++; print e+0, c+0, NR+0 }
' "$transcript") || exit 0
e=$1; c=$2; n=$3

[ "$e" -gt 0 ] 2>/dev/null || exit 0        # no edits this session
last=$(cat "$stamp" 2>/dev/null)
case "$last" in ''|*[!0-9]*) last=0 ;; esac
[ "$e" -gt "$last" ] || exit 0              # nothing edited since the last pass
[ "$c" -lt 2 ] || exit 0                    # two strikes since the last edit -> give up

out=$( ( cd "${CLAUDE_PROJECT_DIR:-.}" && sh -c "$cmd" ) 2>&1 )
rc=$?

if [ "$rc" -eq 0 ]; then
  printf '%s' "$n" > "$stamp" 2>/dev/null
  exit 0
fi

{
  echo "[pseudo-fable-harness] Verify failed (exit $rc): $cmd"
  printf '%s' "$out" | tail -c 1500
  echo ''
  echo 'Fix the failures before completing - finish-gate Gate B is not satisfied. (This check runs because PSEUDO_FABLE_HARNESS_VERIFY_CMD is set; it re-runs on the next stop after new edits.)'
} >&2
exit 2
