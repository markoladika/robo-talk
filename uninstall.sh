#!/bin/bash
# Robo-talk uninstaller
# Usage: bash uninstall.sh

set -e

INSTALL_DIR="${HOME}/.claude/robo-talk"
STYLES_DIR="${HOME}/.claude/output-styles"
SKILLS_DIR="${HOME}/.claude/skills/robo"
SETTINGS_FILE="${HOME}/.claude/settings.json"
FLAG_FILE="${HOME}/.claude/.robo-mode"

echo ""
echo "[ACTION] Uninstalling robo-talk..."

# Remove files
rm -rf "$INSTALL_DIR"
rm -f "$STYLES_DIR/robo-core.md"
rm -rf "$SKILLS_DIR"
rm -f "$FLAG_FILE"

echo "[STATUS] Files removed."

# Remove outputStyle from settings.json
if [ -f "$SETTINGS_FILE" ] && command -v jq &>/dev/null; then
  if jq -e '.outputStyle == "Robo Core"' "$SETTINGS_FILE" &>/dev/null; then
    TEMP=$(mktemp)
    jq 'del(.outputStyle)' "$SETTINGS_FILE" > "$TEMP" && mv "$TEMP" "$SETTINGS_FILE"
    echo "[STATUS] Output style removed from $SETTINGS_FILE"
  fi
else
  echo "[WARNING] Check $SETTINGS_FILE and remove \"outputStyle\": \"Robo Core\" manually."
fi

echo ""
echo "[COMPLETE] robo-talk uninstalled. Restart Claude Code to return to default style."
