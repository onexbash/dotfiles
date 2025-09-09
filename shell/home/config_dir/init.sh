# Load Environment Variables
function load_env() {
  local env_dir="${XDG_CONFIG_HOME:-$HOME/.config}/shell/env"
  source "${env_dir}/vars.sh"
  source "${env_dir}/helper.sh"
  load_colors && load_prompt_styles
}

# Load Shared & specific bash/zsh Config Files
function load_config() {
  local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/shell"  
  # Load Shared Shell Config Files (.sh)
  if [ -d "$config_dir" ]; then
    for file in "$config_dir"/*.sh; do
      [ -f "$file" ] && source "$file"
    done
  else
    echo -e "${I_WARN}$config_dir doesn't exist. No config files are sourced."
    return 0
  fi

  if [[ "${BASH-no}" != "no" ]]; then
    # Load Bash Config Files (.bash)
    for file in "$config_dir"/*.bash; do
      [ -f "$file" ] && source "$file"
    done
  else
    # Load ZSH Config Files (.zsh)
    for file in "$config_dir"/*.zsh; do
      [ -f "$file" ] && source "$file"
    done
  fi
}
