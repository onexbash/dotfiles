#!/usr/bin/env bash
# crewx Worktrees pane: live `wt list` of the project's worktrees (ahead/behind, uncommitted changes).
# shellcheck source=/dev/null
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/util.sh" 2>/dev/null || log_info() { echo "$*"; }
cd "${1:-$PWD}" || exit 1
printf '\e]2;crewx worktrees\a'
last=""
while :; do
  out="$(wt list 2>&1 || git worktree list 2>&1)"
  if [ "$out" != "$last" ]; then
    clear
    log_info "Worktrees  (refreshes every 5s)"
    printf '\n%s\n' "$out"
    last="$out"
  fi
  sleep 5
done
