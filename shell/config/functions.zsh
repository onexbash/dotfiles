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
  local target_path="${1:-.}"
  local os stat_output perms user group filename flag
  os="$(detect_os)"

  # Check if file/directory exists first
  if [ ! -e "$target_path" ]; then
    echo -e "${I_ERR}Path does not exist: ${FG_RED}${target_path}${S_RESET}"
    return 1
  fi

  # Get "<octal perms> <user> <group> <name>" depending on the OS (detect_os from util.sh)
  case "$os" in
    linux | windows)   # GNU coreutils stat (also used by Git Bash / MSYS / Cygwin)
      stat_output=$(stat -c '%a %U %G %n' -- "$target_path" 2>/dev/null)
      ;;
    osx)
      if stat --version >/dev/null 2>&1; then
        # GNU coreutils stat first in PATH (e.g. Homebrew gnubin)
        stat_output=$(stat -c '%a %U %G %n' -- "$target_path" 2>/dev/null)
      else
        # macOS built-in BSD stat
        stat_output=$(stat -f '%Lp %Su %Sg %N' -- "$target_path" 2>/dev/null)
      fi
      ;;
    *)
      echo -e "${I_ERR}Unsupported Platform Detected: ${FG_RED}${os}${S_RESET}"
      return 1
      ;;
  esac

  if [ -z "$stat_output" ]; then
    echo -e "${I_ERR}Failed to get file information"
    return 1
  fi

  # Shared output for all platforms
  read -r perms user group filename <<< "$stat_output"
  echo -e "${FG_MAGENTA}[FILENAME]${S_RESET}${FG_WHITE} ${filename}${S_RESET}"
  echo -e "${FG_MAGENTA}[PERMISSIONS]${S_RESET}${FG_WHITE} ${perms}${S_RESET}"
  echo -e "${FG_MAGENTA}[USER]${S_RESET}${FG_WHITE} ${user}${S_RESET}"
  echo -e "${FG_MAGENTA}[GROUP]${S_RESET}${FG_WHITE} ${group}${S_RESET}"

  for flag in r w x; do
    if [ -"$flag" "$target_path" ]; then
      echo -e "${FG_MAGENTA}[${flag}]${FG_WHITE} by ${USER}: ${FG_GRAY}[${FG_GREEN}YES${FG_GRAY}]${S_RESET}"
    else
      echo -e "${FG_MAGENTA}[${flag}]${FG_WHITE} by ${USER}: ${FG_GRAY}[${FG_RED}NO${FG_GRAY}]${S_RESET}"
    fi
  done
}

