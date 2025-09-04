return {
  'folke/trouble.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  cmd = 'Trouble',
  opts = {
    modes = {
      preview_float = {
        mode = 'diagnostics',
        preview = {
          type = 'float',
          relative = 'editor',
          border = 'rounded',
          title = 'Preview',
          title_pos = 'center',
          position = { 0, -2 },
          size = { width = 0.3, height = 0.3 },
          zindex = 200,
        },
      },
      lsp = {
        win = { position = 'right' },
        filter = {
          ['not'] = { severity = vim.diagnostic.severity.INFO },
        },
      },
    },
  },
  keys = {
    {
      '<leader>xx',
      function()
        require('trouble').toggle('diagnostics')
      end,
      desc = 'trouble: diagnostics',
    },
    {
      '<leader>xr',
      function()
        require('trouble').toggle('lsp_references')
      end,
      desc = 'trouble: references',
    },
    {
      '<leader>xd',
      function()
        require('trouble').toggle('lsp_definitions')
      end,
      desc = 'trouble: definitions',
    },
    {
      '<leader>xc',
      function()
        require('trouble').toggle('lsp_declarations')
      end,
      desc = 'trouble: declarations',
    },
    {
      '<leader>xt',
      function()
        require('trouble').toggle('lsp_type_definitions')
      end,
      desc = 'trouble: type definitions',
    },
    {
      '<leader>xs',
      function()
        require('trouble').toggle('symbols')
      end,
      desc = 'trouble: symbols',
    },
  },
}
