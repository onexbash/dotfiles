# Global instructions

## Working style
- Read the code you are about to change, and follow the project's existing conventions; they win over the defaults below.
- Make the smallest change that fully solves the task. No unrelated refactors, no speculative options.
- Before saying "done", run the project's checks for what you touched (typecheck, lint, tests). Report failures exactly as they happened.
- Mark assumptions. Never invent APIs, flags, versions or results; when unsure about a library, read its docs.
- Answer in the language the user writes in. Code, comments, commit messages and docs in English.
- Git: Conventional Commits. Never push; the user pushes.

## Versions
- Assume the latest stable version of a tool, language or library unless the project or the user pins one.
- Your knowledge may be older than the latest release: check the current version before you pin one (`pnpm view <pkg> version`, `go list -m -versions <module>`, `brew info <formula>`, `mise ls-remote <tool>`).

## Default stack (when the project doesn't specify already)
| Area | Use |
|---|---|
| Packages | Node: **pnpm** (never npm/yarn for installs) · System: **brew** · Dev tools and runtimes: **mise** (`mise.toml`) |
| Web apps | **SvelteKit** + **Svelte 5** (runes) + **TypeScript** (strict) |
| Styling | **TailwindCSS** + **shadcn-svelte** components (`pnpm dlx shadcn-svelte@latest add <component>`) |
| Format / lint | **Prettier** + **ESLint** |
| Tests | **Vitest** (unit) · **Playwright** (e2e) |
| Backends, APIs, scripting | **Go**: `net/http` + **Chi** for routing, **Huma** for OpenAPI-first APIs. Wrap errors with `%w`, `gofmt`/`go vet` clean, table-driven tests |
| Shell scripts | `#!/usr/bin/env bash`, syntax that runs in both **bash and zsh**: quote variables, avoid shell-specific features (zsh glob qualifiers, `${!var}`, array indexing, `[[ =~ ]]` captures) |
| Containers | **podman** + `podman compose` (`compose.yaml`), not docker · **Dockge** if a stack manager is needed |
| IaC | **OpenTofu** (`tofu`, not the terraform CLI) · **Ansible** for configuration |
| CI/CD, repos | **Azure DevOps**: Azure Repos, Azure Pipelines (`azure-pipelines.yml`), Boards (`az` CLI with the devops extension) |
| Security | Secrets: **Gitleaks** · Vulnerabilities: **Trivy** · SAST: **Semgrep CE** · DAST: **ZAP Baseline Scan** · Dependency updates: **Renovate** |
| Environment | Editor: **neovim** · Terminal: **Ghostty** + **tuios** (multiplexer). Target these when suggesting keybindings or config |

## Safety
- Never run `tofu apply`/`destroy`, `ansible-playbook` against real hosts, or anything that changes shared infrastructure, pipelines or Azure DevOps state unless the user asked for exactly that.
- Never print, log or commit secrets. `.env` files stay out of git; commit an `.env.template` instead.
