#!/usr/bin/env zsh

function ls() {
  local eza_args=(
    --long
    --show-symlinks
    --icons
    --color=always
    --no-permissions
    --no-user
    --no-filesize
    --octal-permissions
    --time-style="+%d/%m|%H:%M"
  )

  # Process arguments
  local pass_args=()
  local show_all=false
  local tree_view=false
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -a)
        show_all=true
        ;;
      -t)
        tree_view=true
        ;;
      *)
        pass_args+=("$1")
        ;;
    esac
    shift
  done

  # Add --all if -a was specified
  if [[ "$show_all" == true ]]; then
    eza_args+=(--all)
  fi

  # Add tree options if -t was specified
  if [[ "$tree_view" == true ]]; then
    eza_args+=(--tree --level=2)
  fi

  # Call eza with the constructed arguments
  eza "${eza_args[@]}" "${pass_args[@]}"
}

