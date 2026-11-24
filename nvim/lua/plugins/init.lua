-- [FUNCTION] wrapper for vim.pack.add() to support dependencies
-- entries: a spec ({ src = ... }) or { spec, dependencies = { spec, ... } }
local function pack_add(entries, opts)
	local resolved, seen = {}, {}

	local function push(entry)
		local spec, deps
		if entry.src then
			spec, deps = entry, entry.dependencies
		else
			spec, deps = entry[1], entry.dependencies
		end
		-- dependencies first, recursively
		for _, dep in ipairs(deps or {}) do
			push(dep)
		end
		if seen[spec.src] then
			return
		end
		seen[spec.src] = true
		local clean = vim.deepcopy(spec)
		clean.dependencies = nil
		table.insert(resolved, clean)
	end

	for _, entry in ipairs(entries) do
		push(entry)
	end
	vim.pack.add(resolved, opts)
end

-- | VERSIONING POLICY | --
-- * semver plugins (>= 1.0): r("N.*")   -> latest release within the current major
-- * 0.x plugins:             r("0.N.*") -> patch releases only (0.x minors may break)
-- * no releases:             branch     -> safety net = nvim-pack-lock.json + update review
-- Updates only happen via :lua vim.pack.update(). Commit nvim-pack-lock.json after
-- each successful update; bump a major range deliberately after reading the changelog.
local r = vim.version.range

-- | PLUGIN DEFINITIONS | --
local plugins = {
	-- [colorscheme]
	catppuccin = { src = "https://github.com/catppuccin/nvim", name = "catppuccin", version = "main" },
	-- [treesitter]
	nvim_treesitter = { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	nvim_ts_autotag = { src = "https://github.com/windwp/nvim-ts-autotag", version = "main" },
	-- [LSP]
	nvim_lspconfig = { src = "https://github.com/neovim/nvim-lspconfig", version = r("2.*") },
	mason = { src = "https://github.com/mason-org/mason.nvim", version = r("2.*") },
	mason_lspconfig = { src = "https://github.com/mason-org/mason-lspconfig.nvim", version = r("2.*") },
	otter = { src = "https://github.com/jmbuhr/otter.nvim", version = r("2.*") },
	-- [UTILS]
	mini = { src = "https://github.com/nvim-mini/mini.nvim", version = "stable" },
	snacks = { src = "https://github.com/folke/snacks.nvim", version = r("2.*") },
	-- [auto-complete / indent-guides / auto-pairs]
	blink_lib = { src = "https://github.com/saghen/blink.lib", version = "main" },
	blink_cmp = { src = "https://github.com/saghen/blink.cmp", version = r("1.*") },
	blink_indent = { src = "https://github.com/saghen/blink.indent", version = r("2.*") },
	blink_pairs = { src = "https://github.com/saghen/blink.pairs", version = r("0.7.*") },
	friendly_snippets = { src = "https://github.com/rafamadriz/friendly-snippets", version = "main" },
	-- [Formatter]
	conform = { src = "https://github.com/stevearc/conform.nvim", version = "master" },
	-- [Filetree]
	oil = { src = "https://github.com/stevearc/oil.nvim", version = r("2.*") },
	-- [Find & Replace] (needs the `rg` binary: brew install ripgrep)
	grug_far = { src = "https://github.com/MagicDuck/grug-far.nvim", version = r("1.*") },
	-- [Diagnostics]
	tiny_inline_diagnostic = { src = "https://github.com/rachartier/tiny-inline-diagnostic.nvim", version = "main" },
	workspace_diagnostics = { src = "https://github.com/artemave/workspace-diagnostics.nvim", version = "main" },
	trouble = { src = "https://github.com/folke/trouble.nvim", version = r("3.*") },
	-- [screenshots]
	codesnap = { src = "https://github.com/mistricky/codesnap.nvim", version = r("2.*") },
	-- [AI]
	claudecode = { src = "https://github.com/coder/claudecode.nvim", version = r("0.3.*") },
	-- [markdown]
	render_markdown = { src = "https://github.com/meanderingprogrammer/render-markdown.nvim", version = r("8.*") },
	-- [tuios]
	tuios_navigator = { src = "https://github.com/Tim4c/tuios-nvim-navigator", version = "main" },
}

-- fail loudly on typos like `plugins.mason`
setmetatable(plugins, {
	__index = function(_, name)
		error("pack_add: unknown plugin '" .. name .. "'", 2)
	end,
})

-- | PLUGIN INSTALLATIONS | --
pack_add({
	-- catppuccin
	plugins.catppuccin,
	-- nvim-treesitter
	plugins.nvim_treesitter,
	{ plugins.nvim_ts_autotag, dependencies = { plugins.nvim_treesitter } },
	{ plugins.mason_lspconfig, dependencies = { plugins.mason, plugins.nvim_lspconfig } },
	-- mini.nvim
	plugins.mini,
	-- snacks.nvim
	plugins.snacks,
	-- blink.cmp
	{ plugins.blink_cmp, dependencies = { plugins.blink_lib, plugins.friendly_snippets } },
	-- blink.indent
	plugins.blink_indent,
	-- blink.pairs
	{ plugins.blink_pairs, dependencies = { plugins.blink_lib } },
	-- conform.nvim
	plugins.conform,
	-- oil.nvim
	{ plugins.oil, dependencies = { plugins.mini } },
	-- grug-far.nvim
	{ plugins.grug_far, dependencies = { plugins.mini } },
	-- tiny-inline-diagnostic.nvim
	plugins.tiny_inline_diagnostic,
	-- workspace-diagnostics.nvim
	plugins.workspace_diagnostics,
	-- trouble.nvim
	plugins.trouble,
	-- codesnap
	plugins.codesnap,
	-- claudecode.nvim
	{ plugins.claudecode, dependencies = { plugins.snacks } },
	-- render-markdown.nvim
	{ plugins.render_markdown, dependencies = { plugins.nvim_treesitter, plugins.mini } },
	-- tuios-nvim-navigator
	plugins.tuios_navigator,
})

-- | PLUGIN CONFIGS | --
require("plugins.colorscheme")
require("plugins.treesitter")
require("plugins.mason")
require("plugins.lsp")
-- require("plugins.snippets")
require("plugins.blink")
require("plugins.autocmp")
require("plugins.format")
require("plugins.oil")
require("plugins.mini")
require("plugins.snacks")
-- require("plugins.notify")
require("plugins.find_replace")
require("plugins.diagnostics")
require("plugins.codesnap")
require("plugins.claude")
require("plugins.markdown")
require("plugins.tuios")
