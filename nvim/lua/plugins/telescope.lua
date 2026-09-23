-- | Setup | --
local telescope = require("telescope")
telescope.setup()

-- | Keymaps | --
vim.keymap.set({ "n", "x" }, "<leader>ff", function()
	require("telescope.builtin").find_files()
end, { desc = "Telescope: find files" })
vim.keymap.set({ "n", "x" }, "<leader>fg", function()
	require("telescope.builtin").live_grep()
end, { desc = "Telescope: live grep" })
vim.keymap.set({ "n", "x" }, "<leader>fb", function()
	require("telescope.builtin").buffers()
end, { desc = "Telescope: buffers" })
vim.keymap.set({ "n", "x" }, "<leader>fh", function()
	require("telescope.builtin").help_tags()
end, { desc = "Telescope: help tags" })
