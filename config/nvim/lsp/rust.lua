local function validate_bufnr(bufnr)
  return bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr
end

local function path_is_descendant(parent, child)
  parent = vim.fs.normalize(parent)
  child = vim.fs.normalize(child)
  return string.find(child, parent, 1, true) == 1
end

local function reload_workspace(bufnr)
  bufnr = validate_bufnr(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'rust_analyzer' })
  for _, client in ipairs(clients) do
    vim.notify('Reloading Cargo Workspace')
    client.request('rust-analyzer/reloadWorkspace', nil, function(err)
      if err then
        error(tostring(err))
      end
      vim.notify('Cargo workspace reloaded')
    end, 0)
  end
end

local function is_library(fname)
  local user_home = vim.fs.normalize(vim.env.HOME)
  local cargo_home = os.getenv('CARGO_HOME') or user_home .. '/.cargo'
  local registry = cargo_home .. '/registry/src'
  local git_registry = cargo_home .. '/git/checkouts'

  local rustup_home = os.getenv('RUSTUP_HOME') or user_home .. '/.rustup'
  local toolchains = rustup_home .. '/toolchains'

  for _, item in ipairs({ toolchains, registry, git_registry }) do
    if path_is_descendant(item, fname) then
      local clients = vim.lsp.get_clients({ name = 'rust_analyzer' })
      return #clients > 0 and clients[#clients].config.root_dir or nil
    end
  end
end

local function find_root_pattern(patterns, fname)
  for _, pattern in ipairs(type(patterns) == 'table' and patterns or { patterns }) do
    local found = vim.fs.find(pattern, {
      path = vim.fs.dirname(fname),
      upward = true,
    })
    if #found > 0 then
      return vim.fs.dirname(found[1])
    end
  end
end

return {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local reused_dir = is_library(fname)
    if reused_dir then
      on_dir(reused_dir)
      return
    end

    local cargo_crate_dir = find_root_pattern('Cargo.toml', fname)
    local cargo_workspace_root

    if not cargo_crate_dir then
      on_dir(find_root_pattern('rust-project.json', fname) or find_root_pattern('.git', fname))
      return
    end

    local cmd = {
      'cargo',
      'metadata',
      '--no-deps',
      '--format-version',
      '1',
      '--manifest-path',
      cargo_crate_dir .. '/Cargo.toml',
    }

    vim.system(cmd, { text = true }, function(output)
      if output.code == 0 then
        if output.stdout then
          local result = vim.json.decode(output.stdout)
          if result['workspace_root'] then
            cargo_workspace_root = vim.fs.normalize(result['workspace_root'])
          end
        end
        on_dir(cargo_workspace_root or cargo_crate_dir)
      else
        vim.notify(
          ('[rust_analyzer] cmd failed with code %d: %s\n%s'):format(output.code, table.concat(cmd, ' '), output.stderr)
        )
      end
    end)
  end,
  before_init = function(init_params, config)
    if config.settings and config.settings['rust-analyzer'] then
      init_params.initializationOptions = config.settings['rust-analyzer']
    end
  end,
  on_attach = function()
    vim.api.nvim_buf_create_user_command(0, 'CargoReload', function()
      reload_workspace(0)
    end, { desc = 'Reload current cargo workspace' })
  end,
}
