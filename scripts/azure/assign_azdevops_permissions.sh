#!/usr/bin/env bash

# Grants "Create child nodes" Permission on every Project in the Azure DevOps Organization, to the Entra Groups defined below.
# This allows members of these groups to create Sprints in the Project Boards.
# Default mode is a DRY RUN. Nothing is changed without --apply (which asks for YES first).

# Usage:
#   ./grant-sprint-permissions.sh                          # dry run, all projects of $AZ_DEVOPS_ORG
#   ./grant-sprint-permissions.sh --org cratosde           # dry run, organization by name
#   ./grant-sprint-permissions.sh --project "Name"         # dry run, one project
#   ./grant-sprint-permissions.sh --apply                  # apply
#
# Environment variables (options win over environment):
#   AZ_DEVOPS_ORG       organization name, e.g. cratosde (not the URL)   default: cratosde
#   AZ_DEVOPS_PROJECT   limit the run to one project                      default: all projects

set -uo pipefail
export MSYS_NO_PATHCONV=1 # Git Bash: do not rewrite "vstfs:///..." tokens as paths

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
ITERATION_NAMESPACE_ID="bf7bfa03-b2b7-47db-8113-fa2e002cc5b1" # "Iteration" security namespace
PERMISSION_NAME="CREATE_CHILDREN"                             # "Create child nodes"
ENTRA_GROUPS=(
  "AAA_DevOps_Admins"
  "AAA_DevOps_Admins_Envyze"
  "AAA_DevOps_Contributors"
  "AAA_DevOps_Contributors_Envyze"
  "AAA_DevOps_Members"
  "AAA_DevOps_Members_Envyze"
  "AAA_DevOps_Stakeholders"
  "AAA_DevOps_Stakeholders_Envyze"
)

# ---------------------------------------------------------------------------
# Environment Variables & Options
# ---------------------------------------------------------------------------
AZ_DEVOPS_ORG="${AZ_DEVOPS_ORG:-cratosde}"
AZ_DEVOPS_PROJECT="${AZ_DEVOPS_PROJECT:-}"
PROJECT_SOURCE="AZ_DEVOPS_PROJECT"
APPLY=false

die() {
  echo "ERROR: $*" >&2
  exit 1
}
need_value() { [[ -n "${2:-}" ]] || die "Option $1 needs a value."; }
# Prints the comment header of this file (everything up to the first code line)
show_help() { awk 'NR == 1 { next } /^#/ { sub(/^# ?/, ""); print; next } /^$/ { print; next } { exit }' "$0"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
  --org)
    need_value "$1" "${2:-}"
    AZ_DEVOPS_ORG="$2"
    shift 2
    ;;
  --project)
    need_value "$1" "${2:-}"
    AZ_DEVOPS_PROJECT="$2"
    PROJECT_SOURCE="--project"
    shift 2
    ;;
  --apply)
    APPLY=true
    shift
    ;;
  -h | --help)
    show_help
    exit 0
    ;;
  *) die "Unknown option: $1 (see --help)" ;;
  esac
done

