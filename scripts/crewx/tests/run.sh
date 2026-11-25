#!/usr/bin/env bash
# crewx test suite: hooks, gate, worktree helper and `crewx status` against throwaway git repos.
# Needs git, jq; the worktree tests also need wt (skipped without it). Touches nothing outside a temp dir.
# Usage: tests/run.sh
set -uo pipefail

CREWX="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
HOOKS="$CREWX/plugin/hooks"
T="$(mktemp -d "${TMPDIR:-/tmp}/crewx-test.XXXXXX")"
trap 'rm -rf "$T"' EXIT
export XDG_STATE_HOME="$T/state" HOME_ORIG="$HOME"
unset TUIOS_PANE_ID TUIOS_SESSION CREWX_GATE
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.invalid GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.invalid

pass=0 fail=0
ok() {
  pass=$((pass + 1))
  printf '  ok   %s\n' "$1"
}
no() {
  fail=$((fail + 1))
  printf '  FAIL %s\n' "$1"
  [ -z "${2:-}" ] || printf '       %s\n' "$2" | head -n 8
}
check() { # check <name> <command...>
  local name="$1"
  shift
  if "$@" >/dev/null 2>&1; then ok "$name"; else no "$name"; fi
}

new_repo() { # new_repo <dir>: a git repo on feat-x with one commit and .crewx/ excluded
  mkdir -p "$1" && git -C "$1" init -q -b main && echo one >"$1/a.txt" && git -C "$1" add a.txt &&
    git -C "$1" commit -qm init && git -C "$1" switch -qc feat-x &&
    mkdir -p "$1/.crewx" && echo "/.crewx/" >>"$1/.git/info/exclude"
}
hook() { # hook <script> <json>
  printf '%s' "$2" | "$HOOKS/$1"
}

echo "syntax"
for f in "$CREWX/crewx" "$CREWX/worktree" "$CREWX/setup" "$CREWX/layout-coding.sh" "$CREWX"/panes/*.sh "$HOOKS"/*.sh "$CREWX/tests/run.sh"; do
  check "bash -n ${f#"$CREWX"/}" bash -n "$f"
done
for f in "$CREWX/settings.json" "$HOOKS/hooks.json" "$CREWX/plugin/.claude-plugin/plugin.json"; do
  check "json ${f#"$CREWX"/}" jq -e . "$f"
done
sums="$(for f in "$CREWX"/plugin/agents/*.md; do sed -n '/^<!-- shared rules:/,$p' "$f" | shasum; done | sort -u | wc -l | tr -d ' ')"
[ "$sums" = 1 ] && ok "agents share identical rules" || no "agents share identical rules" "$sums distinct blocks"
for f in "$CREWX"/plugin/agents/*.md; do
  n="$(basename "$f" .md)"
  [ "$(sed -n '2p' "$f")" = "name: $n" ] && grep -q '^model: ' "$f" && grep -q '^description: ' "$f" &&
    ok "agent $n front matter" || no "agent $n front matter"
done

echo "session-start"
R="$T/p1"
new_repo "$R"
R="$(cd "$R" && pwd -P)" # the hooks report the resolved path (TMPDIR may be a symlink)
out="$(hook session-start.sh "{\"session_id\":\"aaaa1111-x\",\"cwd\":\"$R\",\"source\":\"startup\"}")"
sf="$(ls "$R"/.crewx/sessions/*-aaaa1111.md 2>/dev/null)"
[ -f "$sf" ] && ok "creates the state file" || no "creates the state file"
jq -e '.hookSpecificOutput.additionalContext | test("aaaa1111")' <<<"$out" >/dev/null && ok "names it in the context" || no "names it in the context" "$out"
jq -e '.hookSpecificOutput.additionalContext | test("verify is missing")' <<<"$out" >/dev/null && ok "flags a missing .crewx/verify" || no "flags a missing .crewx/verify"
grep -q '^branch: feat-x$' "$sf" && grep -q "^project: $R$" "$sf" && ok "fills the front matter" || no "fills the front matter" "$(head -n 9 "$sf")"
grep -q "$sf" "$XDG_STATE_HOME/crewx/index.tsv" && ok "registers in the index" || no "registers in the index"
[ -s "$R/.crewx/run/aaaa1111.base" ] && ok "records the baseline fingerprint" || no "records the baseline fingerprint"
sed -i '' 's/^status: .*/status: running/' "$sf" 2>/dev/null || sed -i 's/^status: .*/status: running/' "$sf"
printf -- '- 10:00:00 line %s\n' $(seq 1 30) >>"$sf"
out="$(hook session-start.sh "{\"session_id\":\"aaaa1111-x\",\"cwd\":\"$R\",\"source\":\"compact\"}")"
ctx="$(jq -r .hookSpecificOutput.additionalContext <<<"$out")"
[[ "$ctx" == *"status: running"* ]] && ok "re-injects the file after compaction" || no "re-injects the file after compaction"
[[ "$ctx" == *"line 30"* && "$ctx" != *"line 15"$'\n'* ]] && ok "trims the log to its tail" || no "trims the log to its tail"
[ "$(ls "$R"/.crewx/sessions | wc -l | tr -d ' ')" = 1 ] && ok "keeps one file per session" || no "keeps one file per session"
out="$(hook session-start.sh "{\"session_id\":\"bbbb2222-x\",\"cwd\":\"$R\",\"source\":\"startup\"}")"
jq -e '.hookSpecificOutput.additionalContext | test("unfinished")' <<<"$out" >/dev/null && ok "points to an unfinished earlier session" || no "points to an unfinished earlier session"
out="$(hook session-start.sh "{\"session_id\":\"cccc3333\",\"cwd\":\"$T\",\"source\":\"startup\"}")"
[ -z "$out" ] && ok "ignores directories that aren't crewx projects" || no "ignores directories that aren't crewx projects"

