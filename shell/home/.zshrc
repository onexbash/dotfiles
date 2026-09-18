#!/usr/bin/env zsh
# -- -- -- -- -- -- -- -- -- -- -- #
# --         HOME ZSHRC         -- #
# -- -- -- -- -- -- -- -- -- -- -- #
# --          ~/.zshrc          -- #
# -- -- -- -- -- -- -- -- -- -- -- #

# Source Files that extend ~/.zshrc
function load_zshrc_files() {
  local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/shell"
  local config_files=(
    "functions.zsh"
    "aliases.zsh"
    "tools.zsh"
    # "claude.zsh"
  )

  if [[ ! -d "$config_dir" ]]; then
    mkdir -p "$config_dir"
  fi

  local file
  for file in "${config_files[@]}"; do
    local filepath="$config_dir/$file"
    if [[ -r "$filepath" ]]; then
      source "$filepath"
    else
      echo "zshrc: config file not found or not readable: $filepath" >&2
    fi
  done
}

load_zshrc_files
unfunction load_zshrc_files
