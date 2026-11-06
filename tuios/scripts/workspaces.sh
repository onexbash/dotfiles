#!/usr/bin/env sh

# Switch workspace relative to the current one: ws-step.sh -1 or ws-step.sh +1
step=${1:-1}
cur=$(tuios session-info -s "$TUIOS_SESSION" --json \
  | sed -n 's/.*"current_workspace": *\([0-9]*\).*/\1/p')
[ -n "$cur" ] || exit 1
next=$(( (cur - 1 + step + 9) % 9 + 1 ))   # wraps 1 <-> 9
tuios select-workspace -s "$TUIOS_SESSION" "$next"
