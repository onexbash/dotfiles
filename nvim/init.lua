-- Record startup time
_G.nvim_start = vim.uv.hrtime()

-- Check if nvim version is 0.1
if vim.fn.has("nvim-0.12") ~= 1 then
	vim.fn.input("This config requires nvim v0.11+. Please Update neovim! Press Enter to exit...")
	vim.cmd("cquit")
end

-- Map Leader Key (has to be set upfront)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Load Modules
require("core.keymaps")
require("core.options")
require("core.autocmd")
require("core.filetypes")
-- Load plugins
require("plugins")
