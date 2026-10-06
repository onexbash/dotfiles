# --                            -- #
# --     UTILITY SHELL-FILE     -- #
# --    SOURCED BY ZSH & BASH   -- #
# --                            -- #

# [UTIL] Terminal Colors & Prompts
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

# [UTIL] Copy to clipboard
function copy_to_clipboard() {
  if command -v pbcopy &>/dev/null; then
    pbcopy
  elif command -v wl-copy &>/dev/null; then
    wl-copy
  elif command -v xclip &>/dev/null; then
    xclip -selection clipboard 2>/dev/null
  else
    cat
    echo -e "\n${I_WARN}No clipboard tool found — printed above instead." >&2
  fi
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
  if [[ $# -eq 0 ]]; then
    echo "Usage: get_bundle_id <App Name | /path/to/App.app> [...]" >&2
    return 1
  fi

  local os app id rc=0
  os=$(detect_os)

  for app in "$@"; do
    id=""
    if [[ -f "$app/Contents/Info.plist" ]]; then
      # Path to an .app bundle: read Info.plist directly
      if [[ "$os" == "osx" ]]; then
        id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Contents/Info.plist" 2>/dev/null)
      elif command -v python3 >/dev/null 2>&1; then
        id=$(python3 -c 'import plistlib,sys; print(plistlib.load(open(sys.argv[1],"rb"))["CFBundleIdentifier"])' "$app/Contents/Info.plist" 2>/dev/null)
      else
        echo "get_bundle_id: python3 is required to read .app bundles on $os" >&2
        rc=1
        continue
      fi
    elif [[ "$os" == "osx" ]]; then
      # App name: resolve it like `open -a` does
      id=$(osascript -e 'on run argv' -e 'return id of application (item 1 of argv)' -e 'end run' "$app" 2>/dev/null)
    else
      echo "get_bundle_id: lookup by app name only works on macOS ($os); pass a path to an .app bundle instead" >&2
      rc=1
      continue
    fi

    if [[ -z "$id" ]]; then
      echo "get_bundle_id: '$app' not found" >&2
      rc=1
      continue
    fi

    if [[ $# -eq 1 ]]; then
      echo "$id"
    else
      printf '%s: %s\n' "$app" "$id"
    fi
  done

  return $rc
}
