-- | tuios-nvim-navigator | --
local tuios_navigator = require("tuios-nvim-navigator")
tuios_navigator.setup({
	keymaps = {
		left = "<A-h>",
		down = "<A-j>",
		up = "<A-k>",
		right = "<A-l>",
	},
})
