# crewx

A Claude Code agent team (Agent Teams) that runs in tuios. Jarvis leads; Hinata keeps the docs and reviews; Asta, Yuno and Yami do the work.

| Agent | Model | Role |
|---|---|---|
| Jarvis | opus | Team lead: plans, decides, delegates. The only one you need to talk to. |
| Hinata | sonnet | Plan, reviews, changelog, decision log, question queue, status, handoff. Edits only `docs/`. |
| Asta | haiku | Simple, fully specified packages. |
| Yuno | sonnet | Medium packages. |
| Yami | opus | Heavy packages; may propose improvements. |

## Start
```bash
~/.config/scripts/crewx/setup [project-dir]   # default: current directory
```
`setup`:
1. Creates what is missing in the project, never overwriting: `docs/PLAN.md`, `docs/CHANGELOG.md`, `docs/DECISIONS.md`, `docs/HANDOFF.md`, `.crewx/activity.log`.
2. Opens the tuios session `crewx-<dir name>`, or reuses it.
3. Workspace 1 **Jarvis**: starts Jarvis in the Jarvis pane, unless Jarvis is already running there.
   Teammates open as extra panes here and close when Jarvis shuts them down.
4. Workspace 2 **Logs**: left `tail -F .crewx/activity.log`, right a live render of `docs/PLAN.md`. Plain scripts, no tokens.
5. Attaches you to the session (or switches to it, if you are already in tuios).

Running `setup` again is safe: it reuses the session, restarts Jarvis only if he is not running, and recreates missing log panes.

## Work with it
- Talk to Jarvis in his pane. He reads `docs/HANDOFF.md`, `PLAN.md` and `DECISIONS.md` first, then spawns Hinata.
- Ask Hinata for a status digest any time (in her pane, or through Jarvis).
- Jarvis asks you directly only for critical decisions (breaking changes, new dependencies, data migrations, security, high cost) or blockers. Other questions are batched by Hinata.
- Agents don't commit or push. Review `git diff` and commit yourself.
- To end: tell Jarvis you are done. Hinata writes `docs/HANDOFF.md`, Jarvis shuts the team down. The next `setup` resumes from the handoff.

## Files
| Path | What |
|---|---|
| `~/.config/scripts/crewx/setup` | the start script |
| `~/.config/scripts/crewx/settings.json` | crewx-only settings (`claude --settings`): hooks, teammate mode, permissions. Teammates get the same file from the lead. |
| `~/.config/scripts/crewx/log-event.sh` | hook: TaskCreated / TaskCompleted / TeammateIdle → `.crewx/activity.log` |
| `~/.config/scripts/crewx/logs-activity.sh`, `logs-plan.sh` | the two Logs panes |
| `~/.config/scripts/crewx/templates/` | starting content for the project docs |
| `~/.config/claude/agents/{jarvis,hinata,asta,yuno,yami}.md` | agent definitions, each self-contained (shared rules are duplicated at the end of every file; keep them identical) |

## Notes
- Your normal Claude Code sessions are unaffected: the crewx settings only load through `--settings` in `setup`.
- `.crewx/` is per-machine noise; add it to the project's `.gitignore` if you don't want it tracked.
- The PLAN pane uses `glow` if installed, else `cat`.
