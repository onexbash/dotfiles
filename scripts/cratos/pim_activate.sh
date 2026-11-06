#!/usr/bin/env bash
# Activate eligible Entra roles in PIM via Azure CLI + Microsoft Graph.
# Usage:        ./pim-activate.sh [--tenant_id <tenant-id|domain>] ["Justification text"]

set -euo pipefail

# tty_styles
function tty_styles() {
  # -- TERMINAL COLORS -- #
  export C_BLACK=$'\033[1;30m'
  export C_RED=$'\033[1;31m'
  export C_GREEN=$'\033[1;32m'
  export C_YELLOW=$'\033[1;33m'
  export C_BLUE=$'\033[1;34m'
  export C_PURPLE=$'\033[1;35m'
  export C_CYAN=$'\033[1;36m'
  export C_WHITE=$'\033[1;37m'
  export C_GRAY=$'\033[0;90m'
  export C_RESET=$'\033[0m'

  # -- INFO PROMPTS -- #
  export I_SKIP="${C_BLACK}[${C_CYAN} SKIPPING ${C_BLACK}] ${C_RESET}"   # skipping
  export I_WARN="${C_BLACK}[${C_YELLOW} WARNING ${C_BLACK}] ${C_RESET}"  # warning
  export I_OK="${C_BLACK}[${C_GREEN}  OK  ${C_BLACK}] ${C_RESET}"        # ok
  export I_INFO="${C_BLACK}[${C_PURPLE} INFO ${C_BLACK}] ${C_RESET}"     # info
  export I_ERR="${C_BLACK}[${C_RED} ERROR ${C_BLACK}] ${C_RESET}"        # error
  export I_YN="${C_BLACK}[${C_BLUE} y/n ${C_BLACK}] ${C_RESET}"          # ask user for yes/no
  export I_ASK="${C_BLACK}[${C_BLUE} ? ${C_BLACK}] ${C_RESET}"           # ask user for anything
  export I_LOAD="${C_BLACK}[${C_BLUE} LOADING .. ${C_BLACK}] ${C_RESET}" # loading / in progress
}
tty_styles

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
# Role names exactly as shown in PIM ("Eligible assignments" -> Role column)
ROLES=(
  "Application Administrator"
  "User Administrator"
  "Identity Governance Administrator"
  "Security Administrator"
  "Intune Administrator"
  "Lifecycle Workflows Administrator"
  "Tenant Governance Administrator"
)

DURATION="PT8H"                                   # ISO 8601 duration: 8 hours
JUSTIFICATION="Daily administrative tasks"        # Default, can be passed as argument
GRAPH="https://graph.microsoft.com/v1.0"
TENANT_ID=""

# ---------------------------------------------------------------------------
# Arguments
# ---------------------------------------------------------------------------
usage() {
  echo "Usage: $(basename "$0") [--tenant_id <tenant-id|domain>] [\"Justification text\"]"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tenant_id)
      [[ -n "${2:-}" ]] || { echo "${I_ERR}--tenant_id requires a value"; usage; exit 1; }
      TENANT_ID="$2"; shift 2 ;;
    --tenant_id=*)
      TENANT_ID="${1#*=}"; shift ;;
    -h|--help)
      usage; exit 0 ;;
    -*)
      echo "${I_ERR}Unknown option: $1"; usage; exit 1 ;;
    *)
      JUSTIFICATION="$1"; shift ;;
  esac
done

# Prompt for the tenant if none was passed
while [[ -z "$TENANT_ID" ]]; do
  if [[ ! -t 0 ]]; then
    echo "${I_ERR}No --tenant_id given and no interactive terminal to prompt."
    exit 1
  fi
  read -r -p "${I_ASK}Tenant ID (GUID or domain): " TENANT_ID
  TENANT_ID="${TENANT_ID//[[:space:]]/}"
done

# ---------------------------------------------------------------------------
# Login / tenant selection
# ---------------------------------------------------------------------------
# Reuse an existing login for this tenant if there is one, otherwise log in.
EXISTING_ACCOUNT="$(az account list --all \
  --query "[?tenantId=='${TENANT_ID}'] | [0].id" -o tsv 2>/dev/null || true)"

