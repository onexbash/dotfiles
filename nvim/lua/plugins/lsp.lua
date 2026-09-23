-- mason.nvim
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

-- mason-lspconfig.nvim
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
		"stylelint_lsp",
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
		"markdown_oxide",
		"harper_ls",
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

-- Installed outside Mason (toolchain/project-local)
vim.lsp.enable({
	"rust_analyzer", -- Use 'rustup component add rust-analyzer' to install
	"tsc", -- TypeScript 7 from the project's node_modules
})
