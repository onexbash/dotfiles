-- Parser List
local parsers = {
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
	"zsh",
}

-- Configuration (setup)
local treesitter = require("nvim-treesitter")
treesitter.setup({
	install_dir = vim.fn.stdpath("data") .. "/site",
})

-- Parser Installation
local installed = require("nvim-treesitter.config").get_installed()
treesitter.install(vim.iter(parsers)
	:filter(function(parser)
		return not vim.tbl_contains(installed, parser)
	end)
	:totable())

-- Autocmd: Enable Indentation
autocmd("FileType", {
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
		vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})

autocmd("PackChanged", {
	desc = "Update Tree-sitter parsers after plugin updates",
	group = augroup("nvim_treesitter_update", { clear = true }),
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
			vim.cmd("TSUpdate")
		end
	end,
})
