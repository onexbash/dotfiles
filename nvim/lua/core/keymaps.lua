-- | -- | MOTION OVERRIDES | -- | --
-- paste
vim.keymap.set({ 'n', 'v' }, 'p', 'P', { desc = 'paste (no yank)' })
vim.keymap.set({ 'n', 'v' }, 'P', 'p', { desc = 'paste (with yank)' })
-- change
vim.keymap.set({ 'n', 'v' }, 'c', '"_c', { desc = 'change (no yank)' })
vim.keymap.set({ 'n', 'v' }, '"_c', 'c', { desc = 'change (with yank)' })
vim.keymap.set({ 'n', 'v' }, '"_C', 'C', { desc = 'change (with yank)' })
vim.keymap.set({ 'n', 'v' }, 'C', '"_C', { desc = 'change (no yank)' })

-- | -- | KEYMAPS | -- | --

-- open file explorer
vim.keymap.set('n', '<C-n>', '<CMD>Oil<CR>', { desc = 'oil: open filetree' })

-- reload config
vim.keymap.set('n', '<leader>F5', '<cmd>source %<CR>', { desc = 'reload config' })

-- clear search highlight
vim.keymap.set('n', '<ESC>', '<CMD>nohlsearch<CR>', { desc = 'clear search highlight' })

-- | restart nvim | --
local restart_nvim = function()
  -- safe session file
  local sesh_file = vim.env.ONEXSESH .. '/nvim/last.session'
  vim.cmd('mksession! ' .. vim.env.ONEXSESH .. '/nvim/last.session')
  print('session file saved: ' .. sesh_file)
  vim.cmd('qa!')
end
vim.keymap.set('n', '<leader>rs', restart_nvim, { desc = 'restart nvim' })

-- increase / decrease number
vim.keymap.set('n', '<C-+>', '<C-a>', { desc = 'Increase number under cursor' })
vim.keymap.set('n', '<C-->', '<C-x>', { desc = 'Decrease number under cursor' })
