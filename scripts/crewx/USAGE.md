# crewx 2

Claude Code in tuios with one lead, **Jarvis**, who takes a request from the prompt to a committed, verified result. Small changes he makes himself. Larger ones he turns into a short spec and a committed interface ("contract"), then runs implementers, a **tester** and a **scribe** in parallel, integrates their work and has risky changes reviewed with a fresh context. You can run several goals at once; all their questions and results land in one place, the tuios Inbox.

## Where it beats a plain Claude Code session, and where it doesn't
| Goal | What crewx does | Honest limit |
|---|---|---|
| Prompt → result faster | Implementation, tests and docs run at the same time against a committed contract. Parallel goals (`crewx new`) run in their own worktrees and sessions. | For a small change the direct path is a plain session plus a gate: no speed-up, no slow-down. Parallel implementation only pays for 2–4 file-disjoint parts. |
| Less human interaction | Questions are collected and asked **once**, with defaults you accept with one key. Reversible choices are decided and logged. The **gate** (a Stop hook) makes the lead fix failing checks before it stops, so you never have to say "the tests fail". A "done" mail arrives without asking. | Approvals the auto mode can't decide still need you (in the Inbox). |
| Tokens / cost | Cheap models where they suffice (haiku: mechanical edits, docs, searches; sonnet: normal code, tests), effort per agent, the lead's context stays small (agents return a 5-line report), a passing gate costs zero tokens, crewx agents load only in crewx sessions. | Total tokens of a team run are higher than one session (published numbers: 2–7×). The saving is cost per finished result and the lead's context, not raw token count. |
| Docs and tests in parallel | Noelle (tests) and Mimosa (docs) start with the implementers, from the spec and the contract. Tests written from the spec catch what the implementer's own tests miss. | Tests against stubs are red until the implementation is merged; that is expected and handled. |
| One Markdown file per session | `.crewx/sessions/<date>-<id>.md`: goal, status, request and acceptance criteria, decisions, plan, done / in progress / next, waiting on human, and a log the hooks write. Re-injected after compaction or resume. | The lead keeps the sections current by prompt; only the log is written mechanically. |
| One place for human interaction | The tuios Inbox (`Ctrl+B i`) holds every session's approvals, questions, "done" mails and errors, on this machine and linked hosts; push to the phone via `[notify]`. `crewx status` lists every session with its status and open points. | Approvals of long or multi-line commands are answered in the pane, not in the Inbox (tuios limit). |

## The crew
| Agent | Model / effort | Role |
|---|---|---|
| Jarvis | opus | Lead: intake, path choice, spec and contract, dispatch, integration, finish. The only agent you talk to. |
| Asta | haiku / low | Implementer: mechanical, fully specified edits. |
| Yuno | sonnet / medium | Implementer: the default for features and fixes. |
| Yami | opus / high | Implementer: tricky logic, concurrency, security, performance. |
| Noelle | sonnet / medium | Tester: tests from the acceptance criteria and the contract, independent of the implementation. |
| Mimosa | haiku / low | Scribe: README, `docs/`, usage text. Jarvis passes `model: sonnet` for conceptual docs. |
| Hinata | opus / high | Reviewer, read-only: one fresh-context review of large or risky goals. |

All but Jarvis are Claude Code subagents of Jarvis, launched in the background: they start in seconds, run in parallel and return only their report. They are defined in a Claude Code plugin (`plugin/`) that loads only in crewx sessions (`--plugin-dir`), so normal sessions don't pay for their descriptions.

## The flow
```
you ─▶ Jarvis: intake ── ≤ 1 round of questions (mail + one ask-human: "use my defaults?")
                │
                ├─ direct path (most requests): Jarvis implements in the main worktree
                │      └─ optional in parallel: Noelle (tests) · Mimosa (docs), same worktree, own files, no commits
                │
                └─ team path (2–4 file-disjoint parts):
                       spec in the state file ─▶ contract commit on F (types, signatures, stubs)
                       ─▶ in parallel, each in its own worktree:  Asta/Yuno/Yami · Noelle · Mimosa
                       ◀─ reports ── merge each (squash): implementers, then tests, docs any time
                │
                ▼
       finish: Hinata review (if > ~150 lines or risky) · fixes · end of turn ─▶ GATE (Stop hook)
               state file done · report in the pane · "crewx: done – <goal>" mail to your Inbox
```

