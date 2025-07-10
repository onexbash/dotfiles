return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  event = { 'VimEnter' },
  cmd = { 'Telescope' },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'folke/todo-comments.nvim',
    'BurntSushi/ripgrep',
    'nvim-treesitter/nvim-treesitter',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
  },
  config = function()
    local telescope = require('telescope')
    telescope.setup({
      defaults = {
        layout_config = {
          center = { width = 1 },
        },
      },
      pickers = {
        find_files = {
          theme = 'dropdown',
        },
      },
      mappings = {
        n = {
          ['<C-Bsp>'] = 'delete_buffer',
        },
      },
    })
  end,
  keys = {
    -- fuzy find files in cwd
    {
      '<leader>ff',
      function()
        require('telescope.builtin').find_files()
      end,
      mode = { 'v', 'n' },
      desc = 'telescope: find files',
    },
    -- live grep in cwd
    {
      '<leader>fg',
      function()
        require('telescope.builtin').live_grep()
      end,
      mode = { 'v', 'n' },
      desc = 'telescope: live grep',
    },
    -- list open buffers
    {
      '<leader>fb',
      function()
        require('telescope.builtin').buffers()
      end,
      mode = { 'v', 'n' },
      desc = 'telescope: list open buffers',
    },
    -- find document symbols (string, variable, object, constant, ..)
    {
      '<leader>fs',
      function()
        require('telescope.builtin').lsp_document_symbols()
      end,
      mode = { 'v', 'n' },
      desc = 'telescope: document symbols',
    },
    -- list available help tags
    {
      '<leader>fh',
      function()
        require('telescope.builtin').help_tags()
      end,
      mode = { 'v', 'n' },
      desc = 'telescope: help tags',
    },
  },
}
