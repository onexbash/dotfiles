# --            path.zsh            -- #
# --       sourced by: .zshenv      -- #
# --                                -- #

# -- Path Handler -- #
function construct_path() {
  # Default Bin Directories
  local system_paths=(  
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  )
  # MacOS Special Bin Directories
  local osx_paths=(
    "/System/Cryptexes/App/usr/bin"
    "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin"
    "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin"
    "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin"
  )
  # Custom Path Entries
  local custom_paths=(
    # GNU Tools
    "/opt/homebrew/opt/coreutils/libexec/gnubin"
    "/opt/homebrew/opt/grep/libexec/gnubin"
    # Rust / Cargo
    "${CARGO_HOME:-$XDG_CONFIG_HOME/cargo}/bin"
    # ASDF
    "${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
    # GoLang
    "${GOPATH:-$HOME/go}/bin"
  )
  
  # Clear path
  path=()

  # Construct $PATH variable
  typeset -U path
  path=(
      $system_paths
      $osx_paths
      $custom_paths
  )
  
  # Export $PATH
  export PATH


  # ASDF (version manager)
  fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath) # append completions to fpath
  autoload -Uz compinit && compinit # initialize completions
}

# Function Call
construct_path
