return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  init = function()
    vim.treesitter.language.register("bash", "dotenv") -- assign bash parser to dotenv files (.env.*)
  end,
  config = function()
    local ts_config = require("nvim-treesitter.configs")
    ts_config.setup({
      sync_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
      },
      indent = {
        enable = true,
      },
      ensure_installed = {
        "awk",
        "bash",
        "c",
        "c_sharp",
        "cpp",
        "css",
        "csv",
        "diff", -- git diff
        "dockerfile",
        "editorconfig",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "go", -- golang
        "gomod", -- golang module files
        "gosum", -- golang checksum files
        "gotmpl", -- golang template files
        "gowork", -- golang workspace files
        "gpg",
        "graphql",
        "html",
        "ini", -- .ini config files
        "java",
        "javascript",
        "jq",
        "json",
        "jsonc", -- json with comments
        "llvm",
        "latex",
        "lua",
        "make",
        "markdown",
        "markdown_inline",
        "pem", -- .pem certificate files
        "php",
        "powershell",
        "prisma",
        "properties",
        "python",
        "regex",
        "requirements", -- python requirements.txt
        "rust",
        "scss",
        "sql",
        "ssh_config",
        "svelte",
        "swift",
        "terraform",
        "tsx",
        "typescript",
        "vim", -- vimrc files
        "vue", -- vue.js
        "xml",
        "yaml",
      },
    })
  end,
}
