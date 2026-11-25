#!/usr/bin/env bash
# crewx SessionStart hook: one state file per Claude Code session, in <project>/.crewx/sessions/.
#   startup | clear | fork: create the file (from templates/session.md), register it for `crewx status`,
#                           and tell the lead its path (plus an unfinished earlier session, if any).
#   resume | compact:       re-inject the file, so the lead picks up exactly where the state says.
# Also records the work tree's fingerprint, so the Stop gate runs only once something changed.
set -uo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

hook_input
sid="$(field .session_id)"
src="$(field .source)"
root="$(project_root "$(field .cwd)")" || exit 0
[ -n "$sid" ] || exit 0

mkdir -p "$root/.crewx/sessions" "$root/.crewx/run"
file="$(state_file "$root" "$sid")"
new=0
if [ -z "$file" ]; then
  # an unfinished earlier session in this work tree, newest first
  prev=""
  while IFS= read -r f; do
    st="$(sed -n 's/^status: *//p' "$f" | head -n1)"
    case "$st" in done | "") ;; *)
      prev="$f"
      break
      ;;
    esac
  done < <(ls -t "$root"/.crewx/sessions/*.md 2>/dev/null)
  file="$root/.crewx/sessions/$(date '+%Y%m%d-%H%M')-${sid:0:8}.md"
  branch="$(git -C "$root" symbolic-ref --quiet --short HEAD 2>/dev/null || echo detached)"
  tuios_ref="${TUIOS_SESSION:-none}/${TUIOS_PANE_ID:-none}"
  sed -e "s|{{SESSION}}|$(sed_esc "$sid")|g" -e "s|{{BRANCH}}|$(sed_esc "$branch")|g" \
    -e "s|{{TUIOS}}|$(sed_esc "$tuios_ref")|g" -e "s|{{STARTED}}|$(date '+%Y-%m-%d %H:%M')|g" \
    -e "s|{{PROJECT}}|$(sed_esc "$root")|g" \
    "$CREWX_HOME/templates/session.md" >"$file"
  mkdir -p "$(dirname "$CREWX_INDEX")"
  printf '%s\t%s\t%s\t%s\n' "$file" "${TUIOS_SESSION:-}" "${TUIOS_PANE_ID:-}" "$(date +%s)" >>"$CREWX_INDEX"
  new=1
fi
log_state "$file" "session $src"

# Baseline for the gate: the tree as it was when this session started.
[ -e "$root/.crewx/run/${sid:0:8}.base" ] || fingerprint "$root" >"$root/.crewx/run/${sid:0:8}.base"

rel="${file#"$root"/}"
ctx="crewx: this session's state file is $rel (absolute: $file). Keep it current as your rules say."
if [ ! -s "$root/.crewx/verify" ]; then
  ctx="$ctx .crewx/verify is missing or empty: write it before your first change."
fi
if [ "$new" = 1 ] && [ -n "${prev:-}" ]; then
  ctx="$ctx An earlier session in this work tree is unfinished: ${prev#"$root"/} (status: $(sed -n 's/^status: *//p' "$prev" | head -n1)). If the request continues it, carry its open items over."
fi
case "$src" in resume | compact)
  # Front matter and sections, but only the tail of the log: it is the bulky, least useful part.
  body="$(awk '/^## Log/{print; inlog=1; next} !inlog{print}' "$file")"
  log_tail="$(awk 'f{print} /^## Log/{f=1}' "$file" | grep '^- ' | tail -n 15)"
  ctx="$ctx
Current state file (log trimmed to the last 15 lines):
$body
$log_tail"
  ;;
esac

jq -n --arg c "$ctx" '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $c}}'
exit 0
