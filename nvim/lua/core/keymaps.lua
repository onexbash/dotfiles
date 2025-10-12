-- | -- | MOTION OVERRIDES | -- | --
local keymap = vim.keymap.set

-- paste
-- keymap({ 'n', 'v' }, 'p', 'P', { desc = 'paste (no yank)' })
-- keymap({ 'n', 'v' }, 'P', 'p', { desc = 'paste (with yank)' })
-- change
-- keymap({ 'n', 'v' }, 'c', '"_c', { desc = 'change (no yank)' })
-- keymap({ 'n', 'v' }, '"_c', 'c', { desc = 'change (with yank)' })
-- keymap({ 'n', 'v' }, '"_C', 'C', { desc = 'change (with yank)' })
-- keymap({ 'n', 'v' }, 'C', '"_C', { desc = 'change (no yank)' })

-- | -- | KEYMAPS | -- | --

-- open file explorer
keymap("n", "<C-n>", "<CMD>Oil<CR>", { desc = "oil: open filetree" })

-- reload config
keymap("n", "<leader>F5", "<cmd>source %<CR>", { desc = "reload config" })

-- clear search highlight
keymap("n", "<ESC>", "<CMD>nohlsearch<CR>", { desc = "clear search highlight" })

-- | restart nvim | --
local restart_nvim = function()
  -- safe session file
  local sesh_file = vim.env.ONEXCORE .. "/tmp/nvim_session.restored"
  vim.cmd("mksession! " .. sesh_file)
  print("session file saved: " .. sesh_file)
  vim.cmd("qa!")
end
keymap("n", "<leader>rs", restart_nvim, { desc = "restart nvim" })

-- increase / decrease number
keymap("n", "<C-+>", "<C-a>", { desc = "Increase number under cursor" })
keymap("n", "<C-->", "<C-x>", { desc = "Decrease number under cursor" })

-- toggle floating terminal
keymap("n", "<C-t>", "<CMD>Floaterm<CR>", { desc = "Open Floating Terminal" })
keymap("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit Insert Mode in Terminal" })
