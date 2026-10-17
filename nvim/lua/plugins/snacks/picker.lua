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
-- Workspace Diagnostics
-- keymap("n", "<leader>fD", function()
-- 	vim.lsp.buf.workspace_diagnostics()
-- 	-- the request is async: give the servers a moment before opening the picker
-- 	vim.defer_fn(function()
-- 		Snacks.picker.diagnostics()
-- 	end, 300)
-- end, { desc = "Picker: Workspace Diagnostics" })
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
		files = { hidden = true },
		grep = { hidden = true },
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
