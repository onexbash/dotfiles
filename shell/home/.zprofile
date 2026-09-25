#!/usr/bin/env zsh
# -- -- -- -- -- -- -- -- -- -- #
# --      HOME ZPROFILE      -- #
# -- -- -- -- -- -- -- -- -- -- #
# --    $ZDOTDIR/.zprofile   -- #
# -- -- -- -- -- -- -- -- -- -- #

# Source Files that extend .zprofile
function load_zprofile_files() {
  local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/shell"
  local config_files=(
    # "brew.zsh"
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
      echo "zprofile: config file not found or not readable: $filepath" >&2
    fi
  done
}

load_zprofile_files
unfunction load_zprofile_files
