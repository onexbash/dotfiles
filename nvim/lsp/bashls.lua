---@type vim.lsp.Config
return {
  cmd = { "bash-language-server", "start" },
  settings = {
    bashIde = {
      enableShellcheck = true,
      shellcheckArguments = {
        -- Disable shellcheck Rules
        "--exclude=SC1090", -- Warning when sourcing files at dynamic filepaths
        "--exclude=SC1091", -- -- Warning when checking binaries at dynamic filepaths
        "--exclude=SC2181", -- Warning for indirect exit-code checking with $?
        "--exclude=SC2028", -- Warning to use printf over echo for expanding escape sequences.
      },
      globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.zsh|.command|.env)", -- file extensions
    },
  },
  filetypes = { "sh", "bash", "zsh" },
  root_markers = { ".git" },
}
