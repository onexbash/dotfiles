local prettier_fmt = { "prettierd", "prettier", stop_after_first = true }
local eslint_prettier_fmt = { "prettierd", "eslint_d", stop_after_first = false }

return {
  -- mason-tool-installer.nvim
  {
    {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      dependencies = {
        "williamboman/mason.nvim",
      },
      opts = {
        ensure_installed = {
          "prettierd",
          "prettier",
          "eslint_d",
          "eslint",
          "shfmt",
          "stylua",
          "isort",
          "ruff",
          "clang-format",
          "ansible-lint",
          "terraform-ls", -- includes terraform fmt
          "taplo",
        },
        auto_update = true,
        run_on_start = true,
      },
    },
  },
  -- conform.nvim
  {
    "stevearc/conform.nvim",
    dependencies = { "WhoIsSethDaniel/mason-tool-installer.nvim" },
    event = { "BufWritePre", "BufNewFile" },
    cmd = { "ConformInfo" },
    init = function()
      -- set formatexpr for usage with 'gq{vim_motion}'
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
    opts = {
      formatters_by_ft = {
        -- prettier
        javascript = eslint_prettier_fmt,
        typescript = eslint_prettier_fmt,
        css = eslint_prettier_fmt,
        scss = eslint_prettier_fmt,
        html = eslint_prettier_fmt,
        json = eslint_prettier_fmt,
        yaml = eslint_prettier_fmt,
        -- shell
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
        -- lua
        lua = { "stylua" },
        -- python
        python = { "isort", "ruff_format" },
        -- rust
        rust = { "rustfmt" },
        -- go
        go = { "gofmt" },
        -- c/c++
        clang = { "clang-format" },
        -- ansible
        ansible = { "ansible-lint" },
        -- terraform
        terraform = { "terraform_fmt" },
        -- toml
        toml = { "taplo" },
        -- xml
        xml = { "xmllint" },
      },
      default_format_opts = {
        lsp_format = "prefer",
      },
      -- overwrite formatter defaults
      formatters = {
        shfmt = {
          append_args = { "-i", "2" },
        },
      },
      format_on_save = { timeout_ms = 500 },
    },
    keys = {
      {
        "<leader><CR>",
        function()
          require("conform").format({ async = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
  },
}
