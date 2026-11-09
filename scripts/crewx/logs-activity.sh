#!/usr/bin/env bash
# crewx Logs pane (left): live activity log written by the hooks.
cd "${1:-$PWD}" || exit 1
printf '\e]2;crewx activity\a'
exec tail -n 200 -F ./.crewx/activity.log
