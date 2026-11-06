local M = {}

-- Check if a .toml file is a mise file
function M.is_mise_file(path)
	local filepath = vim.fs.normalize(path)
	local filename = vim.fn.fnamemodify(filepath, ":t")
	return filename:match("^%.?mise.*%.toml$") ~= nil
		or filepath:match("/%.?mise/config%.toml$") ~= nil
		or filepath:match("/%.?mise/config%.local%.toml$") ~= nil
		or filepath:match("/%.?mise/config%.[^/]+%.toml$") ~= nil
		or filepath:match("/%.config/mise/mise%.toml$") ~= nil
		or filepath:match("/%.config/mise/mise%.local%.toml$") ~= nil
		or filepath:match("/%.?mise/conf%.d/[^/]+%.toml$") ~= nil
end

return M
