#!/usr/bin/env node

// Robo-talk SessionStart hook
// Emits CORE mode rules to stdout — Claude Code injects this as session context.
// Writes mode flag to ~/.claude/.robo-mode if missing.

const fs = require("fs");
const path = require("path");
const os = require("os");

const FLAG_FILE = path.join(os.homedir(), ".claude", ".robo-mode");
const RULES_DIR = path.join(__dirname, "..", "output-styles");

// Read or initialize mode
let mode = "core";
try {
  if (fs.existsSync(FLAG_FILE)) {
    mode = fs.readFileSync(FLAG_FILE, "utf8").trim() || "core";
  } else {
    fs.mkdirSync(path.dirname(FLAG_FILE), { recursive: true });
    fs.writeFileSync(FLAG_FILE, "core", "utf8");
  }
} catch {
  // If flag file is unreadable, default to core
  mode = "core";
}

// Load rules file
const rulesFile = path.join(RULES_DIR, `robo-${mode}.md`);
let rules;
try {
  rules = fs.readFileSync(rulesFile, "utf8");
} catch {
  // Fallback to core if requested mode file is missing
  rules = fs.readFileSync(path.join(RULES_DIR, "robo-core.md"), "utf8");
}

// Strip frontmatter (output styles have YAML frontmatter we do not need in hook output)
const stripped = rules.replace(/^---[\s\S]*?---\n*/, "");

// Emit to stdout — Claude Code injects SessionStart hook stdout as context
process.stdout.write(stripped);
