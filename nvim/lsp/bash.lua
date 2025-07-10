return {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'bash', 'sh', 'zsh', 'dotenv' }, -- custom filetype 'dotenv' (see: /ftdetect/dotenv.lua)
  root_markers = { '.git' },
  settings = {
    bashIde = {
      globPattern = '*@(.sh|.inc|.bash|.command|.zsh)', -- custom filetype 'bash' (see: /ftdetect/bash.lua)
    },
  },
}
