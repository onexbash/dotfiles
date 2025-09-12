---@type vim.lsp.Config
return {
  cmd = { 'bash-language-server', 'start' },
  settings = {
    bashIde = {
      enableShellcheck = true,
      shellcheckArguments = {
        -- Exclude shellcheck rules
        "--exclude=SC1090", -- Disable warning when sourcing files at dynamic filepaths
        "--exclude=SC1091", -- -- Disable warning when checking binaries at dynamic filepaths
        "--exclude=SC2181", -- Disable warning for indirect exit-code checking with $?
      },
      -- Glob pattern for finding and parsing shell script files in the workspace.
      globPattern = vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.zsh|.command)', -- Default: "**/*@(.sh|.inc|.bash|.command)".
    },
  },
  filetypes = { "sh", "bash", "zsh" },
  root_markers = { '.git' },
}