# Organization: name only, e.g. "cratosde". The URL is built from it.
[[ -n "$AZ_DEVOPS_ORG" ]] || die "Please set AZ_DEVOPS_ORG or pass --org <organization name>"
[[ "$AZ_DEVOPS_ORG" =~ ^[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?$ ]] ||
  die "\"$AZ_DEVOPS_ORG\" is not a valid organization name. Pass only the name (e.g. cratosde), not the URL."
ORG_URL="https://dev.azure.com/$AZ_DEVOPS_ORG"

RUN_DIR="sprint-permissions-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$RUN_DIR" || die "Could not create $RUN_DIR"
ERR_LOG="$RUN_DIR/az-errors.log"
BACKUP_CSV="$RUN_DIR/before-state.csv"
ROLLBACK_SH="$RUN_DIR/rollback.sh"
: >"$ERR_LOG"

# az call with tsv output; Windows line endings stripped; errors go to the log.
az_tsv() { az "$@" --org "$ORG_URL" --only-show-errors -o tsv 2>>"$ERR_LOG" | tr -d '\r'; }

# Reads the explicit Allow/Deny bits of one group on one token into ACE_ALLOW / ACE_DENY.
# Returns non-zero if the call fails (then nothing is decided for that pair).
read_ace() {
  local subject="$1" token="$2" out
  out=$(az_tsv devops security permission show --id "$ITERATION_NAMESPACE_ID" \
    --subject "$subject" --token "$token" \
    --query "[0].acesDictionary.*.[allow, deny] | [0]") || return 1
  IFS=$'\t' read -r ACE_ALLOW ACE_DENY <<<"$out"
  [[ "${ACE_ALLOW:-}" =~ ^-?[0-9]+$ ]] || ACE_ALLOW=0
  [[ "${ACE_DENY:-}" =~ ^-?[0-9]+$ ]] || ACE_DENY=0
  return 0
}

echo "Organization: $AZ_DEVOPS_ORG ($ORG_URL)"
if [[ -n "$AZ_DEVOPS_PROJECT" ]]; then
  echo "Projects:     only \"$AZ_DEVOPS_PROJECT\" (from $PROJECT_SOURCE)"
else
  echo "Projects:     ALL"
fi
echo "Groups:       ${#ENTRA_GROUPS[@]}"
echo "Mode:         $([[ "$APPLY" == true ]] && echo "APPLY (changes will be made after confirmation)" || echo "DRY RUN (nothing is changed)")"
echo "Run folder:   $RUN_DIR"
echo

# ---------------------------------------------------------------------------
# 1. Checks
# ---------------------------------------------------------------------------
echo "== 1. Checks"
command -v az >/dev/null 2>&1 || die "Azure CLI (az) not found."
az extension show --name azure-devops --only-show-errors >/dev/null 2>&1 ||
  die "Azure DevOps extension missing. Run: az extension add --name azure-devops"

signed_in=$(az account show --query "user.name" -o tsv --only-show-errors 2>>"$ERR_LOG" | tr -d '\r') || signed_in=""
[[ -n "$signed_in" ]] || die "Not signed in to Azure CLI. Run: az login"
echo "   Signed in as: $signed_in"

# Read the bit value from the namespace itself instead of hard-coding it.
BIT=$(az_tsv devops security permission namespace show --id "$ITERATION_NAMESPACE_ID" \
  --query "[0].actions[?name=='$PERMISSION_NAME'].bit | [0]") || true
[[ "${BIT:-}" =~ ^[0-9]+$ ]] || die "Could not read the $PERMISSION_NAME bit. Check the organization name and that you are Project Collection Administrator. Details: $ERR_LOG"
echo "   $PERMISSION_NAME = bit $BIT in the Iteration namespace"
echo

# ---------------------------------------------------------------------------
# 2. Resolve the Entra groups (must exist exactly once in the organization)
# ---------------------------------------------------------------------------
echo "== 2. Entra groups"
GROUPS_TSV="$RUN_DIR/entra-groups-in-org.tsv"
: >"$GROUPS_TSV"
cont=""
pages=0
while :; do
  pages=$((pages + 1))
  ((pages > 200)) && die "Group listing did not finish after 200 pages. Nothing was changed."
  args=(devops security group list --scope organization --subject-types aadgp)
  [[ -n "$cont" ]] && args+=(--continuation-token "$cont")
  az_tsv "${args[@]}" --query "graphGroups[].[displayName, descriptor]" >>"$GROUPS_TSV" ||
    die "Could not list Entra groups. Details: $ERR_LOG"
  next=$(az_tsv "${args[@]}" --query "continuationToken" | cut -f1) ||
    die "Could not read the continuation token. Details: $ERR_LOG"
  [[ -z "$next" || "$next" == "None" || "$next" == "$cont" ]] && break
  cont="$next"
done

GROUP_NAMES=()
GROUP_DESCRIPTORS=()
problems=0
for g in "${ENTRA_GROUPS[@]}"; do
  matches=$(awk -F'\t' -v n="$g" '$1 == n { print $2 }' "$GROUPS_TSV" | sort -u)
  count=$(printf '%s\n' "$matches" | grep -c . || true)
  if [[ "$count" -eq 1 ]]; then
    GROUP_NAMES+=("$g")
    GROUP_DESCRIPTORS+=("$matches")
    echo "   OK         $g"
  elif [[ "$count" -eq 0 ]]; then
    echo "   NOT FOUND  $g (not known in this organization)"
    problems=$((problems + 1))
  else
    echo "   AMBIGUOUS  $g ($count groups with this name)"
    problems=$((problems + 1))
  fi
done
((problems == 0)) || die "Resolve the groups above first. Nothing was changed."
echo

# ---------------------------------------------------------------------------
# 3. Projects
# ---------------------------------------------------------------------------
echo "== 3. Projects"
PROJECTS_TXT="$RUN_DIR/projects.txt"
: >"$PROJECTS_TXT"
skip=0
while :; do
  page=$(az_tsv devops project list --top 100 --skip "$skip" --query "value[].name") ||
    die "Could not list projects. Details: $ERR_LOG"
  [[ -z "$page" ]] && break
  printf '%s\n' "$page" >>"$PROJECTS_TXT"
  n=$(printf '%s\n' "$page" | grep -c . || true)
  ((n < 100)) && break
  skip=$((skip + 100))
done

PROJECTS=()
if [[ -n "$AZ_DEVOPS_PROJECT" ]]; then
  grep -Fxq -- "$AZ_DEVOPS_PROJECT" "$PROJECTS_TXT" ||
    die "Project \"$AZ_DEVOPS_PROJECT\" (from $PROJECT_SOURCE) not found. Nothing was changed."
  PROJECTS=("$AZ_DEVOPS_PROJECT")
else
  while IFS= read -r p; do [[ -n "$p" ]] && PROJECTS+=("$p"); done <"$PROJECTS_TXT"
fi
((${#PROJECTS[@]} > 0)) || die "No projects found. Nothing was changed."
echo "   ${#PROJECTS[@]} project(s)"
echo

# ---------------------------------------------------------------------------
# 4. Plan: read the current state, decide per project/group, write the backup
# ---------------------------------------------------------------------------
echo "== 4. Current state and plan"
echo '"project";"group";"token";"explicit_allow_before";"explicit_deny_before";"plan"' >"$BACKUP_CSV"
PLAN_PROJECT=()
PLAN_GROUP=()
PLAN_DESC=()
PLAN_TOKEN=()
n_already=0
n_deny=0
n_err=0

for p in "${PROJECTS[@]}"; do
  root=$(az_tsv boards iteration project list --project "$p" --depth 0 --query identifier) || root=""
  if ! [[ "$root" =~ ^[0-9a-fA-F-]{36}$ ]]; then
    echo "   ERROR      $p: could not read the root iteration node, project skipped"
    n_err=$((n_err + 1))
    continue
  fi
  token="vstfs:///Classification/Node/$root"

  for i in "${!GROUP_NAMES[@]}"; do
    g="${GROUP_NAMES[$i]}"
    d="${GROUP_DESCRIPTORS[$i]}"
    ACE_ALLOW=""
    ACE_DENY=""
    if ! read_ace "$d" "$token"; then
      plan="error-reading-state"
      n_err=$((n_err + 1))
    elif ((ACE_DENY & BIT)); then
      plan="skip-explicit-deny"
      n_deny=$((n_deny + 1))
    elif ((ACE_ALLOW & BIT)); then
      plan="already-allowed"
      n_already=$((n_already + 1))
    else
      plan="grant"
      PLAN_PROJECT+=("$p")
      PLAN_GROUP+=("$g")
      PLAN_DESC+=("$d")
      PLAN_TOKEN+=("$token")
    fi
    printf '"%s";"%s";"%s";"%s";"%s";"%s"\n' "$p" "$g" "$token" "$ACE_ALLOW" "$ACE_DENY" "$plan" >>"$BACKUP_CSV"
    printf '   %-20s %-40s %s\n' "$plan" "$p" "$g"
  done
done

echo
echo "   To grant:           ${#PLAN_PROJECT[@]}"
echo "   Already allowed:    $n_already"
echo "   Explicit Deny:      $n_deny (left unchanged - review manually)"
echo "   Errors:             $n_err (see $ERR_LOG)"
echo "   State before run:   $BACKUP_CSV"
echo

if [[ "$APPLY" != true ]]; then
  echo "DRY RUN finished. Nothing was changed. Re-run with --apply to make the changes."
  exit 0
fi
if ((${#PLAN_PROJECT[@]} == 0)); then
  echo "Nothing to grant. Nothing was changed."
  exit 0
fi

# ---------------------------------------------------------------------------
# 5. Apply (after explicit confirmation)
# ---------------------------------------------------------------------------
read -r -p "Grant $PERMISSION_NAME for ${#PLAN_PROJECT[@]} project/group combination(s) in $AZ_DEVOPS_ORG? Type YES to continue: " answer
[[ "$answer" == "YES" ]] || die "Aborted. Nothing was changed."
echo

{
  echo '#!/usr/bin/env bash'
  echo "# Removes the explicit Allow for $PERMISSION_NAME that grant-sprint-permissions.sh set in run $RUN_DIR."
  echo '# Only entries that had no explicit Allow/Deny before that run are listed here.'
  echo 'set -uo pipefail'
  echo 'export MSYS_NO_PATHCONV=1'
} >"$ROLLBACK_SH"
chmod +x "$ROLLBACK_SH"

echo "== 5. Applying"
n_done=0
n_fail=0
for i in "${!PLAN_PROJECT[@]}"; do
  p="${PLAN_PROJECT[$i]}"
  g="${PLAN_GROUP[$i]}"
  d="${PLAN_DESC[$i]}"
  t="${PLAN_TOKEN[$i]}"
  ACE_ALLOW=""
  ACE_DENY=""
  if az devops security permission update --id "$ITERATION_NAMESPACE_ID" \
    --subject "$d" --token "$t" --allow-bit "$BIT" --merge true \
    --org "$ORG_URL" --only-show-errors -o none 2>>"$ERR_LOG"; then
    # Rollback line is written right away, before verifying.
    printf 'az devops security permission reset --id %q --subject %q --token %q --permission-bit %q --org %q --only-show-errors -o none   # %s / %s\n' \
      "$ITERATION_NAMESPACE_ID" "$d" "$t" "$BIT" "$ORG_URL" "$p" "$g" >>"$ROLLBACK_SH"
    if read_ace "$d" "$t" && ((ACE_ALLOW & BIT)) && ! ((ACE_DENY & BIT)); then
      echo "   GRANTED          $p / $g"
      n_done=$((n_done + 1))
    else
      echo "   VERIFY FAILED    $p / $g (update ran, but the Allow bit could not be confirmed)"
      n_fail=$((n_fail + 1))
    fi
  else
    echo "   ERROR            $p / $g (update failed, see $ERR_LOG)"
    n_fail=$((n_fail + 1))
  fi
done

echo
echo "Done. Granted: $n_done, problems: $n_fail"
echo "Files in $RUN_DIR:"
echo "   before-state.csv  state before the run"
echo "   rollback.sh       undoes exactly the grants of this run"
echo "   az-errors.log     Azure CLI errors"
