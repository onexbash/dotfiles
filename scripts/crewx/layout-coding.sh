#!/usr/bin/env bash
# Shapes the Coding workspace once a client shows the session: tuios splits and resizes only with a client attached.
# Left 30%: lazygit (top) and a shell (bottom). Right 70%: the Editor pane (nvim), which setup already opened.
# Usage: layout-coding.sh <session> <project-dir> <window-to-focus-afterwards>
set -uo pipefail
session="$1" dir="$2" back="$3"

has() { tuios list-windows -s "$session" --json | jq -e --arg n "$1" 'any(.windows[]; .display_name == $n)' >/dev/null; }
has Git && exit 0 # already shaped

for _ in $(seq 120); do # wait up to a minute for the client
  tuios list-clients --json | jq -e --arg s "$session" 'any(.[]; .session == $s)' >/dev/null && break
  sleep 0.5
done

tuios select-workspace -s "$session" 1 >/dev/null # resize acts on the workspace on screen
tuios split-window -s "$session" left -w Editor --name Git >/dev/null || exit 1
tuios split-window -s "$session" horizontal -w Git --name Shell >/dev/null
width() { tuios list-windows -s "$session" --json | jq -r --arg n "$1" '.windows[] | select(.display_name == $n) | .width'; }
for _ in 1 2 3 4 5; do # right after the splits the resize can be dropped; retry until the editor is the wide one
  sleep 0.5
  tuios focus-window -s "$session" Editor >/dev/null
  tuios run-command -s "$session" resize_width_70 >/dev/null
  sleep 0.3
  [ "$(width Editor)" -gt "$(width Git)" ] && break
done
tuios send-text -s "$session" -w Git "cd $(printf %q "$dir") && lazygit
" >/dev/null
tuios send-text -s "$session" -w Shell 'exec "$SHELL" -l
' >/dev/null # tuios starts an interactive shell; make it a login shell
tuios select-workspace -s "$session" 2 >/dev/null
tuios focus-window -s "$session" "$back" >/dev/null
