return {
  cmd = { 'gitlab-ci-ls' },
  filetypes = { 'yaml.gitlab' },
  root_markers = { '.gitlab*', '.git' },
  init_options = {
    cache_path = '/home/runner/.cache/gitlab-ci-ls/',
    log_path = '/home/runner/.cache/gitlab-ci-ls//log/gitlab-ci-ls.log',
  },
}
