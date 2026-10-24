-- | mason.nvim | --
require("mason").setup({
	firewall = {
		enabled = true, -- enables the socket.dev firewall for mason pkg downloads
		auto_managed = true, -- if this is set to false, the sfw binary is required in $PATH
	},
	ui = {
		border = "single", -- single/double/rounded/solid/shadow/none
		backdrop = 60, -- transparency
		width = 0.8,
		height = 0.9,
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

-- Install Mason packages without a valid mason-lspconfig mapping
local registry = require("mason-registry")
registry.refresh(function()
	for _, name in ipairs({ "stylelint-language-server", "ansible-lint" }) do
		local pkg = registry.get_package(name)
		if not pkg:is_installed() then
			pkg:install()
		end
	end
end)

-- | mason-lspconfig.nvim | --
require("mason-lspconfig").setup({
	automatic_enable = {
		exclude = { "jdtls" }, -- started by nvim-jdtls (ftplugin/java.lua)
	},
	ensure_installed = {
		-- Shell
		"bashls",
		"hyprls",
		"powershell_es",
		"systemd_lsp",
		-- Python
		"basedpyright",
		"ruff",
		-- C/C++
		"clangd",
		"neocmake", -- or "cmake"
		-- Go
		"gopls",
		"golangci_lint_ls",
		"templ",
		-- TS/JS + Frameworks
		"ts_ls",
		-- "vtsls", -- TS ≤6, Svelte, tsserver plugins
		"eslint",
		"svelte",
		"graphql",
		"prismals",
		-- HTML/CSS
		"html",
		"superhtml",
		"emmet_language_server",
		"htmx",
		"cssls",
		"somesass_ls",
		"css_variables",
		"cssmodules_ls",
		"tailwindcss",
		-- Other languages
		"jdtls",
		"lua_ls",
		"stylua",
		"phpantom_lsp",
		"ruby_lsp",
		-- "scheme_langserver",
		"vimls",
		-- Config / Data
		"jsonls",
		"yamlls",
		"taplo",
		-- SQL
		"postgres_lsp",
		"sqls",
		"sqruff",
		-- Text
		"marksman",
		"typos_lsp",
		-- Container
		"dockerls",
		"docker_language_server",
		"ansiblels",
		-- IaC
		"terraformls",
		"tflint",
		"ms_terraform_lsp",
		-- CI/CD
		"gh_actions_ls",
		"gitlab_ci_ls",
		"azure_pipelines_ls",
		"zizmor", -- CI/CD Analysis
	},
})

-- | LSP Configurations | --
-- [FUNCTION] populate workspace diagnostics
local function workspace_diagnostics(client, bufnr)
	-- some clients support workspace diagnostics natively
	if client:supports_method("workspace/diagnostic", bufnr) then
		vim.lsp.buf.workspace_diagnostics({ client_id = client.id })
	else
		require("workspace-diagnostics").populate_workspace_diagnostics(client, bufnr)
	end
end

-- LSP: default (*)
vim.lsp.config("*", { on_attach = workspace_diagnostics })

-- LSP: typos_lsp
vim.lsp.config("typos_lsp", {
	init_options = {
		diagnosticSeverity = "Hint",
		config = vim.fn.stdpath("config") .. "/typos.toml",
	},
})

-- LSP: ts_ls
vim.lsp.config("ts_ls", {
	before_init = function(params, config)
		local root = config.root_dir
		if not root then
			return
		end
		-- add "typescript-svelte-plugin" if installed.
		local plugin_dir = vim.fs.joinpath(root, "node_modules", "typescript-svelte-plugin")
		if not vim.uv.fs_stat(plugin_dir) then
			return -- not a Svelte project (or plugin not installed): start ts_ls without it
		end

		params.initializationOptions = params.initializationOptions or {}
		params.initializationOptions.plugins = params.initializationOptions.plugins or {}
		table.insert(params.initializationOptions.plugins, {
			name = "typescript-svelte-plugin",
			location = root, -- tsserver resolves `name` from here via node_modules
		})
	end,
})

-- | Enable LSPs | --
-- | (installed outside of mason) | --
vim.lsp.enable({
	"rust_analyzer", -- Installed by rustup
	"stylelint_lsp",
})

-- | Merge custom on_attach functions with workspace_diagnostics | --
for _, name in ipairs({ "ts_ls", "svelte", "eslint" }) do
	local cfg = vim.lsp.config[name]
	local original = cfg and cfg.on_attach
	if original and original ~= workspace_diagnostics then
		vim.lsp.config(name, {
			on_attach = function(client, bufnr)
				original(client, bufnr)
				workspace_diagnostics(client, bufnr)
			end,
		})
	end
end
