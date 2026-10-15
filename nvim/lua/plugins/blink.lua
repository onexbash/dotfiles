-- | SETUP FUNCTION | --

-- blink.indent
local blink_indent = require("blink.indent")
blink_indent.setup({
	blocked = {
		buftypes = { "terminal", "quickfix", "nofile", "prompt" },
		filetypes = { "lspinfo", "packer", "checkhealth", "help", "man", "gitcommit", "dashboard" },
	},
	mappings = {
		border = "both",
	},
	static = {
		enabled = true,
	},
	scope = {
		enabled = true,
		indent_at_cursor = false,
		char = "▎",
		underline = {
			enabled = false,
		},
	},
})
-- blink.pairs
local blink_pairs = require("blink.pairs")
blink_pairs.setup({
	-- catppuccin highlights
	highlights = {
		groups = {
			"BlinkPairsRed",
			"BlinkPairsYellow",
			"BlinkPairsBlue",
			"BlinkPairsOrange",
			"BlinkPairsGreen",
			"BlinkPairsPurple",
			"BlinkPairsCyan",
		},
	},
})

-- | KEYMAPS | --
-- blink.indent
keymap("n", "<leader>bi", function()
	blink_indent.enable(not blink_indent.is_enabled())
end, { desc = "Toggle Indent Guides" })

-- blink.pairs
