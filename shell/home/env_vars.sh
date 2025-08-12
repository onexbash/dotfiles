# -- -- -- -- -- -- -- -- -- -- #
# -- ENVIRONMENT VARIABLES   -- #
# -- -- -- -- -- -- -- -- -- -- #

# -- CUSTOM -- #
# whether debugging mode in scripts is turned on (when using my helper script)
export TOGGLE_SCRIPT_DEBUG="0" 

# -- DIRECTORY SHORTCUTS -- #
export ONEXCLOUD="/opt/onexcloud"
export ONEXCORE="/opt/onexcore"
export ONEXDOTFILES="/opt/dotfiles"
export CODEX="${ONEXCORE}/codex"

# -- TOOLS -- #
# Starship
export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship/starship.toml"
# Zoxide (better cd)
export _ZO_ECHO=0 # whether to print the matched directory before navigating to it
export _ZO_EXCLUDE_DIRS="$ONEXCLOUD/.secret/*:/tmp/secret" # exclude directories from the zoxide database
export _ZO_FZF_OPTS="" # fzf options during interactive selection (see: man fzf for the list of options)
export _ZO_RESOLVE_SYMLINKS=0 # whether to resolve symlinks before adding directories to the zoxide database
