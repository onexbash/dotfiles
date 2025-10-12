local prettier_fmt = { "prettierd", "eslint_d" }
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
          -- prettier ecosystem
          "prettierd",
          "eslint_d",
          -- shell
          "shfmt",
          -- lua
          "stylua",
          -- python
          "isort",
          "ruff",
          -- rust (installed via rustup usually)
          -- "rustfmt", -- comment out, use rustup
          -- go (installed with go toolchain)
          -- "gofmt", -- comment out, comes with go
          -- c/c++
          "clang-format",
          -- ansible
          "ansible-lint",
          -- terraform
          "terraform-ls", -- includes terraform fmt
          -- toml
          "taplo",
          -- xml (comes with system, not in mason)
        },
        auto_update = false,
        run_on_start = true,
      },
    },
  },
  -- conform.nvim
  {
    "stevearc/conform.nvim",
    dependencies = { "WhoIsSethDaniel/mason-tool-installer.nvim" },
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    init = function()
      -- set formatexpr for usage with 'gq{vim_motion}'
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
    opts = {
      formatters_by_ft = {
        -- prettier
        javascript = prettier_fmt,
        typescript = prettier_fmt,
        css = prettier_fmt,
        scss = prettier_fmt,
        html = prettier_fmt,
        json = prettier_fmt,
        yaml = prettier_fmt,
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
