#!/usr/bin/env bash
# crewx end-to-end smoke test with a real (cheap) Claude Code run: plugin loads, crewx:jarvis resolves,
# SessionStart creates the state file, the Stop gate runs. Needs a logged-in claude; costs a few cents (haiku).
# Usage: tests/e2e.sh
set -uo pipefail

CREWX="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
E="$(mktemp -d "${TMPDIR:-/tmp}/crewx-e2e.XXXXXX")"
trap 'rm -rf "$E"' EXIT
export XDG_STATE_HOME="$E/state"
unset TUIOS_PANE_ID TUIOS_SESSION

cd "$E" || exit 1
git init -q -b feat-e2e && echo hi >a.txt && git add a.txt && git -c user.name=t -c user.email=t@example.invalid commit -qm init
mkdir .crewx && echo /.crewx/ >>.git/info/exclude
echo 'grep -q changed a.txt' >.crewx/verify # fails until the agent writes "changed" into a.txt

out="$(timeout 300 claude -p "Append one line with the word 'nothing' to a.txt using the Edit or Write tool, then end your turn. If the gate blocks you, follow its reason." \
  --agent crewx:jarvis --model haiku --plugin-dir "$CREWX/plugin" --settings "$CREWX/settings.json" \
  --permission-mode acceptEdits --max-budget-usd 0.50 --output-format json 2>&1)"
jq -c '{is_error, cost: .total_cost_usd, result: (.result | .[0:200])}' <<<"$out" 2>/dev/null || printf '%s\n' "$out"

pass=0 fail=0
t() { if eval "$2"; then
  pass=$((pass + 1))
  echo "  ok   $1"
else
  fail=$((fail + 1))
  echo "  FAIL $1"
fi; }
sf="$(ls .crewx/sessions/*.md 2>/dev/null | head -n1)"
t "plugin loaded, SessionStart created the state file" '[ -n "$sf" ]'
t "the state file names the branch" 'grep -q "^branch: feat-e2e" "$sf" 2>/dev/null'
t "the Stop gate ran and blocked the failing tree" 'grep -q "gate fail" "$sf" 2>/dev/null'
echo "--- log:"
sed -n '/^## Log/,$p' "$sf" 2>/dev/null
printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" = 0 ]
