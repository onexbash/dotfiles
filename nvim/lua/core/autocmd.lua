-- Highlight on yank
autocmd("TextYankPost", {
	group = augroup("highlight_yank", { clear = true }),
	desc = "highlight selection on yank",
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = "IncSearch",
			timeout = 200,
		})
	end,
})

-- Restore cursor to file position in previous editing session
autocmd("BufReadPost", {
	callback = function(args)
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(args.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			vim.api.nvim_win_set_cursor(0, mark)
			-- defer centering slightly so it's applied after render
			vim.schedule(function()
				vim.cmd("normal! zz")
			end)
		end
	end,
})

-- Open help in vertical split
autocmd("FileType", {
	pattern = "help",
	command = "wincmd L",
})

-- Auto resize splits when the terminal's window is resized
autocmd("VimResized", {
	command = "wincmd =",
})

-- Syntax highlighting for dotenv files
autocmd("BufRead", {
	group = augroup("dotenv_ft", { clear = true }),
	pattern = { ".env", ".env.*" },
	callback = function()
		vim.bo.filetype = "dosini"
	end,
})

-- Remove plugins from disk that are no longer in vim.pack.add() specs
usercmd("PackClean", function()
	local inactive = vim.iter(vim.pack.get())
		:filter(function(x)
			return not x.active
		end)
		:map(function(x)
			return x.spec.name
		end)
		:totable()
	if #inactive == 0 then
		vim.notify("No inactive plugins to remove", vim.log.levels.INFO)
		return
	end
	vim.pack.del(inactive)
	vim.notify("Removed: " .. table.concat(inactive, ", "), vim.log.levels.INFO)
end, { desc = "Remove plugins not in vim.pack.add() specs" })

-- Auto-compile spell-file edits
autocmd("BufWritePost", {
	pattern = "*/spell/*.add",
	callback = function(args)
		vim.cmd("silent mkspell! " .. vim.fn.fnameescape(args.file))
	end,
})

-- Highlight references
vim.o.updatetime = 250 -- CursorHold delay in ms (default 4000 is too slow)

autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client or not client:supports_method("textDocument/documentHighlight") then
			return
		end

		local buf = args.buf
		local group = augroup("lsp_doc_highlight_" .. buf, { clear = true })

		autocmd({ "CursorHold", "CursorHoldI" }, {
			group = group,
			buffer = buf,
			callback = vim.lsp.buf.document_highlight,
		})
		autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
			group = group,
			buffer = buf,
			callback = vim.lsp.buf.clear_references,
		})
		autocmd("LspDetach", {
			group = group,
			buffer = buf,
			callback = function()
				vim.lsp.buf.clear_references()
				vim.api.nvim_del_augroup_by_id(group)
			end,
		})
	end,
})

set_hl(0, "LspReferenceText", { link = "Visual" })
set_hl(0, "LspReferenceRead", { link = "Visual" })
set_hl(0, "LspReferenceWrite", { link = "Visual", underline = true })
