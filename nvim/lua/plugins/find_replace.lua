-- | -- | FIND & REPLACE (grug-far) | -- | --

-- | OPTIONS | --
vim.opt.inccommand = "split"
vim.opt.grepprg = "rg --vimgrep --smart-case"
vim.opt.grepformat = "%f:%l:%c:%m"

-- | CONFIGURATION | --
local grug_far = require("grug-far")
grug_far.setup({})

-- | EDITORCOMMAND | --
-- Set "FindReplace" as Editorcommand for grug-far
usercmd("FindReplace", function(opts)
	local prefills = opts.args ~= "" and { search = opts.args } or nil
	require("grug-far").open({ prefills = prefills })
end, { nargs = "?", desc = "Search & Replace (project)" })

-- | KEYMAPS | --
-- [<leader>frr]: Find & Replace as quick action via built-in editorcommand (buffer-wide)
keymap({ "n", "x" }, "<leader>frr", function()
	-- Auto-detects: [multi-line selection | single-line selection | word-under-cursor | standard]
	local mode = vim.fn.mode()
	if mode:match("[vV\22]") then
		if mode == "\22" then
			-- Block-wise: \%V keeps matches inside the selected columns
			return [[:s/\%V//gI<Left><Left><Left><Left>]]
		elseif mode == "V" or vim.fn.line("v") ~= vim.fn.line(".") then
			-- Line-wise / multi-line: the range alone limits it to the selected lines
			return [[:s///gI<Left><Left><Left><Left>]]
		end
		-- Single-line: selection becomes the literal search term
		return [["zy:%s/\V<C-r>=substitute(escape(@z, '/\'), "\n", '\\n', 'g')<CR>//gI<Left><Left><Left>]]
	elseif vim.fn.expand("<cword>") ~= "" then
		return [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]
	else
		return [[:%s///gI<Left><Left><Left><Left>]]
	end
end, { expr = true, desc = "Find & Replace: Current File (selection / word / empty)" })

-- [<leader>frw]: Find & Replace workspace-wide
keymap("n", "<leader>frw", function()
	local root = vim.fs.root(0, ".git") or vim.fn.getcwd()
	require("grug-far").open({ prefills = { paths = root } })
end, { desc = "Find & Replace: Workspace-Wide" })

-- [<leader>frc]: Find & Replace with current word under the cursor
keymap("n", "<leader>frc", function()
	require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
end, { desc = "Find & Replace: Current Word under Cursor" })

-- [<leader>fra]: Find & Replace with ast-grep engine
keymap("n", "<leader>fra", function()
	require("grug-far").open({ engine = "astgrep" })
end, { desc = "Find & Replace: Ast-Grep Engine" })

-- [<leader>frf]: Find & Replace in current file only
keymap("n", "<leader>frf", function()
	require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
end, { desc = "Find & Replace: Current File only" })

-- [<leader>frv]: Find & Replace in visual selection
keymap({ "n", "x", "v" }, "<leader>frv", function()
	require("grug-far").open({ visualSelectionUsage = "operate-within-range" })
end, { desc = "Find & Replace: Visual Selection" })
