#!/usr/bin/env bash

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Starship
eval "$(starship init bash)"

# FNM (node version manager)
eval "$(fnm env --use-on-cd --shell bash)"

# Zoxide (smart cd)
eval "$(zoxide init bash)"

# Atuin (shell history)
eval "$(atuin init bash)"

# ASDF (version manager)
export ASDF_DATA_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/asdf"
export ASDF_CONFIG_FILE="${ASDF_DATA_DIR}/config.ini"
. <(asdf completion bash) # initialize completions
