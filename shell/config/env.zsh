# --            env.zsh            -- #
# --       sourced by: .zshenv     -- #
# --                               -- #
#
# -- ENVIRONMENT VARIABLES   -- #
# XDG base dirs
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_BIN_DIR="${HOME}/.local/bin"
# Personal Directory Shortcuts
export XDEV="$HOME/dev" # Dev Directory
export XCONFIG="$XDG_CONFIG_HOME" # Config Directory
export XENV="$XDG_CONFIG_HOME/shell/context" # Context Directory (Environment Specific Configs)
export XCLOUD="$HOME/Library/CloudStorage/ProtonDrive-fabian@schlegel.one-folder" # Cloud Directory
export XLOGS="$XDG_STATE_HOME/logs" # Logs Directory
export XTEMP="/tmp" # Temp Directory
export XSHELL="zsh" # Preferred Shell
# Preferred Package Managers
export XPKG_SYSTEM="brew"
export XPKG_DEVTOOLS="mise"
export XPKG_PYTHON="uv"
export XPKG_NODE="pnpm"
# Scripts
export XSCRIPT_DIR="$XDG_CONFIG_HOME/scripts" # Scripts Directory
export XSCRIPT_DEBUG=0

# Custom # TODO: check if these can be removed in favor of XSCRIPT_.. above
export TOGGLE_SCRIPT_DEBUG_MODE=0 # enable/disable debugging mode for scripts that load the onexbash helper-script
export TOGGLE_PATH_HELPER=0       # enable/disable MacOS path-helper utility

# -- TOOLS ENVIRONMENT -- #
# ZSH
export ZDOTDIR="${ZDOTDIR:-$HOME}"

# Mise
export MISE_CONFIG_DIR="${XDG_CONFIG_HOME}/mise"
export MISE_STATE_DIR="${XDG_STATE_HOME}/mise"
export MISE_CACHE_DIR="${XDG_CACHE_HOME}/mise"
export MISE_DATA_DIR="${XDG_DATA_HOME}/mise"

# ONESETUP
export ONESETUP_CONFIG="${XDG_CONFIG_HOME}/onesetup/config.yml"
export ONESETUP_REPO="https://github.com/onexbash/onesetup.git"
export ONESETUP_SSH_KEY="~/.ssh/id_github_onexbash"
export ONESETUP_SSH_PASS="pass://SSH Keys/id_github_onexbash/Passphrase"
export ONESETUP_VAULT_PASS="pass://Development/Ansible Vault - onesetup/Secret"

# Python / uv
export XDG_BIN_HOME="${XDG_BIN_DIR}"
export UV_TOOL_BIN_DIR="${XDG_BIN_DIR}"

# NPM
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm"

# PNPM
export PNPM_HOME="${XDG_DATA_HOME}/pnpm"

# Azure
export AZ_TENANT="cratos-prod"

# Proton Pass
export PROTON_PASS_SESSION_DIR="${XDG_DATA_HOME}/proton-pass-cli"
export PASS_SSH_VAULT="SSH Keys"

# Fnox
export FNOX_CONFIG_DIR="${XDG_CONFIG_HOME}/fnox"

# Docker/Podman
export DOCKER_HOST="unix://${TMPDIR%/}/podman/podman-machine-default-api.sock"

# Worktrunk
export WORKTRUNK_SYSTEM_CONFIG_PATH="/etc/worktrunk/config.toml" # Global Config
export WORKTRUNK_CONFIG_PATH="${XDG_CONFIG_HOME}/worktrunk/config.toml" # User Config
export WORKTRUNK_PROJECT_CONFIG_PATH="worktrunk.toml" # Project-Wide Config
export WORKTRUNK_VERBOSE=1 # Verbosity Level [0/1/2]
export WORKTRUNK_MAX_CONCURRENT_COMMANDS=24 # Max parallel git commands

# Rust
export CARGO_HOME="${XDG_CONFIG_HOME}/cargo"
export RUSTUP_HOME="${XDG_CONFIG_HOME}/rustup"
source "${CARGO_HOME}/env" # load cargo environment

# GoLang
export GOPATH="${XDG_CONFIG_HOME}/go"
export GOBIN="${GOPATH}/bin"
export GOENV="${GOPATH}/env"
export GOCACHE="${GOPATH}/cache"

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

# Claude
export CLAUDE_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/claude"
export CLAUDE_TRUSTED_DIRS="${HOME}/dev:${HOME}/.config:${XDG_DATA_HOME}/dotfiles:${HOME}/.claude"
export ANTHROPIC_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/anthropic"
export DISABLE_AUTOUPDATER=1 # disable Claude-Code Auto-Updater to be managed by homebrew

# Azure CLI
export AZURE_CONFIG_DIR="${XDG_CONFIG_HOME}/azure"
