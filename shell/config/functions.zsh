# --         functions.zsh         -- #
# --       sourced by: .zshrc      -- #
# --                               -- #

# Print $PATH variable
function print_path() {
  local I_PATH="${FG_BLACK}[${FG_GREEN} 󰗽 ${FG_BLACK}] ${S_RESET}"
  local tmp_path="$PATH"
  while [[ -n "$tmp_path" ]]; do
      # extract the first path entry
      local entry="${tmp_path%%:*}"
      echo -e "${I_PATH}$entry"
      # Remove the processed entry from tmp_path
      if [[ "$tmp_path" == *:* ]]; then
          tmp_path="${tmp_path#*:}"
      else
          tmp_path=""
      fi
  done
}

# Stay awake to prevent "Away" status
awake() {
  local hours="${1:-8}"
  pkill caffeinate 2>/dev/null
  nohup caffeinate -d -i -t $((hours * 3600)) >/dev/null 2>&1 & disown
  echo "Awake for ${hours}h"
}

# Let the Mac sleep again
sleepy() {
  pkill caffeinate && echo "Sleep allowed"
}

# Display File Permissions
function chinfo() {
  local target_path && target_path="$1"
  local os && os="$(detect_os)"
  
  # Define OS-specific functions
  # shellcheck disable=SC2329 
  linux() {
    local stat_output
    stat_output=$(stat -c '%a %U %G %n' "$target_path" 2>/dev/null)
    if [ $? -eq 0 ]; then
      local perms user group filename
      read -r perms user group filename <<< "$stat_output" 
      echo -e "${FG_MAGENTA}[FILENAME]${S_RESET}${FG_WHITE} $filename${S_RESET}"
      echo -e "${FG_MAGENTA}[PERMISSIONS]${S_RESET}${FG_WHITE} $perms${S_RESET}"
      echo -e "${FG_MAGENTA}[USER]${S_RESET}${FG_WHITE} $user${S_RESET}"
      echo -e "${FG_MAGENTA}[GROUP]${S_RESET}${FG_WHITE} $group${S_RESET}"
      echo -e "${FG_MAGENTA}[r]${FG_WHITE} by ${USER}: $([ -r "$target_path" ] && echo "${FG_GRAY}[${FG_GREEN}YES${FG_GRAY}" || echo "${FG_RED}NO")${S_RESET}"
      echo -e "${FG_MAGENTA}[w]${FG_WHITE} by ${USER}: $([ -w "$target_path" ] && echo "${FG_GRAY}[${FG_GREEN}YES${FG_GRAY}" || echo "${FG_RED}NO")${S_RESET}"
      echo -e "${FG_MAGENTA}[x]${FG_WHITE} by ${USER}: $([ -x "$target_path" ] && echo "${FG_GRAY}[${FG_GREEN}YES${FG_GRAY}" || echo "${FG_RED}NO")${S_RESET}"
    else
      echo -e "${I_ERR}Failed to get file information"
    fi
  }
  # shellcheck disable=SC2329 
  macos() {
    # get stat command output
    local stat_output
    if [[ "$(which stat)" == *"homebrew"* ]]; then
      # GNU coreutils `stat`
      stat_output=$(stat -c '%a %U %G %n' "$target_path" 2>/dev/null)
    else
      # MacOS built-in `stat`
      stat_output=$(stat -f '%A %u:%g %N' "$target_path" 2>/dev/null)
    fi
    if [ $? -eq 0 ]; then
      local perms user group filename
      read -r perms user group filename <<< "$stat_output"
      echo -e "${FG_MAGENTA}[FILENAME]${S_RESET}${FG_WHITE} $filename${S_RESET}"
      echo -e "${FG_MAGENTA}[PERMISSIONS]${S_RESET}${FG_WHITE} $perms${S_RESET}"
      echo -e "${FG_MAGENTA}[USER]${S_RESET}${FG_WHITE} $user${S_RESET}"
      echo -e "${FG_MAGENTA}[GROUP]${S_RESET}${FG_WHITE} $group${S_RESET}"
      echo -e "${FG_MAGENTA}[r]${FG_WHITE} by ${USER}: $([ -r "$target_path" ] && echo "${FG_GRAY}[${FG_GREEN}YES${FG_GRAY}]" || echo "[${FG_RED}NO${FG_GRAY}]")"
      echo -e "${FG_MAGENTA}[w]${FG_WHITE} by ${USER}: $([ -w "$target_path" ] && echo "${FG_GRAY}[${FG_GREEN}YES${FG_GRAY}]" || echo "[${FG_RED}NO${FG_GRAY}]")"
      echo -e "${FG_MAGENTA}[x]${FG_WHITE} by ${USER}: $([ -x "$target_path" ] && echo "${FG_GRAY}[${FG_GREEN}YES${FG_GRAY}]" || echo "[${FG_RED}NO${FG_GRAY}]")"
      return
    fi
  }
  # shellcheck disable=SC2329 
  unknown() {
    echo -e "${I_ERR}Unsupported Platform Detected: ${FG_RED}${os}${S_RESET}"
    return 1
  }
   
  # Check if file/directory exists first
  if [ ! -e "$target_path" ]; then
    echo -e "${I_ERR}Path does not exist: ${FG_RED}$target_path${S_RESET}"
    return 1
  fi
  # Call one of macos/linux/unknown function blocks above based on detect_os (util.sh)
  case "$os" in
    osx)   macos ;;
    linux) linux ;;
    *)     unknown ;;
  esac
}

# Script picker: pick a script from $XSCRIPTS
pick_script() {
  local dir="$XSCRIPTS" script
  script="$(cd "$dir" && find -L . -type f \( -name '*.sh' -o -name '*.bash' -o -name '*.zsh' -o -name '*.ps1' \) \
    | sed 's|^\./||' | sort \
    | gum filter --placeholder "Pick a script…" --header "  Scripts" \
        --header.foreground "#cba6f7" --indicator.foreground "#cba6f7" --match.foreground "#cba6f7")" || return

  case "$script" in
    *.zsh) zsh "$dir/$script" "$@" ;;
    *.ps1) pwsh -NoProfile -File "$dir/$script" "$@" ;;
    *)     bash "$dir/$script" "$@" ;;
  esac
}
