-- -- -- -- -- --
-- | AUTOCMD | --
-- -- -- -- -- --

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- highlight on yank
autocmd('TextYankPost', {
  desc = 'highlight on yank',
  group = augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

