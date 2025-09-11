-- | -- | MOTION OVERRIDES | -- | --
local keymap = vim.keymap.set

-- paste
keymap({ 'n', 'v' }, 'p', 'P', { desc = 'paste (no yank)' })
keymap({ 'n', 'v' }, 'P', 'p', { desc = 'paste (with yank)' })
-- change
keymap({ 'n', 'v' }, 'c', '"_c', { desc = 'change (no yank)' })
keymap({ 'n', 'v' }, '"_c', 'c', { desc = 'change (with yank)' })
keymap({ 'n', 'v' }, '"_C', 'C', { desc = 'change (with yank)' })
keymap({ 'n', 'v' }, 'C', '"_C', { desc = 'change (no yank)' })

-- | -- | KEYMAPS | -- | --

-- open file explorer
keymap('n', '<C-n>', '<CMD>Oil<CR>', { desc = 'oil: open filetree' })

-- reload config
keymap('n', '<leader>F5', '<cmd>source %<CR>', { desc = 'reload config' })

-- clear search highlight
keymap('n', '<ESC>', '<CMD>nohlsearch<CR>', { desc = 'clear search highlight' })

-- | restart nvim | --
local restart_nvim = function()
  -- safe session file
  local sesh_file = vim.env.ONEXSESH .. '/nvim/last.session'
  vim.cmd('mksession! ' .. vim.env.ONEXSESH .. '/nvim/last.session')
  print('session file saved: ' .. sesh_file)
  vim.cmd('qa!')
end
keymap('n', '<leader>rs', restart_nvim, { desc = 'restart nvim' })

-- increase / decrease number
keymap('n', '<C-+>', '<C-a>', { desc = 'Increase number under cursor' })
keymap('n', '<C-->', '<C-x>', { desc = 'Decrease number under cursor' })


-- toggle floating terminal
keymap("n", "<C-t>", "<CMD>Floaterm<CR>", { desc = "Open Floating Terminal" })
keymap('t', '<Esc>', '<C-\\><C-n>', { desc = "Exit Insert Mode in Terminal" })


vim.keymap.set('n', '<M-f>', function()
    local current_win = vim.api.nvim_get_current_win()
    local is_maximized = vim.w.is_maximized or false

    if not is_maximized then
        -- Save original dimensions
        vim.w.original_width = vim.api.nvim_win_get_width(current_win)
        vim.w.original_height = vim.api.nvim_win_get_height(current_win)

        -- Maximize to full screen
        vim.api.nvim_win_set_width(current_win, vim.o.columns)
        vim.api.nvim_win_set_height(current_win, vim.o.lines - 1)  -- -1 for statusline

        vim.w.is_maximized = true
    else
        -- Restore original dimensions
        if vim.w.original_width and vim.w.original_height then
            vim.api.nvim_win_set_width(current_win, vim.w.original_width)
            vim.api.nvim_win_set_height(current_win, vim.w.original_height)
        end

        vim.w.is_maximized = false
    end
end, { desc = 'Toggle window fullsize' })
