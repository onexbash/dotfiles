-- enhanced, a and i keybinds
require("mini.ai").setup()

require("mini.align").setup()

-- auto pairs
require("mini.pairs").setup()

-- surround words with vim motions
require("mini.surround").setup({
	mappings = {
		add = "sa", -- Add surrounding
		delete = "sd", -- Delete surrounding
		replace = "sr", -- Replace surrounding
		find = "sf", -- Find Surrounding (right)
		find_left = "sF", -- Find Surrounding (left)
		highlight = "sh", -- Highlight Surrounding
	},
	highlight_duration = 1000,
})

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

require("plugins.mini.statusline")