echo "stop gate"
S='{"session_id":"aaaa1111-x","cwd":"'"$R"'"}'
out="$(hook stop-gate.sh "$S")"
[ -z "$out" ] && ok "unchanged tree: no gate" || no "unchanged tree: no gate" "$out"
echo two >>"$R/a.txt"
out="$(hook stop-gate.sh "$S")"
jq -e '.decision == "block" and (.reason | test("verify is missing"))' <<<"$out" >/dev/null && ok "changed tree without verify: blocks" || no "changed tree without verify: blocks" "$out"
echo 'echo boom-output; exit 3' >"$R/.crewx/verify"
out="$(hook stop-gate.sh "$S")"
jq -e '.decision == "block" and (.reason | test("boom-output")) and (.reason | test("attempt 2/3"))' <<<"$out" >/dev/null && ok "failing gate: blocks with the output" || no "failing gate: blocks with the output" "$out"
out="$(hook stop-gate.sh "$S")"
[ -z "$out" ] && ok "same tree after a failure: doesn't block twice" || no "same tree after a failure: doesn't block twice" "$out"
echo three >>"$R/a.txt"
out="$(hook stop-gate.sh "$S")"
jq -e '.reason | test("attempt 3/3")' <<<"$out" >/dev/null && ok "counts consecutive attempts" || no "counts consecutive attempts" "$out"
echo four >>"$R/a.txt"
out="$(hook stop-gate.sh "$S")"
[ -z "$out" ] && grep -q 'gave up after 3' "$sf" && ok "gives up after the limit and logs it" || no "gives up after the limit and logs it" "$out"
echo 'test -f a.txt' >"$R/.crewx/verify"
out="$(hook stop-gate.sh "$S")"
[ -z "$out" ] && grep -q 'gate pass' "$sf" && ok "passing gate: silent, logged" || no "passing gate: silent, logged" "$out"
echo 'exit 1' >"$R/.crewx/verify"
echo five >>"$R/a.txt"
mkdir -p "$R/.crewx/run/aaaa1111.agents" && : >"$R/.crewx/run/aaaa1111.agents/agent-1"
out="$(hook stop-gate.sh "$S")"
[ -z "$out" ] && grep -q 'gate deferred' "$sf" && ok "waits while crewx subagents run" || no "waits while crewx subagents run" "$out"
rm -f "$R/.crewx/run/aaaa1111.agents/agent-1"
: >"$R/.crewx/gate-off"
out="$(hook stop-gate.sh "$S")"
[ -z "$out" ] && ok ".crewx/gate-off turns it off" || no ".crewx/gate-off turns it off" "$out"
rm -f "$R/.crewx/gate-off"
echo "untracked" >"$R/new.txt"
out="$(hook stop-gate.sh "$S")"
jq -e '.decision == "block"' <<<"$out" >/dev/null && ok "an untracked file counts as a change" || no "an untracked file counts as a change" "$out"

