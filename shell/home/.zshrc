# -- -- -- -- -- -- -- -- -- -- #
# --        HOME ZSHRC       -- #
# -- -- -- -- -- -- -- -- -- -- #
# --     $ZDOTDIR/.zshrc     -- #
# -- -- -- -- -- -- -- -- -- -- #

function load_helper() {
  source "${ZDOTDIR}/scripts/helper.sh"
  load_colors
  load_stylings
}

function load_config() {
  source "${ZDOTDIR}/tools.sh"
  source "${ZDOTDIR}/aliases.sh"
  source "${ZDOTDIR}/functions.sh"
}

function load_external_config() {
  source "${XDG_CONFIG_HOME}/eza/shell.sh"
}

load_helper && load_config && load_external_config

