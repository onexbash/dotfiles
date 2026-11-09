#!/usr/bin/env bash
# crewx Logs pane (right): re-render ./docs/PLAN.md whenever it changes.
cd "${1:-$PWD}" || exit 1
file=./docs/PLAN.md
last=""
render() {
  if command -v glow >/dev/null; then glow -s dark -w "$(tput cols)" "$file"; else cat "$file"; fi
}
while :; do
  # shortcut: polls mtime once per second, swap for fswatch if that ever matters
  cur="$(stat -f '%m %z' "$file" 2>/dev/null || echo missing)"
  if [ "$cur" != "$last" ]; then
    clear
    if [ "$cur" = missing ]; then echo "waiting for $file ..."; else render; fi
    last="$cur"
  fi
  sleep 1
done
