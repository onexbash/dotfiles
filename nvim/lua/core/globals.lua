-- | GLOBAL VARIABLES | --
--
_G.keymap = vim.keymap.set -- set keymap
_G.augroup = vim.api.nvim_create_augroup -- create augroup
_G.autocmd = vim.api.nvim_create_autocmd -- create autocmd
_G.usercmd = vim.api.nvim_create_user_command -- create usercmd
--
_G.set_hl = vim.api.nvim_set_hl -- set highlight group
