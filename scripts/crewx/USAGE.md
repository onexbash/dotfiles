# crewx

A Claude Code agent team (Agent Teams) that runs in tuios. Jarvis leads; Hinata keeps the docs and reviews; Asta, Yuno and Yami do the work.

| Agent | Model | Role |
|---|---|---|
| Jarvis | opus | Team lead: plans, decides, delegates. The only one you need to talk to. |
| Hinata | sonnet | Reviews and merges worker branches, keeps worktrees current, team state and handoff, decision log, question queue, status. Edits only `.crewx/STATE.md` and `docs/DECISIONS.md`. |
| Asta | haiku | Simple, fully specified packages. |
| Yuno | sonnet | Medium packages. |
| Yami | opus | Heavy packages; may propose improvements. |

## When crewx pays off
A team beats a single Claude session only when the work splits into **independent, substantial parts** (different files, each checkable on its own): they then run in parallel, on the cheapest model that does each part well, with a gate and a review in between. Every worker costs a spawn (about a minute) and a review-and-merge cycle, so for a small or tightly coupled change a plain `claude` session is faster and cheaper. Jarvis sizes the team to the request: questions and discussion he answers himself, one coherent change becomes one package for one worker, and only real seams become parallel packages.

## The flow
```
you ─▶ Jarvis: plan, packages with context ─▶ Asta / Yuno / Yami in parallel (own worktrees)
                                              │ gate + commit + rebase
                                              ▼
              Jarvis ◀─ "WP-n merged" ── Hinata: review, gate, squash-merge into F
              (Yami's packages: Jarvis approves before the merge)
```
- **Context packs:** each package carries what Jarvis learned while planning (files and lines, signatures, conventions), so workers don't re-explore.
- **Gate:** `.crewx/verify` holds one line with the project's fast checks (typecheck, lint, unit tests). Jarvis writes it at the first session in a project; check it once. Workers run it before handing off, Hinata before merging, Jarvis on F when the goal is done.
- **Review without detours:** Hinata sends concrete findings straight back to the worker and merges Asta's and Yuno's packages herself once they pass. Jarvis only sees merges, Yami's verdicts and escalations, so his (Opus) context stays small.
- **Warm workers:** a worker with more work at its level gets the next package directly instead of being shut down and respawned.

## Start
```bash
~/.config/scripts/crewx/setup [project-dir]   # default: current directory
```
`setup`:
1. Creates what is missing in the project, never overwriting: `.crewx/STATE.md` and `.crewx/activity.log`, and keeps `.crewx/` out of git through `.git/info/exclude` (local, nothing to commit).
2. Checks the branch: if the project isn't a git repo it stops; if the main worktree isn't on `feat-*`, it asks you right there: proceed on it, or create `feat-<name>` (your uncommitted changes come along).
3. Opens the tuios session `crewx-<dir name>`, or reuses it.
4. Workspace 1 **Coding**: left 30% lazygit (top) and a login shell (bottom), right 70% nvim in the project directory. tuios splits panes only while a client is attached, so `layout-coding.sh` shapes this workspace in the background right after you are attached; it takes a second or two.
5. Workspace 2 **Jarvis**: starts Jarvis in the Jarvis pane, unless Jarvis is already running there. You land here.
6. Workspace 3 **Logs**: left `tail -F .crewx/activity.log`, right a live render of `.crewx/STATE.md`. Plain scripts, no tokens.
7. Workspace 4 **Workers**: a live `wt list` pane, and every teammate (Hinata and the workers) opens beside it and closes when Jarvis shuts it down. Keep the Worktrees pane open: Jarvis starts with `TMUX_PANE` pointing at it, which is how the teammates land on this workspace.
8. Attaches you to the session (or switches to it, if you are already in tuios).

Running `setup` again is safe: it reuses the session, restarts Jarvis only if he is not running, and recreates missing panes (the Coding layout only when its Git pane is gone). A session from an older `setup` (Jarvis on workspace 1) is renumbered in place: Jarvis, Logs and Workers move to 2–4 with their panes, and Coding is added as 1. A Jarvis that was started by an older `setup` keeps opening teammates beside himself until you restart him.

## Work with it
- Talk to Jarvis in his pane. He reads `.crewx/STATE.md` and `docs/DECISIONS.md` first, then spawns Hinata.
- Ask Hinata for a status digest any time (in her pane, or through Jarvis).
- Jarvis asks you directly only for critical decisions (breaking changes, new dependencies, data migrations, security, high cost) or blockers. Other questions are batched by Hinata.
- To end: tell Jarvis you are done. Hinata removes merged worker worktrees and writes the handoff into `.crewx/STATE.md`, Jarvis shuts the team down. The next `setup` resumes from it.

## Files in your project
| File | In git | What |
|---|---|---|
| `docs/DECISIONS.md` | **committed** (you commit it) | decisions that shape the project: architecture, interfaces, dependencies, data, security. Alternatives, reason, who approved. Created with the first such decision |
| `.crewx/STATE.md` | ignored | the team's only state file: goal, branch, packages and status, open questions, team notes (gate command, branch approval), the handoff for the next session |
| `.crewx/verify` | ignored | the gate command |
| `.crewx/activity.log` | ignored | hook log |

There is no changelog file: every package lands as one squashed Conventional Commit on your feature branch, so `git log` is the changelog. Generate release notes from it when you need them.

A project set up by an older crewx still has `docs/PLAN.md`, `CHANGELOG.md`, `HANDOFF.md` (and `DECISIONS.md`). Jarvis reads the old plan and handoff once and carries what's open into `.crewx/STATE.md`; then delete those three yourself. Keep `docs/DECISIONS.md` if it has project decisions in it.

