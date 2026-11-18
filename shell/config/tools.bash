#!/usr/bin/env bash

# Starship
eval "$(starship init bash)"

# Zoxide (smart cd)
eval "$(zoxide init bash)"

# Atuin (shell history)
eval "$(atuin init bash)"

# Cargo
. "$XDG_CONFIG_HOME/rust/cargo/env" # Initialize Cargo Environment
