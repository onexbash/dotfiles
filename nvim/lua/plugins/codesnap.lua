local codesnap = require("codesnap")
local font = "ShureTech Nerd Font"
local c = require("utils.colors")
local codesnap_dir = vim.env.XCLOUD .. "/Media/Images/codesnap"

-- |   SETUP   | --
codesnap.setup({
	show_line_number = true,
	show_workspace = false,
	highlight_color = c.hex("white", 0.1),

	snapshot_config = {
		theme = "catppuccin-mocha", -- <name>.tmTheme
		themes_folders = { vim.env.XDG_CONFIG_HOME .. "/codesnap/themes" },
		fonts_folders = { vim.env.HOME .. "/Library/Fonts" },

		window = {
			mac_window_bar = false,
			shadow = {
				radius = 20,
				color = c.hex("black", 0.6), -- black @ 60%
			},
			margin = { x = 0, y = 0 },
			border = {
				width = 1,
				color = c.hex("dark_gray_2", 0.8), -- dark_gray_2 @ 80%
			},
			title_config = {
				color = c.hex("white"),
				font_family = "Pacifico",
			},
		},

		line_number_color = c.hex("gray"),

		command_output_config = {
			prompt = "❯",
			font_family = font,
			prompt_color = c.hex("pink"),
			command_color = c.hex("green"),
			string_arg_color = c.hex("orange"),
		},

		code_config = {
			font_family = font,
			breadcrumbs = {
				enable = true,
				separator = "/",
				color = c.hex("light_gray_4"),
				font_family = font,
			},
		},

		watermark = {
			content = "",
		},
		-- Diagonal gradient: purple → pink → orange → blue
		background = c.hex("dark_gray_5"),
	},
})

-- |   KEYMAPS   | --

-- Internal CodeSnap modules (v2.1). Used because the public save() rejects any path
-- with a "." in a folder name, and save_highlight() is an empty stub.
local generator = require("codesnap.module").load_generator()
local snap_config = require("codesnap.config")
local snap_static = require("codesnap.static")
local modal = require("codesnap.modal")

-- [FN] Target file: $XCLOUD/Media/Images/codesnap/YY-MM-DD_SNAP.png
-- (a second snap on the same day becomes YY-MM-DD_SNAP_2.png etc. instead of overwriting)
local function target_path()
	vim.fn.mkdir(codesnap_dir, "p")
	local base = codesnap_dir .. "/" .. os.date("%y-%m-%d") .. "_SNAP"
	local path, n = base .. ".png", 1
	while vim.uv.fs_stat(path) do
		n = n + 1
		path = ("%s_%d.png"):format(base, n)
	end
	return path
end

-- [FN] Render the snapshot straight to the target file (same calls as codesnap.save)
local function write(config)
	local ok, err = pcall(function()
		local dest = target_path()
		generator.save(dest, config)
		vim.cmd("delmarks <>")
		vim.notify("CodeSnap saved: " .. dest)
	end)
	if not ok then
		vim.notify("CodeSnap: " .. tostring(err), vim.log.levels.ERROR)
	end
end

-- [FN] Save the selection
local function save()
	write(snap_config.get_config())
end

-- [FN] Pick lines to highlight in a popup, then save (mirrors codesnap.copy_highlight)
local function save_highlight()
	local config = snap_config.get_config()
	modal.pop_modal(config.content.content, vim.bo.filetype, function(selection)
		if not selection then
			return vim.notify("CodeSnap: highlight cancelled")
		end
		config.content.highlight_lines = { { selection[1], selection[2], snap_static.config.highlight_color } }
		write(config)
	end)
end

-- [FN] Clear highlight lines left over from a previous highlight snap
-- (CodeSnap merges them into its stored config, so they would leak into the next snap)
local function reset_highlight()
	local content = snap_static.config.snapshot_config.content
	if content then
		content.highlight_lines = nil
	end
end

-- Prompt key → action
local actions = {
	y = codesnap.copy,
	s = save,
	h = codesnap.copy_highlight,
	H = save_highlight,
}

-- [FN] Ask for the action (single keypress, case-sensitive; anything else cancels)
local function prompt()
	vim.api.nvim_echo({
		{ "CodeSnap  ", "Title" },
		{ "[y]", "Special" },
		{ " Copy  " },
		{ "[s]", "Special" },
		{ " Save  " },
		{ "[h]", "Special" },
		{ " Highlight → Copy  " },
		{ "[H]", "Special" },
		{ " Highlight → Save" },
	}, false, {})
	local ok, key = pcall(vim.fn.getcharstr)
	vim.cmd.echo('""')
	return ok and key or nil
end

-- [FN] Snap the visual selection, or the whole buffer in normal mode
local function snap()
	if vim.fn.mode():match("^[vV\22]") then
		vim.cmd("normal! \27") -- leave visual mode so '< and '> hold the selection
	else
		local view = vim.fn.winsaveview()
		vim.cmd("normal! ggVG\27") -- mark the whole buffer as the selection
		vim.fn.winrestview(view)
	end

	local action = actions[prompt()]
	if action then
		reset_highlight()
		local ok, err = pcall(action)
		if not ok then
			vim.notify("CodeSnap: " .. tostring(err), vim.log.levels.ERROR)
		end
	end
end

-- Set Keymaps
keymap({ "n", "x" }, "<leader>cs", snap, { desc = "CodeSnap: Snapshot selection / buffer" })
