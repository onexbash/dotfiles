#!/usr/bin/env bash
# crewx SubagentStart / SubagentStop hook, for the crewx agents only (not Explore and the like):
#   - one line in the state file's log: start, and on stop the first line of the agent's report
#   - a marker per running agent in .crewx/run/<session>.agents/, so the gate waits for them
# Always exits 0, so it never blocks an agent.
set -uo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

hook_input
sid="$(field .session_id)"
root="$(project_root "$(field .cwd)")" || exit 0
agent="$(field .agent_type)"
is_crewx_agent "$agent" || exit 0
agent="${agent#crewx:}"
id="$(field .agent_id)"
id="${id:-$agent}"
id="${id//\//_}"
marks="$root/.crewx/run/${sid:0:8}.agents"
state="$(state_file "$root" "$sid")"

case "$(field .hook_event_name)" in
SubagentStart)
  mkdir -p "$marks"
  : >"$marks/$id"
  log_state "$state" "start $agent"
  ;;
SubagentStop)
  rm -f "$marks/$id"
  report="$(field .last_assistant_message | grep -m1 '[^[:space:]]' | cut -c1-120)"
  log_state "$state" "stop  $agent${report:+: $report}"
  ;;
esac
exit 0
