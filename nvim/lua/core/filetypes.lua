-- Add Filetypes for my git config & ignore files
vim.filetype.add({
	pattern = {
		[".*/git/config"] = "gitconfig",
		[".*/git/gitignore"] = "gitignore",
	},
})
