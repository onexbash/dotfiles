#!/usr/bin/env bash
set -euo pipefail

# Colored output
function ok()   { echo -e "\033[1;32m[ OK ]\033[0m $*"; }
function info() { echo -e "\033[1;35m[INFO]\033[0m $*"; }
function warn() { echo -e "\033[1;33m[WARN]\033[0m $*" >&2; }
function err()  { echo -e "\033[1;31m[ERR ]\033[0m $*" >&2; exit 1; }

function main() {
  command -v brew &>/dev/null || err "Homebrew is not installed or not in PATH"
  command -v asdf &>/dev/null || err "asdf is not executable"

  [[ "$(command -v asdf)" == *homebrew* ]] && ok "asdf points to homebrew" || warn "asdf does NOT point to homebrew"

  local shims="${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
  [[ ":$PATH:" == *":$shims:"* ]] || err 'asdf shims not in PATH. Add: export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"'

  install_python
  install_lang golang "https://github.com/asdf-community/asdf-golang.git"
  install_lang ruby   "https://github.com/asdf-vm/asdf-ruby.git"
  install_lang neovim "https://github.com/richin13/asdf-neovim.git"

  info "For Go, add the following line to your shell config [zshrc/bashrc]:"
  info '  bash: . "${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/golang/set-env.bash"'
  info '  zsh:  . "${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/golang/set-env.zsh"'
}

# Install only missing brew packages, in one call
function install_deps() {
  local missing=()
  for pkg in "$@"; do
    brew list --formula "$pkg" &>/dev/null || missing+=("$pkg")
  done
  if (( ${#missing[@]} )); then
    info "Installing: ${missing[*]}"
    brew install --formula "${missing[@]}"
  else
    ok "All deps installed"
  fi
}

# Add plugin (if missing), install latest, set as default
function install_lang() {
  local name="$1" url="$2"
  asdf plugin list | grep -qx "$name" || { info "Adding plugin: $name"; asdf plugin add "$name" "$url"; }
  info "Installing $name (latest)"
  asdf install "$name" latest
  asdf set --home "$name" latest
  ok "$name installed & set as default"
}

function install_python() {
  install_deps openssl@3 readline sqlite xz tcl-tk@8 libb2 zstd zlib pkgconf
  install_lang python "https://github.com/asdf-community/asdf-python.git"
}

main "$@"

