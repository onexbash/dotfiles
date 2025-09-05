-- -- -- -- -- -- --
--   LAZY.NVIM    --
-- -- -- -- -- -- --
--                --
--  installation  --
local lazy_data_dir = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazy_data_dir) then
  local lazy_repo_url = "https://github.com/folke/lazy.nvim.git"
  local release_tag = "stable"
  -- pass release tag to git clone cmd (--branch accepts release tags)
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=" .. release_tag, lazy_repo_url, lazy_data_dir })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "ERROR: failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazy_data_dir)

--    setup     --
require("lazy").setup({ { import = "plugins" } }, {
  defaults = {
    version = "*", -- latest stable version if semantic versioning is supported
    lazy = false, -- lazy loading enabled on all plugins unless specifically turned off
  },
  install = {
    colorscheme = { "catppuccin" },
  },
  ui = {
    size = { width = 0.8, height = 0.8 },
    border = "single",
  },
  checker = {
    enabled = true,
  },
  change_detection = {
    enabled = true,
    notify = false, -- disable notification on nvim config change
  },
  performance = {
    rtp = {
      -- disable builtin nvim plugins (e.g: netrw)
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
        "netrwPlugin",
      },
    },
  },

})
