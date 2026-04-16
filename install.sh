#!/bin/bash
# Robo-talk installer
# Usage: curl -fsSL https://raw.githubusercontent.com/markoladika/robo-talk/main/install.sh | bash
#    or: bash install.sh

set -e

REPO="https://github.com/markoladika/robo-talk"
INSTALL_DIR="${HOME}/.claude/robo-talk"
STYLES_DIR="${HOME}/.claude/output-styles"
SKILLS_DIR="${HOME}/.claude/skills/robo"

# Detect if running from local repo (for testing)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_MODE=false
if [ -f "$SCRIPT_DIR/output-styles/robo-core.md" ]; then
  LOCAL_MODE=true
fi

echo ""
echo "[ACTION] Installing robo-talk..."

if [ "$LOCAL_MODE" = true ]; then
  # Local install — copy from current directory
  echo "[STATUS] Local repo detected. Installing from $SCRIPT_DIR"
  rm -rf "$INSTALL_DIR"
  mkdir -p "$INSTALL_DIR"
  cp -R "$SCRIPT_DIR"/* "$INSTALL_DIR/"
  cp "$SCRIPT_DIR"/.gitignore "$INSTALL_DIR/" 2>/dev/null || true
else
  # Remote install — clone from GitHub
  if [ -d "$INSTALL_DIR" ]; then
    echo "[STATUS] Existing install found. Updating."
    cd "$INSTALL_DIR" && git pull --quiet
  else
    git clone --depth 1 "$REPO" "$INSTALL_DIR"
  fi
fi

# Copy output style
mkdir -p "$STYLES_DIR"
cp "$INSTALL_DIR/output-styles/robo-core.md" "$STYLES_DIR/"
echo "[STATUS] Output style copied to $STYLES_DIR/robo-core.md"

# Copy skill
mkdir -p "$SKILLS_DIR"
cp "$INSTALL_DIR/skills/robo/SKILL.md" "$SKILLS_DIR/"
echo "[STATUS] Skill /robo copied to $SKILLS_DIR/"

# Make hooks executable
chmod +x "$INSTALL_DIR/hooks/"*.sh "$INSTALL_DIR/hooks/"*.js 2>/dev/null || true

# Auto-activate output style in ~/.claude/settings.json
SETTINGS_FILE="${HOME}/.claude/settings.json"
if command -v jq &>/dev/null; then
  if [ -f "$SETTINGS_FILE" ]; then
    # Merge outputStyle into existing settings
    TEMP=$(mktemp)
    jq '. + {"outputStyle": "Robo Core"}' "$SETTINGS_FILE" > "$TEMP" && mv "$TEMP" "$SETTINGS_FILE"
  else
    echo '{"outputStyle": "Robo Core"}' > "$SETTINGS_FILE"
  fi
  echo "[STATUS] Output style activated in $SETTINGS_FILE"
else
  # No jq — write if file does not exist, otherwise instruct user
  if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{"outputStyle": "Robo Core"}' > "$SETTINGS_FILE"
    echo "[STATUS] Output style activated in $SETTINGS_FILE"
  else
    echo "[WARNING] jq not found. Add manually to $SETTINGS_FILE:"
    echo '  "outputStyle": "Robo Core"'
  fi
fi

echo ""
echo "[COMPLETE] robo-talk installed and activated."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Start a new Claude Code session. Robo Core is active."
echo ""
echo " To deactivate: /config → Output style → Default"
echo " To uninstall:  rm -rf ~/.claude/robo-talk ~/.claude/output-styles/robo-core.md ~/.claude/skills/robo"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
