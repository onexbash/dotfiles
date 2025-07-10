-- clipboard
vim.opt.clipboard = "unnamedplus"

-- scrolloff
vim.opt.scrolloff = 8 -- keep 8 lines above/below cursor till end of file

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
vim.g['airline#extensions#tabline#enabled'] = 0

-- files
vim.opt.swapfile = false -- disable swapfile

-- ui
vim.opt.laststatus = 3

vim.opt.timeout = true
vim.opt.timeoutlen = 1000
vim.opt.spelllang = { "en" }

if vim.g.neovide then
  vim.cmd("cd ~/.config/nvim")
  vim.g.background_color = "#1e1e2e"
  vim.g.neovide_transparency = 0
  vim.o.guifont = "ShureTechMono Nerd Font Mono:h18"
  vim.g.neovide_refresh_rate = 75
  vim.g.neovide_cursor_animation_length = 0.04
  vim.g.neovide_cursor_trail_size = 0.7
  -- vim.g.neovide_cursor_vfx_mode = "railgun"
  -- vim.g.neovide_cursor_vfx_mode = "torpedo"
  -- vim.g.neovide_cursor_vfx_mode = "pixiedust"
  -- vim.g.neovide_cursor_vfx_mode = "ripple"
  -- vim.g.neovide_cursor_vfx_mode = "wireframe"
  vim.g.neovide_cursor_vfx_mode = "sonicboom"

  -- Really weird issue in which my winbar would be drawn multiple times as I
  -- scrolled down the file, this fixed it, found in:
  -- https://github.com/neovide/neovide/issues/1550
  vim.g.neovide_scroll_animation_length = 0

  vim.g.neovide_input_macos_option_key_is_meta = "only_right"
end
