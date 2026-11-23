#!/usr/bin/env zsh
# Called from ~/.ssh/config: Load SSH keys from Proton Pass via pass_ssh()

# Keep stdout free for ssh/git; send all output to stderr
exec 1>&2

# GUI apps start without the shell PATH; make mise and Homebrew tools findable
export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"

source ~/.config/shell/util.sh || exit 1
source ~/.config/shell/functions.zsh || exit 1
pass_ssh "${1:-${PASS_SSH_VAULT:-SSH Keys}}"
