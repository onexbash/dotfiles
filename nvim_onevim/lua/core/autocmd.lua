local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local usercmd = vim.api.nvim_create_user_command

-- highlight on yank
autocmd("TextYankPost", {
  desc = "highlight on yank",
  group = augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Automatically Decode binary plist files
-- TODO: test if this breaks plist files that arent supposed to be encoded
local plist_group = vim.api.nvim_create_augroup("PlistAutoConvert", { clear = true })

local function is_binary_plist(path)
  local f = io.open(path, "rb")
  if not f then return false end
  local header = f:read(8)
  f:close()
  return header ~= nil and header:sub(1, 6) == "bplist"
end

-- Decode binary -> xml1 before nvim reads the file
vim.api.nvim_create_autocmd("BufReadPre", {
  group = plist_group,
  pattern = "*.plist",
  callback = function(args)
    local path = args.match
    if is_binary_plist(path) then
      vim.fn.system({ "plutil", "-convert", "xml1", path })
    end
  end,
})

-- Encode back to binary1 after nvim writes the file
vim.api.nvim_create_autocmd("BufWritePost", {
  group = plist_group,
  pattern = "*.plist",
  callback = function(args)
    vim.fn.system({ "plutil", "-convert", "binary1", args.match })
  end,
})
