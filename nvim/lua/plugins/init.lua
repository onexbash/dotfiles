vim.pack.add({
	-- Colorscheme
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin", version = "main" },
	-- Tree-sitter
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	-- LSP
	{ src = "https://github.com/neovim/nvim-lspconfig", version = "v2.12.0" },
	{ src = "https://github.com/mason-org/mason.nvim", version = "v2.3.1" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim", version = "v2.3.0" },
	-- Snippets
	{ src = "https://github.com/rafamadriz/friendly-snippets", version = "main" },
	-- Mini (Utility Collection)
	{ src = "https://github.com/nvim-mini/mini.nvim", version = "main" },
	-- Snacks (Utility Collection)
	{ src = "https://github.com/folke/snacks.nvim", version = "v2.31.0" },
	-- Auto-Complete
	{ src = "https://github.com/saghen/blink.cmp", version = "v1.10.2" },
	-- Formatter
	{ src = "https://github.com/stevearc/conform.nvim", version = "master" },
	-- Filetree
	--{ src = "https://github.com/stevearc/oil.nvim", version = "v2.16.0" },
	--{ src = "https://github.com/refractalize/oil-git-status.nvim", version = "main" },
	-- Find & Replace
	{ src = "https://github.com/MagicDuck/grug-far.nvim", version = "1.6.78" },
	{ src = "https://github.com/BurntSushi/ripgrep", version = "15.2.0" },
	-- Dashboard
	{ src = "https://github.com/nvimdev/dashboard-nvim", version = "master" },
	-- Diagnostics
	{ src = "https://github.com/rachartier/tiny-inline-diagnostic.nvim", version = "main" },
	-- Codesnap
	{ src = "https://github.com/mistricky/codesnap.nvim", version = "v2.1.1" },
	-- Claude Code
	{ src = "https://github.com/coder/claudecode.nvim", version = "v0.3.0" },
})

require("plugins.colorscheme")
require("plugins.treesitter")
require("plugins.lsp")
-- require("plugins.snippets")
require("plugins.autocmp")
require("plugins.format")
-- require("plugins.oil")
require("plugins.mini")
require("plugins.snacks")
require("plugins.notify")
require("plugins.find_replace")
require("plugins.dashboard")
require("plugins.diagnostics")
require("plugins.codesnap")
require("plugins.claude")
