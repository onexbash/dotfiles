return {
  cmd = { 'ansible-language-server', '--stdio' },
  filetypes = { 'yaml.ansible' },
  root_markers = { 'ansible.cfg', '.ansible-lint' },
  settings = {
    ansible = {
      ansible = {
        path = 'ansible',
      },
      executionEnvironment = {
        enabled = false,
      },
      python = {
        interpreterPath = 'python',
      },
      validation = {
        enabled = true,
        lint = {
          enabled = false, -- linting handled by nvim-lint
        },
      },
    },
  },
}
