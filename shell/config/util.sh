# --                            -- #
# --     UTILITY SHELL-FILE     -- #
# --    SOURCED BY ZSH & BASH   -- #
# --                            -- #

# Main Function for calling Functions that should always be called
function init_utils() {
  tty_styles
}

# -- TTY STYLES -- #
tty_styles() {
  # Colors only when stdout and stderr are terminals and NO_COLOR is not set
  if [[ -t 1 && -t 2 && -z ${NO_COLOR-} ]]; then
    C_RED=$'\033[1;31m' C_GREEN=$'\033[1;32m' C_YELLOW=$'\033[1;33m'
    C_BLUE=$'\033[1;34m' C_PURPLE=$'\033[1;35m' C_CYAN=$'\033[1;36m'
    C_WHITE=$'\033[1;37m' C_GRAY=$'\033[0;90m' C_RESET=$'\033[0m'
  else
    C_RED="" C_GREEN="" C_YELLOW="" C_BLUE="" C_PURPLE="" C_CYAN="" C_WHITE="" C_GRAY="" C_RESET=""
  fi
  # Styled Output Variables
  I_MSG="${C_PURPLE}" # Output Variable without Prefix for Standard Messages
  I_SKIP="${C_GRAY}[${C_CYAN} SKIP ${C_GRAY}]${C_RESET} "
  I_WARN="${C_GRAY}[${C_YELLOW} WARN ${C_GRAY}]${C_RESET} "
  I_OK="${C_GRAY}[${C_GREEN} OK ${C_GRAY}]${C_RESET} "
  I_INFO="${C_GRAY}[${C_PURPLE} INFO ${C_GRAY}]${C_RESET} "
  I_ERR="${C_GRAY}[${C_RED} ERROR ${C_GRAY}]${C_RESET} "
  # Styled Input Variables
  I_INPUT="${C_GRAY}[${C_BLUE}  ${C_GRAY}]${C_RESET} "
  I_ASK="${C_GRAY}[${C_BLUE} ? ${C_GRAY}]${C_RESET} "
  I_YN="${C_GRAY}[${C_BLUE} y/n ${C_GRAY}]${C_RESET} "
}

# Shared Log Wrapper for Log Functions below
_log() {
  local style=$1
  shift
  printf '%s%s%s\n' "$style" "$*" "$C_RESET"
}

# Shared Input Wrapper for Prompts with user-input below
# _input [-s] <style> <var_name> <message...>   (-s: hidden input, e.g. for secrets)
_input() {
  local __input_silent=""
  if [[ ${1-} == -s ]]; then
    __input_silent=1
    shift
  fi
  local __input_style=$1 __input_var=$2 __input_rc=0
  shift 2
  printf '%s%s%s ' "$__input_style" "$*" "$C_RESET" >&2
  # Store User Input in the Variable named by the caller
  if [[ -n $__input_silent ]]; then
    IFS= read -rs "${__input_var:?_input: missing variable name}" || __input_rc=$?
    printf '\n' >&2 # hidden input: the Enter key is not echoed
  else
    IFS= read -r "${__input_var:?_input: missing variable name}" || __input_rc=$?
  fi
  return "$__input_rc"
}

# Log Functions (Output)
log_() { _log "$I_MSG" "$@"; }
log_ok() { _log "$I_OK" "$@"; }
log_info() { _log "$I_INFO" "$@"; }
log_skip() { _log "$I_SKIP" "$@"; }
log_warn() { _log "$I_WARN" "$@" >&2; }
log_err() { _log "$I_ERR" "$@" >&2; }
# Log Functions (Input)
# Usage: input_ask var_name "Please enter X:"
input_() { _input "$I_INPUT" "$@"; }
input_ask() { _input "$I_ASK" "$@"; }
input_yn() { _input "$I_YN" "$@"; }
input_secret() { _input -s "$I_ASK" "$@"; }

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
    log_ok "Running Script in Debug Mode"
  fi
}

# [UTIL] Read .env File
function read_env() {
  local file=${1/#\~/$HOME} line key value

  [[ -r $file ]] || {
    log_err "read_env: cannot read '$file'"
    return 1
  }

  while IFS= read -r line || [[ -n $line ]]; do
    [[ $line =~ ^[[:space:]]*(#|$) ]] && continue # skip comments & blank lines
    key=${line%%=*}
    value=${line#*=}
    value=${value#[\"\']} # strip surrounding quotes
    value=${value%[\"\']}
    export "$key=$value"
  done <"$file"
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
  printf '\n' >&2 # the printed text may not end with a newline
  log_warn "No clipboard tool found on ${C_YELLOW}${os}${C_RESET} — printed above instead."
  return 1
}

# [UTIL] Open a URL in the Default Browser
function _open_url() {
  if [[ "$OSTYPE" == darwin* ]]; then
    open "$1"
  else
    xdg-open "$1"
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
    log_err "Unsupported package manager."
    return 1
  fi
}

# Call main Function with Args
init_utils "$@"
