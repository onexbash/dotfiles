#!/usr/bin/env zsh
# -- -- -- -- -- -- -- -- -- -- #
# --        HOME ZSHRC       -- #
# -- -- -- -- -- -- -- -- -- -- #
# --     $ZDOTDIR/.zshrc     -- #
# -- -- -- -- -- -- -- -- -- -- #

function load_config() {
  source "${ZDOTDIR}/tools.sh"
  source "${ZDOTDIR}/aliases.sh"
}

function load_external_config() {
  source "${XDG_CONFIG_HOME}/eza/shell.sh"
}

load_config
load_external_config

