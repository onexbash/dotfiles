-- | KEYMAPS | --
-- Keymap Function to avoid repetition
local map = function(lhs, picker, desc)
	keymap("n", lhs, function()
		Snacks.picker[picker]()
	end, { desc = "Picker: " .. desc })
end

-- Find Files
map("<leader>ff", "smart", "Find Files (smart)")
-- Grep Strings
map("<leader>fg", "grep", "Grep")
-- Command History
map("<leader>fc", "command_history", "Command History")
-- Buffers
map("<leader>fb", "buffers", "Buffers")
-- Diagnostics
map("<leader>fd", "diagnostics", "Diagnostics")
-- Help
map("<leader>fh", "help", "Help Pages")
-- Manpages
map("<leader>fm", "man", "Manpages")
-- LSP: Definition
map("xd", "lsp_definitions", "Definition")
-- LSP: References
map("xr", "lsp_references", "References")
-- LSP: Implementation
map("xi", "lsp_implementations", "Implementation")
-- LSP: Type Definition
map("xt", "lsp_type_definitions", "Type Definition")

-- | CONFIGURATION | --
return {
	enabled = true,
	sources = {
		explorer = {
			layout = { layout = { position = "right" } },
		},
	},
}
