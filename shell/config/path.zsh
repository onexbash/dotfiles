# --            path.zsh            -- #
# --       sourced by: .zshenv      -- #
# --                                -- #
#
# PATH layers (high -> low priority):
#   1. User paths     - depend on $HOME or env vars, defined in this file
#   2. System paths   - /etc/paths + /etc/paths.d/* (managed by onesetup / Ansible, see group_vars/all/shell.yml -> system_paths)
#   3. Fallback paths - MacOS defaults, only matter if /etc/paths.d is missing
#   4. Inherited      - entries added by the parent process, kept last

# -- Homebrew environment -- #
# Sets HOMEBREW_PREFIX, MANPATH, INFOPATH, ...
# Its PATH entries come from /etc/paths.d/1-homebrew
function init_homebrew() {
  [[ -x /opt/homebrew/bin/brew ]] || return 0
  eval "$(/opt/homebrew/bin/brew shellenv)"
}

# -- Path Handler -- #
function construct_path() {
  # Deduplicate entries (keeps first occurrence) and tie $PATH to $path
  typeset -gU path PATH

  # 1. User paths
  local user_paths=(
    # Mise - shims
    $MISE_DATA_DIR/shims(N-/)
    # PNPM - Global
    $PNPM_HOME/bin(N-/)
    # Rust
    ${CARGO_HOME:-$XDG_CONFIG_HOME/rust/cargo}/bin(N-/)
    # Go
    ${GOBIN:-${GOPATH:-$XDG_CONFIG_HOME/go}/bin}(N-/)
  )

  # 2. System paths (files are read in filename order -> priority prefix)
  local system_paths=() file
  for file in /etc/paths /etc/paths.d/*(N.); do
    [[ -r $file ]] && system_paths+=(${(f)"$(< $file)"})
  done
  system_paths=(${^system_paths}(N-/))

  # 3. Fallback paths
  local fallback_paths=(
    /usr/local/bin
    /usr/bin
    /bin
    /usr/sbin
    /sbin
  )

  # Construct PATH (high -> low priority)
  path=(
    "${user_paths[@]}"
    "${system_paths[@]}"
    "${fallback_paths[@]}"
    "${path[@]}"
  )

  export PATH
}

# -- Function Calls -- #
init_homebrew
construct_path
unfunction init_homebrew construct_path
