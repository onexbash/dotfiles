-- |   USER COMMANDS   | --

-- VIM PACK
-- names of all installed plugins (for command-line completion)
local function complete(arglead)
	local names = vim.tbl_map(function(p)
		return p.spec.name
	end, vim.pack.get())
	return vim.tbl_filter(function(name)
		return vim.startswith(name, arglead)
	end, names)
end

-- VIM Pack: Info
usercmd("Pack", function(o)
	vim.pack.update(nil, { offline = o.bang })
end, { bang = true, desc = "VIM-Pack: Show Plugin Info" })

-- VIM Pack: Update
usercmd("PackUpdate", function(o)
	vim.pack.update(#o.fargs > 0 and o.fargs or nil, { force = true })
end, { nargs = "*", complete = complete, desc = "VIM-Pack: Update installed Plugins" })

-- -- | VIM PACK | --
-- -- Update installed Plugins
-- usercmd("PackUpdate", function(o)
-- 	vim.pack.update(#o.fargs > 0 and o.fargs or nil)
-- end, { nargs = "*", desc = "Review and apply plugin updates" })
--
-- -- Show installed Plugins
-- usercmd("PackStatus", function()
-- 	vim.pack.update(nil, { offline = true })
-- end, { desc = "Show installed plugin revisions" })