### The gate
`.crewx/verify` holds one shell line with the project's fast checks (typecheck, lint, unit tests). Jarvis writes it in a new project. When Jarvis ends a turn **and the work tree changed** since the last check, the Stop hook runs it:
- **pass:** nothing enters the conversation; the log gets `gate pass`.
- **fail:** the stop is blocked and Jarvis gets the last 40 lines as his next instruction. After 3 failed attempts in a row it lets him stop, logs it and mails you.
- It never runs twice on the same tree: if Jarvis stops again without changes (because the failure isn't his, for example your uncommitted edits), it lets him.
- It waits while crewx subagents are running.
- Off: `CREWX_GATE=off` in the environment, or `touch .crewx/gate-off`. Timeout: `CREWX_GATE_TIMEOUT` (default 600 s); attempts: `CREWX_GATE_MAX` (default 3).

## Commands
```bash
~/.config/scripts/crewx/crewx start [dir]              # open or reuse the project's session (default: .)
~/.config/scripts/crewx/crewx new <name> "<request>"   # parallel goal: worktree feat-<name>, own session, lead starts on the request
~/.config/scripts/crewx/crewx status [--watch]         # all crewx sessions: status, open points, age
~/.config/scripts/crewx/crewx gate [dir]               # run .crewx/verify by hand
~/.config/scripts/crewx/crewx doctor                   # tools, tuios integration, agent files
```
Tip: `alias crewx=~/.config/scripts/crewx/crewx`. The old `setup` still works and runs `crewx start`.

`crewx start`:
1. Settles the branch with you in the terminal: not a git repo → stop; not on `feat-*` → proceed, or create `feat-<name>` (your uncommitted changes come along).
2. Creates `.crewx/` and keeps it out of git through `.git/info/exclude` (local, nothing to commit). Pre-trusts the folder for Claude Code when it lies in `$CLAUDE_TRUSTED_DIRS`.
3. Opens or reuses the tuios session `crewx-<dir name>`:
   - **1 Coding:** nvim (right, 70%), lazygit and a login shell (left).
   - **2 Lead:** Jarvis, started from a shell so the pane survives `/exit`. You land here.
   - **3 Board:** left the live state file of the current session, right `crewx status --watch` for every session on the machine.
   - **4 Worktrees:** live `wt list`.
4. Attaches you, or switches to it when you're already in tuios. Running it again is safe; a crewx 1 session is converted in place.

`crewx new <name> "<request>"` makes the worktree `feat-<name>` from your current branch with worktrunk (so the project's `wt` hooks install dependencies), opens a session for it without the Coding workspace, starts Jarvis with the request and returns. Start three, walk away, answer the Inbox. crewx never merges goals: when one is done, review and merge `feat-<name>` yourself (`wt merge`, or `tuios review` / `ctrl+b v` first).

## Working with it
- Type the request into the Lead pane, ideally with the acceptance criteria you care about. Then leave it.
- **Everything that needs you is in the Inbox** (`Ctrl+B i`; `Ctrl+B o` jumps to the oldest item): approvals, Jarvis's question round, "done" mails, gate give-ups, errors, from every session. Answer a question with a digit; answer details by mail (prefix `M`), or type into the Lead pane.
- **Away from the desk:** set up `[notify]` in the tuios config (ntfy, Pushover, webhook, see `tuios --skill notify`) so questions, approvals and "done" mails reach your phone.
- Look in any time: Board workspace (state file, all sessions), Worktrees workspace, or ask Jarvis.
- Correct a decision by telling Jarvis; he records it as `by human`.

## Files in your project
| File | In git | What |
|---|---|---|
| `.crewx/sessions/<date>-<id>.md` | ignored | one state file per Claude Code session (template: `templates/session.md`) |
| `.crewx/verify` | ignored | the gate command, one line |
| `.crewx/run/` | ignored | gate bookkeeping (fingerprints, attempts, running-agent markers) |
| `.crewx/worktree.log` | ignored | what the worktree helper did |
| `docs/DECISIONS.md` | **committed** (you commit it) | decisions that shape the project; created with the first one |

There is no changelog file: every package lands as one squashed Conventional Commit on F, so `git log` is the changelog. A project from crewx 1 may still have `.crewx/STATE.md` and `.crewx/activity.log`; they are no longer read: carry anything open into a request, then delete them.

## Git and worktrees
```
lead worktree (project dir, or a `crewx new` worktree)   F = feat-<name>   you, Jarvis (direct path, merges)
└─ .worktrees/<F>-yuno     branch <F>-yuno     Yuno   (team path only, removed after its merge)
└─ .worktrees/<F>-noelle   branch <F>-noelle   Noelle
```
- The helper (`worktree help`) guards the branch, creates agent worktrees with worktrunk (project `wt` hooks run, so dependencies exist), squash-merges a package into one commit and fast-forwards F, rebases the other clean worktrees, and removes merged ones. Nothing is ever pushed; you push.
- Your own work in the main worktree: keep going. A merge stops (exit 6) instead of touching your work if you have staged changes, or uncommitted changes in the same files; Jarvis asks and merges the rest meanwhile.
- Worktrunk silently skips project hooks you haven't approved. For a new project, approve them once yourself: `wt switch --create crewx-approve`, then `wt remove crewx-approve`. Agents never approve hooks.

## Files of crewx
| Path | What |
|---|---|
| `crewx` | the CLI (start, new, status, gate, doctor) |
| `setup` | crewx 1 entry point, runs `crewx start` |
| `settings.json` | crewx-only settings (`--settings`): auto permission mode, git deny rules, allowed tuios and helper commands |
| `plugin/.claude-plugin/plugin.json` | the Claude Code plugin manifest (`--plugin-dir plugin`) |
| `plugin/agents/*.md` | the seven agents; the shared rules block at the end is identical in all (`crewx doctor` checks) |
| `plugin/hooks/hooks.json` | SessionStart → `session-start.sh`, Stop → `stop-gate.sh`, SubagentStart/Stop → `log-event.sh` |
| `worktree` | git helper for agent worktrees |
| `panes/state.sh`, `panes/worktrees.sh` | Board and Worktrees panes (plain scripts, no tokens) |
| `layout-coding.sh` | shapes the Coding workspace once a client is attached |
| `templates/` | `session.md` (state file), `DECISIONS.md` |
| `tests/run.sh` | offline test suite: hooks, gate, helper, status (no Claude calls) |
| `tests/e2e.sh` | smoke test with a real haiku run: plugin, agent name, hooks (costs a few cents) |

## Upgrading from crewx 1
1. Delete the old global agent files `~/.config/claude/agents/{jarvis,asta,yuno,yami,hinata}.md`. The plugin replaces them, and as global agents they cost tokens in every normal session and shadow the plugin's names. `crewx doctor` warns while they exist.
2. In a running crewx 1 session, exit Jarvis (`/exit`) and run `crewx start` again; the workspaces are renamed, the old log panes closed.
3. Run `tests/run.sh`, then once `tests/e2e.sh`.

## Limits
- Subagents are not tuios panes: the rail shows Jarvis only. Follow them in the state file's log and the Worktrees workspace.
- A tuios daemon restart ends Jarvis and his running subagents. Run `crewx start` again; the session state file and the worktrees with commits are still there (`claude --resume` inside the Lead pane picks up the conversation, and the hook re-injects the state file).
- The gate runs in the lead's worktree only. Agents run it themselves in their worktrees before reporting.

## Design notes (why it looks like this)
- **One writer per file, parallel readers and verifiers.** Parallel writers on shared code fail more often than they save time; parallel tests, docs and review are the reliable wins (Cognition, "Multi-agents: what's actually working", 2026; Claude Code agent-teams docs).
- **A check the agent must pass beats an instruction to check.** Hence the Stop-hook gate (Claude Code hooks docs; Anthropic, "Effective harnesses for long-running agents").
- **Route models by difficulty, not by role prestige.** Opus lead with cheaper workers outperformed a single Opus agent in Anthropic's research system, at a higher token count (Anthropic, "How we built our multi-agent research system").
- **Agent teams (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`) are not used:** each teammate is a full session with its own context (several times the tokens) and the benchmark gains for coding were small; subagents with a 5-line report keep the lead's context small.
- **tuios stays:** its Inbox across sessions and hosts, held approvals, `ask-human`, mail and phone notifications are exactly the "one place for the human" that plain Claude Code lacks. Claude Code does the agent work; tuios does the human side.
