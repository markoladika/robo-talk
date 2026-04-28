#!/bin/bash
# Robo-talk installer
# Usage: curl -fsSL https://raw.githubusercontent.com/markoladika/robo-talk/main/install.sh | bash
#    or: bash install.sh

set -e

REPO="https://github.com/markoladika/robo-talk"

# Detect target Claude Code config dirs.
# Override with: CLAUDE_HOMES="path1:path2" curl ... | bash
#
# A Claude Code config dir is identified by containing settings.json
# AND at least one Claude-specific subdir (projects/, todos/, statsig/,
# shell-snapshots/, ide/, plugins/). This catches:
#   - default ~/.claude
#   - multi-account ~/.claude01, ~/.claude02, ...
#   - XDG-style ~/.config/claude*
#   - custom CLAUDE_CONFIG_DIR locations used by account wrappers
is_claude_config_dir() {
  local d="$1"
  [ -d "$d" ] || return 1
  [ -f "$d/settings.json" ] || return 1
  for marker in projects todos statsig shell-snapshots ide plugins; do
    [ -d "$d/$marker" ] && return 0
  done
  return 1
}

if [ -n "$CLAUDE_HOMES" ]; then
  IFS=':' read -ra CLAUDE_DIRS <<< "$CLAUDE_HOMES"
else
  CLAUDE_DIRS=()
  # Scan likely roots; bounded depth to stay fast on big home dirs.
  while IFS= read -r -d '' settings; do
    d="$(dirname "$settings")"
    if is_claude_config_dir "$d"; then
      # de-dup
      skip=false
      for existing in "${CLAUDE_DIRS[@]}"; do
        [ "$existing" = "$d" ] && skip=true && break
      done
      $skip || CLAUDE_DIRS+=("$d")
    fi
  done < <(find "$HOME" -maxdepth 6 -type f -name settings.json \
             -not -path "*/node_modules/*" \
             -not -path "*/.cache/*" \
             -not -path "*/.git/*" \
             -not -path "*/projects/*" \
             -print0 2>/dev/null)
  # Fallback if nothing found (fresh machine, first install)
  [ ${#CLAUDE_DIRS[@]} -eq 0 ] && CLAUDE_DIRS=("$HOME/.claude")
fi

# Clone/update the repo once, into the primary account
INSTALL_DIR="${CLAUDE_DIRS[0]}/robo-talk"

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

# Make hooks executable
chmod +x "$INSTALL_DIR/hooks/"*.sh "$INSTALL_DIR/hooks/"*.js 2>/dev/null || true

# Install into every detected account
for CLAUDE_DIR in "${CLAUDE_DIRS[@]}"; do
  echo "[STATUS] Installing into $CLAUDE_DIR"
  STYLES_DIR="$CLAUDE_DIR/output-styles"
  SKILLS_DIR="$CLAUDE_DIR/skills/robo"
  SETTINGS_FILE="$CLAUDE_DIR/settings.json"

  mkdir -p "$STYLES_DIR" "$SKILLS_DIR"
  cp "$INSTALL_DIR/output-styles/robo-core.md" "$STYLES_DIR/"
  cp "$INSTALL_DIR/skills/robo/SKILL.md" "$SKILLS_DIR/"

  mkdir -p "$(dirname "$SETTINGS_FILE")"
  if command -v node &>/dev/null; then
    node -e '
      const fs = require("fs");
      const f = process.argv[1];
      const d = fs.existsSync(f) ? JSON.parse(fs.readFileSync(f, "utf8")) : {};
      d.outputStyle = "Robo Core";
      fs.writeFileSync(f, JSON.stringify(d, null, 2) + "\n");
    ' "$SETTINGS_FILE"
  else
    if [ ! -f "$SETTINGS_FILE" ]; then
      echo '{"outputStyle": "Robo Core"}' > "$SETTINGS_FILE"
    else
      echo "[WARNING] node not found. Add manually to $SETTINGS_FILE:"
      echo '  "outputStyle": "Robo Core"'
    fi
  fi
done

echo ""
echo "[COMPLETE] robo-talk installed and activated for ${#CLAUDE_DIRS[@]} account(s)."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Start a new Claude Code session. Robo Core is active."
echo ""
echo " To deactivate: /config → Output style → Default"
echo " To uninstall:  rm -rf ~/.claude/robo-talk ~/.claude*/output-styles/robo-core.md ~/.claude*/skills/robo"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
