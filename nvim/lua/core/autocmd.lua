-- -- -- -- -- --
-- | AUTOCMD | --
-- -- -- -- -- --

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local usercmd = vim.api.nvim_create_user_command

-- highlight on yank
autocmd('TextYankPost', {
  desc = 'highlight on yank',
  group = augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Floating Terminal
usercmd('Floaterm', function()
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = math.floor(vim.o.columns * 0.8),
    height = math.floor(vim.o.lines * 0.8),
    col = math.floor(vim.o.columns * 0.1),
    row = math.floor(vim.o.lines * 0.1),
    border = 'rounded'
  })
  vim.cmd('terminal')
end, {})
