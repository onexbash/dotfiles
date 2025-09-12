function print_path() {
  local I_PATH="${FG_BLACK}[${FG_GREEN} $E_CROSS ${FG_BLACK}] ${FG_RESET}"
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

# Display File Permissions
function chinfo() {
  local target_path && target_path="$1"
  
  # Define OS-specific functions
  linux() {
    local stat_output
    stat_output=$(stat -c '%a %U %G %n' "$target_path" 2>/dev/null)
    if [ $? -eq 0 ]; then
      local perms user group filename
      read -r perms user group filename <<< "$stat_output"
      
      echo -e "${FG_PURPLE}Filename:${FG_RESET}${FG_WHITE} $filename${FG_RESET}"
      echo -e "${FG_PURPLE}Permissions:${FG_RESET}${FG_WHITE} $perms${FG_RESET}"
      echo -e "${FG_PURPLE}Owner (user):${FG_RESET}${FG_WHITE} $user${FG_RESET}"
      echo -e "${FG_PURPLE}Owner (group):${FG_RESET}${FG_WHITE} $group${FG_RESET}"
      echo -e "${FG_PURPLE}Readable for $USER?:${FG_RESET}${FG_WHITE} $([ -r "$target_path" ] && echo "Yes" || echo "No")${FG_RESET}"
      echo -e "${FG_PURPLE}Writable for $USER?:${FG_RESET}${FG_WHITE} $([ -w "$target_path" ] && echo "Yes" || echo "No")${FG_RESET}"
      echo -e "${FG_PURPLE}Executable for $USER?:${FG_RESET}${FG_WHITE} $([ -x "$target_path" ] && echo "Yes" || echo "No")${FG_RESET}"
    else
      echo -e "${I_ERR}Failed to get file information"
    fi
  }
  
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
      echo -e "${FG_PURPLE}[FILENAME]${FG_RESET}${FG_WHITE} $filename${FG_RESET}"
      echo -e "${FG_PURPLE}[PERMISSIONS]${FG_RESET}${FG_WHITE} $perms${FG_RESET}"
      echo -e "${FG_PURPLE}[USER]${FG_RESET}${FG_WHITE} $user${FG_RESET}"
      echo -e "${FG_PURPLE}[GROUP]${FG_RESET}${FG_WHITE} $group${FG_RESET}"
      echo -e "${FG_PURPLE}[r]${FG_WHITE} by ${USER}: $([ -r "$target_path" ] && echo "${FG_GRAY}[${FG_GREEN}YES${FG_GRAY}" || echo "${FG_RED}NO")${FG_RESET}"
      echo -e "${FG_PURPLE}[w]${FG_WHITE} by ${USER}: $([ -w "$target_path" ] && echo "${FG_GRAY}[${FG_GREEN}YES${FG_GRAY}" || echo "${FG_RED}NO")${FG_RESET}"
      echo -e "${FG_PURPLE}[x]${FG_WHITE} by ${USER}: $([ -x "$target_path" ] && echo "${FG_GRAY}[${FG_GREEN}YES${FG_GRAY}" || echo "${FG_RED}NO")${FG_RESET}"
      return
    fi
  }
  
  unknown() {
    echo -e "${I_ERR}Unsupported Platform Detected: ${FG_RED}unknown${FG_RESET}"
    return 1
  }
  
 
  # Check if file/directory exists first
  if [ ! -e "$target_path" ]; then
    echo -e "${I_ERR}Path does not exist: ${FG_RED}$target_path${FG_RESET}"
    return 1
  fi
  
  # Execute above's function block for the detected platform
  detect_os && echo "$OS"
  
}

function get_bundle_id() {
  detect_os && echo "$OS"
}

