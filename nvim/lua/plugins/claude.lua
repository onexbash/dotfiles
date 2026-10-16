-- | CONFIG | --
local claude = require("claudecode")
claude.setup({
	terminal = {
		split_side = "right",
		split_width_percentage = 0.50,
		provider = "snacks",
	},
})

-- | AUTOCMD | --
-- Push Claude-Code Windows to the right side
-- vim.api.nvim_create_autocmd("WinNew", {
-- 	callback = function()
-- 		local new = vim.api.nvim_get_current_win()
-- 		if vim.api.nvim_win_get_config(new).relative ~= "" then
-- 			return
-- 		end -- ignore floating windows
-- 		vim.schedule(function()
-- 			for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
-- 				local buf = vim.api.nvim_win_get_buf(win)
-- 				if vim.bo[buf].buftype == "terminal" and vim.api.nvim_buf_get_name(buf):match("claude") then
-- 					local width = vim.api.nvim_win_get_width(win)
-- 					vim.api.nvim_win_call(win, function()
-- 						if vim.fn.winnr() ~= vim.fn.winnr("l") then
-- 							vim.cmd("wincmd L")
-- 						end -- move only if not already far right
-- 					end)
-- 					vim.api.nvim_win_set_width(win, width)
-- 				end
-- 			end
-- 		end)
-- 	end,
-- })

-- | KEYMAPS | --
-- Toggle Window
keymap({ "n", "t" }, "<C-b>", "<CMD>ClaudeCode<CR>", { desc = "ClaudeCode: Toggle" })
keymap("n", "<leader>cc", "<cmd>ClaudeCodeContinue<CR>", { desc = "Claude: continue last session" })
