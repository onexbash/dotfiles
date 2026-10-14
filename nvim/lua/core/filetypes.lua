-- | CUSTOM FILETYPES |

-- git config & git ignore
vim.filetype.add({
	pattern = {
		[".*/git/config"] = "gitconfig",
		[".*/git/gitignore"] = "gitignore",
	},
})

-- Azure CLI config
local azure_dir = vim.fs.normalize(vim.env.AZURE_CONFIG_DIR or "~/.azure")
vim.filetype.add({
	filename = {
		[azure_dir .. "/config"] = "dosini",
		[azure_dir .. "/clouds.config"] = "dosini",
		[azure_dir .. "/azuredevops/config"] = "dosini",
	},
})

-- Ansible-yaml
vim.filetype.add({
	pattern = {
		[".*%.ya?ml"] = function(path)
			if vim.fs.root(path, { "ansible.cfg", ".ansible-lint" }) then
				return "yaml.ansible"
			end
			return nil -- return nil to default to yaml
		end,
	},
})
