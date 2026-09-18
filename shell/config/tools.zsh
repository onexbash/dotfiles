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

# EZA (better ls)
function ls() {
  local eza_args=(
    --long
    --show-symlinks
    --icons
    --color=always
    --no-permissions
    --no-user
    --no-filesize
    --octal-permissions
    --time-style="+%d/%m|%H:%M"
  )
  # Process arguments
  local pass_args=()
  local show_all=false
  local tree_view=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -a)
        show_all=true
        ;;
      -t)
        tree_view=true
        ;;
      *)
        pass_args+=("$1")
        ;;
    esac
    shift
  done
  # Add --all if -a was specified
  if [[ "$show_all" == true ]]; then
    eza_args+=(--all)
  fi
  # Add tree options if -t was specified
  if [[ "$tree_view" == true ]]; then
    eza_args+=(--tree --level=2)
  fi
  # Call eza with the constructed arguments
  eza "${eza_args[@]}" "${pass_args[@]}"
}
