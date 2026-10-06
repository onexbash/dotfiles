# -- -- -- -- -- -- -- -- -- -- -- -- #
# --        USER BASH_LOGOUT       -- #
# -- -- -- -- -- -- -- -- -- -- -- -- #
# --         ~/.bash_logout        -- #
# -- -- -- -- -- -- -- -- -- -- -- -- #

# Clear Console when leaving the Terminal
if [[ $SHLVL -eq 1 && -t 1 ]]; then
  print -n '\e[H\e[2J\e[3J'
fi
