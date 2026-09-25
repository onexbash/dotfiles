require("codesnap").setup({
	show_line_number = true,
	highlight_color = "#1E1E2E",
	show_workspace = true,
	save_path = vim.env.HOME .. "Library/CloudStorage/ProtonDrive-fabian@schlegel.one-folder/Media/CodeSnap",
	snapshot_config = {
		code_config = {
			font_family = "CaskaydiaCove Nerd Font",
			theme = "candy",
			window = {
				mac_window_bar = false,
				margin = {
					x = 20,
					y = 20,
				},
				border = {
					width = 1,
					color = "#b4befe",
				},
				title_config = {
					color = "#b4befe",
				},
			},
			breadcrumbs = {
				enable = true,
				separator = "/",
				color = "#b4befe", -- catppuccin "lavender"
				font_family = "Caskaydia Nerd Font Mono",
			},
		},
	},
	watermark = "",
	background = "#1E1E2E",
})
