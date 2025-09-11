return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod' },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' } },
  },
  keys = { -- Mapping to toggle DBUI
    { '<leader>db', '<cmd>DBUIToggle<CR>', desc = 'Toggle DBUI' },
  },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  init = function()
    -- ensure directories to save database files exist
    local db_dir = vim.fn.stdpath('data') .. '~/.ssh/db'
    local tmp_dir = vim.fn.stdpath('data') .. '~/.tmp'
    if vim.fn.isdirectory(db_dir) == 0 then
      vim.fn.mkdir(db_dir, 'p')
    end
    if vim.fn.isdirectory(tmp_dir) == 0 then
      vim.fn.mkdir(tmp_dir, 'p')
    end

    -- options: gbui
    vim.g.db_ui_show_help = 0
    vim.g.db_ui_win_position = 'right'
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_use_nvim_notify = 1

    -- This sets the location of the `connections.json` file, which includes the
    -- DB conection strings (plaintext passwords, do not track this file!)
    -- default location: `~/.local/share/db_ui`
    vim.g.db_ui_save_location = '~/Library/Mobile Documents/com~apple~CloudDocs/db-ui'
    vim.g.db_ui_save_location = "~/.ssh/db"
    vim.g.db_ui_tmp_query_location = "~/.tmp"

    vim.g.db_ui_hide_schemas = { 'pg_toast_temp.*' }
  end,
}
