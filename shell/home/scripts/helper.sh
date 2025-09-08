#!/usr/bin/env bash
# -- -- -- -- -- -- -- -- -- -- #
# --      HELPER SCRIPT      -- #
# -- -- -- -- -- -- -- -- -- -- #
# this script loads prompt stylings, sets some options
# and provides reusable functions that can be sourced by other scripts.

# Function to export all common colors as environment variables (background & foreground)
function load_colors() {
  # -- DEFINE ANSI CODES -- #
  declare -A colorcodes
  colorcodes=(
    ["black"]="0"
    ["red"]="1" 
    ["green"]="2"
    ["yellow"]="3"
    ["blue"]="4"
    ["magenta"]="5"
    ["cyan"]="6"
    ["white"]="7"
    ["gray"]="8"
  )

  # Control Codes
  local foreground="38"
  local background="48"
  local colorspace="5" # 5) 256 Colors | 2) RGB Colors
  
  # -- CONSTRUCT ANSI ESCAPE SEQUENCE -- #
  get_ansi_sequence() {
    local type="$1"    # "fg" or "bg"
    local color="$2"   # color name from colorcodes array

    if [[ "$type" == "fg" ]]; then
      type="$foreground"
    elif [[ "$type" == "bg" ]]; then
      type="$background"
    fi
    # return constructed ansi escape sequence
    echo "\e[${type};${colorspace};${colorcodes[$color]}m"
  }
 
  # -- EXPORT VARIABLES -- #
  # Export Color Variables
  for color in "${!colorcodes[@]}"; do
    # Foreground Colors
    # usage: `echo -e "${FG_BLUE}blue text"`
    export "FG_${color^^}"="$(get_ansi_sequence "fg" "$color")"
    # Background Colors
    # usage: `echo -e "${BG_BLUE}blue background"`
    export "BG_${color^^}"="$(get_ansi_sequence "bg" "$color")"
  done 
  # Export Style Variables
  export RESET="\e[0m"
  export BOLD="\e[1m"
}


# -- PROMPT STYLINGS -- #
function load_stylings(){
  # Terminal Prompts
  export I_OK="${C_BLACK}[${C_GREEN}  OK  ${C_BLACK}] ${C_RESET}"       # ok
  export I_WARN="${C_BLACK}[${C_YELLOW} WARNING ${C_BLACK}] ${C_RESET}" # warning
  export I_ERR="${C_BLACK}[${C_RED} ERROR ${C_BLACK}] ${C_RESET}"    # error
  export I_INFO="${C_BLACK}[${C_PURPLE} INFO ${C_BLACK}] ${C_RESET}"    # info
  export I_DO="${C_BLACK}[${C_PURPLE}  ...  ${C_BLACK}] ${C_RESET}"     # do
  export I_DONE="${C_BLACK}[${C_GREEN} DONE ${C_BLACK}] ${C_RESET}"     # done
  export I_ASK="${C_BLACK}[${C_BLUE} ? ${C_BLACK}] ${C_RESET}"          # ask user for anything
  export I_ASK_YN="${C_BLACK}[${C_BLUE} [Y/N] ${C_BLACK}] ${C_RESET}"   # ask user for yes or no
  # ASCII-Mojis
  export E_CROSS="♱"
  export E_HEART="❤︎"
  export E_STAR="✮"
  export E_ARROW_RIGHT="»"
  export E_ARROW_LEFT="«"
  export E_CHECK="✔"
  export E_X="✘"
  export E_HEADPHONES="☊"
  export E_MUSIC="♪"
  export E_MUSIC2="♫ "
  export E_MICROPHONE="🎤︎︎"
  export E_SUN="☀︎ "
  export E_MOON="⏾"
  export E_BOLT="⚡︎" 
  export E_EURO="€"
  export E_DOLLAR="$"
  export E_YEN="¥" 
  export E_YUAN="Y̶"
  # ASCII Arts TODO: find collection & fetch automatically
  export A_CROSSES=". ݁₊ ⊹ . ݁ ⟡ ݁ . ⊹ ₊ ݁."
  export A_STARS="─── ⋆⋅☆⋅⋆ ───"
  export A_STAR_BANG="˗ˏˋ ★ ˎˊ˗"
  export A_SNIPER="▄︻デ══━一" 
  export A_BORDER_SINGLE="────────────────"
  export A_BORDER_DOUBLE="════════════════"
  export A_BORDER_CHAINS="⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘⫘"
  export A_BORDER_STARS="── ⋆⋅☆⋅⋆ ──"
  export A_BORDER1="✦•┈๑⋅⋯ ⋯⋅๑┈•✦" 
  export A_BORDER3=""
  export A_BORDER4=""
}

# -- SCRIPT MODES -- #
function set_modes() {
  # Exit on error & pipe failures
  set -eo pipefail
  # Prompt whether script should run in debug-mode when $TOGGLE_SCRIPT_DEBUG_MODE env var is not set.
  if [[ -z $TOGGLE_SCRIPT_DEBUG_MODE ]]; then
    read -p "$(echo -e "${I_ASK_YN}Run Script in Debug Mode? ")" -r answer
      case "$answer" in
        [Yy]) TOGGLE_SCRIPT_DEBUG_MODE=1;;
        *)    TOGGLE_SCRIPT_DEBUG_MODE=0;;
    esac
    if [[ $TOGGLE_SCRIPT_DEBUG_MODE -eq 1 ]]; then
      set -x && echo -e "${I_OK}Running Script in Debug Mode"
    fi
  fi
}

# -- DETECT OPERATING SYSTEM -- #
function detect_os() {
  case "$(uname -s)" in
    Linux*)  echo "linux";;
    Darwin*) echo "macos";;
    *)       echo "unknown";;
  esac
}

# -- DETECT SCRIPT CWD -- #
function get_script_pwd() {
  SOURCE="${BASH_SOURCE[0]}"
  while [ -L "$SOURCE" ]; do
    DIR="$(cd -P -- "$(dirname -- "$SOURCE")" >/dev/null 2>&1 && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
  done
  # this directory
  THIS_DIR="$(cd -P -- "$(dirname -- "$SOURCE")" >/dev/null 2>&1 && pwd)" && export THIS_DIR="$THIS_DIR"
  # parent directory of this directory
  PARENT_DIR="$(dirname "$THIS_DIR")" && export PARENT_DIR="$PARENT_DIR"
  # repository root (only works inside of a git repository)
  REPO_ROOT="$(git rev-parse --show-toplevel)" && export REPO_ROOT="$REPO_ROOT"
}

# -- LOAD ENV FILES -- #
function load_env_file() {
  # Accepts a directory as parameter & loads variables from all .env files inside of it.
  # usage: load_env_file "/directory/with/env_files"
  local env_dir="$1"
  if [ -f "$env_dir/.env" ]; then
    set -a
    source "$env_dir/.env"
    set +a
  else
    echo "No .env file found in $env_dir" >&2
  fi
}


