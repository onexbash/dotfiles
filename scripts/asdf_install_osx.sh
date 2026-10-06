#!/usr/bin/env bash

function main() {
  # Source Utility Script & Call Functions
  source "$SHELL_UTIL_FILE"
  set_modes
  tty_styles

  # Call Functions of this Script
  asdf_installer
}

# ASDF Installation Logic
function asdf_installer() {
  command -v brew &>/dev/null || echo -e "${I_ERR}Homebrew is not installed or not in PATH"
  command -v asdf &>/dev/null || echo -e "${I_ERR}asdf is not executable"

  [[ "$(command -v asdf)" == *homebrew* ]] && echo -e "${I_OK}asdf points to homebrew" || echo -e "${I_WARN}asdf does NOT point to homebrew"

  local shims="${ASDF_DATA_DIR:-$HOME/.asdf}/shims"
  [[ ":$PATH:" == *":$shims:"* ]] || echo -e "${I_ERR}asdf shims not in PATH. Add: export PATH=\"\${ASDF_DATA_DIR:-\$HOME/.asdf}/shims:\$PATH\""

  install_python
  install_lang golang "https://github.com/asdf-community/asdf-golang.git"
  install_lang ruby "https://github.com/asdf-vm/asdf-ruby.git"
  install_lang lua "https://github.com/Stratus3D/asdf-lua.git"
  install_lang neovim "https://github.com/richin13/asdf-neovim.git"

  echo -e "${I_INFO}For Go, add the following line to your shell config [zshrc/bashrc]:"
  echo -e "${I_INFO}bash: . \"\${ASDF_DATA_DIR:-\$HOME/.asdf}/plugins/golang/set-env.bash\""
  echo -e "${I_INFO}zsh:  . \"\${ASDF_DATA_DIR:-\$HOME/.asdf}/plugins/golang/set-env.zsh\""
}

# Install only missing brew packages, in one call
function install_deps() {
  local missing=()
  for pkg in "$@"; do
    brew list --formula "$pkg" &>/dev/null || missing+=("$pkg")
  done
  if ((${#missing[@]})); then
    echo -e "${I_INFO}Installing: ${missing[*]}"
    brew install --formula "${missing[@]}"
  else
    echo -e "${I_OK}All deps installed"
  fi
}

# Add plugin (if missing), install latest, set as default
function install_lang() {
  local name="$1" url="$2"
  asdf plugin list | grep -qx "$name" || {
    echo -e "${I_INFO}Adding plugin: $name"
    asdf plugin add "$name" "$url"
  }
  echo -e "${I_INFO}Installing $name (latest)"
  asdf install "$name" latest
  asdf set --home "$name" latest
  echo -e "${I_OK}$name installed & set as default"
}

function install_python() {
  install_deps openssl@3 readline sqlite xz tcl-tk@8 libb2 zstd zlib pkgconf
  install_lang python "https://github.com/asdf-community/asdf-python.git"
}

main "$@"
