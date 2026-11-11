#!/usr/bin/env bash
# crewx hook: one line per SubagentStart / SubagentStop in <project>/.crewx/activity.log.
# On stop it logs the first line of the subagent's report ("WP-3 done · abc123 · gate: pass").
# Always exits 0, so it never blocks an agent.
in="$(cat)"
dir="${CLAUDE_PROJECT_DIR:-$(jq -r '.cwd // empty' <<<"$in" 2>/dev/null)}"
[ -d "$dir/.crewx" ] || exit 0 # not a crewx project: log nothing

line="$(jq -r '
  [ (now | localtime | strftime("%H:%M:%S")),
    ((.hook_event_name // "?") | sub("^Subagent"; "") | ascii_downcase),
    ((.agent_type // "") | if . == "" then "subagent" else . end),
    ((.last_assistant_message // "") | split("\n") | map(select(test("\\S"))) | (.[0] // "") | .[0:100])
  ] | map(select(. != "")) | join("  ")' <<<"$in" 2>/dev/null)" || line="$(date +%T)  unparsed hook event"

printf '%s\n' "$line" >> "$dir/.crewx/activity.log"
exit 0
