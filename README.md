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
1. Copy `output-styles/robo-core.md` to `~/.claude/output-styles/`
2. Add to `~/.claude/settings.json`: `"outputStyle": "Robo Core"`
3. Restart Claude Code

The one-liner also sets three optional noise-reduction settings (`spinnerTipsEnabled`, `showTurnDuration`, `awaySummaryEnabled` → `false`) — only if you have not already chosen a value. `uninstall.sh` reverts them.

---

## Usage

**Check status:** `/robo`  
**Turn on:** `/robo on`  
**Turn off:** `/robo off`  

Manual: Edit `~/.claude/settings.json`, set `"outputStyle"` to `"Robo Core"` (on) or `"Default"` (off). Restart Claude Code.

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

Two variants ship; install **one**. They have distinct style names so they never collide in `/config`:

- **robo-core.md** — style name `Robo Core` (3,069 tokens). Full instructions. Installed by default; recommended for Claude Code.
- **robo-core-minimal.md** — style name `Robo Core Minimal` (~350 tokens). Leanest variant; good for API system prompts or a smaller footprint.

Both enforce identical rules. The minimal version removes verbose explanations.

---

## Status line (tokens & usage)

robo-talk ships an optional status line at `statusline/robo-statusline.sh`. It reads the session JSON Claude Code sends on stdin and shows one compact row:

```
[ROBO] Opus 4.8 | 5h:4pm  ███████░░░ 73% | 146k/200k |  7d:Mon 4pm 41%
```

- **Robo indicator** — `[ROBO]` appears only when the active output style is `Robo Core*` (read from `output_style.name`).
- **5h window** — `5h:4pm` = when the 5-hour limit resets, from `rate_limits.five_hour.resets_at`.
- **Context usage** — color-coded bar + `%` from `context_window.used_percentage` (green <70%, yellow 70–89%, red 90%+).
- **Context tokens** — `146k/200k` from `context_window.total_input_tokens` and `context_window_size` (live context window, not cumulative session totals — the status line does not expose those).
- **7d window** — `7d:Mon 4pm 41%` = reset day/time + percent used, from `rate_limits.seven_day.*`.

Reset times render in local time (works on macOS and Linux). Rate-limit segments appear only for Pro/Max subscribers, after the first response.

> **No dollar cost shown.** `cost.total_cost_usd` is a pay-as-you-go *estimate* computed from token usage — it is meaningless on a Pro/Max subscription (you do not pay per token), so this status line omits it. Watch the rate-limit percentages instead.

Requires `jq`. **Enable it** (it never overwrites an existing status line):

```bash
# during install
ROBO_STATUSLINE=1 curl -fsSL https://raw.githubusercontent.com/markoladika/robo-talk/main/install.sh | bash
```

Or manually, in `~/.claude/settings.json`:

```json
{
  "statusLine": { "type": "command", "command": "~/.claude/robo-statusline.sh" }
}
```

**Already have your own status line?** Keep it — just add a robo indicator by reading `output_style.name` from the stdin JSON:

```bash
STYLE=$(echo "$input" | jq -r '.output_style.name // "Default"')
case "$STYLE" in "Robo Core"*) echo -n "[ROBO] ";; esac
```

---

## FAQ

**Not working?** Verify `~/.claude/settings.json` has `"outputStyle": "Robo Core"`. Start new Claude Code session. Run `/robo` to check.

**Turn it off?** Edit settings: `"outputStyle": "Default"`. Restart Claude Code.

**Does it reduce accuracy?** No. Brevity constraints can improve accuracy on certain tasks.

**Works on all models?** Yes. Works on all current Claude models (Opus 4.8, Sonnet 4.6, Haiku 4.5, Fable 5).

---

## Links

**GitHub:** https://github.com/markoladika/robo-talk  
**License:** MIT — Free to use, modify, distribute

---

**Start a new Claude Code session to activate Robo Core.**
