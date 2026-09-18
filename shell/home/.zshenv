#!/usr/bin/env zsh
# -- -- -- -- -- -- -- -- -- -- #
# --       HOME ZSHENV       -- #
# -- -- -- -- -- -- -- -- -- -- #
# --        ~/.zshenv        -- #
# -- -- -- -- -- -- -- -- -- -- #

# Source Files that extend ~/.zshenv
function load_zshenv_files() {
  local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
  local config_files=(
    "env.zsh"
    "path.zsh"
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
      echo "zshenv: config file not found or not readable: $filepath" >&2
    fi
  done
}

load_zshenv_files
unfunction load_zshenv_files
