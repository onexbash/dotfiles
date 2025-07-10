vim.filetype.add({
  extension = {
    yml = function(path, bufnr)
      local dir = vim.fs.dirname(path)
      while dir ~= nil and dir ~= '/' do
        local cfg_path = dir .. '/ansible.cfg'
        local cfg_exists = vim.fn.filereadable(cfg_path) == 1
        if cfg_exists then
          return 'yaml.ansible'
        end
        dir = vim.fs.dirname(dir)
      end
      return 'yaml'
    end,
    yaml = function(path, bufnr)
      local dir = vim.fs.dirname(path)
      while dir ~= nil and dir ~= '/' do
        local cfg_path = dir .. '/ansible.cfg'
        local cfg_exists = vim.fn.filereadable(cfg_path) == 1
        if cfg_exists then
          return 'yaml.ansible'
        end
        dir = vim.fs.dirname(dir)
      end
      return 'yaml'
    end,
  },
})
