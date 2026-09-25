-- | KEYMAPS | --
-- Keymap Function to avoid repetition
local keymap = function(lhs, picker, desc)
	vim.keymap.set("n", lhs, function()
		Snacks.picker[picker]()
	end, { desc = "Picker: " .. desc })
end

-- Find Files
keymap("<leader>ff", "smart", "Find Files (smart)")
-- Grep Strings
keymap("<leader>fg", "grep", "Grep")
-- Command History
keymap("<leader>fc", "command_history", "Command History")
-- Buffers
keymap("<leader>fb", "buffers", "Buffers")
-- Diagnostics
keymap("<leader>fd", "diagnostics", "Diagnostics")
-- Help
keymap("<leader>fh", "help", "Help Pages")
-- Manpages
keymap("<leader>fm", "man", "Manpages")
-- LSP: Definition
keymap("xd", "lsp_definitions", "Definition")
-- LSP: References
keymap("xr", "lsp_references", "References")
-- LSP: Implementation
keymap("xi", "lsp_implementations", "Implementation")
-- LSP: Type Definition
keymap("xt", "lsp_type_definitions", "Type Definition")

-- | CONFIGURATION | --
return {
	enabled = true,
	sources = {
		explorer = {
			layout = { layout = { position = "right" } },
		},
	},
}
