-- Map Leader Key (has to be set upfront)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Load Modules
require("core.keymaps")
require("core.options")
require("core.autocmd")
require("core.lazy")
