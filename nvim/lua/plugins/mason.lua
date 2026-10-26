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
local registry = require("mason-registry")
local packages = {
	"stylelint-language-server",
	"ansible-lint",
	"prettier",
	"prettierd",
	"biome",
}
-- Auto-install mason packages
registry.refresh(function()
	for _, name in ipairs(packages) do
		local pkg = registry.get_package(name)
		if not pkg:is_installed() then
			pkg:install()
		end
	end
end)

-- Auto-Update installed packages
local function update_mason_packages()
	registry.refresh(function()
		for _, pkg in ipairs(registry.get_installed_packages()) do
			local installed = pkg:get_installed_version()
			local latest = pkg:get_latest_version()
			if installed and latest and installed ~= latest and not pkg:is_installing() then
				pkg:once("install:success", function()
					vim.schedule(function()
						vim.notify(("mason: updated %s %s → %s"):format(pkg.name, installed, latest))
					end)
				end)
				pkg:once("install:failed", function()
					vim.schedule(function()
						vim.notify("mason: failed to update " .. pkg.name, vim.log.levels.ERROR)
					end)
				end)
				pkg:install()
			end
		end
	end)
end

-- Usercmd for Auto-Updating
usercmd("MasonUpdateAll", update_mason_packages, {
	desc = "Update all outdated Mason packages",
})

-- Run Auto-Update Function on nvim startup
autocmd("VimEnter", {
	group = augroup("MasonAutoUpdate", { clear = true }),
	once = true,
	desc = "Update all outdated Mason packages on startup",
	callback = function()
		update_mason_packages()
	end,
})
