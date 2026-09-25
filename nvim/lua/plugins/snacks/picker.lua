-- | PICKER | --
-- Find Files
vim.keymap.set("n", "<leader>ff", function()
	Snacks.picker.smart()
end, { desc = "Picker: Find Files (smart)" })
-- Grep Strings
vim.keymap.set("n", "<leader>fg", function()
	Snacks.picker.grep()
end, { desc = "Picker: Grep Strings" })
-- Command History
vim.keymap.set("n", "<leader>fc", function()
	Snacks.picker.command_history()
end, { desc = "Picker: Command History" })
-- Buffers
vim.keymap.set("n", "<leader>fb", function()
	Snacks.picker.buffers()
end, { desc = "Picker: Buffers" })
-- Diagnostics
vim.keymap.set("n", "<leader>fd", function()
	Snacks.picker.diagnostics()
end, { desc = "Picker: Diagnostics" })
-- Help
vim.keymap.set("n", "<leader>fh", function()
	Snacks.picker.help()
end, { desc = "Picker: Help Pages" })
-- Manpages
vim.keymap.set("n", "<leader>fm", function()
	Snacks.picker.man()
end, { desc = "Picker: Manpages" })

-- LSP: Definition
vim.keymap.set("n", "xd", function()
	Snacks.picker.lsp_definitions()
end, { desc = "Picker: LSP Definition (go to)" })
-- LSP: References
vim.keymap.set("n", "xr", function()
	Snacks.picker.lsp_references()
end, { desc = "Picker: LSP References (go to)" })
-- LSP: Implementation
vim.keymap.set("n", "xi", function()
	Snacks.picker.lsp_implementations()
end, { desc = "Picker: LSP Implementation (go to)" })
-- LSP: Type Definition
vim.keymap.set("n", "xt", function()
	Snacks.picker.lsp_type_definitions()
end, { desc = "Picker: LSP Type Definition (go to)" })
