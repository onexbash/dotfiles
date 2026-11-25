# --         functions.zsh         -- #
# --       sourced by: .zshrc      -- #
# --                               -- #

# Print $PATH variable
function print_path() {
  local I_PATH="${C_GRAY}[${C_GREEN} 󰗽 ${C_GRAY}]${C_RESET} "
  local tmp_path="$PATH"
  while [[ -n "$tmp_path" ]]; do
      # extract the first path entry
      local entry="${tmp_path%%:*}"
      _log "$I_PATH" "$entry"
      # Remove the processed entry from tmp_path
      if [[ "$tmp_path" == *:* ]]; then
          tmp_path="${tmp_path#*:}"
      else
          tmp_path=""
      fi
  done
}

# Reload Shell Session
function reload_shell() {
  if [ -n "${ZSH_VERSION-}" ]; then
    ((${#jobstates})) && { log_err "reload_shell: end background jobs first."; return 1; }
    fc -AI 2>/dev/null # save this session's history
    exec zsh -l
  elif [ -n "${BASH_VERSION-}" ]; then
    [ -n "$(jobs -p)" ] && { log_err "reload_shell: end background jobs first."; return 1; }
    history -a # save this session's history
    exec "$BASH" -l
  fi
  log_err "reload_shell: only zsh and bash are supported."
  return 1
}


# -- SECRETS -- #
# Watch the Proton Pass Auth URL opened in Browser
_pass_login_watch() {
  local line url opened=0
  while IFS= read -r line || [[ -n $line ]]; do
    printf '%s\n' "$line" # pass pass-cli's own output through unchanged
    if ((!opened)) && [[ ${PASS_OPEN_BROWSER:-1} == 1 && $line == *https://account.proton.me/* ]]; then
      url="https://account.proton.me/${line#*https://account.proton.me/}"
      url=${url%%[[:space:]]*}
      _open_url "$url" >/dev/null 2>&1 && opened=1 && log_info "Opened the login page in your default browser."
    fi
  done
}

# Ensure Proton Pass CLI is authenticated
pass_auth() {
  [[ -n ${I_OK-} ]] || tty_styles
  if ! command -v pass-cli >/dev/null 2>&1; then
    log_err "pass-cli not found in PATH. Install it from https://proton.me/pass/download"
    return 127
  fi
  # `pass-cli info` exits non-zero when there is no valid session
  if pass-cli info >/dev/null 2>&1; then
    log_ok "Proton Pass CLI is authenticated."
    return 0
  fi
  log_warn "Proton Pass CLI is not authenticated."
  log_info "Running: pass-cli login${*:+ $*}"
  # Process substitution keeps pass-cli's exit status (works in bash and zsh)
  if ! pass-cli login "$@" > >(_pass_login_watch) 2>&1; then
    log_err "pass-cli login failed."
    return 1
  fi
  # Verify the new session actually works
  if pass-cli info >/dev/null 2>&1; then
    log_ok "Logged in to Proton Pass."
  else
    log_err "Login finished, but the session could not be verified (pass-cli info still fails)."
    return 1
  fi
}

# Read Secrets from Proton Pass & Export as Environment Variables (defined in secrets.env)
pass_env() {
  local file="$HOME/.config/shell/secrets.env" key ref value failed=0

  pass_auth || return
  read_env "$file" || return

  # Variable names defined in the file (one per line)
  while IFS= read -r key; do
    ref=$(printenv "$key")
    [[ $ref == pass://* ]] || continue # only resolve Proton Pass references

    if value=$(pass-cli item view "$ref") && [[ -n $value ]]; then
      export "$key=$value"
    else
      unset "$key" # don't leave the reference behind as the "secret"
      log_err "Could not read $key from Proton Pass ($ref)"
      failed=1
    fi
  done < <(sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\)=.*/\1/p' "$file")

  ((failed)) && return 1
  log_ok "Secrets exported."
}
# Import SSH Keys from Proton Pass to the ssh-agent
pass_ssh() {
  local vault=${1:-"Development"}

  pass_auth || return

  # ssh-add -l exits with 2 if no agent is reachable (0 = has keys, 1 = no keys)
  ssh-add -l >/dev/null 2>&1
  if (($? == 2)); then
    log_err "Cannot connect to the ssh-agent (SSH_AUTH_SOCK='${SSH_AUTH_SOCK-}')."
    return 1
  fi

  pass-cli ssh-agent load --vault-name "$vault" || {
    log_err "Loading SSH keys from vault '$vault' failed."
    return 1
  }
}


# -- INACTIVITY -- #
# Stay awake to prevent "Away" status
xawake() {
  local hours="${1:-8}"
  pkill caffeinate 2>/dev/null
  nohup caffeinate -d -i -t $((hours * 3600)) >/dev/null 2>&1 & disown
  log_info "Awake for ${hours}h"
}

# Let the Mac sleep again
xsleep() {
  pkill caffeinate && log_info "Sleep allowed"
}

# Prevent inactivity via mouse-input
xactive() { 
  while true
  do
    cliclick m:+20,+20 m:-20,-20
    sleep 5
  done
}

# -- PERMISSIONS -- #
# Display File Permissions
function chinfo() {
  local target_path="${1:-.}"
  local os stat_output perms user group filename flag
  os="$(detect_os)"

  # Check if file/directory exists first
  if [ ! -e "$target_path" ]; then
    log_err "Path does not exist: ${C_RED}${target_path}${C_RESET}"
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
      log_err "Unsupported Platform Detected: ${C_RED}${os}${C_RESET}"
      return 1
      ;;
  esac

  if [ -z "$stat_output" ]; then
    log_err "Failed to get file information"
    return 1
  fi

  # Shared output for all platforms
  read -r perms user group filename <<< "$stat_output"
  log_info "${C_PURPLE}[FILENAME]${C_RESET}${C_WHITE} ${filename}${C_RESET}"
  log_info "${C_PURPLE}[PERMISSIONS]${C_RESET}${C_WHITE} ${perms}${C_RESET}"
  log_info "${C_PURPLE}[USER]${C_RESET}${C_WHITE} ${user}${C_RESET}"
  log_info "${C_PURPLE}[GROUP]${C_RESET}${C_WHITE} ${group}${C_RESET}"

  for flag in r w x; do
    if [ -"$flag" "$target_path" ]; then
      log_info "${C_PURPLE}[${flag}]${C_WHITE} by ${USER}: ${C_GRAY}[${C_GREEN}YES${C_GRAY}]${C_RESET}"
    else
      log_info "${C_PURPLE}[${flag}]${C_WHITE} by ${USER}: ${C_GRAY}[${C_RED}NO${C_GRAY}]${C_RESET}"
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
    log_info "Select key type:"
    select type in ecdsa ecdsa-sk ed25519 ed25519-sk mldsa44-ed25519 rsa; do
      [ -n "$type" ] && break
      log_err "Invalid selection."
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
    log_warn "$type is not listed by 'ssh -Q key' on this system."
    input_yn answer "Continue Anyway?"
    case "$answer" in [yY]*) ;; *) return 1 ;; esac
  fi

  # 2. Filename (plain names go to ~/.ssh)
  while :; do
    if [ -z "$file" ]; then
      input_ask file "Filename (saved in ~/.ssh unless a path is given):" || return 1
      [ -n "$file" ] || { log_err "Filename must not be empty."; continue; }
    fi
    case "$file" in
      "~/"*) file="$HOME/${file#\~/}" ;;
      */*)   ;;
      *)     file="$HOME/.ssh/$file" ;;
    esac
    if [ -e "$file" ] || [ -e "$file.pub" ]; then
      log_err "\"$file\" already exists – choose another name."
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
      input_ask comment "Comment:" || return 1
      [ -n "$comment" ] && break
      log_err "Comment must not be empty."
    done
  fi

  # 4. Build options
  set -- -t "$type" -a 96 -f "$file" -C "$comment"
  case "$type" in
    rsa)   set -- "$@" -b 4096 ;;
    ecdsa) set -- "$@" -b 521 ;;
    *-sk)
      set -- "$@" -O verify-required
      input_yn answer "Store key on the security key (resident, recoverable via ssh-keygen -K)?" || return 1
      case "$answer" in [yY]*) set -- "$@" -O resident ;; esac
      ;;
  esac

  log_info "Running: ssh-keygen $*"
  command ssh-keygen "$@" || return   # stop here if key generation failed

  # 5. Copy fingerprint (SHA256) to clipboard
  fp=$(command ssh-keygen -l -E sha256 -f "$file.pub" 2>/dev/null | awk '{print $2}')
  if [ -z "$fp" ]; then
    log_warn "Could not read fingerprint of \"$file.pub\"."
  elif command -v copy_to_clipboard >/dev/null 2>&1; then
    # copy_to_clipboard reads stdin; on failure it prints the text and a warning itself
    if printf '%s' "$fp" | copy_to_clipboard; then
      log_ok "Fingerprint copied to clipboard: $fp"
    fi
  else
    log_info "Fingerprint: $fp (copy_to_clipboard not defined)"
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
    log_err "get_bundle_id only works on macOS"
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
      log_err "Unknown option: ${C_RED}${arg}${C_RESET}"
      return 1
      ;;
    *) apps+=("$arg") ;;
    esac
  done
  if [[ ${#apps[@]} -eq 0 ]]; then
    log_info "Usage: get_bundle_id [--stdout | --copy] <App Name | /path/to/App.app> [...]" >&2
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
      log_err "App not found: ${C_RED}${app}${C_RESET}"
      rc=1
    elif [[ "$mode" == "copy" ]]; then
      ids+=("$id")
    elif [[ ${#apps[@]} -eq 1 ]]; then
      echo "$id" # plain value, so it can be captured with $(...)
    else
      log_ok "${C_WHITE}${app}${C_RESET}: ${C_CYAN}${id}${C_RESET}"
    fi
  done

  # Copy all found IDs at once (one per line, no trailing newline)
  if [[ "$mode" == "copy" && ${#ids[@]} -gt 0 ]]; then
    if (
      IFS=$'\n'
      printf '%s' "${ids[*]}"
    ) | copy_to_clipboard; then
      log_ok "Copied to clipboard: ${C_CYAN}${ids[*]}${C_RESET}"
    else
      rc=1
    fi
  fi

  return $rc
}

# -- AZURE CLI -- #

# Authenticate Azure CLI
function az-login() {
  command -v az >/dev/null 2>&1 || { log_err "Azure CLI (az) not found in PATH."; return 1; }

  local -a auth=()
  local as=""
  if [[ "${1:-}" == "--user" ]]; then
    shift
  elif [[ -n "$AZ_CLIENT_ID" && -n "$AZ_CLIENT_SECRET" ]]; then
    auth=(--service-principal --username "$AZ_CLIENT_ID" --password "$AZ_CLIENT_SECRET")
    as=" as service principal $AZ_CLIENT_ID"
  fi

  # AZURE_CORE_LOGIN_EXPERIENCE_V2=off skips the interactive subscription picker (this call only)
  log_info "Logging in to $AZ_TENANT ($AZ_TENANT_ID)$as"
  AZURE_CORE_LOGIN_EXPERIENCE_V2=off \
    az login "${auth[@]}" --tenant "$AZ_TENANT_ID" --allow-no-subscriptions --output none "$@" ||
    { local rc=$?; log_err "az login failed (exit code $rc)."; return "$rc"; }

  az account set --subscription "$AZ_SUBSCRIPTION_ID" ||
    { log_err "Could not select subscription $AZ_SUBSCRIPTION_ID."; return 1; }

  log_ok "Logged in to $AZ_TENANT - subscription: $(az account show --query name --output tsv 2>/dev/null)"
}

# Activate Entra Roles (PIM)
# Usage: azpim [-d <0-8>] [-j <justification>] 
function az-pim() {
  local duration="PT8H" justification="Activated via azpim (Azure CLI)" dry=0
  local acct tenant utype uid now just body resp code msg eligible active
  local rid scope name status ok=0 pending=0 skip=0 fail=0
  local graph="https://graph.microsoft.com/v1.0/roleManagement/directory"

  # -- Arguments -- #
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--duration)
        [[ -n "${2:-}" ]] || { log_err "azpim: $1 needs a value"; return 1; }
        duration="$2"; shift 2 ;;
      -j|--justification)
        [[ -n "${2:-}" ]] || { log_err "azpim: $1 needs a value"; return 1; }
        justification="$2"; shift 2 ;;
      -n|--dry-run) dry=1; shift ;;
      -h|--help)
        printf '%s\n' "Usage: azpim [-d|--duration <hours|ISO8601>] [-j|--justification <text>] [-n|--dry-run]"
        return 0 ;;
      *) log_err "azpim: unknown option '$1' (see azpim --help)"; return 1 ;;
    esac
  done
  [[ "$duration" =~ ^[0-9]+$ ]] && duration="PT${duration}H"
  [[ "$duration" == P* ]] || { log_err "azpim: invalid duration '$duration' (e.g. 4 or PT4H or PT30M)"; return 1; }

  # -- Login: must be a *user* in the current context tenant (service principals cannot self-activate) -- #
  command -v az >/dev/null 2>&1 || { log_err "Azure CLI (az) not found in PATH."; return 1; }
  [[ -n "${AZ_TENANT_ID:-}" ]] || { log_err "azpim: AZ_TENANT_ID not set - run env_azure <tenant> first."; return 1; }

  # join() returns one string "tenantId|userType" - independent of how az formats lists in tsv
  acct=$(az account show --query "join('|', [tenantId, user.type])" --output tsv 2>/dev/null)
  tenant=${acct%%|*}
  utype=${acct##*|}
  if [[ "$tenant" != "$AZ_TENANT_ID" || "$utype" != "user" ]]; then
    log_warn "azpim: Azure CLI is not signed in as a user in $AZ_TENANT - running az-login --user"
    az-login --user || return $?
  fi

  uid=$(az ad signed-in-user show --query id --output tsv 2>/dev/null) && [[ -n "$uid" ]] ||
    { log_err "azpim: could not resolve the signed-in user."; return 1; }

  # -- Eligible + already active roles (Graph PIM API) -- #
  eligible=$(az rest --method GET \
    --url "$graph/roleEligibilityScheduleInstances/filterByCurrentUser(on='principal')?\$expand=roleDefinition" \
    --query "value[].[roleDefinitionId, directoryScopeId, roleDefinition.displayName]" --output tsv) ||
    { log_err "azpim: could not list eligible role assignments."; return 1; }

  [[ -n "$eligible" ]] || { log_info "azpim: no eligible Entra roles found for $uid in $AZ_TENANT."; return 0; }

  active=$(az rest --method GET \
    --url "$graph/roleAssignmentScheduleInstances/filterByCurrentUser(on='principal')" \
    --query "value[].[roleDefinitionId, directoryScopeId]" --output tsv) ||
    { log_err "azpim: could not list active role assignments."; return 1; }

  # -- Activate -- #
  now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  just=${justification//\\/\\\\}   # JSON-escape backslashes
  just=${just//\"/\\\"}            # JSON-escape double quotes

  log_info "azpim: activating eligible roles in $AZ_TENANT for $duration"
  while IFS=$'\t' read -r rid scope name <&3; do
    [[ -n "$rid" ]] || continue

    if [[ $'\n'"$active"$'\n' == *$'\n'"$rid"$'\t'"$scope"$'\n'* ]]; then
      log_info "already active : $name ($scope)"; skip=$((skip + 1)); continue
    fi
    if (( dry )); then
      log_info "[dry-run]      : would activate $name ($scope) for $duration"; continue
    fi

    body=$(printf '{"action":"selfActivate","principalId":"%s","roleDefinitionId":"%s","directoryScopeId":"%s","justification":"%s","scheduleInfo":{"startDateTime":"%s","expiration":{"type":"AfterDuration","duration":"%s"}}}' \
      "$uid" "$rid" "$scope" "$just" "$now" "$duration")

    if resp=$(az rest --method POST --url "$graph/roleAssignmentScheduleRequests" \
        --headers "Content-Type=application/json" --body "$body" \
        --query status --output tsv 2>&1); then
      status=${resp##*$'\n'}
      case "$status" in
        PendingApproval) log_warn "pending approval: $name ($scope)"; pending=$((pending + 1)) ;;
        *)               log_ok   "activated      : $name ($scope) [$status]"; ok=$((ok + 1)) ;;
      esac
    else
      code=$(printf '%s' "$resp" | sed -n 's/.*"code":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
      msg=$(printf '%s' "$resp" | sed -n 's/.*"message":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
      if [[ "$code" == "RoleAssignmentExists" ]]; then
        log_info "already active : $name ($scope)"; skip=$((skip + 1))
      else
        log_err "failed         : $name ($scope) - ${code:-error}: ${msg:-$resp}"; fail=$((fail + 1))
      fi
    fi
  done 3<<<"$eligible"

  (( dry )) && return 0
  log_info "azpim: activated $ok, pending approval $pending, already active $skip, failed $fail"
  if (( fail )); then
    log_warn "azpim: policy failures (MFA, justification, ticket, max duration) - try az-login --user with MFA, -j <text> or a shorter -d"
    return 1
  fi
}
# Installs missing extensions from $AZ_EXTENSIONS. 
# Usage: az-extensions [--upgrade]
function az-extensions() {
  command -v az >/dev/null 2>&1 || { log_err "Azure CLI (az) not found in PATH."; return 1; }
  local -a upgrade=()
  [[ "${1:-}" == "--upgrade" ]] && upgrade=(--upgrade)

  local installed ext
  installed=$(az extension list --query "[].name" -o tsv 2>/dev/null)
  for ext in "${AZ_EXTENSIONS[@]}"; do
    if [[ -z "${upgrade[*]}" ]] && grep -qx -- "$ext" <<<"$installed"; then
      continue
    fi
    log_info "Azure CLI extension: $ext"
    az extension add --name "$ext" "${upgrade[@]}" --only-show-errors ||
      log_err "Could not install extension $ext"
  done
}

# -- PODMAN -- #
function pd-rm() {
  podman rmi --all --force
}

function pd-prune(){
  podman system prune --all --force
}
