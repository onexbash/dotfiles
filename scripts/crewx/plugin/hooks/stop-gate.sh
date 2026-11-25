#!/usr/bin/env bash
# crewx Stop hook: the gate. When the lead ends a turn and the work tree changed, run .crewx/verify.
#   pass:  silent (no tokens), recorded in the state file's log.
#   fail:  block the stop and hand the lead the last lines of output, up to CREWX_GATE_MAX times in a row;
#          then let it stop, log it and mail the person (tuios Inbox).
# It never runs twice on the same tree: an unchanged tree after a failure means the lead chose to stop
# (for example: the failure isn't this session's), so it doesn't block again.
# It waits while crewx subagents are running: their half-finished work is not a failure yet.
# Off switch: CREWX_GATE=off in the environment, or a file .crewx/gate-off in the project.
set -uo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

hook_input
sid="$(field .session_id)"
root="$(project_root "$(field .cwd)")" || exit 0
[ -n "$sid" ] || exit 0
[ "${CREWX_GATE:-on}" = off ] || [ -e "$root/.crewx/gate-off" ] && exit 0

max="${CREWX_GATE_MAX:-3}"
run="$root/.crewx/run/${sid:0:8}"
mkdir -p "$root/.crewx/run"
state="$(state_file "$root" "$sid")"

fp="$(fingerprint "$root")"
[ "$fp" = "$(cat "$run.base" 2>/dev/null)" ] && exit 0 # nothing changed in this session
[ "$fp" = "$(cat "$run.pass" 2>/dev/null)" ] && exit 0 # already passed on this tree
fail_fp="" fail_n=0
[ -f "$run.fail" ] && read -r fail_fp fail_n <"$run.fail"
[ "$fp" = "$fail_fp" ] && exit 0 # failed on this very tree before; the lead chose to stop

# Subagents still running? Markers come from log-event.sh; older than 3 h counts as stale.
running="$(find "$run.agents" -type f -mmin -180 2>/dev/null | wc -l | tr -d ' ')"
if [ "${running:-0}" -gt 0 ]; then
  [ "$fp" = "$(cat "$run.deferred" 2>/dev/null)" ] || log_state "$state" "gate deferred: $running subagent(s) running"
  echo "$fp" >"$run.deferred"
  exit 0
fi

block() { # block <reason>: count the attempt, then block or give up
  fail_n=$((fail_n + 1))
  if [ "$fail_n" -gt "$max" ]; then
    echo "$fp 0" >"$run.fail" # the next change gets fresh attempts
    log_state "$state" "gate FAIL, gave up after $max attempts"
    notify_human "crewx: gate failing – $(basename "$root")" "The gate still fails after $max attempts in $root. The lead stopped; see ${state:-the state file}."
    exit 0
  fi
  echo "$fp $fail_n" >"$run.fail"
  log_state "$state" "gate fail ($fail_n/$max)"
  jq -n --arg r "$1" '{decision: "block", reason: $r}'
  exit 0
}

cmd="$(grep -v '^[[:space:]]*#' "$root/.crewx/verify" 2>/dev/null | sed '/^[[:space:]]*$/d' | head -n1)"
if [ -z "$cmd" ]; then
  block "crewx gate: you changed files, but .crewx/verify is missing or empty. Write one shell line with the project's fast checks (typecheck, lint, unit tests; 'true' if it has none), record it as a decision, then end your turn again."
fi

secs="${CREWX_GATE_TIMEOUT:-600}"
if command -v timeout >/dev/null; then
  out="$(cd "$root" && timeout "$secs" bash -c "$cmd" 2>&1)"
else
  out="$(cd "$root" && bash -c "$cmd" 2>&1)"
fi
rc=$?

if [ "$rc" = 0 ]; then
  echo "$fp" >"$run.pass"
  rm -f "$run.fail"
  log_state "$state" "gate pass"
  exit 0
fi

[ "$rc" = 124 ] && note=" (timed out after ${secs}s)" || note=""
block "crewx gate failed$note (attempt $((fail_n + 1))/$max): \`$cmd\` exited $rc.
$(printf '%s\n' "$out" | tail -n 40)

Fix what this session broke, then end your turn again. If this session didn't cause it (the human's uncommitted edits, a flaky or pre-existing failure): don't touch it, note it under '## Waiting on human' in the state file, and end your turn without further changes; the gate won't block an unchanged tree twice."
