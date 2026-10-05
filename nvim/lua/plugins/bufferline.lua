-- | BUFFERLINE | --

-- Configuration
local bufferline = require("bufferline")
bufferline.setup({})

-- Keymaps
keymap("n", "<Left>", function()
	require("bufferline").cycle(-1)
end, { desc = "bufferline  navigate tab (left)" })
keymap("n", "<Right>", function()
	require("bufferline").cycle(1)
end, { desc = "bufferline  navigate tab (right)" })
keymap("n", "<S-Left>", function()
	require("bufferline").move(-1)
end, { desc = "bufferline  move tab (left)" })
keymap("n", "<S-Right>", function()
	require("bufferline").move(1)
end, { desc = "bufferline  move tab (right)" })
keymap("n", "<S-Down>", function()
	require("bufferline").toggle_pin()
end, { desc = "bufferline  pin/unpin tab" })
keymap("n", "<leader>q", function()
	require("bufferline").unpin_and_close()
end, { desc = "bufferline  close tab" })
