# -- ZelliJ Shell Integration -- #

# Layout Picker
# $1: optional session name
_zj_layout() {
  emulate -L zsh
  setopt null_glob

  local dir="${XDG_CONFIG_HOME:-$HOME/.config}/zellij/layouts"
  local -a layouts args
  local file name choice

  [[ -n "$1" ]] && args=(--session "$1")

  for file in "$dir"/*.kdl; do
    name="${file##*/}"            # strip path
    name="${name%.kdl}"           # strip extension
    [[ "$name" == *.swap ]] && continue
    layouts+=("$name")
  done

  # No custom layouts: start with the default one
  if (( ${#layouts[@]} == 0 )); then
    zellij "${args[@]}"
    return
  fi

  choice=$(
    {
      printf '%b\n' "${C_GREEN}[default layout]${C_RESET}"
      printf '%s\n' "${layouts[@]}"
    } | sk --ansi --prompt="layout> " --height=40% --reverse
  )

  case "$choice" in
    "")                   return 2 ;;   # Esc: back to main menu
    *"[default layout]"*) zellij "${args[@]}" ;;
    *)                    zellij "${args[@]}" --new-session-with-layout "$dir/$choice.kdl" ;;
  esac
}

# Picker Function for creating/attaching ZelliJ Sessions
zj() {
  emulate -L zsh

  local sessions choice session_name dir rc

  while true; do
    sessions=$(zellij list-sessions --short 2>/dev/null)

    choice=$(
      {
        printf '%b\n' \
          "${C_BLUE}[plain terminal]${C_RESET}" \
          "${C_GREEN}[new session]${C_RESET}"
        if [[ -n "$sessions" ]]; then
          printf '%s\n' "$sessions"
        fi
      } | sk --ansi --prompt="zellij> " --height=40% --reverse
    )

    case "$choice" in
      "" | *"[plain terminal]"*)
        return 1
        ;;
      *"[new session]"*)
        # Directory: prefilled with $PWD, editable, Tab-completion works
        dir="$PWD"
        vared -p "Directory: " -c dir
        dir="${dir/#\~/$HOME}"              # expand leading ~
        if [[ ! -d "$dir" ]]; then
          printf '%b\n' "${I_ERR}'$dir' is not a directory."
          continue
        fi

        # Session name: defaults to the directory basename, clear it for a random name
        session_name="${dir##*/}"
        vared -p "Session name: " -c session_name

        if [[ -n "$session_name" ]] && printf '%s\n' "$sessions" | grep -qxF "$session_name"; then
          printf '%b\n' "${I_WARN}Session '$session_name' already exists."
          continue
        fi

        # Subshell: all panes start in $dir, your shell's $PWD is unchanged
        ( cd "$dir" && _zj_layout "$session_name" )
        rc=$?
        (( rc == 2 )) && continue   # back to main menu
        return "$rc"
        ;;
      *)
        zellij attach "$choice"
        return
        ;;
    esac
  done
}

# Call zj function if not already inside a session
if [[ -z "$ZELLIJ" && -o interactive ]]; then
  zj && [[ "$ZELLIJ_AUTO_EXIT" == "true" ]] && exit
fi

# Delete zellij sessions: Tab to mark, Enter to delete
function zj_delete() {
  emulate -L zsh
  local name

  zellij list-sessions --short 2>/dev/null \
    | sk --multi --reverse --height=40% --prompt="delete> " \
    | while IFS= read -r name; do
        [[ "$name" == "$ZELLIJ_SESSION_NAME" ]] && continue   # never kill the current session
        zellij delete-session --force "$name" && printf '%b\n' "${I_OK}Deleted '$name'"
      done
}

# List zellij sessions
function zj_list() {
  zellij list-sessions 
}

# Call Session Picker
function zj_pick() {
  zj
}
