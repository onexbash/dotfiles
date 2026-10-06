# -- -- -- -- -- -- -- -- -- -- #
# --       HOME ZSHENV       -- #
# -- -- -- -- -- -- -- -- -- -- #
# --        ~/.zshenv        -- #
# -- -- -- -- -- -- -- -- -- -- #

# Load user shell-profile shared with all Shells (sh|bash|zsh)
function load_sh_profile(){
  [ -f "$HOME/.profile" ] && emulate sh -c '. "$HOME/.profile"'
}

# Source Files that extend ~/.zshenv
function load_zshenv_files() {
  local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/shell"
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

# Call & Undefine above Functions
load_sh_profile
load_zshenv_files
unfunction load_sh_profile load_zshenv_files
