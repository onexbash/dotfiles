#!/usr/bin/env bash

# --                            -- #
# --     RUN AUTOSTART APPS     -- #
# --                            -- #

# Main Function (Constructor)
function main() {
  # Source Utility Script & Call Functions
  source "$SHELL_UTIL_FILE"
  set_modes
  tty_styles

  # Function Calls
  run_autostart_apps "$@"
}

function run_autostart_apps() {
  # zsh: an unmatched glob expands to nothing instead of raising an error
  [ -n "${ZSH_VERSION:-}" ] && setopt local_options null_glob

  local dir="$HOME/Library/LaunchAgents"
  local dry_run=0 filter="" f name label arg prog i count=0 failed=0
  local -a cmd

  if [ "${1:-}" = "-n" ]; then
    dry_run=1
    shift
  fi
  filter="${1:-}"

  if [ ! -d "$dir" ]; then
    echo -e "${I_ERR}Directory not found: ${C_CYAN}${dir}${C_RESET}" >&2
    return 1
  fi

  [ "$dry_run" -eq 1 ] && echo -e "${I_INFO}Dry run – nothing will be started."

  for f in "$dir"/*.plist; do
    [ -f "$f" ] || continue
    name="${f##*/}"
    case "$name" in *"$filter"*) ;; *) continue ;; esac

    # Collect ProgramArguments.0, .1, ... until plutil runs out of entries
    cmd=()
    prog=""
    i=0
    while arg=$(plutil -extract "ProgramArguments.$i" raw -o - "$f" 2>/dev/null); do
      [ "$i" -eq 0 ] && prog="$arg"
      cmd+=("$arg")
      i=$((i + 1))
    done

    # Fall back to the "Program" key if there is no ProgramArguments array
    if [ ${#cmd[@]} -eq 0 ]; then
      if arg=$(plutil -extract Program raw -o - "$f" 2>/dev/null); then
        prog="$arg"
        cmd=("$arg")
      fi
    fi

    if [ ${#cmd[@]} -eq 0 ]; then
      echo -e "${I_SKIP}${name} ${C_BLACK}(no Program/ProgramArguments)${C_RESET}"
      continue
    fi

    label=$(plutil -extract Label raw -o - "$f" 2>/dev/null) || label="$name"

    if [ "$dry_run" -eq 1 ]; then
      echo -e "${I_INFO}${C_CYAN}${label}${C_RESET} → ${cmd[*]}"
      count=$((count + 1))
      continue
    fi

    if [ "${prog##*/}" = "open" ]; then
      # "open" returns immediately, so its exit status is reliable
      if "${cmd[@]}" >/dev/null 2>&1; then
        echo -e "${I_OK}${C_CYAN}${label}${C_RESET}"
        count=$((count + 1))
      else
        echo -e "${I_ERR}${C_CYAN}${label}${C_RESET} → ${cmd[*]}" >&2
        failed=$((failed + 1))
      fi
    else
      # Other programs may keep running: start detached, no job-control output
      ("${cmd[@]}" >/dev/null 2>&1 &)
      echo -e "${I_OK}${C_CYAN}${label}${C_RESET} ${C_BLACK}(started in background)${C_RESET}"
      count=$((count + 1))
    fi
  done

  if [ "$dry_run" -eq 1 ]; then
    echo -e "${I_INFO}${count} agent(s) listed."
  elif [ "$failed" -gt 0 ]; then
    echo -e "${I_WARN}${count} agent(s) started, ${C_RED}${failed} failed${C_RESET}."
  else
    echo -e "${I_INFO}${count} agent(s) started."
  fi
}

# Call Main Function with Args
main "$@"
