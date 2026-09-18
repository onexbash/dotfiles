#!/usr/bin/env bash

# Start SSH Agent if not running
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
fi

# Define keys to load
KEYS=(
    "$HOME/.ssh/id_ed25519"
    "$HOME/.ssh/id_rsa"
    "$HOME/.ssh/id_netcup_server"
)

# Get current fingerprint list
LOADED_FINGERPRINTS=$(ssh-add -l 2>/dev/null || true)

for KEY in "${KEYS[@]}"; do
    if [ -f "$KEY" ]; then
        # Extract public key fingerprint if .pub file exists, otherwise read from private key
        PUB_FILE="${KEY}.pub"
        if [ -f "$PUB_FILE" ]; then
            FINGERPRINT=$(ssh-keygen -lf "$PUB_FILE" 2>/dev/null | awk '{print $2}')
        else
            FINGERPRINT=$(ssh-keygen -lf "$KEY" 2>/dev/null | awk '{print $2}')
        fi

        # Add key if fingerprint is missing from agent
        if [ -n "$FINGERPRINT" ] && ! echo "$LOADED_FINGERPRINTS" | grep -qF "$FINGERPRINT"; then
            ssh-add "$KEY"
        fi
    fi
done
