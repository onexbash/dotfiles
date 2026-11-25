# -- -- -- -- -- -- -- -- -- -- -- #
# --         USER BASHRC        -- #
# -- -- -- -- -- -- -- -- -- -- -- #
# --          ~/.bashrc         -- #
# -- -- -- -- -- -- -- -- -- -- -- #

# Only run for interactive shells
[[ $- != *i* ]] && return

# Source global bash config
if [[ -f /etc/bashrc ]]; then
  . /etc/bashrc
fi

# Configure Shell
: "${SHELL_CONFIG_DIR:=${XDG_CONFIG_HOME:-$HOME/.config}/shell}"
HISTFILE="$SHELL_CONFIG_DIR/.bash_history"
[[ -d ${HISTFILE%/*} ]] || mkdir -p "${HISTFILE%/*}"
HISTSIZE=100000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T '
shopt -s histappend
PROMPT_COMMAND+=('history -a')

# Define Shell Config Files to load
function config_files() {
  local files=(
    "util.sh"
    "ssh.bash"
    "tools.bash"
    "aliases.bash"
  )
  local file
  for file in "${files[@]}"; do
    if [[ -r "$SHELL_CONFIG_DIR/$file" ]]; then
      printf '%s\n' "$SHELL_CONFIG_DIR/$file"
    else
      printf 'bashrc: config file not found or not readable: %s\n' "$SHELL_CONFIG_DIR/$file" >&2
    fi
  done
}

# Source Shell Config Files
mapfile -t config_paths < <(config_files)
for config_file in "${config_paths[@]}"; do
  # shellcheck source=/dev/null
  source "$config_file"
done

unset config_file config_paths
unset -f config_files
