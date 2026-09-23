vim.api.nvim_create_autocmd("PackChanged", {
	group = vim.api.nvim_create_augroup("pack_build", { clear = true }),
	callback = function(ev)
		local d = ev.data
		if d.spec.name ~= "telescope-fzf-native.nvim" then
			return
		end
		if d.kind ~= "install" and d.kind ~= "update" then
			return
		end

		local res = vim.system({ "make" }, { cwd = d.path }):wait()
		if res.code ~= 0 then
			vim.notify("fzf-native build failed:\n" .. res.stderr, vim.log.levels.ERROR)
		end
	end,
})

vim.pack.add({
	-- Colorscheme
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin", version = "main" },
	-- Mini
	{ src = "https://github.com/nvim-mini/mini.nvim", version = "main" },
	{ src = "https://github.com/nvim-mini/mini.icons", version = "main" },
	-- Tree-sitter
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	-- LSP
	{ src = "https://github.com/neovim/nvim-lspconfig", version = "v2.12.0" },
	{ src = "https://github.com/mason-org/mason.nvim", version = "v2.3.1" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim", version = "v2.3.0" },
	-- Snippets
	{ src = "https://github.com/rafamadriz/friendly-snippets", version = "main" },
	-- Auto-Complete
	{ src = "https://github.com/saghen/blink.cmp", version = "v1.10.2" },
	-- Formatter
	{ src = "https://github.com/stevearc/conform.nvim", version = "master" },
	-- Filetree
	{ src = "https://github.com/stevearc/oil.nvim", version = "v2.16.0" },
	{ src = "https://github.com/refractalize/oil-git-status.nvim", version = "main" },
	-- Find & Replace
	{ src = "https://github.com/MagicDuck/grug-far.nvim", version = "1.6.78" },
	{ src = "https://github.com/BurntSushi/ripgrep", version = "15.2.0" },
	-- Dashboard
	{ src = "https://github.com/nvimdev/dashboard-nvim", version = "master" },
	-- Telescope
	{ src = "https://github.com/nvim-telescope/telescope.nvim", version = "v0.2.1" },
	{ src = "https://github.com/nvim-lua/plenary.nvim", version = "master" },
	{ src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim", version = "main" },
	-- Diagnostics
	{ src = "https://github.com/rachartier/tiny-inline-diagnostic.nvim", version = "main" },
	-- Codesnap
	{ src = "https://github.com/mistricky/codesnap.nvim", version = "v2.1.1" },
	-- { src = "", version = "" },
})

require("plugins.colorscheme")
require("plugins.treesitter")
require("plugins.lsp")
-- require("plugins.snippets")
require("plugins.autocmp")
require("plugins.format")
require("plugins.oil")
require("plugins.mini")
require("plugins.statusline")
require("plugins.notify")
require("plugins.find_replace")
require("plugins.dashboard")
require("plugins.telescope")
require("plugins.diagnostics")
require("plugins.codesnap")
