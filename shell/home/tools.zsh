#!/usr/bin/env zsh
# -- -- -- -- -- -- #
# --    TOOLS    -- #
# -- -- -- -- -- -- #

# Zoxide (better cd)
eval "$(zoxide init zsh --cmd cd --hook pwd)"

# Starship
eval "$(starship init zsh)"

# ZSH-Autocomplete
# source "$(brew --prefix)/opt/zsh-autocomplete/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

# fnm (node version manager)
eval "$(fnm env --use-on-cd --shell zsh)"

# Atuin (shell history)
eval "$(atuin init zsh)"

# ASDF (version manager)
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath) # append completions to fpath
autoload -Uz compinit && compinit # initialize completions

# Ghostty
if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
  source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration" # enable shell-integration
fi