if [[ -n "$EXISTING_ACCOUNT" ]]; then
  az account set --subscription "$EXISTING_ACCOUNT"
  echo "${I_INFO}Using existing login for tenant ${C_WHITE}${TENANT_ID}${C_RESET}"
else
  echo "${I_LOAD}Logging in to tenant ${C_WHITE}${TENANT_ID}${C_RESET} ..."
  az login --tenant "$TENANT_ID" --allow-no-subscriptions >/dev/null
fi

ACTIVE_TENANT="$(az account show --query tenantId -o tsv)"
PRINCIPAL_ID="$(az ad signed-in-user show --query id -o tsv)"
START_TIME="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Escape characters that would break the JSON body
JUSTIFICATION_ESCAPED="$(printf '%s' "$JUSTIFICATION" | sed 's/\\/\\\\/g; s/"/\\"/g')"

echo
echo "${I_INFO}Tenant:        ${C_WHITE}${ACTIVE_TENANT}${C_RESET}"
echo "${I_INFO}User:          ${C_WHITE}${PRINCIPAL_ID}${C_RESET}"
echo "${I_INFO}Duration:      ${C_WHITE}${DURATION}${C_RESET}"
echo "${I_INFO}Justification: ${C_WHITE}${JUSTIFICATION}${C_RESET}"
echo

# ---------------------------------------------------------------------------
# Activation
# ---------------------------------------------------------------------------
ELIGIBLE_URL="$GRAPH/roleManagement/directory/roleEligibilitySchedules/filterByCurrentUser(on='principal')?\$expand=roleDefinition"

ok=0; failed=0

for ROLE in "${ROLES[@]}"; do
  echo "${I_LOAD}${C_GRAY}${ROLE}${C_RESET}"

  # One line per eligibility: <roleDefinitionId> <directoryScopeId>
  MATCHES="$(az rest --method GET --url "$ELIGIBLE_URL" \
    --query "value[?roleDefinition.displayName=='${ROLE}'].[roleDefinitionId, directoryScopeId]" \
    -o tsv)"

  if [[ -z "$MATCHES" ]]; then
    echo "${I_SKIP}${C_WHITE}${ROLE}${C_RESET}: no eligible assignment found"
    ((failed++)) || true
    continue
  fi

  while IFS=$'\t' read -r ROLE_DEF_ID SCOPE; do
    BODY=$(cat <<EOF
{
  "action": "selfActivate",
  "principalId": "$PRINCIPAL_ID",
  "roleDefinitionId": "$ROLE_DEF_ID",
  "directoryScopeId": "$SCOPE",
  "justification": "$JUSTIFICATION_ESCAPED",
  "scheduleInfo": {
    "startDateTime": "$START_TIME",
    "expiration": { "type": "afterDuration", "duration": "$DURATION" }
  }
}
EOF
)
    if OUT="$(az rest --method POST \
                --url "$GRAPH/roleManagement/directory/roleAssignmentScheduleRequests" \
                --headers "Content-Type=application/json" \
                --body "$BODY" \
                --query status -o tsv 2>&1)"; then
      if [[ "$OUT" == "PendingApproval" ]]; then
        echo "${I_WARN}${C_WHITE}${ROLE}${C_RESET} ${C_GRAY}(scope ${SCOPE})${C_RESET}: ${C_YELLOW}${OUT}${C_RESET}"
      else
        echo "${I_OK}${C_WHITE}${ROLE}${C_RESET} ${C_GRAY}(scope ${SCOPE})${C_RESET}: ${C_GREEN}${OUT}${C_RESET}"
      fi
      ((ok++)) || true
    else
      echo "${I_ERR}${C_WHITE}${ROLE}${C_RESET} ${C_GRAY}(scope ${SCOPE})${C_RESET}:"
      echo "        ${C_RED}$(echo "$OUT" | tail -n 3 | tr '\n' ' ')${C_RESET}"
      ((failed++)) || true
    fi
  done <<< "$MATCHES"
done

echo
if [[ $failed -eq 0 ]]; then
  echo "${I_OK}Done: ${C_GREEN}${ok} successful${C_RESET}, ${failed} failed/skipped."
else
  echo "${I_WARN}Done: ${C_GREEN}${ok} successful${C_RESET}, ${C_RED}${failed} failed/skipped${C_RESET}."
fi
[[ $failed -eq 0 ]]
