#!/usr/bin/env bash
# Builds one results table (every project, one row per test level) and posts it to Teams.
# Each project's test job leaves summaries/summary-<Project>/summary.env behind.
# Set DRY_RUN=1 to print the card instead of posting it.
set -euo pipefail

SUMMARY_DIR="${SUMMARY_DIR:-summaries}"
PROJECTS=("Project1:Project 1" "Project2:Project 2")

NOW=$(date -u +"%a, %d %b %Y %H:%M:%S GMT")
TODAY=$(date -u +"%a %b %d %Y")
ANY_BAD=0
ROWS=""

cell() { # width text [color] [weight]
  printf '{"type":"Column","width":%s,"items":[{"type":"TextBlock","text":"%s","wrap":true,"color":"%s","weight":"%s"}]}' "$1" "$2" "${3:-Default}" "${4:-Default}"
}

add_row() { # label level total failed
  local status color
  if [ "$3" = "0" ]; then status="no results"; color="Attention"; ANY_BAD=1
  elif [ "$4" != "0" ]; then status="error"; color="Attention"; ANY_BAD=1
  else status="success"; color="Good"; fi
  ROWS="$ROWS,{\"type\":\"ColumnSet\",\"separator\":true,\"columns\":[$(cell 4 "$1 - $2"),$(cell 4 "$NOW"),$(cell 2 "$status" "$color"),$(cell 2 "$3"),$(cell 2 "$4")]}"
}

for entry in "${PROJECTS[@]}"; do
  dir="${entry%%:*}"
  label="${entry#*:}"
  D_TOTAL=0; D_FAILED=0; A_TOTAL=0; A_FAILED=0; B_TOTAL=0; B_FAILED=0; P_TOTAL=0; P_FAILED=0; JOB_STATUS=missing
  file="$SUMMARY_DIR/summary-$dir/summary.env"
  # A project that crashed before saving results keeps the zeros above and shows as "no results".
  if [ -f "$file" ]; then
    set -a; . "$file"; set +a
  fi
  [ "$JOB_STATUS" = "success" ] || ANY_BAD=1
  add_row "$label" "Backend unit (.NET)"   "$D_TOTAL" "$D_FAILED"
  add_row "$label" "Angular unit (Vitest)" "$A_TOTAL" "$A_FAILED"
  add_row "$label" "API (Bruno)"           "$B_TOTAL" "$B_FAILED"
  add_row "$label" "UI (Playwright)"       "$P_TOTAL" "$P_FAILED"
done

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
        { "type": "TextBlock", "size": "Large", "weight": "Bolder", "wrap": true, "text": "Test Results $TODAY" },
        { "type": "TextBlock", "wrap": true, "text": "Commit ${COMMIT:0:7} on ${BRANCH:-main} by ${ACTOR:-unknown}. Click [here]($RUN_URL) for more information" },
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
