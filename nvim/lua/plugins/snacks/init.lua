local snacks = require("snacks")
snacks.setup({
	lazygit = {
		enabled = true,
	},
	picker = require("plugins.snacks.picker"),
	explorer = {
		enabled = true,
		replace_netrw = true,
		trash = true,
	},
	dashboard = require("plugins.snacks.dashboard"),
})

-- | LAZYGIT | --
-- Open Lazygit
vim.keymap.set("n", "<leader>lg", function()
	Snacks.lazygit()
end, { desc = "Snacks: Open Lazygit" })

-- | EXPLORER | --
vim.keymap.set({ "n", "v" }, "<C-n>", function()
	Snacks.explorer()
end, { desc = "Snacks: Open File Explorer" })
