# Global instructions

## Rules
- Use the Read tool instead of cat to view file contents

## Tech Stack (when the project doesn't specify otherwise)
- Assume the latest stable version of a tool, language or library unless the project or the user pins one.
- Your knowledge may be older than the latest release: check the current version before you pin one (`pnpm view <pkg> version`, `go list -m -versions <module>`, `brew info <formula>`, `mise ls-remote <tool>`).

| Area | Use |
|---|---|
| Packages | Node: **pnpm** · System: **brew** · Devtools and runtimes: **mise** (`mise.toml`) |
| Web apps | **SvelteKit v3+** + **Svelte v5** + **TypeScript v7** |
| Styling | **TailwindCSS v4** + **shadcn-svelte** components (`pnpm dlx shadcn-svelte@latest add <component>`) |
| Format / lint | **Prettier** + **ESLint** |
| Tests | **Vitest** (unit) · **Playwright** (e2e) |
| Backends, APIs, scripting | **GoLang**: `net/http` + **Chi** for routing, **Huma** for OpenAPI-first APIs. Wrap errors with `%w`, `gofmt`/`go vet` clean, table-driven tests |
| Shell scripts | `#!/usr/bin/env bash`, syntax that runs in both **bash and zsh**: quote variables, avoid shell-specific features (zsh glob qualifiers, `${!var}`, array indexing, `[[ =~ ]]` captures) |
| Containers | **podman** + `podman compose` (`compose.yaml`), not docker · **Dockge** if a stack manager is needed |
| IaC | **OpenTofu** (`tofu`, not the terraform CLI) · **Ansible** for configuration |
| CI/CD, repos | **Azure DevOps**: Azure Repos, Azure Pipelines (`azure-pipelines.yml`), Boards (`az` CLI with the devops extension) |
| Security | Secrets: **Gitleaks** · Vulnerabilities: **Trivy** · SAST: **Semgrep CE** · DAST: **ZAP Baseline Scan** · Dependency updates: **Renovate** |
| Environment | Editor: **neovim** · Terminal: **Ghostty** + **tuios** (multiplexer). Target these when suggesting keybindings or config |

