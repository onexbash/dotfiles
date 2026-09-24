#!/usr/bin/env bash

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# ZelliJ
# Auto-Start ZelliJ if not inside a session already
if [[ -z "$ZELLIJ" ]]; then 
  if [[ "$ZELLIJ_AUTO_ATTACH" == "true" ]]; then 
    zellij attach -c
  else
    zellij
  fi 
  if [[ "$ZELLIJ_AUTO_EXIT" == "true" ]]; then 
    exit 
  fi 
fi
# eval "$(zellij setup --generate-auto-start bash)"

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

# Cargo
. "$HOME/.cargo/env" # Initialize Cargo Environment

# GoLang
export PATH="$PATH:${GOPATH:-$HOME/go}/bin" # Add GoLang's bin directory to $PATH
