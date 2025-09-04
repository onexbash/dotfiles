vim.filetype.add({
  extension = {
    bash = 'bash',
  },
  pattern = {
    ['.*'] = function(path, bufnr)
      -- Read the first line (shebang)
      local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ''
      if first_line:match('#!.*bash') then
        return 'bash'
      end
    end,
  },
})
