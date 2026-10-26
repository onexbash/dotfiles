local conform = require("conform")

local fmt_web = { "biome", "prettierd", "prettier", stop_after_first = true }
local fmt_sql = { "sql_formatter", "sqlfmt", stop_after_first = true }
local fmt_yaml = { "prettierd", "prettier", stop_after_first = true }

conform.setup({
	format_on_save = {
		timeout_ms = 10000,
		lsp_format = "fallback",
	},
	formatters_by_ft = {
		lua = { "stylua" },
		go = { "goimports", "gofumpt" },
		sql = fmt_sql,
		graphql = fmt_web,
		javascript = fmt_web,
		javascriptreact = fmt_web,
		typescript = fmt_web,
		typescriptreact = fmt_web,
		json = fmt_web,
		svelte = fmt_web,
		css = fmt_web,
		html = fmt_web,
		rust = { "rustfmt", lsp_format = "fallback" },
		yaml = fmt_yaml,
		["yaml.ansible"] = fmt_yaml, -- fast on save; ansible-lint only via :AnsibleLintFix
	},
	formatters = {
		biome = { require_cwd = true },
		prettierd = { require_cwd = true },
		sql_formatter = {
			prepend_args = { "--language", "postgresql" },
		},
	},
})

-- Run ansible-lint's fixer manually, in the background so the editor doesn't freeze
vim.api.nvim_create_user_command("AnsibleLintFix", function()
	conform.format({
		formatters = { "ansible-lint" },
		timeout_ms = 120000,
		async = true,
	}, function(err)
		if err then
			vim.notify("ansible-lint: " .. err, vim.log.levels.WARN)
		else
			vim.notify("ansible-lint: done")
		end
	end)
end, { desc = "Format the current buffer with ansible-lint" })
