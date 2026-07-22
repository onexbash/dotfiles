return {
  "stevearc/oil.nvim",
  lazy = false,
  version = "2.16.0",
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  keys = {
    {
      '<C-n>',
      function()
        require('oil').toggle_float()
      end,
    },
  },
  config = function()
    -- keymaps
    -- vim.keymap.set("n", "<C-n>", "<CMD>Oil<CR>", { desc = "Open File Explorer" })
    
    -- options
    require("oil").setup({
      default_file_explorer = true,
      columns = { 'icon' }, -- | icon | permissions | size | mtime
      buf_options = {
        buflisted = false,
        bufhidden = "hide",
      },
      win_options = {
        wrap = false,
        signcolumn = "no",
        cursorcolumn = false,
        foldcolumn = "0",
        spell = false,
        list = false,
        conceallevel = 3,
        concealcursor = "nvic",
      },
      delete_to_trash = true,
      skip_confirm_for_simple_edits = false,
      prompt_save_on_select_new_entry = true,
      cleanup_delay_ms = 2000,
      lsp_file_methods = {
        enabled = true, -- Enable/Disable LSP file operations
        timeout_ms = 1000,
        autosave_changes = "unmodified", -- autosave buffers updated with LSP operations
      },
      constrain_cursor = "name", -- cursor location (false | "name" | "editable")
      watch_for_changes = true, -- refresh on file change
      use_default_keymaps = false, -- clear default keymaps
      view_options = {
        show_hidden = true,
        -- Function to define what hidden_files are
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
    })
  end,
}
