# -- -- -- -- -- -- -- -- -- -- #
# -- ENVIRONMENT VARIABLES   -- #
# -- -- -- -- -- -- -- -- -- -- #

# -- XDG BASE DIRS -- #
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# -- SHELL [zsh] -- #
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/shell/zsh"

# -- DIRECTORY SHORTCUTS -- #
export ONEXCLOUD="/opt/onexcloud" && export XCLOUD="$ONEXCLOUD" # Network Storage (Personal Cloud)
export ONEXCORE="/opt/onexcore" && export XCORE="$ONEXCORE" # Core Files
export ONEXDEV="${XCORE}/dev" && export XDEV="$ONEXDEV"
export ONEXREPOS="${XDEV}/repos" && export XREPOS="$ONEXREPOS"

# -- CUSTOM -- #
export TOGGLE_SCRIPT_DEBUG_MODE=0 # enable/disable debugging mode for scripts that load the onexbash helper-script
export TOGGLE_PATH_HELPER=0 # enable/disable MacOS path-helper utility

