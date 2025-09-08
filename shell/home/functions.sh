#!/usr/bin/env zsh

# Github Banner Generator
function bannergen() {
  THIS_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
  
  "$THIS_DIR/scripts/github_banner_generator.sh" || echo -e "${I_ERR} File doesn't exist: $THIS_DIR/scripts/github_banner_generator.sh"
}

# Display File Permissions
function chinfo() {
  local target_path="$(pwd)/$1"
  
  # Define OS-specific functions
  linux() {
    local stat_output
    stat_output=$(stat -c '%a %U %G %n' "$target_path" 2>/dev/null)
    if [ $? -eq 0 ]; then
      local perms user group filename
      read -r perms user group filename <<< "$stat_output"
      
      echo -e "${C_PURPLE}Filename:${C_RESET}${C_WHITE} $filename${C_RESET}"
      echo -e "${C_PURPLE}Permissions:${C_RESET}${C_WHITE} $perms${C_RESET}"
      echo -e "${C_PURPLE}Owner (user):${C_RESET}${C_WHITE} $user${C_RESET}"
      echo -e "${C_PURPLE}Owner (group):${C_RESET}${C_WHITE} $group${C_RESET}"
      echo -e "${C_PURPLE}Readable for $USER?:${C_RESET}${C_WHITE} $([ -r "$target_path" ] && echo "Yes" || echo "No")${C_RESET}"
      echo -e "${C_PURPLE}Writable for $USER?:${C_RESET}${C_WHITE} $([ -w "$target_path" ] && echo "Yes" || echo "No")${C_RESET}"
      echo -e "${C_PURPLE}Executable for $USER?:${C_RESET}${C_WHITE} $([ -x "$target_path" ] && echo "Yes" || echo "No")${C_RESET}"
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
      echo -e "${C_PURPLE}[FILENAME]${C_RESET}${C_WHITE} $filename${C_RESET}"
      echo -e "${C_PURPLE}[PERMISSIONS]${C_RESET}${C_WHITE} $perms${C_RESET}"
      echo -e "${C_PURPLE}[USER]${C_RESET}${C_WHITE} $user${C_RESET}"
      echo -e "${C_PURPLE}[GROUP]${C_RESET}${C_WHITE} $group${C_RESET}"
      echo -e "${C_PURPLE}[r]${C_WHITE} by ${USER}: $([ -r "$target_path" ] && echo "${C_GRAY}[${C_GREEN}YES${C_GRAY}" || echo "${C_RED}NO")${C_RESET}"
      echo -e "${C_PURPLE}[w]${C_WHITE} by ${USER}: $([ -w "$target_path" ] && echo "${C_GRAY}[${C_GREEN}YES${C_GRAY}" || echo "${C_RED}NO")${C_RESET}"
      echo -e "${C_PURPLE}[x]${C_WHITE} by ${USER}: $([ -x "$target_path" ] && echo "${C_GRAY}[${C_GREEN}YES${C_GRAY}" || echo "${C_RED}NO")${C_RESET}"
      return
    fi
  }
  
  unknown() {
    echo -e "${I_ERR}Unsupported Platform Detected: ${C_RED}unknown${C_RESET}"
    return 1
  }
  
  # Execute above's function block for the detected platform
  local platform=$(detect_os)
  
  # Check if file/directory exists first
  if [ ! -e "$target_path" ]; then
    echo -e "${I_ERR}Path does not exist: ${C_RED}$target_path${C_RESET}"
    return 1
  fi
  
  $platform
}

# Display System Information
function sysinfo() {
  HOSTNAME="$(hostname -s)"
  OS="$(sw_vers -productName)"
  OS_VERSION="$(sw_vers -productVersion)"
  IFACE="$(route -n get default 2>/dev/null | awk '/interface:/{print $2; exit}')"
  
  IPV4=""
  if [[ -n "${IFACE}" ]]; then
    if ipconfig getifaddr "$IFACE" >/dev/null 2>&1; then
      IPV4="$(ipconfig getifaddr "$IFACE")"
    else
      IPV4="$(ifconfig "$IFACE" 2>/dev/null | awk '$1=="inet"{print $2; exit}')"
    fi
  fi
  echo -e "${I_INFO}HOSTNAME: $HOSTNAME"
  echo -e "${I_INFO}OS: $OS"
  echo -e "${I_INFO}OS Version: $OS_VERSION"
  echo -e "${I_INFO}Network Interface: ${IFACE:-unknown}${IPV4:+ ($IPV4)}"
}

# Print formatted output of the `$PATH` variable
function print_path() {
  local I_PATH="${C_BLACK}[${C_GREEN} $E_CROSS ${C_BLACK}] ${C_RESET}"
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
