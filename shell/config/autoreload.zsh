zmodload zsh/datetime
zmodload -F zsh/stat b:zstat

typeset -g _CFG_LOADED_AT=$EPOCHSECONDS
typeset -ga _CFG_WATCH=(
  ${XDG_CONFIG_HOME:-$HOME/.config}/shell/*.zsh(N)
  ${ZDOTDIR:-$HOME}/.zshrc(N)
  ${ZDOTDIR:-$HOME}/.zshenv(N)
  ${ZDOTDIR:-$HOME}/.zprofile(N)
)

_cfg_autoreload() {
  (( ${#jobstates} )) && return   # don't kill background/suspended jobs
  local f mtime
  for f in $_CFG_WATCH; do
    zstat -A mtime +mtime -- $f 2>/dev/null || continue   # follows symlinks
    if (( mtime > _CFG_LOADED_AT )); then
      print -P "%F{magenta}↻ ${f:t} changed, reloading shell%f"
      fc -AI                                  # flush history before exec
      [[ -o login ]] && exec zsh -l || exec zsh   # keep login/non-login mode
    fi
  done
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _cfg_autoreload
