#!/usr/bin/env zsh

# Github Banner Generator
function bannergen() {
  THIS_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
  
  "$THIS_DIR/scripts/github_banner_generator.sh" || echo -e "${I_ERR} File doesn't exist: $THIS_DIR/scripts/github_banner_generator.sh"
}

# Print System Information
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
