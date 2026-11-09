#!/usr/bin/env bash
# crewx: start Jarvis. Runs under `tuios tmux-shim`, in the Jarvis pane.
# $1: tuios window id of the Worktrees pane on the Workers workspace. Claude Code splits teammate
# panes off $TMUX_PANE, so pointing it at that pane puts every teammate on the Workers workspace.
if [ -n "${1:-}" ] && p="$(tmux display-message -p -t "%$1" '#{pane_id}' 2>/dev/null)" && [ -n "$p" ]; then
  export TMUX_PANE="$p"
else
  echo "crewx: Workers anchor pane not found; teammates will open beside Jarvis" >&2
fi
exec env CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude --agent jarvis --settings "$HOME/.config/scripts/crewx/settings.json"
