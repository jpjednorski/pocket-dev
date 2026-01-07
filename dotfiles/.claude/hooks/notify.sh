#!/usr/bin/env bash
set -euo pipefail

[[ -f ~/.pocket-dev.env ]] && source ~/.pocket-dev.env

TOPIC="${NTFY_TOPIC:-}"
[[ -z "$TOPIC" ]] && exit 0

TYPE="${1:-}"
PROJECT="${PROJECT_NAME:-$(basename "$PWD")}"

QUESTION=""
if [[ -n "${CLAUDE_EVENT_DATA:-}" ]]; then
    QUESTION=$(echo "$CLAUDE_EVENT_DATA" | jq -r '.tool_input.questions[0].question // empty' 2>/dev/null || echo "")
fi

case "$TYPE" in
    question)
        MSG="$PROJECT: Claude needs input"
        [[ -n "$QUESTION" ]] && MSG="$MSG - ${QUESTION:0:100}"
        ;;
    *)
        MSG="$PROJECT: Claude notification"
        ;;
esac

curl -sf -X POST "https://ntfy.sh/$TOPIC" \
    -H "Title: pocket-dev" \
    -H "Priority: high" \
    -H "Tags: robot" \
    -d "$MSG" &>/dev/null &

exit 0
