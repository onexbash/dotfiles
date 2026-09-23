-- | Setup | --
require("grug-far").setup({})

-- | Keymaps | --
vim.keymap.set("n", "<leader>frr", function()
	require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") }, transient = true })
end, { desc = "Find Replace: with word under cursor" })

vim.keymap.set("n", "<leader>fra", function()
	require("grug-far").open({ engine = "astgrep", transient = false })
end, { desc = "Find Replace: with astgrep engine" })

vim.keymap.set("x", "<leader>frv", function()
	require("grug-far").open({ visualSelectionUsage = "operate-within-range", transient = true })
end, { desc = "Find Replace: inside of visual selection" })
