#!/bin/bash
# Robo-talk statusline badge
# Reads mode from ~/.claude/.robo-mode and outputs badge

FLAG_FILE="$HOME/.claude/.robo-mode"
MODE="core"

if [ -f "$FLAG_FILE" ]; then
  MODE=$(cat "$FLAG_FILE" 2>/dev/null)
  MODE="${MODE:-core}"
fi

MODE_UPPER=$(echo "$MODE" | tr '[:lower:]' '[:upper:]')
echo "[ROBO:${MODE_UPPER}]"
