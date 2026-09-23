local keymap = vim.keymap.set

-- Disable Space bar as it's used as the leader key
keymap({ "n", "v" }, "<leader>", "<nop>", { desc = "Disable leader key default" })

-- Reload neovim configuration
keymap("n", "<leader>F5", "<cmd>source %<CR>", { desc = "reload config" })

-- Clear search highlight
keymap("n", "<ESC>", "<CMD>nohlsearch<CR>", { desc = "clear search highlight" })

-- Increase / decrease number
keymap("n", "<C-+>", "<C-a>", { desc = "Increase number under cursor" })
keymap("n", "<C-->", "<C-x>", { desc = "Decrease number under cursor" })

-- Navigate Buffers
keymap("n", "<S-l>", ":bnext<CR>", { silent = true, desc = "Next buffer" })
keymap("n", "<S-h>", ":bprevious<CR>", { silent = true, desc = "Previous buffer" })

-- | REMAPS | --

-- | VIM MOTIONS | --
-- override: paste
keymap("v", "p", '"_dP', { desc = "Remap paste to prevent overwriting the clipboard" })
