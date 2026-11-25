# -- -- -- -- -- -- -- -- -- -- -- #
# --         HOME ZSHRC         -- #
# -- -- -- -- -- -- -- -- -- -- -- #
# --          ~/.zshrc          -- #
# -- -- -- -- -- -- -- -- -- -- -- #

# Configure Shell
: ${SHELL_CONFIG_DIR:=${XDG_CONFIG_HOME:-$HOME/.config}/shell}
HISTFILE="$SHELL_CONFIG_DIR/.zsh_history"
[[ -d ${HISTFILE:h} ]] || mkdir -p "${HISTFILE:h}"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY SHARE_HISTORY HIST_IGNORE_SPACE HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_VERIFY

# Define Shell Config Files to load
function config_files() {
  local files=(
    "util.sh"
    "context.zsh"
    "autoreload.zsh"
    "functions.zsh"
    "tools.zsh"
    "completions.zsh"
    "aliases.zsh"
  )
  local file
  for file in $files; do
    if [[ -r "$SHELL_CONFIG_DIR/$file" ]]; then
      print -r -- "$SHELL_CONFIG_DIR/$file"
    else
      print -u2 "zshrc: config file not found or not readable: $SHELL_CONFIG_DIR/$file"
    fi
  done
}

# Source Shell Config Files
for config_file in ${(f)"$(config_files)"}; do
  source "$config_file"
done

unset config_file
unfunction config_files
