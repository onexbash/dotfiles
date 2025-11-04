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
          "prettier",
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
        typescript = { "eslint", "prettier", stop_after_first = true },
        typescriptreact = { "eslint", "prettier", stop_after_first = true },
        javascript = { "eslint", "prettier", stop_after_first = true },
        javascriptreact = { "eslint", "prettier", stop_after_first = true },
        css = { "eslint", "prettier", stop_after_first = true },
        scss = { "eslint", "prettier", stop_after_first = true },
        html = { "eslint", "prettier", stop_after_first = true },
        json = { "eslint", "prettier", stop_after_first = true },
        yaml = { "eslint", "prettier", stop_after_first = true },
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
