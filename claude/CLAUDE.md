## Git branching
When creating a new branch, always base it on the correct branch:
1. Run `git fetch origin` first.
2. If `dev` exists (locally or as `origin/dev`), branch from `origin/dev`.
3. Otherwise, branch from `origin/main`, or `origin/master` if `main` doesn't exist.
Always pass the base explicitly, e.g. `git switch -c feature/x origin/dev`.
Never create a branch from whatever is currently checked out.
