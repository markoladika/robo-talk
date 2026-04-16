---
name: robo
description: Display robo-talk status and toggle on/off. Use /robo, /robo on, /robo off.
---

# Robo-Talk Toggle

Check current status in ~/.claude/settings.json and display it to the user.

**If Robo Core is currently ON:**
- Confirm: "Robo Core is ON"
- Show: **Status codes:** [DIAGNOSIS] [ACTION] [SCAN] [PATCH] [RESULT] [ERROR] [DECISION] [COMPLETE] [STATUS] [NEXT] [WARNING] [BLOCKED]
- Offer: "Type `/robo off` or `/robo OFF` to turn it off"

**If Robo Core is currently OFF:**
- Confirm: "Robo Core is OFF"
- Show: Output style is Default
- Offer: "Type `/robo on` or `/robo ON` to turn it on"

**If user provided "on", "ON", "off", or "OFF" argument:**
- Silently update ~/.claude/settings.json outputStyle field (do NOT show diff):
  - For "on"/"ON": set to "Robo Core"
  - For "off"/"OFF": set to "Default"
- Confirm briefly: "[STATUS] Robo Core is now [ON/OFF]. Start a new session to apply."
- Do NOT change the current session — new session required for style to activate

**Design notes:**
- Read settings.json, extract current outputStyle value
- If outputStyle is "Robo Core", status is ON; otherwise OFF
- If user passed an argument, update silently and confirm; no file diff display
- Do not show Update() output or changed lines
- If no argument, just display status
- No contractions in responses
- Keep output brief and direct