## Working with tuios
Every agent is a tuios pane, so tuios knows its state through the Claude Code integration (`tuios integration install claude-code`; `setup` warns if it's missing or outdated).

| Where | What you see / do |
|---|---|
| **Rail** | every crewx agent with its state and its crewx line: Jarvis's goal, Hinata's current job, each worker's `WP` and branch |
| **Ctrl+B i** (agents view) | *Needs you*: Jarvis's questions, Hinata's question batches and status mails, permission prompts, errors. *Ready for review*, *Working*, *Idle* below |
| **Ctrl+B o** | jump to the oldest thing waiting for you |
| **Jarvis's questions** (`ask-human`) | pick the answer with a digit in the Inbox; the answer reaches Jarvis as mail. Blocking decisions only: branch choice, critical decisions, blockers |
| **Hinata's mail** | batched non-urgent questions and status digests. Reply with `r`; she records the answers and passes them on |
| **Talking to an agent** | type in its pane, or `r` on its row: the reply is queued until the agent is at rest |
| **Phone** | set up `[notify]` in the tuios config (ntfy, Pushover, webhook): Jarvis's questions and permission prompts reach you when you're away |

Agents talk to each other with Agent Teams messages, not tuios mail. tuios mail is only the channel between the team and you.

Limits:
- Teammates start in the main worktree and `cd` into their own, so tuios's review (`Ctrl+B v`), checkpoints and the folder on a worker's row point at the main worktree. Review a worker's work with `git diff <F>...<F>-<worker>` or `wt switch <F>-<worker>`.
- tuios task boards and `tuios fan` aren't used: the Agent Teams task list and the crewx worktree helper do that job.
- A tuios daemon restart ends every pane. Don't resume crewx teammates from the Inbox's *Resume* rows (they'd come back outside the team); run `setup` again, and Jarvis resumes from the handoff in `.crewx/STATE.md`.

## Git and worktrees
```
main worktree (project dir)   F = feat-<name>   you, Jarvis, Hinata
└─ .worktrees/<F>-asta        branch <F>-asta   Asta
└─ .worktrees/<F>-yuno        branch <F>-yuno   Yuno
└─ .worktrees/<F>-yami        branch <F>-yami   Yami
```
- **Branch guard:** `setup` asks you before Jarvis starts. After that, the helper refuses every worktree step on a branch that isn't `feat-*` (or one you approved); the agents then pause and Jarvis asks you through the Inbox.
- **Workers** get their worktree on demand (`worktree up <worker>`, via worktrunk, so the project's `.config/wt.toml` hooks install dependencies, copy env files, ...). They commit only on their own branch and rebase onto F before handing off.
- **Merge back:** after her review and the gate (and Jarvis's OK for Yami's packages), Hinata runs `worktree merge`: the worker's commits are squashed into one Conventional Commit and F is fast-forwarded to it. Result: one commit per work package on F, made by the team. Nothing is ever pushed; you push.
- **Keeping workers current:** after every merge (and before every review), `worktree sync` rebases clean worker worktrees that are behind F. Busy or conflicting ones get a message to commit and rebase themselves.
- **Your own work in the main worktree:** keep going as usual. A merge stops (exit 6) instead of touching your work if you have *staged* changes, or if your uncommitted changes touch the same files. Hinata's `docs/DECISIONS.md` edits stay uncommitted for you to commit.
- **Look around:** `wt list` shows all worktrees with ahead/behind; `wt switch <F>-yuno` takes you into a worker's worktree.
- Worktrunk silently skips project hooks you haven't approved when agents create worktrees. For a new project, approve them once yourself: `wt switch --create crewx-approve`, then `wt remove crewx-approve`. Agents never approve hooks.

## Files
| Path | What |
|---|---|
| `~/.config/scripts/crewx/setup` | the start script |
| `~/.config/scripts/crewx/settings.json` | crewx-only settings (`claude --settings`): hooks, teammate mode, permissions. Teammates get the same file from the lead. |
| `~/.config/scripts/crewx/worktree` | git helper: branch guard, worker worktrees, squash-merge, sync (`worktree help`) |
| `~/.config/scripts/crewx/log-event.sh` | hook: TaskCreated / TaskCompleted / TeammateIdle → `.crewx/activity.log` |
| `~/.config/scripts/crewx/jarvis.sh` | starts Jarvis under the tmux shim, with `TMUX_PANE` on the Workers anchor |
| `~/.config/scripts/crewx/logs-activity.sh`, `logs-plan.sh`, `logs-worktrees.sh` | the Logs panes and the Workers anchor pane |
| `~/.config/scripts/crewx/layout-coding.sh` | shapes the Coding workspace (splits, 30/70, lazygit, login shell) once a client is attached |
| `<project>/.crewx/verify` | the project's gate: one shell line of fast checks |
| `~/.config/scripts/crewx/templates/` | starting content of `.crewx/STATE.md` and `docs/DECISIONS.md` |
| `~/.config/claude/agents/{jarvis,hinata,asta,yuno,yami}.md` | agent definitions, each self-contained (shared rules are duplicated at the end of every file; keep them identical) |

## Notes
- Your normal Claude Code sessions are unaffected: the crewx settings only load through `--settings` in `setup`.
- `.crewx/` stays out of git through the repository's local `.git/info/exclude`; your `.gitignore` is not touched.
- The state pane uses `glow` if installed, else `cat`.
