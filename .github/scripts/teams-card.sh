#!/usr/bin/env bash
# Builds one results table (one row per project, one column per test level) and posts it to Teams.
# Each project's test job leaves summaries/summary-<Project>/summary.env behind.
# Set DRY_RUN=1 to print the card instead of posting it.
set -euo pipefail

SUMMARY_DIR="${SUMMARY_DIR:-summaries}"
PROJECTS=("Project1:Project 1" "Project2:Project 2")

NOW=$(date -u +"%d %b %Y %H:%M GMT")
TODAY=$(date -u +"%a %b %d %Y")
ANY_BAD=0
ROWS=""

col() { # width text [color] [weight]. Width 2 columns hold numbers and statuses, so they are centred.
  local align=Left; [ "$1" = "2" ] && align=Center
  printf '{"type":"Column","width":%s,"verticalContentAlignment":"Center","items":[{"type":"TextBlock","text":"%s","wrap":true,"color":"%s","weight":"%s","horizontalAlignment":"%s"}]}' "$1" "$2" "${3:-Default}" "${4:-Default}" "$align"
}

level_col() { # total failed -> "passed/total", red when something failed or nothing ran
  if [ "$1" = "0" ]; then col 2 "none" Attention
  elif [ "$2" != "0" ]; then col 2 "$(($1 - $2))/$1" Attention
  else col 2 "$1/$1" Good; fi
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

  TOTAL=$((D_TOTAL + A_TOTAL + B_TOTAL + P_TOTAL))
  FAILED=$((D_FAILED + A_FAILED + B_FAILED + P_FAILED))
  if [ "$FAILED" != "0" ]; then STATUS="error"
  elif [ "$D_TOTAL" = "0" ] || [ "$A_TOTAL" = "0" ] || [ "$B_TOTAL" = "0" ] || [ "$P_TOTAL" = "0" ]; then STATUS="no results"
  elif [ "$JOB_STATUS" != "success" ]; then STATUS="error"
  else STATUS="success"; fi
  if [ "$STATUS" = "success" ]; then COLOR="Good"; else COLOR="Attention"; ANY_BAD=1; fi

  ROWS="$ROWS,{\"type\":\"ColumnSet\",\"separator\":true,\"columns\":[$(col 3 "$label"),$(level_col "$D_TOTAL" "$D_FAILED"),$(level_col "$A_TOTAL" "$A_FAILED"),$(level_col "$B_TOTAL" "$B_FAILED"),$(level_col "$P_TOTAL" "$P_FAILED"),$(col 3 "$NOW"),$(col 2 "$STATUS" "$COLOR"),$(col 2 "$TOTAL"),$(col 2 "$FAILED")]}"
done

if [ "$ANY_BAD" = "1" ]; then
  FOOTER_TEXT="Some tests failed or did not run! If this is a project you work on, please investigate and correct the failing tests."
  FOOTER_COLOR="Attention"
else
  FOOTER_TEXT="All tests passed."
  FOOTER_COLOR="Good"
fi

HEADER="{\"type\":\"ColumnSet\",\"separator\":true,\"columns\":[$(col 3 Name Default Bolder),$(col 2 "API (.NET)" Default Bolder),$(col 2 Angular Default Bolder),$(col 2 Bruno Default Bolder),$(col 2 Playwright Default Bolder),$(col 3 "Last run" Default Bolder),$(col 2 Status Default Bolder),$(col 2 "Total Tests" Default Bolder),$(col 2 "Failed Tests" Default Bolder)]}"

CARD=$(cat <<JSON
{
  "type": "message",
  "attachments": [{
    "contentType": "application/vnd.microsoft.card.adaptive",
    "content": {
      "type": "AdaptiveCard",
      "version": "1.4",
      "msteams": { "width": "Full" },
      "body": [
        { "type": "TextBlock", "size": "Large", "weight": "Bolder", "wrap": true, "text": "Test Results $TODAY" },
        { "type": "TextBlock", "wrap": true, "text": "Commit ${COMMIT:0:7} on ${BRANCH:-main} by ${ACTOR:-unknown}. Click [here]($RUN_URL) for more information. Test columns show passed/total." },
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
