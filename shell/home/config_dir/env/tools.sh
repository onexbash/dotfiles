# -- TOOLS -- #
# Starship
export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship/starship.toml"
# Zoxide (smart cd)
export _ZO_ECHO=0 # whether to print the matched directory before navigating to it
export _ZO_EXCLUDE_DIRS="$ONEXCLOUD/.secret/*:/tmp/secret" # exclude directories from the zoxide database
export _ZO_FZF_OPTS="" # fzf options during interactive selection (see: man fzf for the list of options)
export _ZO_RESOLVE_SYMLINKS=0 # whether to resolve symlinks before adding directories to the zoxide database

# Homebrew
export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1 # opt-out of sending Azure Functions Core tools telematry to microsoft.
export HOMEBREW_NO_ENV_HINTS=1 # disable hints about homebrew environment variables.

# GoLang
export GOPATH="${XDG_CONFIG_HOME}/go"

