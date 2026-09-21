# --            path.zsh            -- #
# --       sourced by: .zshenv      -- #
# --                                -- #

# -- Path Handler -- #
function construct_path() {
  # Deduplicate entries and tie scalar $PATH to array $path
  typeset -gU path PATH
  
  # Add paths from /etc/paths & /etc/paths.d/*
  local system_paths=()

  if [[ -f "/etc/paths" ]]; then
    system_paths+=(${(f)"$(< /etc/paths)"})
  fi 
 
  local file
  for file in /etc/paths.d/*(N.); do
     system_paths+=(${(f)"$(< "$file")"})
  done

  # Default Path Entries
  local default_paths=(  
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  )

  # Custom Path Entries
  # note: '(N-/)' drops the entry if no directory exists for a path entry
  local custom_paths=(
    # Homebrew TODO: check if it makes more sense to add them to /etc/paths.d/50-custom
    /opt/homebrew/bin(N-/)
    /opt/homebrew/sbin(N-/)
    # GNU Utils
    /opt/homebrew/opt/coreutils/libexec/gnubin(N-/)
    /opt/homebrew/opt/grep/libexec/gnubin(N-/)
    # Rust / Cargo
    ${CARGO_HOME:-$XDG_CONFIG_HOME/cargo}/bin(N-/)
    # ASDF
    ${ASDF_DATA_DIR:-$HOME/.asdf}/shims(N-/)
    # GoLang
    ${GOPATH:-$HOME/go}/bin(N-/)
  )
  
  # Clear & construct PATH (high-to-low priority)
  path=(
      "${custom_paths[@]}"
      "${system_paths[@]}"
      "${default_paths[@]}"
  )
  
  # Export PATH
  export PATH

  # ASDF Completions setup
  if [[ -d "${ASDF_DATA_DIR:-$HOME/.asdf}/completions" ]]; then
    fpath=("${ASDF_DATA_DIR:-$HOME/.asdf}/completions" $fpath)
  fi
}

# Function Call
construct_path
