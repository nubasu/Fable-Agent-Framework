#!/usr/bin/env bash
# pseudo-fable-harness v1.2 (2026-07-05) -- SessionStart hook: inject .claude/state/ into context.
# v1.1: PSEUDO_FABLE_HARNESS_DISABLE kill switch (keys: session, all) + stale-state warning (>60 min).
# If state files exist, stdout (added to context on SessionStart) lists them and inlines the
# newest one so the session boots from files, not memory (session-bootstrap OPEN / solo P4).
# Silent (no output) when there is no state. Fails open on any error.
# Kept ASCII-only in step with the .ps1 twin.

cat > /dev/null

case ",$(printf '%s' "${PSEUDO_FABLE_HARNESS_DISABLE:-}" | tr -d ' ')," in
  *,session,*|*,all,*) exit 0 ;;
esac

root="${CLAUDE_PROJECT_DIR:-$PWD}"
state_dir="$root/.claude/state"
[ -d "$state_dir" ] || exit 0

# newest first; regular files only (dotfiles excluded by ls default)
files=$(cd "$state_dir" 2>/dev/null && ls -1tp 2>/dev/null | grep -v '/$' | head -n 10)
[ -n "$files" ] || exit 0

echo '[pseudo-fable-harness] .claude/state/ is not empty - boot from files, not memory (session-bootstrap OPEN if installed; otherwise re-read the state, re-verify the top load-bearing facts in the code, and declare position/next-move before resuming). After a compaction, treat this as a new session in disguise.'
echo 'State files (newest first):'
printf '%s\n' "$files" | sed 's/^/  - /'

newest=$(printf '%s\n' "$files" | head -n 1)
if [ -n "$(find "$state_dir/$newest" -mmin +60 -print 2>/dev/null)" ]; then
  echo 'WARNING: the newest state file is over 60 minutes old - if work happened since, it is STALE; re-verify against the code and git before trusting it.'
fi
echo "--- $newest, first 60 lines ---"
head -n 60 "$state_dir/$newest" | head -c 4000
echo ''
echo '--- end of state file ---'
exit 0
