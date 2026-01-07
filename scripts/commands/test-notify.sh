#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

USER_HOME=$(get_home)

if [[ -f "$USER_HOME/.pocket-dev.env" ]]; then
    source "$USER_HOME/.pocket-dev.env"
fi

TOPIC="${NTFY_TOPIC:-}"

if [[ -z "$TOPIC" ]]; then
    log_error "NTFY_TOPIC not configured"
    log_info "Set it in $POCKET_DEV_DIR/.env and run 'just install' again"
    exit 1
fi

log_step "Sending test notification to topic: $TOPIC"

if curl -sf -X POST "https://ntfy.sh/$TOPIC" \
    -H "Title: pocket-dev test" \
    -H "Priority: default" \
    -H "Tags: test_tube" \
    -d "Test notification from $(hostname) at $(date '+%H:%M:%S')"; then
    echo ""
    log_success "Notification sent! Check your phone."
else
    echo ""
    log_error "Failed to send notification"
    exit 1
fi
