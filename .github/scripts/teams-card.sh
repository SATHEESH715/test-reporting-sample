#!/usr/bin/env bash
# Builds a results table card (one row per test level) and posts it to Teams.
# Set DRY_RUN=1 to print the card instead of posting it.
set -euo pipefail

NOW=$(date -u +"%a, %d %b %Y %H:%M:%S GMT")
TODAY=$(date -u +"%a %b %d %Y")
ANY_BAD=0
ROWS=""

cell() { # width text [color] [weight]
  printf '{"type":"Column","width":%s,"items":[{"type":"TextBlock","text":"%s","wrap":true,"color":"%s","weight":"%s"}]}' "$1" "$2" "${3:-Default}" "${4:-Default}"
}

add_row() { # level total failed
  local status color
  if [ "$2" = "0" ]; then status="no results"; color="Attention"; ANY_BAD=1
  elif [ "$3" != "0" ]; then status="error"; color="Attention"; ANY_BAD=1
  else status="success"; color="Good"; fi
  ROWS="$ROWS,{\"type\":\"ColumnSet\",\"separator\":true,\"columns\":[$(cell 4 "$PROJECT - $1"),$(cell 4 "$NOW"),$(cell 2 "$status" "$color"),$(cell 2 "$2"),$(cell 2 "$3")]}"
}

add_row "Backend unit (.NET)"   "$D_TOTAL" "$D_FAILED"
add_row "Angular unit (Vitest)" "$A_TOTAL" "$A_FAILED"
add_row "API (Bruno)"           "$B_TOTAL" "$B_FAILED"
add_row "UI (Playwright)"       "$P_TOTAL" "$P_FAILED"
[ "${JOB_STATUS:-success}" = "success" ] || ANY_BAD=1

if [ "$ANY_BAD" = "1" ]; then
  FOOTER_TEXT="Some tests failed or did not run! If this is a project you work on, please investigate and correct the failing tests."
  FOOTER_COLOR="Attention"
else
  FOOTER_TEXT="All tests passed."
  FOOTER_COLOR="Good"
fi

HEADER="{\"type\":\"ColumnSet\",\"separator\":true,\"columns\":[$(cell 4 Name Default Bolder),$(cell 4 "Last run" Default Bolder),$(cell 2 Status Default Bolder),$(cell 2 "Total Tests" Default Bolder),$(cell 2 "Failed Tests" Default Bolder)]}"

CARD=$(cat <<JSON
{
  "type": "message",
  "attachments": [{
    "contentType": "application/vnd.microsoft.card.adaptive",
    "content": {
      "type": "AdaptiveCard",
      "version": "1.4",
      "body": [
        { "type": "TextBlock", "size": "Large", "weight": "Bolder", "wrap": true, "text": "$PROJECT Test Results $TODAY" },
        { "type": "TextBlock", "wrap": true, "text": "Click [here]($RUN_URL) for more information" },
        $HEADER$ROWS,
        { "type": "TextBlock", "wrap": true, "separator": true, "weight": "Bolder", "color": "$FOOTER_COLOR", "text": "$FOOTER_TEXT" }
      ]
    }
  }]
}
JSON
)

if [ "${DRY_RUN:-0}" = "1" ]; then
  echo "$CARD"
else
  curl -sf -X POST "$TEAMS_URL" -H "Content-Type: application/json" -d "$CARD"
fi
