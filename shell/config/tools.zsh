# --            tools.zsh            -- #
# --       sourced by: .zshrc        -- #
# --                                 -- #

# Zoxide (better cd)
eval "$(zoxide init zsh --cmd cd --hook pwd)"

# Starship
eval "$(starship init zsh)"

# fnm (node version manager)
eval "$(fnm env --use-on-cd --shell zsh)"

# Atuin (shell history)
eval "$(atuin init zsh)"

# Ghostty
if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
  source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration" # enable shell-integration
fi

# ASDF
# Initialize completions (PATH adding handled in path.zsh)
autoload -Uz compinit && compinit

# GoLang
# Run the asdf-golang set-env Script to ensure GOROOT, GOPATH & GOBIN are set correctly
source "${ASDF_DATA_DIR:-$HOME/.config/asdf}/plugins/golang/set-env.zsh"

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

# --  git-credential-keepassxc  -- #
# -- alias: gck | ./aliases.zsh -- #
# --                            -- #

# [FNC] Overwrite --config for custom config-file
git-credential-keepassxc() {
  command git-credential-keepassxc --config "${XDG_CONFIG_HOME:-$HOME/.config}/gck/config.json" "$@"
}
# [ALIAS] git-credential-keepassxc -> gck
alias gck="git-credential-keepassxc"

# [FNC] Install gck
function gck_install() {
  # Install gck
  cargo install --locked git-credential-keepassxc
  # Install cargo-update
  cargo install --locked cargo-update
  # Install gck Features
  cargo install --locked --features "all" git-credential-keepassxc
  # Install gck Features autoupdate
  cargo install-update-config git-credential-keepassxc --enforce-lock --feature "all"
}
# [FNC] Update gck
function gck_update() {
  cargo install-update git-credential-keepassxc
}
# [FNC] Add programs to allowed callers
gck_add_caller() {
  tty_styles
  local prog="$1" bin
 
  if [ -z "$prog" ]; then
    echo -ne "${I_ASK}Program or path to add to allowed callers (e.g. git): "
    read -r prog
  fi
  prog="${prog/#\~/$HOME}"   # expand leading ~ (not expanded when typed at the prompt)
 
  case "$prog" in
    # Path given: make it absolute and normalized (resolves ./ and ../)
    */*) bin="$(cd "$(dirname "$prog")" 2>/dev/null && pwd)/$(basename "$prog")" ;;
    # Name given: resolve via PATH (zsh: whence -p, bash: type -P)
    *)   bin="$(whence -p "$prog" 2>/dev/null || type -P "$prog" 2>/dev/null)" ;;
  esac
 
  if [ ! -f "$bin" ] || [ ! -x "$bin" ]; then
    echo -e "${I_ERR}'${prog}' is not an executable program" >&2
    return 1
  fi
 
  echo -e "${I_INFO}Adding allowed caller: ${C_CYAN}${bin}${C_RESET}"
  if git-credential-keepassxc caller add --uid "$(id -u)" --gid "$(id -g)" "$bin"; then
    echo -e "${I_OK}Added ${C_CYAN}${bin}${C_RESET}"
  else
    echo -e "${I_ERR}Failed to add ${C_CYAN}${bin}${C_RESET}" >&2
    return 1
  fi
}

# -- GitHub -- #
# [ENV] Export GitHub Personal Access Token from KeepassXC
export GITHUB_PAT_PUBLIC_READ="$(printf 'protocol=https\nhost=api.github.com\n\n' | git-credential-keepassxc get 2>/dev/null | sed -n 's/^password=//p')"
