# --            path.zsh            -- #
# --       sourced by: .zshenv      -- #
# --                                -- #

# Initialize Homebrew before constructing the PATH
function init_homebrew() { 
  eval $(/opt/homebrew/bin/brew shellenv)
}

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
    # ASDF
    ${ASDF_DATA_DIR:-$HOME/.asdf}/shims(N-/)
    # Rust / Cargo
    ${CARGO_HOME:-$XDG_CONFIG_HOME/cargo}/bin(N-/)
    # GoLang
    ${GOPATH:-$HOME/go}/bin(N-/)
    # Homebrew
    /opt/homebrew/bin(N-/)
    /opt/homebrew/sbin(N-/)
    # GNU Utils
    /opt/homebrew/opt/coreutils/libexec/gnubin(N-/)
    /opt/homebrew/opt/grep/libexec/gnubin(N-/)
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


# Function Calls
init_homebrew
construct_path
