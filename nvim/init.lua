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

-- Load Utils -> `/lua/utils/init.lua`
require("utils")

-- Load Modules -> `/lua/core/init.lua`
require("core")

-- Load plugins -> `lua/plugins/init.lua`
require("plugins")
