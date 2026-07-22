local keymap = vim.keymap.set

-- reload config
keymap("n", "<leader>F5", "<cmd>source %<CR>", { desc = "reload config" })

-- clear search highlight
keymap("n", "<ESC>", "<CMD>nohlsearch<CR>", { desc = "clear search highlight" })

-- increase / decrease number
keymap("n", "<C-+>", "<C-a>", { desc = "Increase number under cursor" })
keymap("n", "<C-->", "<C-x>", { desc = "Decrease number under cursor" })
