require("catppuccin").setup({
	flavour = "mocha",
	background = "mocha",
	transparent_background = true,
	float = {
		transparent = true, -- transparent floating windows
		solid = false, -- solid styling for floating windows
	},
	term_colors = true, -- whether to use the Terminal Emulator or nvim Colorscheme for Terminal Buffers inside of nvim
	dim_inactive = {
		enabled = false, -- dims the background of inactive windows
	},
	no_italic = false,
	no_bold = false,
	no_underline = false,
	auto_integrations = true, -- automatically detects installed plugins with catppuccin integration & enables the theme for them
	integrations = {
		blink_cmp = {
			style = "bordered",
		},
		blink_indent = true,
		blink_pairs = true,
		grug_far = true,
		mason = true,
		mini = true,
		noice = true,
		treesitter_context = true,
		render_markdown = true,
		snacks = {
			enabled = true,
			indent_scope_color = "mauve", -- catppuccin color (e.g: 'lavender')
		},
		lsp_trouble = true,
		treesitter = true,
		markdown = true,
	},
	-- custom color overrides
	custom_highlights = function(colors)
		return {
			Comment = { fg = colors.overlay0 },
			CursorLineNr = { fg = colors.green },
		}
	end,
})

-- Apply Colorscheme
vim.cmd.colorscheme("catppuccin-nvim")
