#!/usr/bin/env bash
# pseudo-fable-harness v1.2 (2026-07-05) -- PostToolUse hook (matcher: Task|Agent):
# after a subagent returns, remind the lead to run accept-work before integrating.
# v1.1: PSEUDO_FABLE_HARNESS_DISABLE kill switch (keys: accept, all).
# Exit 2 feeds stderr back to the model as feedback; the tool result itself is untouched.
# Kept ASCII-only in step with the .ps1 twin.

cat > /dev/null

case ",$(printf '%s' "${PSEUDO_FABLE_HARNESS_DISABLE:-}" | tr -d ' ')," in
  *,accept,*|*,all,*) exit 0 ;;
esac

echo '[pseudo-fable-harness] A subagent returned. Before integrating anything: run `accept-work` - verify its done-criteria independently (a report is a claim, not a fact), read the full diff, then ACCEPT / PATCH / BOUNCE / RECLAIM. For a read-only scout/report agent with nothing to integrate, note that and continue.' >&2
exit 2