# Custom Command [ssh-keygen]: Generate SSH-Keys
x_ssh_keygen() {
  local type="" file="" comment="" dir pat answer opt fp
  local have_f=0 have_C=0
  local OPTIND=1 OPTARG
  local PS3="Key type (number): "

  # 0. Parse -t/-f/-C; anything else → real ssh-keygen, untouched
  while getopts ":t:f:C:" opt; do
    case "$opt" in
      t) type=$OPTARG ;;
      f) file=$OPTARG; have_f=1 ;;
      C) comment=$OPTARG; have_C=1 ;;
      *) command ssh-keygen "$@"; return ;;
    esac
  done
  if [ "$OPTIND" -le "$#" ]; then   # leftover non-option arguments
    command ssh-keygen "$@"; return
  fi

  # 1. Key type
  if [ -z "$type" ]; then
    echo "Select key type:"
    select type in ecdsa ecdsa-sk ed25519 ed25519-sk mldsa44-ed25519 rsa; do
      [ -n "$type" ] && break
      echo "Invalid selection." >&2
    done
    [ -n "$type" ] || return 1   # aborted with Ctrl-D
  fi

  # Check whether the local OpenSSH supports the selected type
  case "$type" in
    ecdsa)           pat='^ecdsa-sha2-nistp' ;;
    ecdsa-sk)        pat='^sk-ecdsa-sha2-nistp256@openssh\.com$' ;;
    ed25519)         pat='^ssh-ed25519$' ;;
    ed25519-sk)      pat='^sk-ssh-ed25519@openssh\.com$' ;;
    rsa)             pat='^ssh-rsa$' ;;
  esac
  if ! ssh -Q key 2>/dev/null | grep -qE "$pat"; then
    printf 'Warning: "%s" is not listed by "ssh -Q key" on this system.\n' "$type" >&2
    printf 'Continue anyway? [y/N] '
    read -r answer || return 1
    case "$answer" in [yY]*) ;; *) return 1 ;; esac
  fi

  # 2. Filename (plain names go to ~/.ssh)
  while :; do
    if [ -z "$file" ]; then
      printf 'Filename (saved in ~/.ssh unless a path is given): '
      read -r file || return 1
      [ -n "$file" ] || { echo "Filename must not be empty." >&2; continue; }
    fi
    case "$file" in
      "~/"*) file="$HOME/${file#\~/}" ;;
      */*)   ;;
      *)     file="$HOME/.ssh/$file" ;;
    esac
    if [ -e "$file" ] || [ -e "$file.pub" ]; then
      printf '"%s" already exists – choose another name.\n' "$file" >&2
      [ "$have_f" -eq 1 ] && return 1   # passed via -f: abort instead of prompting
      file=""
      continue
    fi
    break
  done
  dir=$(dirname -- "$file")
  [ -d "$dir" ] || mkdir -p -m 700 "$dir" || return 1

  # 3. Comment
  if [ "$have_C" -eq 0 ]; then
    while :; do
      printf 'Comment: '
      read -r comment || return 1
      [ -n "$comment" ] && break
      echo "Comment must not be empty." >&2
    done
  fi

  # 4. Build options
  set -- -t "$type" -a 96 -f "$file" -C "$comment"
  case "$type" in
    rsa)   set -- "$@" -b 4096 ;;
    ecdsa) set -- "$@" -b 521 ;;
    *-sk)
      set -- "$@" -O verify-required
      printf 'Store key on the security key (resident, recoverable via ssh-keygen -K)? [y/N] '
      read -r answer || return 1
      case "$answer" in [yY]*) set -- "$@" -O resident ;; esac
      ;;
  esac

  printf '\nRunning: ssh-keygen'
  printf ' %s' "$@"
  printf '\n\n'
  command ssh-keygen "$@" || return   # stop here if key generation failed

  # 5. Copy fingerprint (SHA256) to clipboard
  fp=$(command ssh-keygen -l -E sha256 -f "$file.pub" 2>/dev/null | awk '{print $2}')
  if [ -z "$fp" ]; then
    printf 'Warning: could not read fingerprint of "%s.pub".\n' "$file" >&2
  elif command -v copy_to_clipboard >/dev/null 2>&1; then
    # copy_to_clipboard reads stdin; on failure it prints the text and a warning itself
    if printf '%s' "$fp" | copy_to_clipboard; then
      printf '\nFingerprint copied to clipboard: %s\n' "$fp"
    fi
  else
    printf '\nFingerprint: %s (copy_to_clipboard not defined)\n' "$fp"
  fi
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


# Custom Command [get_bundle_id]: Get the BundleID of an App
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

# Azure CLI
function azlogin() {
  # -- TENANTS: "Display name|tenant-id" -- #
  local -a tenants
  tenants=(
    "Cratos[prod]|63f98c75-61b7-4c1c-b937-da7324147db9"
    "DZ Bank|fcf9c1f5-c9d7-456c-922a-e8d2be15a058"
    "EON Data|03e6c03e-074e-474c-8d40-3eac96d82a77"
  )

  if ! command -v az >/dev/null 2>&1; then
    printf '%s\n' "${I_ERR}Azure CLI (az) not found in PATH." >&2
    return 1
  fi

  if (( ${#tenants[@]} == 0 )); then
    printf '%s\n' "${I_ERR}No tenants defined in azlogin()." >&2
    return 1
  fi

  # -- ARGUMENTS -- #
  # az login has no --subscription option, so it is extracted here and
  # applied with `az account set` after the login. Everything else is passed through.
  local subscription=""
  local -a az_args
  az_args=()
  while (( $# > 0 )); do
    case "$1" in
      --subscription)
        if [[ -z "${2:-}" ]]; then
          printf '%s\n' "${I_ERR}--subscription requires a value." >&2
          return 1
        fi
        subscription="$2"
        shift 2
        ;;
      --subscription=*)
        subscription="${1#*=}"
        shift
        ;;
      *)
        az_args+=("$1")
        shift
        ;;
    esac
  done

  # -- MENU -- #
  # Iterate instead of indexing: bash arrays start at 0, zsh arrays at 1
  local entry name id choice rc i=0
  printf '%s\n' "${I_INFO}Select a tenant:"
  for entry in "${tenants[@]}"; do
    i=$((i + 1))
    printf '  %s%2d)%s %s %s(%s)%s\n' \
      "$C_CYAN" "$i" "$C_RESET" "${entry%%|*}" "$C_GRAY" "${entry#*|}" "$C_RESET"
  done

  printf '%s' "${I_ASK}Tenant [1-${#tenants[@]}, q to cancel]: "
  read -r choice

  if [[ -z "$choice" || "$choice" == [qQ] ]]; then
    printf '%s\n' "${I_SKIP}Login cancelled."
    return 0
  fi

  # Regex without leading zeros avoids octal interpretation in bash arithmetic
  if ! [[ "$choice" =~ ^[1-9][0-9]*$ ]] || (( choice > ${#tenants[@]} )); then
    printf '%s\n' "${I_ERR}Invalid selection: ${choice}" >&2
    return 1
  fi

  i=0
  for entry in "${tenants[@]}"; do
    i=$((i + 1))
    if (( i == choice )); then
      name="${entry%%|*}"
      id="${entry#*|}"
      break
    fi
  done

  # -- LOGIN -- #
  printf '%s\n' "${I_LOAD}Logging in to ${C_WHITE}${name}${C_RESET} ${C_GRAY}(${id})${C_RESET}"
  # AZURE_CORE_LOGIN_EXPERIENCE_V2=off skips the interactive subscription picker
  # (overrides core.login_experience_v2 for this call only)
  AZURE_CORE_LOGIN_EXPERIENCE_V2=off \
    az login --tenant "$id" --allow-no-subscriptions --output none "${az_args[@]}"
  rc=$?

  if (( rc != 0 )); then
    printf '%s\n' "${I_ERR}az login failed (exit code ${rc})." >&2
    return "$rc"
  fi
  printf '%s\n' "${I_OK}Logged in to ${name}."

  # -- SUBSCRIPTION -- #
  if [[ -n "$subscription" ]]; then
    if ! az account set --subscription "$subscription"; then
      printf '%s\n' "${I_ERR}Could not select subscription: ${subscription}" >&2
      return 1
    fi
  fi

  local current
  current="$(az account show --query "name" --output tsv 2>/dev/null)"
  printf '%s\n' "${I_INFO}Active subscription: ${C_WHITE}${current:-unknown}${C_RESET}"
  return 0
}