echo "log-event"
E() { printf '{"session_id":"aaaa1111-x","cwd":"%s","hook_event_name":"%s","agent_type":"%s","agent_id":"%s","last_assistant_message":%s}' "$R" "$1" "$2" "$3" "$(jq -Rs . <<<"${4:-}")"; }
hook log-event.sh "$(E SubagentStart crewx:yuno ag-9)"
[ -e "$R/.crewx/run/aaaa1111.agents/ag-9" ] && grep -q 'start yuno' "$sf" && ok "start: marker and log line" || no "start: marker and log line"
hook log-event.sh "$(E SubagentStop crewx:yuno ag-9 $'\n\nWP-2 done · abc123 · gate: pass\n- details')"
[ ! -e "$R/.crewx/run/aaaa1111.agents/ag-9" ] && grep -q 'stop  yuno: WP-2 done · abc123 · gate: pass' "$sf" && ok "stop: marker gone, first report line logged" || no "stop: marker gone, first report line logged" "$(tail -n 2 "$sf")"
before="$(wc -l <"$sf")"
hook log-event.sh "$(E SubagentStart Explore ag-10)"
[ "$(wc -l <"$sf")" = "$before" ] && [ ! -e "$R/.crewx/run/aaaa1111.agents/ag-10" ] && ok "ignores non-crewx subagents" || no "ignores non-crewx subagents"

echo "crewx status"
out="$("$CREWX/crewx" status 2>&1)"
[[ "$out" == *"running"*"p1:feat-x"* ]] && ok "lists the session with status and branch" || no "lists the session with status and branch" "$out"
printf -- '- 1. drop the v1 endpoint? default: keep\n' >"$T/wait.md"
sed -i '' '/^## Waiting on human/r '"$T/wait.md" "$sf" 2>/dev/null || sed -i '/^## Waiting on human/r '"$T/wait.md" "$sf"
out="$("$CREWX/crewx" status 2>&1)"
[[ "$(grep 'p1:feat-x' <<<"$out")" =~ running[[:space:]]+1[[:space:]] ]] && ok "counts points waiting on the human" || no "counts points waiting on the human" "$out"

echo "worktree helper"
W="$T/p2"
mkdir -p "$W" && git -C "$W" init -q -b main && echo one >"$W/a.txt" && git -C "$W" add a.txt && git -C "$W" commit -qm init
(cd "$W" && "$CREWX/worktree" check >/dev/null 2>&1)
[ $? = 3 ] && ok "check: exit 3 off a feat branch" || no "check: exit 3 off a feat branch"
(cd "$W" && "$CREWX/worktree" new-feature demo >/dev/null 2>&1)
[ "$(git -C "$W" branch --show-current)" = feat-demo ] && ok "new-feature switches to feat-demo" || no "new-feature switches to feat-demo"
out="$(cd "$W" && "$CREWX/worktree" up bogus 2>&1)"
[[ "$out" == *"unknown agent"* ]] && ok "rejects unknown agent names" || no "rejects unknown agent names" "$out"
if command -v wt >/dev/null; then
  mkdir -p "$W/.crewx" && echo "/.crewx/" >>"$W/.git/info/exclude"
  p="$(cd "$W" && "$CREWX/worktree" up noelle 2>/dev/null | tail -n1)"
  if [ -d "$p" ]; then
    ok "up noelle creates a worktree"
    [ "$(git -C "$p" branch --show-current)" = feat-demo-noelle ] && ok "on branch <F>-noelle" || no "on branch <F>-noelle"
    out="$(cd "$p" && "$CREWX/worktree" sync 2>&1)"
    [[ "$out" == *"not from the agent worktree"* ]] && ok "refuses to run inside an agent worktree" || no "refuses to run inside an agent worktree" "$out"
    echo t1 >"$p/t1.test" && git -C "$p" add t1.test && git -C "$p" commit -qm wip1 &&
      echo t2 >"$p/t2.test" && git -C "$p" add t2.test && git -C "$p" commit -qm wip2
    out="$(cd "$W" && "$CREWX/worktree" merge noelle 'test(demo): add tests' 2>&1)"
    [[ "$out" == merged* ]] && [ "$(git -C "$W" log -1 --format=%s)" = 'test(demo): add tests' ] &&
      [ "$(git -C "$W" rev-list --count main..feat-demo)" = 1 ] && ok "merge squashes into one commit on F" || no "merge squashes into one commit on F" "$out"
    out="$(cd "$W" && "$CREWX/worktree" remove noelle 2>&1)"
    [ ! -d "$p" ] && ok "remove deletes the merged worktree" || no "remove deletes the merged worktree" "$out"
  else
    no "up noelle creates a worktree" "$p"
  fi
else
  echo "  skip worktree up/merge/remove: wt not installed"
fi

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" = 0 ]
