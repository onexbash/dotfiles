# crewx

Claude Code in tuios with one lead, Jarvis, who takes a request from the prompt to a finished, merged and checked result. Small changes he makes himself, like a normal session. Larger ones he splits across worker subagents that run in parallel in their own git worktrees, merges their work and has it reviewed once with a fresh context.

Goals, in this order: you step in as little as possible · the result is there fast · it is correct · it uses few tokens.

| Agent | Model | Role |
|---|---|---|
| Jarvis | opus | Lead: the only agent you talk to. Plans, implements small changes, launches workers, merges, finishes. |
| Asta | haiku | Worker: mechanical, fully specified edits. |
| Yuno | sonnet | Worker: the default for normal features and fixes. |
| Yami | opus | Worker: tricky logic, concurrency, security, performance. |
| Hinata | opus | Reviewer, read-only: reviews the finished change of a goal and reports defects. |

Workers and Hinata are subagents of Jarvis (Claude Code's Agent tool), not separate sessions: they start in seconds, run in the background in parallel, and return only their report, so Jarvis's context stays small.

## The flow
```
you ─▶ Jarvis ─┬─ direct path: implements, gate, commit ─────────────────────────────┐
               └─ team path:  packages ─▶ Asta / Yuno / Yami in parallel worktrees     │
                              ◀─ reports ── merge each (squash) + gate on F            │
                                                                                       ▼
                                         finish: gate · Hinata review · fixes · STATE.md · report + Inbox mail
```
- **Direct path** for most requests: one coherent change, or parts that touch the same files. Same speed as a plain Claude Code session, plus the gate and a commit.
- **Team path** only when the work splits along file-disjoint seams into 2–5 substantial parts.
- **Gate:** `.crewx/verify` holds one line with the project's fast checks (typecheck, lint, unit tests). Jarvis writes it himself in a new project. Workers run it before reporting, Jarvis after every merge and at the end.
- **Review:** Hinata reviews the whole change once, when it is larger than about 150 lines or touches security, data, concurrency, money or a public interface. Jarvis fixes what she finds and checks the fixes himself.
- **Fewer questions:** Jarvis decides reversible choices himself and writes them under "Assumptions" in `.crewx/STATE.md` and in his report. He asks you only for things that are expensive or impossible to undo (data, security, breaking interfaces, paid services, a dependency with no clear standard choice, a request with two different readings), through the Inbox, and keeps working on everything else meanwhile.
- **Finish without being asked:** when a goal is done, Jarvis reports in his pane and sends a short tuios mail (`crewx: done – <goal>`) to your Inbox. There is no "tell Jarvis you're done" step.

## Start
```bash
~/.config/scripts/crewx/setup [project-dir]   # default: current directory
```
`setup`:
1. Creates what is missing, never overwriting: `.crewx/STATE.md` and `.crewx/activity.log`, and keeps `.crewx/` out of git through `.git/info/exclude` (local, nothing to commit).
2. Checks the branch: if the project isn't a git repo it stops; if the main worktree isn't on `feat-*`, it asks you right there: proceed on it, or create `feat-<name>` (your uncommitted changes come along). This is the only question before work starts.
3. Opens the tuios session `crewx-<dir name>`, or reuses it.
4. Workspace 1 **Coding**: left 30% lazygit (top) and a login shell (bottom), right 70% nvim in the project directory. tuios splits panes only while a client is attached, so `layout-coding.sh` shapes this workspace in the background right after you are attached.
5. Workspace 2 **Jarvis**: starts `claude --agent jarvis` with the crewx settings, unless he is already running there. You land here.
6. Workspace 3 **Logs**: left the activity log (each worker's start and its one-line report), right a live render of `.crewx/STATE.md`. Plain scripts, no tokens.
7. Workspace 4 **Workers**: a live `wt list` of the worker worktrees, with ahead/behind.
8. Attaches you to the session (or switches to it, if you are already in tuios).

Running `setup` again is safe: it reuses the session, starts Jarvis only if he is not running, and recreates missing panes. A session from an older `setup` is renumbered in place. **A Jarvis started by an older crewx still runs the old team flow: exit him (`/exit`) and run `setup` again.**

## Work with it
- Type the request into Jarvis's pane, ideally with the acceptance criteria you care about. Then leave it: questions and the final report reach your Inbox.
- Look in on it any time: Logs workspace (activity, state), Workers workspace (worktrees), or ask Jarvis.
- Correct an assumption by telling Jarvis; he takes it from there.

## Files in your project
| File | In git | What |
|---|---|---|
| `docs/DECISIONS.md` | **committed** (you commit it) | decisions that shape the project: architecture, interfaces, dependencies, data, security. Created with the first such decision |
| `.crewx/STATE.md` | ignored | goal, branch, packages and status, assumptions, open questions, team notes, handoff |
| `.crewx/verify` | ignored | the gate command |
| `.crewx/activity.log` | ignored | hook log: worker starts and reports |

There is no changelog file: every package lands as one squashed Conventional Commit on your feature branch, so `git log` is the changelog.

A project set up by an older crewx may still have `docs/PLAN.md`, `CHANGELOG.md`, `HANDOFF.md`. Jarvis carries what's open into `.crewx/STATE.md` once; then delete those three yourself.

## Working with tuios
| Where | What you see / do |
|---|---|
| **Rail** | Jarvis with his state and current goal |
| **Ctrl+B i** (agents view) | *Needs you*: Jarvis's questions, his "done" mails, permission prompts, errors |
| **Ctrl+B o** | jump to the oldest thing waiting for you |
| **Jarvis's questions** (`ask-human`) | pick the answer with a digit in the Inbox; it reaches Jarvis as mail, and he keeps working meanwhile |
| **Phone** | set up `[notify]` in the tuios config (ntfy, Pushover, webhook): questions, permission prompts and "done" mails reach you when you're away |

Limits:
- Workers aren't panes, so the rail and `Ctrl+B v` show Jarvis only. Follow the workers in the activity log and the Worktrees pane; review a worker's branch with `git diff <F>...<F>-<worker>` while it exists.
- A tuios daemon restart ends Jarvis and his running workers. Run `setup` again; Jarvis resumes from `.crewx/STATE.md`, and worker worktrees with commits are still there to merge.

## Git and worktrees
```
main worktree (project dir)   F = feat-<name>   you, Jarvis (direct path, merges)
└─ .worktrees/<F>-yuno        branch <F>-yuno   Yuno   (team path only, removed after its merge)
└─ .worktrees/<F>-yami        branch <F>-yami   Yami
```
- **Branch guard:** `setup` asks you before Jarvis starts. After that the helper refuses worktree work on a branch that isn't `feat-*` (or one you approved).
- **Workers** get their worktree from `worktree up <worker>` (via worktrunk, so the project's `.config/wt.toml` hooks install dependencies, copy env files, ...). They commit on their own branch and rebase onto F before reporting.
- **Merge:** Jarvis runs `worktree merge`: the worker's commits become one Conventional Commit and F is fast-forwarded to it. Then the gate runs on F and the worktree is removed. Nothing is ever pushed; you push.
- **Your own work in the main worktree:** keep going as usual. A merge stops (exit 6) instead of touching your work if you have *staged* changes, or uncommitted changes in the same files; Jarvis then asks you and merges the other packages meanwhile.
- Worktrunk silently skips project hooks you haven't approved. For a new project, approve them once yourself: `wt switch --create crewx-approve`, then `wt remove crewx-approve`. Agents never approve hooks.

## Files
| Path | What |
|---|---|
| `~/.config/scripts/crewx/setup` | the start script |
| `~/.config/scripts/crewx/settings.json` | crewx-only settings (`claude --settings`): auto permission mode, a few git rules, the activity hooks. Subagents run under the same settings |
| `~/.config/scripts/crewx/worktree` | git helper: branch guard, worker worktrees, squash-merge, sync (`worktree help`) |
| `~/.config/scripts/crewx/log-event.sh` | hook: SubagentStart / SubagentStop → `.crewx/activity.log` |
| `~/.config/scripts/crewx/logs-activity.sh`, `logs-plan.sh`, `logs-worktrees.sh` | the Logs panes and the Worktrees pane |
| `~/.config/scripts/crewx/layout-coding.sh` | shapes the Coding workspace once a client is attached |
| `~/.config/scripts/crewx/templates/` | starting content of `.crewx/STATE.md` and `docs/DECISIONS.md` |
| `~/.config/scripts/crewx/bench/` | compare crewx with a plain session on fixed tasks (`bench/BENCH.md`) |
| `~/.config/claude/agents/{jarvis,hinata,asta,yuno,yami}.md` | agent definitions (the shared rules at the end of each file are kept identical) |

## Notes
- Your normal Claude Code sessions are unaffected: the crewx settings only load through `--settings` in `setup`.
- The state pane uses `glow` if installed, else `cat`.
