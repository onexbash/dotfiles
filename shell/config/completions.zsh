# -- COMPLETIONS -- #
# ~/.config/shell/completions.zsh (sourced by ~/.zshrc, zsh only)
# 
# ${XDG_CONFIG_HOME:-$HOME/.config}/shell/completions
#   _<name>      zsh completion function, autoloaded on demand via fpath (preferred)
#   <name>.zsh   sourced at startup, only for scripts that can't live in fpath (npm, pnpm)
#   anything else is ignored (.bash, .ps1, ...)
#
# Generated completions are refreshed with `completions-refresh`, never at startup.

[[ -o interactive ]] || return 0

: "${COMPLETIONS_DIR:=${XDG_CONFIG_HOME:-$HOME/.config}/shell/completions}"
: "${COMPLETIONS_CACHE:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh}"

# Carapace only for commands that have no good native completion, e.g. (kubectl helm).
# Empty = carapace disabled. Run `completions-refresh` after changing this list.
typeset -gaU CARAPACE_COMMANDS=( )

setup_compinit() {
  local dump="$COMPLETIONS_CACHE/zcompdump-$ZSH_VERSION"
  local -a candidates stale

  # ---- Completion paths (existing dirs only, no duplicates, own dir wins) ----
  candidates=(
    "$COMPLETIONS_DIR"
    "$HOMEBREW_PREFIX/share/zsh-completions"
    "$HOMEBREW_PREFIX/share/zsh/site-functions"
  )
  typeset -gU fpath
  fpath=( ${^candidates}(N/) $fpath )

  # ---- compinit with cached dump ----
  zmodload zsh/complist
  autoload -Uz compinit
  mkdir -p "$COMPLETIONS_CACHE"

  stale=( "$dump"(N.mh+24) )
  if (( $#stale )) || [[ ! -s $dump || $COMPLETIONS_DIR -nt $dump ]]; then
    compinit -d "$dump"
    # compinit does not rewrite a still-valid dump, so its mtime would stay old
    # and every following start would run the full (slow) check again.
    touch "$dump"
  else
    compinit -C -d "$dump"
  fi

  # Compiled dump loads faster; compile in the background when outdated.
  if [[ -s $dump && ( ! -s $dump.zwc || $dump -nt $dump.zwc ) ]]; then
    zcompile "$dump" &!
  fi

  # ---- Styles ----
  zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
  zstyle ':completion:*:descriptions' format '[%d]'
  zstyle ':completion:*' use-cache on
  zstyle ':completion:*' cache-path "$COMPLETIONS_CACHE/compcache"
}

load_completions() {
  local f
  local -a failed
  for f in "$COMPLETIONS_DIR"/*.zsh(N.r) "$COMPLETIONS_CACHE"/carapace.zsh(N.r); do
    source "$f" || failed+=( "${f:t}" )
  done
  (( $#failed )) && log_warn "[completions] failed to load: ${failed[*]}"
  return 0
}

runtime_completions() {
  # OpenTofu (bash-style completer, resolved via PATH at completion time)
  if (( $+commands[tofu] )); then
    autoload -Uz bashcompinit && bashcompinit
    complete -o nospace -C tofu tofu
  fi
}

# Regenerate static completion files. Run manually after tool updates
# (e.g. after `brew upgrade` / `mise upgrade`), then `exec zsh`.
completions-refresh() {
  emulate -L zsh
  local dir=$COMPLETIONS_DIR tmp name first
  local -a cmd
  mkdir -p "$dir" "$COMPLETIONS_CACHE" || return 1

  # name -> command that prints a zsh completion starting with '#compdef'
  local -A gen=(
    uv            'uv generate-shell-completion zsh'
    uvx           'uvx --generate-shell-completion zsh'
    mise          'mise completion zsh'
    rustup        'rustup completions zsh rustup'
    cargo         'rustup completions zsh cargo'
    golangci-lint 'golangci-lint completion zsh'
    gitleaks      'gitleaks completion zsh'
    trivy         'trivy completion zsh'
    tuios         'tuios completion zsh'
    fnox          'fnox completion zsh'
  )

  for name in ${(ko)gen}; do
    cmd=( ${(z)gen[$name]} )
    if (( ! $+commands[$cmd[1]] )); then
      log_skip "_$name ($cmd[1] not found)"
      continue
    fi
    tmp=$(mktemp "$dir/.$name.XXXXXX") || continue
    first=
    if "${cmd[@]}" >| "$tmp" 2>/dev/null && read -r first < "$tmp" && [[ $first == '#compdef'* ]]; then
      mv -f "$tmp" "$dir/_$name" && log_ok "_$name"
    else
      rm -f "$tmp"
      log_err "_$name (no '#compdef' output; may need to be sourced as $name.zsh)"
    fi
  done

  # Carapace: one cached snippet for the selected commands only
  if (( $+commands[carapace] && ${#CARAPACE_COMMANDS} )); then
    for name in $CARAPACE_COMMANDS; do
      carapace "$name" zsh
    done >| "$COMPLETIONS_CACHE/carapace.zsh"
    log_ok "carapace (${CARAPACE_COMMANDS[*]})"
  else
    rm -f "$COMPLETIONS_CACHE/carapace.zsh"
  fi

  # Force a full compinit on the next start
  rm -f "$COMPLETIONS_CACHE"/zcompdump-*(N)
  log_info "Done. Restart the shell with: exec zsh"
}

# Setup ZSH-Autosuggestions
setup_autosuggestions() {
  local plugin="$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -r $plugin ]] || return 0

  # Suggest from history first; if nothing matches, from what Tab would complete.
  typeset -ga ZSH_AUTOSUGGEST_STRATEGY=( history completion )
  typeset -g  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20    # no suggestions for long command lines
  # typeset -g ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8' # change if suggestions are hard to see

  # Load after compinit: it wraps the widgets that exist at load time.
  # (zsh-syntax-highlighting, if used, must still be sourced after this file.)
  source "$plugin"
}

setup_compinit
load_completions
runtime_completions
setup_autosuggestions  # gray inline suggestions, accept with → or End
