return {
  'mistricky/codesnap.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  build = 'make build_generator',
  keys = {
    -- take screenshot & save
    {
      '<leader>cs',
      '<cmd>CodeSnapSave<cr>',
      mode = 'v',
      desc = 'codesnap  take screenshot & save',
    },
    -- take screenshot & copy to clipboard
    {
      '<leader>cc',
      function()
        require('codesnap').copy_into_clipboard()
      end,
      mode = 'v',
      desc = 'codesnap  take screenshot & copy to clipboard',
    },
    -- take ascii screenshot & copy to clipboard
    {
      '<leader>ca',
      '<cmd>CodeSnapASCII<cr>',
      mode = { 'v', 'n' },
      desc = 'codesnap  take ascii screenshot & copy to clipboard',
    },
  },
  opts = {
    bg_padding = 0,
    -- bg_x_padding = 122,
    -- bg_y_padding = 82,
    mac_window_bar = false,
    title = 'CodeSnap.nvim',
    code_font_family = 'Hurmit Nerd Font',
    watermark_font_family = 'Pacifico',
    watermark = '',
    bg_theme = 'default',
    breadcrumbs_separator = '/',
    has_breadcrumbs = false,
    has_line_number = true,
    show_workspace = false,
    min_width = 0,
    save_path = vim.env.XCLOUD .. '/media/images/screenshots/codesnap',
  },
}
