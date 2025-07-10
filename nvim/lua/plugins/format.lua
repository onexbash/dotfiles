return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  opts = {
    -- default options
    default_format_opts = {
      lsp_format = 'fallback',
      timeout_ms = 2000,
      async = false, -- enabling could lead to problems
    },
    -- auto format on save
    format_on_save = {
      lsp_format = 'fallback',
      timeout_ms = 2000,
    },
    -- configure formatters
    formatters = {
      gawk = {},
      -- golang
      gofumpt = {},
      goimports = {},
      -- prettier
      prettier = {
        options = {
          ft_parsers = {
            --     javascript = "babel",
            --     javascriptreact = "babel",
            --     typescript = "typescript",
            --     typescriptreact = "typescript",
            --     vue = "vue",
            --     css = "css",
            --     scss = "scss",
            --     less = "less",
            --     html = "html",
            --     json = "json",
            --     jsonc = "json",
            --     yaml = "yaml",
            --     markdown = "markdown",
            --     ["markdown.mdx"] = "mdx",
            --     graphql = "graphql",
            --     handlebars = "glimmer",
          },
          -- Use a specific prettier parser for a file extension
          ext_parsers = {
            -- qmd = "markdown",
          },
        },
      },
      -- injected
      injected = {
        options = {
          -- Set to true to ignore errors
          ignore_errors = false,
          -- Map of treesitter language to filetype
          lang_to_ft = {
            bash = 'sh',
          },
          -- Map of treesitter language to file extension
          -- A temporary file name with this extension will be generated during formatting
          -- because some formatters care about the filename.
          lang_to_ext = {
            bash = 'sh',
            c_sharp = 'cs',
            elixir = 'exs',
            javascript = 'js',
            julia = 'jl',
            latex = 'tex',
            markdown = 'md',
            python = 'py',
            ruby = 'rb',
            rust = 'rs',
            teal = 'tl',
            typescript = 'ts',
          },
          lang_to_formatters = {},
        },
      },

      ruff_format = {}, -- python formatter
      ruff_fix = {}, -- python linter
      ruff_organize_imports = {}, -- python import organizer
      rustfmt = {}, -- rust
      -- shell formatter
      shfmt = {
        prepend_args = { '-i', '2' },
      },
      -- sql formatter & linter
      sqlfluff = {},
      -- lua formatter
      stylua = {
        args = {
          '--search-parent-directories',
          '--config-path',
          vim.env.XDG_CONFIG_HOME .. '/tools/formatter/stylua.toml',
          '-', -- tell stylua to read from stdin (required for conform)
        },
      },
      swiftformat = {}, -- swift formatter
      taplo = {}, -- toml formatter
      terraform_fmt = {},
    },
    -- set formatters by filetype
    formatters_by_ft = {
      ['_'] = { 'trim_whitespace' }, -- for filetypes that have no formatter configured
      awk = { 'gawk' },
      go = { 'gofumpt', 'goimports' },
      -- prettier
      javascript = { 'prettier', stop_after_first = true },
      javascriptreact = { 'prettier', stop_after_first = true },
      typescript = { 'prettier', stop_after_first = true },
      typescriptreact = { 'prettier', stop_after_first = true },
      html = { 'prettier', stop_after_first = true },
      json = { 'prettier', stop_after_first = true },
      python = { 'ruff_organize_imports', 'ruff_format', 'ruff_fix' },
      lua = { 'stylua' },
      sh = { 'shfmt' },
      bash = { 'shfmt' },
      zsh = { 'shfmt' },
      terraform = { 'terraform_fmt' },
    },
  },
  init = function()
    vim.o.formatexpr = 'v:lua.require\'conform\'.formatexpr()' -- format expression (idk for what)
  end,
  keys = {
    {
      '<leader>ff',
      function()
        require('conform').format({ async = true })
      end,
      mode = '',
      desc = 'Format buffer',
    },
  },
}
