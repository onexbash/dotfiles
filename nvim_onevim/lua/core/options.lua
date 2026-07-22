-- clipboard
vim.opt.clipboard = "unnamedplus"

-- scrolloff
vim.opt.scrolloff = 8 -- keep 8 lines above/below cursor till end of file

-- search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- cursor line
vim.opt.cursorline = true -- highlight cursorline
vim.opt.relativenumber = true -- make line numbers relative
vim.opt.number = true -- enable line numbers
vim.opt.wrap = false -- disable line wrapping
vim.opt.fillchars:append({ eob = " " }) -- disable end-of-buffer indicators (~)

-- indentation
vim.opt.tabstop = 2 -- 2 spaces for tabs
vim.opt.shiftwidth = 2 -- 2 spaces for indent width
vim.opt.expandtab = true -- expand tab to spaces
vim.opt.autoindent = true -- auto indent on new line

-- colors
vim.opt.termguicolors = true -- enable 24-bit colors
vim.opt.background = "dark" -- colorschemes that can be light or dark will be made dark

-- disabled providers
vim.g.loaded_perl_provider = 0 -- perl
vim.g.loaded_ruby_provider = 0 -- ruby
vim.g.loaded_python3_provider = 0 -- python

-- tabline
-- disable tabline & airline as token over by "bufferline.nvim"-
vim.opt.showtabline = 0
vim.g["airline#extensions#tabline#enabled"] = 0

-- files
vim.opt.swapfile = false -- disable swapfile
vim.opt.undofile = true -- enable undofile

-- ui
vim.opt.winborder = "rounded"
vim.opt.laststatus = 3

vim.opt.timeout = true
vim.opt.timeoutlen = 1000
vim.opt.spelllang = { "en" }
