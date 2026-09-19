# --            path.zsh            -- #
# --       sourced by: .zshenv      -- #
# --                                -- #

# -- Path Handler -- #
function construct_path() {
  # Deduplicate entries and tie scalar $PATH to array $path
  typeset -U path PATH
  
  # Add paths from /etc/paths & /etc/paths.d/*
  local system_paths=()

  if [[ -f "/etc/paths" ]]; then
    system_paths+=(${(f)"$(< /etc/paths)"})
  fi 

  if [[ -d "/etc/paths.d" ]]; then
    for file in /etc/paths.d/*(N); do
      [[ -f "$file" ]] && system_paths+=(${(f)"$(< "$file")"})
    done
  fi 

  # Default Path Entries
  local default_paths=(  
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  )

  # Custom Path Entries
  local custom_paths=(
    # Homebrew
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    # GNU Utils
    "/opt/homebrew/opt/coreutils/libexec/gnubin"
    "/opt/homebrew/opt/grep/libexec/gnubin"
    # Rust / Cargo
    "${CARGO_HOME:-$XDG_CONFIG_HOME/cargo}/bin"
    # ASDF
    "${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
    # GoLang
    "${GOPATH:-$HOME/go}/bin"
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
