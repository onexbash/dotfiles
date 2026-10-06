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
  export C_BLACK='\033[1;30m'
  export C_RED='\033[1;31m'
  export C_GREEN='\033[1;32m'
  export C_YELLOW='\033[1;33m'
  export C_BLUE='\033[1;34m'
  export C_PURPLE='\033[1;35m'
  export C_CYAN='\033[1;36m'
  export C_WHITE='\033[1;37m'
  export C_GRAY='\033[1;34m'
  export C_RESET='\033[0m'

  # -- INFO PROMPTS -- #
  export I_SKIP="${C_BLACK}[${C_CYAN} SKIPPING ${C_BLACK}] ${C_RESET}"   # skipping
  export I_WARN="${C_BLACK}[${C_YELLOW} WARNING ${C_BLACK}] ${C_RESET}"  # warning
  export I_OK="${C_BLACK}[${C_GREEN}  OK  ${C_BLACK}] ${C_RESET}"        # ok
  export I_INFO="${C_BLACK}[${C_PURPLE} INFO ${C_BLACK}] ${C_RESET}"     # info
  export I_ERR="${C_BLACK}[${C_YELLOW} ERROR ${C_BLACK}] ${C_RESET}"     # error
  export I_YN="${C_BLACK}[${C_BLUE} y/n ${C_BLACK}] ${C_RESET}"          # ask user for yes/no
  export I_ASK="${C_BLACK}[${C_BLUE} ? ${C_BLACK}] ${C_RESET}"           # ask user for anything
  export I_LOAD="${C_BLACK}[${C_BLUE} LOADING .. ${C_BLACK}] ${C_RESET}" # ask user for anything
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

# [UTIL] Get the bundle ID of MacOS apps
function get_bundle_id() {
  if [[ "$(detect_os)" != "osx" ]]; then
    echo -e "${I_ERR}get_bundle_id only works on macOS" >&2
    return 1
  fi

  # Parse arguments: flags can be placed anywhere, the last mode flag wins
  local mode="stdout" arg
  local -a apps=() ids=()
  for arg in "$@"; do
    case "$arg" in
    --stdout) mode="stdout" ;;
    --copy) mode="copy" ;;
    -*)
      echo -e "${I_ERR}Unknown option: ${C_RED}${arg}${C_RESET}" >&2
      return 1
      ;;
    *) apps+=("$arg") ;;
    esac
  done
  if [[ ${#apps[@]} -eq 0 ]]; then
    echo -e "${I_INFO}Usage: get_bundle_id [--stdout | --copy] <App Name | /path/to/App.app> [...]" >&2
    return 1
  fi

  local app id rc=0
  for app in "${apps[@]}"; do
    if [[ "$app" == *.app ]]; then
      # Path to an .app bundle: read its Info.plist
      id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Contents/Info.plist" 2>/dev/null)
    else
      # App name: resolve it like `open -a` does
      id=$(osascript -e 'on run argv' -e 'return id of application (item 1 of argv)' -e 'end run' "$app" 2>/dev/null)
    fi

    if [[ -z "$id" ]]; then
      echo -e "${I_ERR}App not found: ${C_RED}${app}${C_RESET}" >&2
      rc=1
    elif [[ "$mode" == "copy" ]]; then
      ids+=("$id")
    elif [[ ${#apps[@]} -eq 1 ]]; then
      echo "$id"
    else
      echo -e "${I_OK}${C_WHITE}${app}${C_RESET}: ${C_CYAN}${id}${C_RESET}"
    fi
  done

  # Copy all found IDs at once (one per line, no trailing newline)
  if [[ "$mode" == "copy" && ${#ids[@]} -gt 0 ]]; then
    if (
      IFS=$'\n'
      printf '%s' "${ids[*]}"
    ) | copy_to_clipboard; then
      echo -e "${I_OK}Copied to clipboard: ${C_CYAN}${ids[*]}${C_RESET}"
    else
      rc=1
    fi
  fi

  return $rc
}

# Call main Function with Args
main "$@"
