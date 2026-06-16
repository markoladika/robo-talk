#!/usr/bin/env bash
# robo-talk install/uninstall test.
# Runs install + uninstall against a throwaway fake Claude home and asserts
# correctness: outputStyle set, noise settings added non-destructively, user
# settings preserved, files copied, statusline opt-in wired, uninstall reverts.
# Exits non-zero on any failure (for CI).
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(dirname "$SCRIPT_DIR")"
TMP="$(mktemp -d)"
FAKE="$TMP/home"
CLAUDE="$FAKE/.claude"
mkdir -p "$CLAUDE/projects"   # marker subdir so install recognizes it as a config dir
trap 'rm -rf "$TMP"' EXIT

pass=0; fail=0
ck(){ if eval "$2"; then echo "  ok    $1"; pass=$((pass+1)); else echo "  FAIL  $1"; fail=$((fail+1)); fi; }
# JSON value helper (python3 is always present)
jget(){ python3 -c "import json,sys;d=json.load(open('$1'));print(d.get('$2','__MISSING__'))" 2>/dev/null; }

echo "== robo-talk install/uninstall test =="

# Pre-existing user settings: must be preserved / not overridden.
printf '{"theme":"dark","showTurnDuration":true}' > "$CLAUDE/settings.json"

echo "-- install (targeted at fake home) --"
HOME="$FAKE" CLAUDE_HOMES="$CLAUDE" bash "$REPO/install.sh" >/dev/null 2>&1

ck "outputStyle set to Robo Core"          '[ "$(jget "$CLAUDE/settings.json" outputStyle)" = "Robo Core" ]'
ck "spinnerTipsEnabled added (false)"       '[ "$(jget "$CLAUDE/settings.json" spinnerTipsEnabled)" = "False" ]'
ck "awaySummaryEnabled added (false)"       '[ "$(jget "$CLAUDE/settings.json" awaySummaryEnabled)" = "False" ]'
ck "user showTurnDuration PRESERVED (true)" '[ "$(jget "$CLAUDE/settings.json" showTurnDuration)" = "True" ]'
ck "user theme PRESERVED"                   '[ "$(jget "$CLAUDE/settings.json" theme)" = "dark" ]'
ck "output style copied"                    '[ -f "$CLAUDE/output-styles/robo-core.md" ]'
ck "robo skill copied"                      '[ -f "$CLAUDE/skills/robo/SKILL.md" ]'

echo "-- install with ROBO_STATUSLINE=1 --"
HOME="$FAKE" CLAUDE_HOMES="$CLAUDE" ROBO_STATUSLINE=1 bash "$REPO/install.sh" >/dev/null 2>&1
ck "statusline script copied + executable"  '[ -x "$CLAUDE/robo-statusline.sh" ]'
ck "statusLine wired to robo-statusline"    'python3 -c "import json;c=json.load(open(\"'"$CLAUDE"'/settings.json\"));import sys;sys.exit(0 if \"robo-statusline\" in c.get(\"statusLine\",{}).get(\"command\",\"\") else 1)"'

if command -v jq >/dev/null 2>&1; then
  echo "-- statusline smoke (jq present) --"
  OUT=$(echo '{"model":{"display_name":"Opus 4.8"},"context_window":{"used_percentage":50,"total_input_tokens":100000,"context_window_size":200000},"output_style":{"name":"Robo Core"}}' | bash "$CLAUDE/robo-statusline.sh")
  ck "statusline renders bar + percent + tokens" 'echo "$OUT" | grep -q "50%" && echo "$OUT" | grep -q "100k/200k"'
  ck "statusline shows [ROBO] when active"        'echo "$OUT" | grep -q "ROBO"'
else
  echo "  skip  statusline smoke (jq not installed)"
fi

echo "-- uninstall --"
HOME="$FAKE" bash "$REPO/uninstall.sh" >/dev/null 2>&1
ck "output style removed"                   '[ ! -f "$CLAUDE/output-styles/robo-core.md" ]'
ck "robo skill removed"                     '[ ! -d "$CLAUDE/skills/robo" ]'
if command -v jq >/dev/null 2>&1; then
  ck "outputStyle reverted"                 '[ "$(jget "$CLAUDE/settings.json" outputStyle)" = "__MISSING__" ]'
  ck "noise settings reverted"              '[ "$(jget "$CLAUDE/settings.json" spinnerTipsEnabled)" = "__MISSING__" ]'
  ck "user theme STILL preserved"           '[ "$(jget "$CLAUDE/settings.json" theme)" = "dark" ]'
  ck "user showTurnDuration STILL preserved" '[ "$(jget "$CLAUDE/settings.json" showTurnDuration)" = "True" ]'
fi

echo "-> $pass passed, $fail failed"
[ "$fail" -eq 0 ]
