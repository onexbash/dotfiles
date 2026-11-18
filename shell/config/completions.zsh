# -- COMPLETIONS -- #
# ~/.config/shell/completions.zsh (sourced by ~/.zshrc)
#
# One directory for everything: ${XDG_CONFIG_HOME:-$HOME/.config}/shell/completions
#   _<name>        zsh completion function, loaded on demand via fpath   (e.g. _rustup, _cargo)
#   <name>.zsh     sourced at startup in zsh                              (e.g. tuios.zsh)
#   <name>.bash    sourced at startup in bash
#   <name>.sh      sourced in both shells
#   anything else  ignored

: "${COMPLETIONS_DIR:=${XDG_CONFIG_HOME:-$HOME/.config}/shell/completions}"

# Minimal fallback, only used if log_info isn't defined elsewhere.
if ! typeset -f log_info >/dev/null 2>&1; then
  log_info() { printf '[INFO] %s\n' "$*" >&2; }
fi

setup_compinit() {
  local dir="${1:-$COMPLETIONS_DIR}"
  local zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
  local -a candidates stale

  # ---- Completion paths (only existing directories are added, no duplicates) ----
  candidates=(
    "$dir"                                      # your _name files
    "$HOMEBREW_PREFIX/share/zsh-completions"    # zsh-completions
    "$HOMEBREW_PREFIX/share/zsh/site-functions" # brew-installed tools (incl. brew)
  )
  typeset -gU fpath
  fpath=( ${^candidates}(N/) $fpath )

  # ---- compinit with cached dump ----
  # Full rebuild (incl. security check) if the dump is missing, older than a day,
  # or the completions directory changed (file added, removed or renamed).
  zmodload zsh/complist
  autoload -Uz compinit
  mkdir -p "${zcompdump:h}"
  stale=( "$zcompdump"(N.mh+24) )
  if (( $#stale )) || [[ ! -s $zcompdump || $dir -nt $zcompdump ]]; then
    compinit -d "$zcompdump"
  else
    compinit -C -d "$zcompdump"
  fi

  # ---- Nicer matching ----
  zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
  zstyle ':completion:*:descriptions' format '[%d]'
  
  # ---- Carapace ----
  source <(carapace _carapace)
}

load_completions() {
  # Completions only matter in interactive shells.
  case $- in *i*) ;; *) return 0 ;; esac

  local dir="${1:-$COMPLETIONS_DIR}"
  local shell_ext file name restore_nullglob
  local -a files loaded failed ondemand

  if [ -n "${ZSH_VERSION:-}" ]; then
    shell_ext=zsh
    # Sourced zsh completion scripts call compdef, which needs compinit.
    if ! typeset -f compdef >/dev/null 2>&1; then
      autoload -Uz compinit && compinit
    fi
  elif [ -n "${BASH_VERSION:-}" ]; then
    shell_ext=bash
  else
    log_info "load_completions: unsupported shell, skipping"
    return 1
  fi

  if [ ! -d "$dir" ]; then
    log_info "load_completions: $dir not found, nothing loaded"
    return 0
  fi

  # Collect files without erroring on an empty directory.
  if [ "$shell_ext" = zsh ]; then
    eval 'files=( "$dir"/*(N) )'   # eval keeps zsh glob syntax away from bash's parser
  else
    restore_nullglob=$(shopt -p nullglob)
    shopt -s nullglob
    files=( "$dir"/* )
    eval "$restore_nullglob"
  fi

  for file in "${files[@]}"; do
    [ -f "$file" ] && [ -r "$file" ] || continue
    name=${file##*/}
    case "$name" in
      _*)                       # zsh function file: compinit loads it on demand
        [ "$shell_ext" = zsh ] && ondemand+=("${name#_}")
        continue ;;
      *."$shell_ext" | *.sh) ;; # source it
      *) continue ;;
    esac

    # shellcheck disable=SC1090
    if . "$file"; then
      loaded+=("${name%.*}")
    else
      failed+=("$name")
    fi
  done

  if [ "${#loaded[@]}" -gt 0 ]; then
    log_info "Loaded ${#loaded[@]} completion(s) for $shell_ext: ${loaded[*]}"
  fi
  if [ "${#ondemand[@]}" -gt 0 ]; then
    if eval '(( ${fpath[(Ie)$dir]} ))'; then
      log_info "On-demand completion(s): ${ondemand[*]}"
    else
      log_info "On-demand completion(s) not active, $dir is not in fpath: ${ondemand[*]}"
    fi
  fi
  if [ "${#loaded[@]}" -eq 0 ] && [ "${#ondemand[@]}" -eq 0 ]; then
    log_info "No $shell_ext completions found in $dir"
  fi
  if [ "${#failed[@]}" -gt 0 ]; then
    log_info "Failed to load completion(s): ${failed[*]}"
  fi
}

runtime_completions() {
  # OpenTofu (bash-style completer, resolved via PATH at completion time)
  if (( $+commands[tofu] )); then
    autoload -U +X bashcompinit && bashcompinit
    complete -o nospace -C tofu tofu
  fi
}

# Function Calls
setup_compinit
load_completions
runtime_completions
