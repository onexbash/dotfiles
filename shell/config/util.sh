# --                            -- #
# --     UTILITY SHELL-FILE     -- #
# --    SOURCED BY ZSH & BASH   -- #
# --                            -- #

# Main 'Constructor' that calls init functions (which should always be called)
function main() {
  tty_styles
}

function tty_styles() {
  # Disable colors when output isn't a terminal or NO_COLOR is set
  if [[ -t 1 && -z ${NO_COLOR-} ]]; then
    C_RED=$'\033[1;31m' C_GREEN=$'\033[1;32m' C_YELLOW=$'\033[1;33m'
    C_BLUE=$'\033[1;34m' C_PURPLE=$'\033[1;35m' C_CYAN=$'\033[1;36m'
    C_WHITE=$'\033[1;37m' C_GRAY=$'\033[0;90m' C_RESET=$'\033[0m'
  else
    C_RED="" C_GREEN="" C_YELLOW="" C_BLUE="" C_PURPLE="" C_CYAN="" C_WHITE="" C_GRAY="" C_RESET=""
  fi

  # Fixed-width labels so messages line up
  I_SKIP="${C_GRAY}[${C_CYAN}SKIPPING${C_GRAY}]${C_RESET} "
  I_WARN="${C_GRAY}[${C_YELLOW}WARNING ${C_GRAY}]${C_RESET} "
  I_OK="${C_GRAY}[${C_GREEN}   OK   ${C_GRAY}]${C_RESET} "
  I_INFO="${C_GRAY}[${C_PURPLE}  INFO  ${C_GRAY}]${C_RESET} "
  I_ERR="${C_GRAY}[${C_RED} ERROR  ${C_GRAY}]${C_RESET} "
  I_ASK="${C_GRAY}[${C_BLUE}   ?    ${C_GRAY}]${C_RESET} "
  I_ASK_YN="${C_GRAY}[${C_BLUE}  y/n   ${C_GRAY}]${C_RESET} "
}

log_ok() { printf '%s%s\n' "$I_OK" "$*"; }
log_info() { printf '%s%s\n' "$I_INFO" "$*"; }
log_warn() { printf '%s%s\n' "$I_WARN" "$*" >&2; }
log_err() { printf '%s%s\n' "$I_ERR" "$*" >&2; }
log_skip() { printf '%s%s\n' "$I_SKIP" "$*"; }
log_ask() { printf '%s%s\n' "$I_ASK" "$*"; }
log_ask_yn() { printf '%s%s\n' "$I_ASK_YN" "$*"; }

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
