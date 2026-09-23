local conform = require("conform")

local fmt_web = { "biome", "prettierd", "prettier", stop_after_first = true }
local fmt_sql = { "sql_formatter", "sqlfmt", stop_after_first = true }

conform.setup({
  format_on_save = {
	  timeout_ms = 5000,
		lsp_format = "fallback",
	},
  formatters_by_ft = {
		lua = { "stylua" },
    go = { "goimports", "gofumpt" },
    sql = { fmt_sql },
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
	},
  formatters = {
    biome = { require_cwd = true },
    prettierd = { require_cwd = true },
		sql_formatter = {
			prepend_args = { "--language", "postgresql" },
		},
	},
})


