# --            env.zsh            -- #
# --       sourced by: .zshenv     -- #
# --                               -- #


# -- ENVIRONMENT VARIABLES   -- #
# XDG base dirs
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Personal Directory Shortcuts
export XDEV="$HOME/dev"
export XREPOS="$XDEV/repos"
export XCLOUD="$HOME/Library/CloudStorage/ProtonDrive-fabian@schlegel.one-folder"
export XCONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
export XSCRIPTS="$XCONFIG/scripts"

# Custom
export TOGGLE_SCRIPT_DEBUG_MODE=0 # enable/disable debugging mode for scripts that load the onexbash helper-script
export TOGGLE_PATH_HELPER=0       # enable/disable MacOS path-helper utility

# -- TOOLS ENVIRONMENT -- #
# Rust
export CARGO_HOME="${XDG_CONFIG_HOME}/rust/cargo"
export RUSTUP_HOME="${XDG_CONFIG_HOME}/rust/rustup"
source "${CARGO_HOME}/env" # load cargo environment

# Starship
export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship/starship.toml"

# Zoxide (smart cd)
export _ZO_ECHO=0                                          # whether to print the matched directory before navigating to it
export _ZO_EXCLUDE_DIRS="${XCLOUD}/Vault" # exclude directories from the zoxide database
export _ZO_FZF_OPTS=""                                     # fzf options during interactive selection (see: man fzf for the list of options)
export _ZO_RESOLVE_SYMLINKS=0                              # whether to resolve symlinks before adding directories to the zoxide database

# Homebrew
export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1 # opt-out of sending Azure Functions Core tools telematry to microsoft.
export HOMEBREW_NO_ENV_HINTS=1                 # disable hints about homebrew environment variables.

# ASDF
export ASDF_DATA_DIR="${XDG_CONFIG_HOME}/asdf"
export ASDF_CONFIG_FILE="${XDG_CONFIG_HOME}/asdf/config.ini"
 
# Claude-Code
export DISABLE_AUTOUPDATER=1 # disable Claude-Code Auto-Updater to be managed by homebrew
