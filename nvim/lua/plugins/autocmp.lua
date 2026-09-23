local blink = require("blink.cmp")
blink.setup({
	enabled = function()
		return not vim.tbl_contains({ "markdown" }, vim.bo.filetype) -- Disable autocmp for specific filetypes
	end,
	-- Keymaps
	keymap = {
		preset = "none",
		["<C-space>"] = { "show", "show_documentation", "hide_documentation" }, -- Show Documentation
		["<C-e>"] = { "hide", "fallback" }, -- Hide Completion
		["<Tab>"] = { "select_and_accept", "fallback" }, -- Select & Accept
		["<C-p>"] = { "select_prev", "fallback_to_mappings" }, -- Select Previous
		["<C-n>"] = { "select_next", "fallback_to_mappings" }, -- Select Next
		["<C-b>"] = { "scroll_documentation_up", "fallback" }, -- Scroll Documentation Up
		["<C-f>"] = { "scroll_documentation_down", "fallback" }, -- Scroll Documentation Down
		["<Right>"] = { "snippet_forward", "fallback" }, -- Snippet Forward
		["<Left>"] = { "snippet_backward", "fallback" }, -- Snippet Backward
		["<C-k>"] = { "show_signature", "hide_signature", "fallback" }, -- Show/Hide Signature
	},
	snippets = { preset = "default" },
	completion = {
		menu = {
			auto_show = true,
		},
		ghost_text = {
			enabled = true,
		},
		list = {
			selection = {
				preselect = true,
				auto_insert = false,
			},
		},
		accept = {
			auto_brackets = { enabled = true },
		},
		documentation = {
			auto_show = true,
		},
	},
	sources = {
		default = { "lsp", "buffer", "snippets", "path" },

		providers = {
			cmdline = {
				-- Disable autocmp in only-shell command mode
				enabled = function()
					return vim.fn.getcmdtype() ~= ":" or not vim.fn.getcmdline():match("^[%%0-9,'<>%-]*!")
				end,
			},
			snippets = {
				opts = {
					friendly_snippets = true,
					search_paths = { vim.fn.stdpath("config") .. "/snippets" },
				},
			},
		},
	},
})
