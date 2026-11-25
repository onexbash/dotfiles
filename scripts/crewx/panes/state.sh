#!/usr/bin/env bash
# crewx Board pane (left): live render of the project's most recently changed session state file.
# shellcheck source=/dev/null
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/util.sh" 2>/dev/null || log_info() { echo "$*"; }
cd "${1:-$PWD}" || exit 1
printf '\e]2;crewx state\a'
last=""
render() {
  if command -v glow >/dev/null; then glow -s dark -w "$(tput cols)" "$1"; else cat "$1"; fi
}
while :; do
  file="$(ls -t ./.crewx/sessions/*.md 2>/dev/null | head -n1)"
  # polls once per second; cheap enough for one file
  cur="$file $(stat -c '%Y %s' "$file" 2>/dev/null || stat -f '%m %z' "$file" 2>/dev/null || echo missing)"
  if [ "$cur" != "$last" ]; then
    clear
    if [ -z "$file" ]; then log_info "waiting for the lead's first session in .crewx/sessions/ ..."; else render "$file"; fi
    last="$cur"
  fi
  sleep 1
done
