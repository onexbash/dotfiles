#!/usr/bin/env sh

# Builds the coding layout on the current workspace.
# Start from a workspace with a single window.
set -e
s="$TUIOS_SESSION"

tuios run-command -s "$s" EnableTiling
tuios set-window  -s "$s" --name code-top                          # the existing window
tuios split-window vertical   -s "$s" -w code-top --name code-main   # new window on the right
tuios split-window horizontal -s "$s" -w code-top --name code-bottom # new window below code-top

tuios focus-window -s "$s" code-main
tuios run-command  -s "$s" resize_width_70    # right column: 70% width
tuios focus-window -s "$s" code-top
tuios run-command  -s "$s" resize_height_60   # top left: 60% height
tuios focus-window -s "$s" code-main
