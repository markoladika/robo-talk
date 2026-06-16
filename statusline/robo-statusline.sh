#!/usr/bin/env bash
# robo-talk status line
# Shows: robo indicator, model, dir, context-usage bar, context tokens, rate limits.
# No dollar cost: cost.total_cost_usd is a pay-as-you-go ESTIMATE and is
# meaningless on a Pro/Max subscription. Rate limits (5h/7d) are the real
# subscription-usage signal. Token counts shown are CURRENT context, not
# cumulative session totals (the statusline does not expose those).
# Reads Claude Code session JSON on stdin. Field reference:
#   https://code.claude.com/docs/en/statusline
# Enable by pointing settings.json "statusLine".command at this file, or run
#   ROBO_STATUSLINE=1 bash install.sh
# Requires: jq.

input=$(cat)
j() { printf '%s' "$input" | jq -r "$1" 2>/dev/null; }

MODEL=$(j '.model.display_name // "?"')
PCT=$(j '.context_window.used_percentage // 0' | cut -d. -f1)
IN=$(j '.context_window.total_input_tokens // 0')
SIZE=$(j '.context_window.context_window_size // 0')
STYLE=$(j '.output_style.name // "Default"')
FIVE=$(j '.rate_limits.five_hour.used_percentage // empty')
FIVE_R=$(j '.rate_limits.five_hour.resets_at // empty')
WEEK=$(j '.rate_limits.seven_day.used_percentage // empty')
WEEK_R=$(j '.rate_limits.seven_day.resets_at // empty')

# Fallbacks if non-numeric
case "$PCT" in ''|*[!0-9]*) PCT=0 ;; esac
case "$IN"  in ''|*[!0-9]*) IN=0 ;; esac
case "$SIZE" in ''|*[!0-9]*) SIZE=0 ;; esac

# Human-readable token count: 146000 -> 146k, 1000000 -> 1.0M
hum() { if [ "$1" -ge 1000000 ]; then awk "BEGIN{printf \"%.1fM\", $1/1000000}"; else echo "$(( $1 / 1000 ))k"; fi; }

# Format a unix-epoch reset time in local time. Cross-platform: BSD `date -r`
# (macOS) and GNU `date -d @` (Linux). fmt_hour -> "4pm"; fmt_dayhour -> "Mon 4pm".
fmt_hour() {
  local e="$1" h ap
  h=$(date -r "$e" +'%I' 2>/dev/null) || h=$(date -d "@$e" +'%I' 2>/dev/null)
  ap=$(date -r "$e" +'%p' 2>/dev/null) || ap=$(date -d "@$e" +'%p' 2>/dev/null)
  [ -z "$h" ] && return
  h=${h#0}; [ -z "$h" ] && h=12
  printf '%s%s' "$h" "$(printf '%s' "$ap" | tr '[:upper:]' '[:lower:]')"
}
fmt_dayhour() {
  local e="$1" d t
  d=$(date -r "$e" +'%a' 2>/dev/null) || d=$(date -d "@$e" +'%a' 2>/dev/null)
  t=$(fmt_hour "$e"); [ -z "$t" ] && return
  printf '%s %s' "$d" "$t"
}

# Robo indicator only when an output style named "Robo Core*" is active
ROBO=""
case "$STYLE" in "Robo Core"*) ROBO="[ROBO] " ;; esac

GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; CYAN='\033[36m'; RESET='\033[0m'
if   [ "$PCT" -ge 90 ]; then C="$RED"
elif [ "$PCT" -ge 70 ]; then C="$YELLOW"
else                        C="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v F "%${FILLED}s"; printf -v E "%${EMPTY}s"
BAR="${F// /█}${E// /░}"

TOKENS="$(hum "$IN")"
[ "$SIZE" -gt 0 ] && TOKENS="${TOKENS}/$(hum "$SIZE")"

# 5h segment: reset time, before the bar.  7d segment: reset + usage, after tokens.
FIVE_SEG=""
[ -n "$FIVE_R" ] && FIVE_SEG="5h:$(fmt_hour "$FIVE_R")"
WEEK_SEG=""
if [ -n "$WEEK_R" ] || [ -n "$WEEK" ]; then
  WEEK_SEG="7d:"
  [ -n "$WEEK_R" ] && WEEK_SEG="${WEEK_SEG}$(fmt_dayhour "$WEEK_R") "
  [ -n "$WEEK" ] && WEEK_SEG="${WEEK_SEG}$(printf '%.0f' "$WEEK")%"
fi

LINE="${CYAN}${ROBO}${MODEL}${RESET}"
[ -n "$FIVE_SEG" ] && LINE="${LINE} | ${FIVE_SEG}"
LINE="${LINE}  ${C}${BAR}${RESET} ${PCT}% | ${TOKENS}"
[ -n "$WEEK_SEG" ] && LINE="${LINE} |  ${WEEK_SEG}"
printf '%b\n' "$LINE"
