-- | KEYMAPS | --
-- Find Files
keymap("n", "<leader>ff", function()
	Snacks.picker.smart()
end, { desc = "Picker: Find Files (smart)" })
-- Grep Strings
keymap("n", "<leader>fg", function()
	Snacks.picker.grep()
end, { desc = "Picker: Grep Strings" })
-- Command History
keymap("n", "<leader>fc", function()
	Snacks.picker.command_history()
end, { desc = "Picker: Command History" })
-- Buffers
keymap("n", "<leader>fb", function()
	Snacks.picker.buffers()
end, { desc = "Picker: Buffers" })
-- Help
keymap("n", "<leader>fh", function()
	Snacks.picker.help()
end, { desc = "Picker: Help Pages" })
-- Manpages
keymap("n", "<leader>fm", function()
	Snacks.picker.man()
end, { desc = "Picker: Manpages" })
-- LSP: Diagnostics
keymap("n", "<leader>xx", function()
	Snacks.picker.diagnostics()
end, { desc = "Toggle Diagnostics Window" })
-- LSP: Buffer Diagnostics
keymap("n", "<leader>xX", function()
	Snacks.picker.diagnostics_buffer()
end, { desc = "Toggle Buffer Diagnostics Window" })
-- LSP: Definition
keymap("n", "<leader>xd", function()
	Snacks.picker.lsp_definitions()
end, { desc = "Go to Definition" })
-- LSP: Reference
keymap("n", "<leader>xr", function()
	Snacks.picker.lsp_references()
end, { desc = "Go to Reference" })
-- LSP: Implementation
keymap("n", "<leader>xi", function()
	Snacks.picker.lsp_implementations()
end, { desc = "Go to Implementation" })
-- LSP: Type Definition
keymap("n", "<leader>xt", function()
	Snacks.picker.lsp_type_definitions()
end, { desc = "Go to Type Definition" })
-- Jump back (like <C-o>)
keymap("n", "<leader><BS>", "<C-o>", { desc = "Jump back" })

-- | CONFIGURATION | --
return {
	enabled = true,
	sources = {
		files = { hidden = true },
		grep = {
			hidden = true,
			regex = false,
			win = {
				-- toggle regex
				input = { keys = { ["<c-r>"] = { "toggle_regex", mode = { "i", "n" } } } },
			},
		},
		explorer = {
			layout = { layout = { position = "right" } },
		},
		diagnostics = {
			actions = {
				-- Function to yank diagnostic messages
				yank_message = function(picker)
					local msgs = vim.tbl_map(function(it)
						return it.item and it.item.message or it.text
					end, picker:selected({ fallback = true }))
					vim.fn.setreg("+", table.concat(msgs, "\n\n"))
					Snacks.notify("Copied " .. #msgs .. " diagnostic(s)")
				end,
			},
			win = {
				-- Yank diagnostic message (ctrl + y)
				input = { keys = { ["<c-y>"] = { "yank_message", mode = { "n", "i" } } } },
				-- Yank from diagnostics list (y)
				list = { keys = { ["y"] = "yank_message" } },
			},
		},
	},
}
