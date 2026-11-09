#!/usr/bin/env bash
# crewx hook: append one line per TaskCreated / TaskCompleted / TeammateIdle event
# to <project>/.crewx/activity.log. Always exits 0, so it never blocks an agent.
in="$(cat)"
dir="${CLAUDE_PROJECT_DIR:-$(jq -r '.cwd // empty' <<<"$in" 2>/dev/null)}"
[ -d "$dir/.crewx" ] || exit 0 # not a crewx project: log nothing

line="$(jq -r '
  [ (now | localtime | strftime("%H:%M:%S")),
    (.hook_event_name // "?"),
    (.teammate_name // "Jarvis"),
    (if .task_id then "#\(.task_id) \(.task_subject // "")" else empty end)
  ] | join("  ")' <<<"$in" 2>/dev/null)" || line="$(date +%T)  unparsed hook event"

printf '%s\n' "$line" >> "$dir/.crewx/activity.log"
exit 0
