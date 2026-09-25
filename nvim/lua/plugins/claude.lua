-- | CONFIG | --
local claude = require("claudecode")
claude.setup({
	terminal = {
		split_side = "right",
		split_width_percentage = 0.30,
		provider = "snacks",
	},
})

-- | KEYMAPS | --
local map = function(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { desc = "Claude: " .. desc })
end

map("n", "<leader>cc", "<cmd>ClaudeCode<cr>", "Toggle")
