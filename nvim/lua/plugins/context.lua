-- | -- | FUNCTION CONTEXT DISPLAY | -- | --
return {
  "nvim-treesitter/nvim-treesitter-context",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    enable = true,
    multiwindow = false,
  },
}
