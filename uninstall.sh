#!/bin/bash
# Robo-talk uninstaller
# Usage: bash uninstall.sh

set -e

INSTALL_DIR="${HOME}/.claude/robo-talk"
STYLES_DIR="${HOME}/.claude/output-styles"
SKILLS_DIR="${HOME}/.claude/skills/robo"
SETTINGS_FILE="${HOME}/.claude/settings.json"
FLAG_FILE="${HOME}/.claude/.robo-mode"   # legacy installs only; safe to remove if absent

echo ""
echo "[ACTION] Uninstalling robo-talk..."

# Remove files
rm -rf "$INSTALL_DIR"
rm -f "$STYLES_DIR/robo-core.md"
rm -rf "$SKILLS_DIR"
rm -f "$FLAG_FILE"
rm -f "${HOME}/.claude/robo-statusline.sh"

echo "[STATUS] Files removed."

# Remove robo-talk settings from settings.json
# Reverts outputStyle plus the noise-reduction settings the installer added
# (only the ones still set to robo-talk's value, so user overrides are kept).
if [ -f "$SETTINGS_FILE" ] && command -v jq &>/dev/null; then
  TEMP=$(mktemp)
  jq '
    (if .outputStyle == "Robo Core" then del(.outputStyle) else . end)
    | (if .spinnerTipsEnabled == false then del(.spinnerTipsEnabled) else . end)
    | (if .showTurnDuration == false then del(.showTurnDuration) else . end)
    | (if .awaySummaryEnabled == false then del(.awaySummaryEnabled) else . end)
    | (if (.statusLine.command // "") | test("robo-statusline") then del(.statusLine) else . end)
  ' "$SETTINGS_FILE" > "$TEMP" && mv "$TEMP" "$SETTINGS_FILE"
  echo "[STATUS] robo-talk settings removed from $SETTINGS_FILE"
else
  echo "[WARNING] Check $SETTINGS_FILE and remove \"outputStyle\": \"Robo Core\" (and spinnerTipsEnabled/showTurnDuration/awaySummaryEnabled) manually."
fi

echo ""
echo "[COMPLETE] robo-talk uninstalled. Restart Claude Code to return to default style."
