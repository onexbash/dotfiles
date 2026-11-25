#!/usr/bin/env bash
# Shared helpers for the crewx hooks. Sourced, never run. Every hook must exit 0 unless it means to block.
# shellcheck disable=SC2034 # variables are used by the sourcing hooks

CREWX_HOME="${CREWX_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)}"
CREWX_INDEX="${XDG_STATE_HOME:-$HOME/.local/state}/crewx/index.tsv"
CREWX_AGENTS="asta|yuno|yami|noelle|mimosa|hinata"

hook_input() { # reads the hook's JSON from stdin into $IN
  IN="$(cat)"
}
field() { # field <jq path> -> value from $IN, empty if missing
  jq -r "$1 // empty" <<<"$IN" 2>/dev/null
}

project_root() { # project_root <dir> -> top of its work tree, if it is a crewx project
  local d="${1:-$PWD}" top
  top="$(git -C "$d" rev-parse --show-toplevel 2>/dev/null)" || return 1
  [ -d "$top/.crewx" ] || return 1
  printf '%s\n' "$top"
}

state_file() { # state_file <root> <session_id> -> path of this session's state file, empty if none
  local root="$1" sid="${2:0:8}" f
  [ -n "$sid" ] || return 0
  for f in "$root"/.crewx/sessions/*-"$sid".md; do
    [ -e "$f" ] && {
      printf '%s\n' "$f"
      return 0
    }
  done
  return 0
}

stamp() { date '+%H:%M:%S'; }
sed_esc() { printf '%s' "$1" | sed 's/[&|\\]/\\&/g'; } # escape a sed replacement that uses | as delimiter

log_state() { # log_state <state file> <text>: append one line under "## Log" (the last section)
  [ -n "$1" ] && [ -f "$1" ] || return 0
  printf -- '- %s %s\n' "$(stamp)" "$2" >>"$1"
}

fingerprint() { # fingerprint <root>: changes with HEAD, tracked content, untracked files and the gate command
  local root="$1"
  {
    cat "$root/.crewx/verify" 2>/dev/null # a new gate command is worth a new run
    git -C "$root" rev-parse HEAD 2>/dev/null
    git -C "$root" diff HEAD 2>/dev/null
    # untracked, not ignored files: names and content hashes
    git -C "$root" ls-files --others --exclude-standard 2>/dev/null
    git -C "$root" ls-files --others --exclude-standard -z 2>/dev/null |
      (cd "$root" && xargs -0 git hash-object -- 2>/dev/null)
  } | shasum | cut -c1-16
}

is_crewx_agent() { # is_crewx_agent <agent_type>: true for crewx:<name> and the bare names
  [[ "$1" =~ ^(crewx:)?($CREWX_AGENTS)$ ]]
}

notify_human() { # notify_human <subject> <text>: tuios mail to the person, if this runs in a tuios pane
  [ -n "${TUIOS_PANE_ID:-}" ] && command -v tuios >/dev/null || return 0
  tuios send-agent-message -w human --from "$TUIOS_PANE_ID" --subject "$1" "$2" >/dev/null 2>&1 || true
}
