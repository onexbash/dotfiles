# Construct `$PATH` variable based on path files
function set_path() {
  # define path files in the desired order
  local path_files=(
    "${XDG_CONFIG_HOME:-$HOME/.config}/shell/paths/custom.env"
    "${XDG_CONFIG_HOME:-$HOME/.config}/shell/paths/default.env"
    "${XDG_CONFIG_HOME:-$HOME/.config}/shell/paths/system.env"
  )
  # read path files
  local path_list=()
  for path_file in "${path_files[@]}"; do
    if [[ -f "$path_file" ]]; then
      # append each line as a new entry of the $PATH variable
      while IFS= read -r line; do
        if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then # skip empty lines and comments `#`
          path_list+=("$line")
        fi
      done < "$path_file"
    fi
  done
  # clear $PATH variable
  export PATH=""
  # append path_list to $PATH variable
  if (( ${#path_list[@]} )); then
    joined=$(IFS=:; printf '%s' "${path_list[*]}")     # convert array to colon-separated string
    export PATH="$joined"     # set the complete path (since we cleaned it up)
  fi
}
set_path
