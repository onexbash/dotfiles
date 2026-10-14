# -- -- -- -- -- -- -- -- -- -- -- #
# --         HOME ZSHRC         -- #
# -- -- -- -- -- -- -- -- -- -- -- #
# --          ~/.zshrc          -- #
# -- -- -- -- -- -- -- -- -- -- -- #

# Function to Source Shell Files
function load_shell_files() {
  local shell_dir="${XDG_CONFIG_HOME:-$HOME/.config}/shell"

  if [[ ! -d "$shell_dir" ]]; then
    mkdir -p "$shell_dir"
  fi

  # Source Utility Shell File
  local util_file="${shell_dir}/util.sh"
  source "$util_file" && echo -e "${I_OK}Utility Shell File sourced: ~/.config/shell/util.sh" || echo -e "${I_ERR}Failed to source Utility Shell File! Make sure it exists with correct permissions: $shell_dir/util.sh"

  # Load Config Shell Files that extend ~/.zshrc
  local config_files=(
    "zellij.zsh"
    "autoreload.zsh"
    "functions.zsh"
    "aliases.zsh"
    "tools.zsh"
    # "claude.zsh"
  )
  local file
  for file in "${config_files[@]}"; do
    local filepath="$shell_dir/$file"
    if [[ -r "$filepath" ]]; then
      source "$filepath"
    else
      echo "zshrc: config file not found or not readable: $filepath" >&2
    fi
  done
}

load_shell_files
unfunction load_shell_files
