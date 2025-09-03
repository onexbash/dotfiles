# -- -- -- -- -- -- -- -- -- -- #
# -- ENVIRONMENT VARIABLES   -- #
# -- -- -- -- -- -- -- -- -- -- #

# -- CUSTOM -- #
# whether debugging mode in scripts is turned on (when using my helper script)
export TOGGLE_SCRIPT_DEBUG_MODE=0 # enable/disable debugging mode for scripts that load the onexbash helper-script
export TOGGLE_PATH_HELPER=0 # enable/disable MacOS path-helper utility

# -- DIRECTORY SHORTCUTS -- #
export ONEXCLOUD="/opt/xcloud" && export XCLOUD="$ONEXCLOUD" # Network Storage (Personal Cloud) 
export ONEXCORE="/opt/onexcore" && export XCORE="$ONEXCORE" # Core Files
export ONEXDOTS="/opt/onexdotfiles" && export XDOTS="$ONEXDOTS" # Dotfiles Origin
export ONEXDEV="${XCORE}/dev" && export XDEV="$ONEXDEV"
export ONEXREPOS="${XDEV}/repos" && export XREPOS="$ONEXREPOS"

# -- TOOLS -- #
# Starship
export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship/starship.toml"
# Zoxide (better cd)
export _ZO_ECHO=0 # whether to print the matched directory before navigating to it
export _ZO_EXCLUDE_DIRS="$ONEXCLOUD/.secret/*:/tmp/secret" # exclude directories from the zoxide database
export _ZO_FZF_OPTS="" # fzf options during interactive selection (see: man fzf for the list of options)
export _ZO_RESOLVE_SYMLINKS=0 # whether to resolve symlinks before adding directories to the zoxide database

# Homebrew
export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1 # opt-out of sending Azure Functions Core tools telematry to microsoft.
export HOMEBREW_NO_ENV_HINTS=1 # disable hints about homebrew environment variables.

# GoLang
export GOPATH="${XDG_CONFIG_HOME}/go"

# -- VIM -- #
# export VIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/vim"
# export VIMINIT="source ${VIM_CONFIG_DIR}/vimrc"
