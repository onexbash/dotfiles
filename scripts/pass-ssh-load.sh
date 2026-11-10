#!/usr/bin/env bash

# Load SSH keys from Proton Pass into the ssh-agent if it has none yet.
# Called from ~/.ssh/config:
# Usage: pass-ssh-load [vault]   (default: $PASS_SSH_VAULT or "SSH Keys")

set -u

# ssh/git read the connection on stdout, so this script only writes to stderr
exec 1>&2

vault=${1:-${PASS_SSH_VAULT:-SSH Keys}}
# GUI apps start without the shell PATH; make mise and Homebrew tools findable
export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/mise/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"

# ssh-add -l: 0 = agent has keys, 1 = agent is empty, 2 = no agent
ssh-add -l >/dev/null 2>&1
case $? in
0) exit 0 ;;
2)
  echo "pass-ssh-load: no ssh-agent reachable (SSH_AUTH_SOCK='${SSH_AUTH_SOCK-}')"
  exit 1
  ;;
esac

command -v pass-cli >/dev/null 2>&1 || {
  echo "pass-ssh-load: pass-cli not found in PATH"
  exit 127
}

# Log in only if there is no valid session and a terminal to prompt on
if ! pass-cli info >/dev/null 2>&1; then
  if ! (: </dev/tty) 2>/dev/null; then
    echo "pass-ssh-load: not logged in to Proton Pass and no terminal to log in from"
    exit 1
  fi
  echo "pass-ssh-load: logging in to Proton Pass..."
  pass-cli login </dev/tty >/dev/tty || exit 1
fi

pass-cli ssh-agent load --vault-name "$vault"
