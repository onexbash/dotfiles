function main() {
  tty_styles
  set_path
  environment
}

# Set TTY Style Variables (colors, prompts, ..)
function tty_styles() {
  # -- TERMINAL COLORS -- #
  export C_BLACK='\033[1;30m'
  export C_RED='\033[1;31m'
  export C_GREEN='\033[1;32m'
  export C_YELLOW='\033[1;33m'
  export C_BLUE='\033[1;34m'
  export C_PURPLE='\033[1;35m'
  export C_CYAN='\033[1;36m'
  export C_WHITE='\033[1;37m'
  export C_GRAY='\033[1;34m'
  export C_RESET='\033[0m'

  # -- INFO PROMPTS -- #
  export I_SKIP="${C_BLACK}[${C_CYAN} SKIPPING ${C_BLACK}] ${C_RESET}"   # skipping
  export I_WARN="${C_BLACK}[${C_YELLOW} WARNING ${C_BLACK}] ${C_RESET}"  # warning
  export I_OK="${C_BLACK}[${C_GREEN}  OK  ${C_BLACK}] ${C_RESET}"        # ok
  export I_INFO="${C_BLACK}[${C_PURPLE} INFO ${C_BLACK}] ${C_RESET}"     # info
  export I_ERR="${C_BLACK}[${C_YELLOW} ERROR ${C_BLACK}] ${C_RESET}"     # error
  export I_YN="${C_BLACK}[${C_BLUE} y/n ${C_BLACK}] ${C_RESET}"          # ask user for yes/no
  export I_ASK="${C_BLACK}[${C_BLUE} ? ${C_BLACK}] ${C_RESET}"           # ask user for anything
  export I_LOAD="${C_BLACK}[${C_BLUE} LOADING .. ${C_BLACK}] ${C_RESET}" # ask user for anything

}

# Construct `$PATH` variable based on path files
function set_path() {
  # define path files in the desired order
  local path_files=(
    "${XDG_CONFIG_HOME:-$HOME/.config}/shell/paths/custom.env"
    "${XDG_CONFIG_HOME:-$HOME/.config}/shell/paths/default.env"
    "${XDG_CONFIG_HOME:-$HOME/.config}/shell/paths/system.env"
  )
  # read path files
  local path_list=()
  for path_file in "${path_files[@]}"; do
    if [[ -f "$path_file" ]]; then
      # append each line as a new entry of the $PATH variable
      while IFS= read -r line; do
        if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then # skip empty lines and comments `#`
          path_list+=("$line")
        fi
      done <"$path_file"
    fi
  done
  # clear $PATH variable
  export PATH=""
  # append path_list to $PATH variable
  if ((${#path_list[@]})); then
    joined=$(
      IFS=:
      printf '%s' "${path_list[*]}"
    )                     # convert array to colon-separated string
    export PATH="$joined" # set the complete path (since we cleaned it up)
  fi
}

function environment() {
  # -- ENVIRONMENT VARIABLES   -- #
  # XDG base dirs
  export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
  export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
  export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
  export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

  # SHELL [zsh]
  export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/shell/zsh"

  # Directory Shortcuts
  export ONEXCLOUD="/opt/onexcloud" && export XCLOUD="$ONEXCLOUD" # Network Storage (Personal Cloud)
  export ONEXCORE="${HOME}/onexcore" && export XCORE="$ONEXCORE"  # Core Files
  export ONEXDEV="${XCORE}/dev" && export XDEV="$ONEXDEV"

  # Custom
  export TOGGLE_SCRIPT_DEBUG_MODE=0 # enable/disable debugging mode for scripts that load the onexbash helper-script
  export TOGGLE_PATH_HELPER=0       # enable/disable MacOS path-helper utility

  # -- TOOLS ENVIRONMENT -- #
  # Starship
  export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship/starship.toml"
  # Zoxide (smart cd)
  export _ZO_ECHO=0                                          # whether to print the matched directory before navigating to it
  export _ZO_EXCLUDE_DIRS="$ONEXCLOUD/.secret/*:/tmp/secret" # exclude directories from the zoxide database
  export _ZO_FZF_OPTS=""                                     # fzf options during interactive selection (see: man fzf for the list of options)
  export _ZO_RESOLVE_SYMLINKS=0                              # whether to resolve symlinks before adding directories to the zoxide database

  # Homebrew
  export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1 # opt-out of sending Azure Functions Core tools telematry to microsoft.
  export HOMEBREW_NO_ENV_HINTS=1                 # disable hints about homebrew environment variables.

  # GoLang
  export GOPATH="${XDG_CONFIG_HOME}/go"

  # Claude-Code
  export DISABLE_AUTOUPDATER=1 # disable Claude-Code Auto-Updater to be managed by homebrew
}

# Main Function Call
main "$@"
