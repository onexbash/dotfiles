-- -- -- -- -- -- -- -- -- -- -- -- --
--   FUNCTION COLLECTION TO REUSE   --
-- -- -- -- -- -- -- -- -- -- -- -- --
local M = {}
-- add mason bin directory to $PATH variable for the current nvim session
M.add_mason_to_path = function()
  vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin" .. ":" .. vim.env.PATH
end

return M
