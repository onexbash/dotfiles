# -- -- -- -- -- -- -- -- -- -- #
# --       HOME ZSHENV       -- #
# -- -- -- -- -- -- -- -- -- -- #
# --        ~/.zshenv        -- #
# -- -- -- -- -- -- -- -- -- -- #

# Load user shell-profile shared with all Shells (sh|bash|zsh)
function load_sh_profile(){
  [ -f "$HOME/.profile" ] && emulate sh -c '. "$HOME/.profile"'
}

# Source Files that extend ~/.zshenv
function load_zshenv_files() {
  local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/shell"
  local config_files=(
    "env.zsh"
    "path.zsh"
    "secrets.sh"
  )

  if [[ ! -d "$config_dir" ]]; then
    mkdir -p "$config_dir"
  fi

  local file
  for file in "${config_files[@]}"; do
    local filepath="$config_dir/$file"
    if [[ -r "$filepath" ]]; then
      source "$filepath"
    else
      echo "zshenv: config file not found or not readable: $filepath" >&2
    fi
  done
}

# Define Fallbacks when issues with the utility shell file happen
function set_fallbacks() {
  _tty_styles() {
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
  }; _tty_styles "$@"; unset -f _tty_styles
}

# Call & Undefine above Functions
set_fallbacks
load_sh_profile
load_zshenv_files
unfunction set_fallbacks load_sh_profile load_zshenv_files
