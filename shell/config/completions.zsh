load_completions() {
  # Completions only matter in interactive shells.
  case $- in *i*) ;; *) return 0 ;; esac

  local dir="${1:-${XDG_CONFIG_HOME:-$HOME/.config}/shell/completions}"
  local shell_ext file name restore_nullglob
  local -a files loaded failed

  if [ -n "${ZSH_VERSION:-}" ]; then
    shell_ext=zsh
    # zsh completion scripts call compdef, which needs compinit.
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
      *."$shell_ext" | *.sh) ;;
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
  else
    log_info "No $shell_ext completions found in $dir"
  fi
  if [ "${#failed[@]}" -gt 0 ]; then
    log_info "Failed to load completion(s): ${failed[*]}"
  fi
}

# Function Calls
load_completions
