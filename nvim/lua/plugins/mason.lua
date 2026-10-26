-- | mason.nvim | --
local mason = require("mason")
mason.setup({
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

-- | mason-registry | --
local mason_registry = require("mason-registry")
local packages = {
	"stylelint-language-server",
	"ansible-lint",
	"prettier",
	"prettierd",
	"biome",
}
-- Auto-install mason packages
mason_registry.refresh(function()
	for _, name in ipairs(packages) do
		local pkg = mason_registry.get_package(name)
		if not pkg:is_installed() then
			pkg:install()
		end
	end
end)
