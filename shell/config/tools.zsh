# --            tools.zsh            -- #
# --       sourced by: .zshrc        -- #
# --                                 -- #

# -- Zoxide -- #
eval "$(zoxide init zsh --cmd cd --hook pwd)"

# -- Starship -- #
eval "$(starship init zsh)"

# -- Atuin -- #
eval "$(atuin init zsh)"

# -- Ghostty -- #
# Enable shell-integration
if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
  source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
fi

# -- Worktrunk -- #
# Setup Shell Integration for Worktrunk
if command -v wt >/dev/null 2>&1; then
  eval "$(command wt config shell init zsh)";
fi

# -- FZF -- #
# Apply Catppuccin-Mocha Theme for fzf
export FZF_THEME_OPTS=" \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4"
export FZF_DEFAULT_OPTS="$FZF_THEME_OPTS --height=40% --layout=reverse --border"

# -- CLAUDE -- #
# Claude Wrapper to Auto Trust Directories under ~/dev/
function claude_trust() {
  command -v jq >/dev/null || return 0      # stay silent if jq is missing
  local trust_root="$HOME/dev" cfg="$HOME/.claude.json" key top common
  local -a keys
  if top=$(git rev-parse --show-toplevel 2>/dev/null); then
    keys+=("$top")
    common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
    [[ "$common" == */.git ]] && keys+=("${common%/.git}")
  else
    keys+=("$(pwd -P)")
  fi
  for key in "${keys[@]}"; do
    case "$key" in "$trust_root"|"$trust_root"/*) ;; *) continue ;; esac
    [[ -f "$cfg" ]] || echo '{}' > "$cfg"
    jq -e --arg p "$key" '.projects[$p].hasTrustDialogAccepted == true' "$cfg" >/dev/null 2>&1 && continue
    jq --arg p "$key" '.projects[$p] = ((.projects[$p] // {}) + {hasTrustDialogAccepted: true})' \
      "$cfg" > "$cfg.tmp" && mv "$cfg.tmp" "$cfg"
  done
}

# -- EZA -- #
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
    input_ask prog "Program or path to add to allowed callers (e.g. git):" || return 1
  fi
  prog="${prog/#\~/$HOME}"   # expand leading ~ (not expanded when typed at the prompt)

  case "$prog" in
    # Path given: make it absolute and normalized (resolves ./ and ../)
    */*) bin="$(cd "$(dirname "$prog")" 2>/dev/null && pwd)/$(basename "$prog")" ;;
    # Name given: resolve via PATH (zsh: whence -p, bash: type -P)
    *)   bin="$(whence -p "$prog" 2>/dev/null || type -P "$prog" 2>/dev/null)" ;;
  esac

  if [ ! -f "$bin" ] || [ ! -x "$bin" ]; then
    log_err "'${prog}' is not an executable program"
    return 1
  fi

  log_info "Adding allowed caller: ${C_CYAN}${bin}${C_RESET}"
  if git-credential-keepassxc caller add --uid "$(id -u)" --gid "$(id -g)" "$bin"; then
    log_ok "Added ${C_CYAN}${bin}${C_RESET}"
  else
    log_err "Failed to add ${C_CYAN}${bin}${C_RESET}"
    return 1
  fi
}
