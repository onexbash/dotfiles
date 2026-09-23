-- | Configuration | --
vim.diagnostic.config({
	underline = true,
	virtual_text = false, -- Disabled & handled by tiny-inline-diagnostic
	update_in_insert = false,
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = " ",
			[vim.diagnostic.severity.INFO] = " ",
		},
	},
})

-- | Keymaps | --
-- toggle buffer diagnostics in the location list
vim.keymap.set("n", "<leader>xx", function()
	if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
		vim.cmd.lclose()
	else
		vim.diagnostic.setloclist({ title = "Buffer Diagnostics" })
	end
end, { desc = "diagnostics: buffer (loclist)" })

-- | tiny-inline-diagnostic.nvim | --
require("tiny-inline-diagnostic").setup({
	preset = "modern", -- modern/classic/minimal/powerline/ghost/simple
	transparent_bg = false,
	transparent_cursorline = true,
	-- Colors (highlight groups or hex values)
	hi = {
		error = "DiagnosticError", -- Highlight for error diagnostics
		warn = "DiagnosticWarn", -- Highlight for warning diagnostics
		info = "DiagnosticInfo", -- Highlight for info diagnostics
		hint = "DiagnosticHint", -- Highlight for hint diagnostics
		arrow = "NonText", -- Highlight for the arrow pointing to diagnostic
		background = "CursorLine", -- Background highlight for diagnostics
		mixing_color = "Normal", -- Color to blend background with (or "None")
	},
	options = {
		show_source = {
			enabled = true,
		},
		show_code = true, -- Display the diagnostic code (e.g: F401)
		use_icons_from_diagnostic = true, -- Use icons from vim.diagnostic.config()
		throttle = 10, -- 0 = immediate updates (can cause lags)
		softwrap = 30,
		multilines = {
			enabled = true,
			always_show = true,
			severity = { vim.diagnostic.severity.ERROR, vim.diagnostic.severity.WARN }, -- Show errors & warnings everywhere but info & hints only on the cursor line
		},
	},
})
