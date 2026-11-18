#!/usr/bin/env bash

# Normalizes permissions in one or more directory trees (e.g. dotfiles repo, ~/.config):
#   directories                                         700
#   executable files (shebang "#!", Mach-O or ELF)      700
#   all other files                                     600
# Read-only items stay read-only for the owner (500 / 400), e.g. the Go module cache.
# Skips .git directories, symlinks, sockets and other special files.
# Default mode is a DRY RUN.

# Usage:
#   fix-permissions.sh [--apply] [dir ...]
#
#   dir       one or more directories
#             default: $XDG_DATA_HOME/dotfiles and $XDG_CONFIG_HOME
#   --apply   change the permissions (without it, only the planned changes are shown)

set -uo pipefail

die() {
  echo "ERROR: $*" >&2
  exit 1
}
show_help() { awk 'NR == 1 { next } /^#/ { sub(/^# ?/, ""); print; next } /^$/ { print; next } { exit }' "$0"; }

SHOW_MAX=30 # changes printed per directory; the full list goes to the report file

# ---------------------------------------------------------------------------
# Arguments
# ---------------------------------------------------------------------------
APPLY=false
TARGETS=()
for arg in "$@"; do
  case "$arg" in
  --apply) APPLY=true ;;
  -h | --help)
    show_help
    exit 0
    ;;
  -*) die "Unknown option: $arg (see --help)" ;;
  *) TARGETS+=("$arg") ;;
  esac
done
if ((${#TARGETS[@]} == 0)); then
  TARGETS=(
    "${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles"
    "${XDG_CONFIG_HOME:-$HOME/.config}"
  )
fi

# Resolve and validate all targets before changing anything
HOME_REAL="$(cd "$HOME" && pwd -P)"
ROOTS=()
for t in "${TARGETS[@]}"; do
  [[ -d "$t" ]] || die "Directory not found: $t"
  r="$(cd "$t" && pwd -P)"
  case "$r" in
  "/" | "$HOME_REAL") die "Refusing to run on $r" ;;
  esac
  ROOTS+=("$r")
done

# stat syntax differs: GNU (Linux) vs. BSD (macOS). Output: mode<TAB>type<TAB>path
if stat -c '%a' / >/dev/null 2>&1; then
  STAT=(stat -c $'%a\t%F\t%n')
else
  STAT=(stat -f $'%Lp\t%HT\t%N')
fi

REPORT="${TMPDIR:-/tmp}/fix-permissions-$(date +%Y%m%d-%H%M%S).txt"
LIST_DIR="$(mktemp -d)" || die "Could not create a temp directory"
trap 'rm -rf "$LIST_DIR"' EXIT
: >"$REPORT"

echo "Mode:   $([[ "$APPLY" == true ]] && echo "APPLY" || echo "DRY RUN (nothing is changed)")"
echo "Report: $REPORT"
echo

# Magic bytes of native executables
MACHO_64=$'\xcf\xfa\xed\xfe'
MACHO_32=$'\xce\xfa\xed\xfe'
MACHO_FAT=$'\xca\xfe\xba\xbe'
ELF=$'\x7fELF'

# Returns 0 if the file is a script with shebang or a native executable
is_executable() {
  local head=""
  LC_ALL=C IFS= read -r -d '' -n 4 head 2>/dev/null <"$1"
  [[ "${head:0:2}" == "#!" || "$head" == "$MACHO_64" || "$head" == "$MACHO_32" ||
    "$head" == "$MACHO_FAT" || "$head" == "$ELF" ]]
}

total_change=0
total_ok=0

for root in "${ROOTS[@]}"; do
  echo "== $root"
  echo "== $root" >>"$REPORT"
  n_ok=0
  n_change=0
  : >"$LIST_DIR/700"
  : >"$LIST_DIR/600"
  : >"$LIST_DIR/500"
  : >"$LIST_DIR/400"

  while IFS=$'\t' read -r have type path; do
    [[ -n "$path" ]] || continue
    mode="000$have"
    mode="${mode: -3}" # last three digits (owner/group/other), also for short values like "0"
    owner_writable=$(((${mode:0:1} & 2) != 0))

    case "$type" in
    [Dd]irectory) ((owner_writable)) && want=700 || want=500 ;;
    *)
      if is_executable "$path"; then
        ((owner_writable)) && want=700 || want=500
      else
        ((owner_writable)) && want=600 || want=400
      fi
      ;;
    esac

    if [[ "$have" == "$want" ]]; then
      n_ok=$((n_ok + 1))
      continue
    fi

    rel="${path#"$root"}"
    rel="${rel#/}"
    line="$(printf '   %4s -> %s   %s' "$have" "$want" "${rel:-.}")"
    ((n_change < SHOW_MAX)) && echo "$line"
    echo "$line" >>"$REPORT"
    printf '%s\0' "$path" >>"$LIST_DIR/$want"
    n_change=$((n_change + 1))
  done < <(find "$root" -name .git -prune -o \( -type d -o -type f \) -exec "${STAT[@]}" {} + 2>>"$REPORT")

  ((n_change > SHOW_MAX)) && echo "   ... and $((n_change - SHOW_MAX)) more (see report)"
  echo "   correct: $n_ok, $([[ "$APPLY" == true ]] && echo "changing" || echo "would change"): $n_change"

  if [[ "$APPLY" == true ]]; then
    for m in 700 600 500 400; do
      [[ -s "$LIST_DIR/$m" ]] || continue
      xargs -0 chmod "$m" <"$LIST_DIR/$m" || echo "   WARNING: some chmod $m calls failed (see messages above)" >&2
    done
  fi
  echo

  total_change=$((total_change + n_change))
  total_ok=$((total_ok + n_ok))
done

echo "Total: correct $total_ok, $([[ "$APPLY" == true ]] && echo "changed" || echo "would change") $total_change"
if [[ "$APPLY" == true ]]; then
  echo "Check 'git status' in your repos: git tracks the execute bit."
else
  echo "DRY RUN finished. Nothing was changed. Re-run with --apply to make the changes."
fi
