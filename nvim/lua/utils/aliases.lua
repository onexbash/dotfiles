-- | ALIASES | --
local M = {}

-- functions
M.augroup = vim.api.nvim_create_augroup
M.autocmd = vim.api.nvim_create_autocmd

-- directories
M.lsp_dir = vim.fn.stdpath('config') .. '/lsp'
return M

-- USAGE:
-- local a = require("utils.aliases")
-- a.autocmd()
