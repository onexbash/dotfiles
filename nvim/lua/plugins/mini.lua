-- enhanced, a and i keybinds
require("mini.ai").setup()

require("mini.align").setup()

-- auto pairs
require("mini.pairs").setup()

-- access to surround keymaps sa,sd,sc etc
require("mini.surround").setup()

-- icons
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons() -- Let mini.icons pretend to be nvim-devicons to work where it's not supported

-- better jump capabilities
require("mini.jump").setup()

-- git diff
require("mini.diff").setup({
	view = {
		style = "sign",
		signs = { add = "┃", change = "┃", delete = "┃" },
	},
})

-- toggle formatting of brackets
require("mini.splitjoin").setup({
	mappings = {
		toggle = "<leader>m",
	},
})
