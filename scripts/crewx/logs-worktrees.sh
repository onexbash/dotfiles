#!/usr/bin/env bash
# crewx Workers pane: live `wt list` of the project's worktrees (ahead/behind, uncommitted changes).
# Teammate panes open beside this pane; keep it running, it anchors them.
cd "${1:-$PWD}" || exit 1
last=""
while :; do
  out="$(wt list 2>&1 || git worktree list 2>&1)"
  if [ "$out" != "$last" ]; then clear; printf 'Worktrees  (refreshes every 5s)\n\n%s\n' "$out"; last="$out"; fi
  sleep 5
done
