# robo-talk

**Robotic communication style for Claude Code.** Terse. Structured. 59.8% fewer tokens.

Eliminates filler, enforces status codes, improves scannability. One model call. Same cost as default — but faster to read.

---

## Install

**One-liner:**
```bash
curl -fsSL https://raw.githubusercontent.com/markoladika/robo-talk/main/install.sh | bash
```

Start a new Claude Code session. Done.

**Manual:**
1. Copy `output-styles/robo-core-minimal.md` to `~/.claude/output-styles/`
2. Add to `~/.claude/settings.json`: `"outputStyle": "Robo Core"`
3. Restart Claude Code

---

## Usage

**Check status:** `/robo`  
**Turn on:** `/robo on`  
**Turn off:** `/robo off`  

Manual: Edit `~/.claude/settings.json`, change `"outputStyle": "Robo Core"` → `"Robo Core"` or `"Default"`. Restart Claude Code.

---

## Before & After

**Default Claude:**
> That's a great question! When you change a function signature, it can cause a cascade of issues throughout your codebase. Let me help you understand...

**Robo Core:**
> [DIAGNOSIS] Signature change broke 3 call sites and 2 test files.
> ```bash
> grep -rn "oldFunctionName" src/
> ```
> [NEXT] Update each call site with new parameter. Run `npm test` to verify.

**Result:** Same info. 59.8% fewer tokens. Faster to scan.

---

## Token Metrics

| Metric | Result |
|--------|--------|
| Output reduction | 59.8% |
| Overall savings (with cache) | 12% |
| System prompt | 350 tokens |
| Response length reduction | 60.9% |

**How it works:** Robo-Talk injects style rules into Claude's system prompt. Model self-enforces rules. Zero API overhead.

**With prompt caching:** First request pays 350 tokens (cached), subsequent requests reuse cache. Multi-turn sessions see 12%+ savings.

---

## Status Codes

| Code | Meaning |
|------|---------|
| `[DIAGNOSIS]` | Problem identified |
| `[ACTION]` | Executing task |
| `[SCAN]` | Searching files |
| `[PATCH]` | Code change |
| `[RESULT]` | Output/data |
| `[ERROR]` | Failed |
| `[DECISION]` | Input needed |
| `[WARNING]` | Risk |
| `[STATUS]` | Update |

**Closing tags:** `[NEXT →]` `[DECISION →]` `[COMPLETE ■]` `[BLOCKED →]`

---

## Rules

- No contractions ("do not" not "don't")
- No filler (just, simply, basically, actually, really)
- No sycophancy (Great question, Happy to help, Certainly)
- No hedging (maybe, perhaps, possibly)
- No apologies (sorry, apologize)
- No trailing summaries
- **Max 2 lines prose** — everything else is code/files/status codes
- **Short sentences** — Subject. Verb. Object.
- **Binary framing** — YES or NO before nuance
- **Every response** — starts with code, ends with tag

---

## System Prompts

- **robo-core-minimal.md** (350 tokens) — recommended, use for API
- **robo-core.md** (3,069 tokens) — full docs, use in Claude Code

Both enforce identical rules. Minimal version removes verbose explanations.

---

## FAQ

**Not working?** Verify `~/.claude/settings.json` has `"outputStyle": "Robo Core"`. Start new Claude Code session. Run `/robo` to check.

**Turn it off?** Edit settings: `"outputStyle": "Default"`. Restart Claude Code.

**Does it reduce accuracy?** No. Brevity constraints can improve accuracy on certain tasks.

**Works on all models?** Yes. Tested on Claude Opus. Works on all Claude models.

---

## Links

**GitHub:** https://github.com/markoladika/robo-talk  
**License:** MIT — Free to use, modify, distribute

---

**Start a new Claude Code session to activate Robo Core.**
