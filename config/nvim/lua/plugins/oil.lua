return {
  'stevearc/oil.nvim',
  dependencies = { { 'echasnovski/mini.icons', opts = {} } },
  lazy = false,
  opts = {
    default_file_explorer = true,
    delete_to_trash = true, -- Move to trash instead of instantly deleting
    use_default_keymaps = false, -- clear default keymaps
    columns = { 'icon' }, -- | icon | permissions | size | mtime
    watch_for_changes = true, -- reload on file change
    constrain_cursor = "name", -- cursor position: false/editable/name
    lsp_file_methods = {
      enable = true, -- LSP file operations
      autosave_changes = "unmodified"
    },
    view_options = {
      show_hidden = true, -- Show hidden files (dotfiles)
      -- function to define what hidden_files are
      is_hidden_file = function(name)
        local m = name:match('^%.')
        return m ~= nil
      end,
      -- Function to define files to be always hidden
      is_always_hidden = function(name)
        -- always hidden: [..] [.Trash] [.DS_Store]
        if name == '..' or name == '.Trash' or name == '.DS_Store' then
          return true
        end
        return false
      end,
    },
    float = {
      max_width = 0.3, -- Values are percentages relative to window size
      max_height = 0,
      border = 'single',
      preview_split = 'left',
      split = 'botright',
      override = function(defaults)
        -- align to the right right
        defaults['col'] = vim.o.columns - defaults['width'] - 2

        return defaults
      end,
      get_win_title = function ()
        return "filetree"
      end,
      win_options = {
        colorcolumn = "",
        cursorcolumn = false,
      }
    },
    keymaps = {
      ['g?'] = { 'actions.show_help', desc = 'oil: show keymaps' },
      ['<CR>'] = { 'actions.select', desc = 'oil: open' },
      ['<C-s>'] = { 'actions.select', opts = { vertical = true }, desc = 'oil: open in vertical split' },
      ['<C-p>'] = { 'actions.preview', desc = 'oil: open in preview' },
      ['<C-q>'] = { 'actions.close', desc = 'oil: close' },
      ['<F5>'] = { 'actions.refresh', desc = 'oil: refresh' },
      ['<BS>'] = { 'actions.parent', desc = 'oil: go to parent directory' },
      ['<C-.>'] = { 'actions.open_cwd', desc = 'oil: open cwd' },
      ['<C-CR>'] = { 'actions.open_external', desc = 'oil: open with default app' },
      ['H'] = { 'actions.toggle_hidden', desc = 'oil: toggle hidden files' },
    },
  },
  keys = {
    {
      '<C-n>',
      function()
        require('oil').toggle_float()
      end,
    },
  },
}
