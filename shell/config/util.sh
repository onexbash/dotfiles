# --                            -- #
# --     UTILITY SHELL-FILE     -- #
# --    SOURCED BY ZSH & BASH   -- #
# --                            -- #

# Main 'Constructor' that calls init functions (which should always be called)
function main() {
  tty_styles
}

# [INIT] Terminal Colors & Prompts
function tty_styles() {
  # -- TERMINAL COLORS -- #
  export C_BLACK=$'\033[1;30m'
  export C_RED=$'\033[1;31m'
  export C_GREEN=$'\033[1;32m'
  export C_YELLOW=$'\033[1;33m'
  export C_BLUE=$'\033[1;34m'
  export C_PURPLE=$'\033[1;35m'
  export C_CYAN=$'\033[1;36m'
  export C_WHITE=$'\033[1;37m'
  export C_GRAY=$'\033[0;90m'
  export C_RESET=$'\033[0m'

  # -- INFO PROMPTS -- #
  export I_SKIP="${C_BLACK}[${C_CYAN} SKIPPING ${C_BLACK}] ${C_RESET}"   # skipping
  export I_WARN="${C_BLACK}[${C_YELLOW} WARNING ${C_BLACK}] ${C_RESET}"  # warning
  export I_OK="${C_BLACK}[${C_GREEN}  OK  ${C_BLACK}] ${C_RESET}"        # ok
  export I_INFO="${C_BLACK}[${C_PURPLE} INFO ${C_BLACK}] ${C_RESET}"     # info
  export I_ERR="${C_BLACK}[${C_RED} ERROR ${C_BLACK}] ${C_RESET}"        # error
  export I_YN="${C_BLACK}[${C_BLUE} y/n ${C_BLACK}] ${C_RESET}"          # ask user for yes/no
  export I_ASK="${C_BLACK}[${C_BLUE} ? ${C_BLACK}] ${C_RESET}"           # ask user for anything
  export I_LOAD="${C_BLACK}[${C_BLUE} LOADING .. ${C_BLACK}] ${C_RESET}" # loading / in progress
}

# [UTIL] Detect Operating System
function detect_os() {
  local platform
  platform=$(uname -s)
  case "$platform" in
  Linux*) echo "linux" ;;
  Darwin*) echo "osx" ;;
  CYGWIN* | MINGW* | MSYS*) echo "windows" ;;
  *) echo "unsupported" ;;
  esac
}

# [UTIL] Set Script Modes TODO: refactor this
function set_modes() {
  set -eo pipefail
  TOGGLE_SCRIPT_DEBUG_MODE="${TOGGLE_SCRIPT_DEBUG_MODE:-0}"
  if [[ "$TOGGLE_SCRIPT_DEBUG_MODE" -eq 1 ]]; then
    set -x
    echo -e "${I_OK}Running Script in Debug Mode"
  fi
}

# [UTIL] Copy stdin to clipboard
function copy_to_clipboard() {
  local os
  os="$(detect_os)"
  # MacOS (pbcopy/xclip)
  if [[ "$os" == "osx" ]]; then
    if command -v pbcopy &>/dev/null; then
      pbcopy
      return
    fi
    if command -v xclip &>/dev/null; then
      xclip -selection clipboard 2>/dev/null
      return
    fi
  # Linux (wl-copy/xclip/xsel)
  elif [[ "$os" == "linux" ]]; then
    if [[ -n "$WAYLAND_DISPLAY" ]] && command -v wl-copy &>/dev/null; then
      wl-copy
      return
    fi
    if [[ -n "$DISPLAY" ]]; then
      if command -v xclip &>/dev/null; then
        xclip -selection clipboard 2>/dev/null
        return
      fi
      if command -v xsel &>/dev/null; then
        xsel --clipboard --input
        return
      fi
    fi
  fi

  cat
  echo -e "\n${I_WARN}No clipboard tool found on ${C_YELLOW}${os}${C_RESET} — printed above instead." >&2
  return 1
}

# [UTIL] Linux PKG Installer
function install_linux_pkg() {
  local pkg="$1"
  if command -v apt-get &>/dev/null; then
    sudo apt-get update -qq && sudo apt-get install -y "$pkg"
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y "$pkg"
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm "$pkg"
  else
    echo -e "${I_ERR}Unsupported package manager." >&2 && return 1
  fi
}

# Call main Function with Args
main "$@"
