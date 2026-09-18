#!/usr/bin/env zsh
# -- -- -- -- -- -- -- -- -- -- -- #
# --        HOME ZLOGOUT        -- #
# -- -- -- -- -- -- -- -- -- -- -- #
# --         ~/.zlogout         -- #
# -- -- -- -- -- -- -- -- -- -- -- #

# Source Files that extend ~/.zlogout
function load_zlogout_files() {
  local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/shell"
  local config_files=(
    "logout.zsh"
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
      echo "zlogout: config file not found or not readable: $filepath" >&2
    fi
  done
}

load_zlogout_files
unfunction load_zlogout_files
