# -- -- -- -- -- -- -- -- -- -- -- -- -- #
# --         USER BASH_PROFILE        -- #
# -- -- -- -- -- -- -- -- -- -- -- -- -- #
# --          ~/.bash_profile         -- #
# -- -- -- -- -- -- -- -- -- -- -- -- -- #

# Source global bash_profile
if [ -f /etc/bash_profile ]; then
  . /etc/bash_profile
fi

# Source user shell-profile shared with all Shells (sh|bash|zsh)
if [ -f "$HOME/.profile" ]; then
  if [ -n "$ZSH_VERSION" ]; then
    emulate sh -c '. "$HOME/.profile"'
  else
    . "$HOME/.profile"
  fi
fi

# Source User Config Files
load_configs() {
  local config_dir file cfg_path # not "path": in zsh it is tied to $PATH
  config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/shell"

  # Define Config Files & Loading Order
  local configs=(
    "env.bash"
  )

  # Source defined Config Files
  for file in "${configs[@]}"; do
    cfg_path="$config_dir/${file}"
    if [ -r "$cfg_path" ]; then
      . "$cfg_path"
    else
      echo "ERR: Config file not found or unreadable: $cfg_path" >&2
    fi
  done
}

# Define Fallbacks when issues with the utility shell file happen
set_fallbacks() {
  # -- TERMINAL COLORS -- #
  export C_BLACK=$'\033[1;30m'
  export C_RED=$'\033[1;31m'
  export C_GREEN=$'\033[1;32m'
  export C_YELLOW=$'\033[1;33m'
  export C_BLUE=$'\033[1;34m'
  export C_PURPLE=$'\033[1;35m'
  export C_CYAN=$'\033[1;36m'
  export C_WHITE=$'\033[1;37m'
  export C_GRAY=$'\033[0;90m'
  export C_RESET=$'\033[0m'

  # -- INFO PROMPTS -- #
  export I_SKIP="${C_BLACK}[${C_CYAN} SKIPPING ${C_BLACK}] ${C_RESET}"   # skipping
  export I_WARN="${C_BLACK}[${C_YELLOW} WARNING ${C_BLACK}] ${C_RESET}"  # warning
  export I_OK="${C_BLACK}[${C_GREEN}  OK  ${C_BLACK}] ${C_RESET}"        # ok
  export I_INFO="${C_BLACK}[${C_PURPLE} INFO ${C_BLACK}] ${C_RESET}"     # info
  export I_ERR="${C_BLACK}[${C_RED} ERROR ${C_BLACK}] ${C_RESET}"        # error
  export I_YN="${C_BLACK}[${C_BLUE} y/n ${C_BLACK}] ${C_RESET}"          # ask user for yes/no
  export I_ASK="${C_BLACK}[${C_BLUE} ? ${C_BLACK}] ${C_RESET}"           # ask user for anything
  export I_LOAD="${C_BLACK}[${C_BLUE} LOADING .. ${C_BLACK}] ${C_RESET}" # loading / in progress
}

# Call & Undefine above Functions (unset -f works in bash and zsh)
set_fallbacks
load_configs
unset -f set_fallbacks load_configs
