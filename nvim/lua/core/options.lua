-- clipboard
vim.opt.clipboard = "unnamedplus"

-- scrolloff
vim.opt.scrolloff = 8 -- keep 8 lines above/below cursor till end of file

-- search
vim.opt.ignorecase = true -- case-insensitive search
vim.opt.smartcase = true
vim.opt.incsearch = true -- enable highlighting search

-- cursor line
vim.opt.cursorline = true -- highlight cursorline
vim.opt.number = true -- enable line numbers
vim.opt.relativenumber = true -- make line numbers relative
vim.opt.wrap = false -- disable line wrapping
vim.opt.breakindent = true -- prevent line wrapping
vim.opt.fillchars:append({ eob = " " }) -- disable end-of-buffer indicators (~)

-- indentation
vim.opt.tabstop = 2 -- 2 spaces for tabs
vim.o.softtabstop = 2 -- how many spaces tab inserts
vim.opt.shiftwidth = 2 -- 2 spaces for indent width
vim.opt.expandtab = true -- expand tab to spaces
vim.opt.autoindent = true -- auto indent on new line
vim.opt.smartindent = true

-- colors
vim.opt.termguicolors = true -- enable 24-bit colors
vim.opt.background = "dark" -- colorschemes that can be light or dark will be made dark

-- disabled providers
vim.g.loaded_perl_provider = 0 -- perl
vim.g.loaded_ruby_provider = 0 -- ruby
vim.g.loaded_python3_provider = 0 -- python

-- tabline
-- disable tabline & airline as token over by "bufferline.nvim"
vim.opt.showtabline = 0
vim.g["airline#extensions#tabline#enabled"] = 0

-- files
vim.opt.swapfile = false -- disable swapfile
vim.opt.updatetime = 200 -- save swap file with 200ms debouncing
vim.opt.backup = false -- disable backup on q
vim.opt.autoread = true -- auto update file if changed outside of nvim
vim.opt.undofile = true -- enable undofile

-- ui
vim.opt.winborder = "rounded"
vim.opt.laststatus = 3
vim.opt.pumheight = 10 -- max height of completion menu
vim.opt.winborder = "rounded" -- rounded border
vim.opt.showmode = false -- disable showing mode below statusline
vim.opt.signcolumn = "yes" -- always show sign column

-- splits
vim.opt.splitbelow = true -- better splitting
vim.opt.splitright = true -- better splitting

-- other
vim.opt.timeout = true
vim.opt.timeoutlen = 1000
vim.opt.spelllang = { "en" }
