return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  branch = "main", -- master(legacy) or main(new)
  build = ":TSUpdate",
  config = function()     
    -- parser insallations
    local treesitter = require("nvim-treesitter")
    treesitter.install({
      "awk",
      "bash",
      "c",
      "comment",
      "cpp",
      "css",
      "csv",
      "diff",
      "dockerfile",
      "editorconfig",
      "git_config",
      "git_rebase",
      "gitattributes",
      "gitcommit",
      "gitignore",
      "go",
      "gomod",
      "graphql",
      "html",
      "http",
      "hyprlang",
      "java",
      "javascript",
      "jinja",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "make",
      "php",
      "powershell",
      "prisma",
      "python",
      "ruby",
      "rust",
      "scheme",
      "scss",
      "sql",
      "ssh_config",
      "svelte",
      "swift",
      "terraform",
      "toml",
      "typescript",
      "tsx",
      "vim",
      "vimdoc",
      "xml",
      "yaml",
      "zsh"
    })
    
    -- options 
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        -- Enable treesitter highlighting and disable regex syntax
        pcall(vim.treesitter.start)
        -- Enable treesitter-based indentation
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
    
    -- parser registrations
    vim.treesitter.language.register("bash", "zsh")
  end,
}
