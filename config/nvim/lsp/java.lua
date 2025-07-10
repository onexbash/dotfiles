-- detect operating system because java-language-server has multiple versions per OS
local os = nil
if vim.uv.os_uname().sysname == 'Darwin' then
  os = 'mac'
end
if vim.uv.os_uname().sysname == 'Linux' then
  os = 'linux'
end
if vim.uv.os_uname().sysname == 'Windows_NT' then
  os = 'windows'
end

return {
  cmd = vim.fn.stdpath('data') .. '/mason/packages/java-language-server/dist/lang_server_' .. os .. '.sh',
  filetypes = { 'java' },
  root_markers = { 'build.gradle', 'build.gradle.kts', 'pom.xml', '.git' },
  settings = {},
}
