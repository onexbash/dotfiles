-- | SETUP FUNCTION | --
local render_markdown = require("render-markdown")
render_markdown.setup({
	enabled = true,
	completions = { lsp = { enabled = true } },
	file_types = { "markdown" },
})
keymap("n", "<leader>tm", "<cmd>RenderMarkdown toggle<CR>", { desc = "Markdown: toggle in-buffer render" })

-- | KEYMAPS | --
local preview_job
-- Toggle Markdown Preview
keymap("n", "<leader>mp", function()
	if preview_job then
		vim.fn.jobstop(preview_job)
		preview_job = nil
		return vim.notify("Markdown preview stopped")
	end
	local file = vim.api.nvim_buf_get_name(0)
	if vim.bo.filetype ~= "markdown" or file == "" then
		return vim.notify("Not a markdown file", vim.log.levels.WARN)
	end
	preview_job = vim.fn.jobstart({ "gh", "markdown-preview", "--dark-mode", file }, {
		on_exit = function()
			preview_job = nil
		end,
	})
end, { desc = "Markdown: toggle GitHub preview" })
