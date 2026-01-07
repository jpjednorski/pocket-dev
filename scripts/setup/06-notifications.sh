#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

log_section "Push Notifications"

CURRENT_USER=$(get_user)
USER_HOME=$(get_home)

log_step "Configuring ntfy.sh notifications..."

ENV_FILE="$USER_HOME/.pocket-dev.env"
cat > "$ENV_FILE" << EOF
NTFY_TOPIC="${NTFY_TOPIC:-}"
EOF
chown "$CURRENT_USER:$CURRENT_USER" "$ENV_FILE"
chmod 600 "$ENV_FILE"

if [[ -n "${NTFY_TOPIC:-}" ]]; then
    log_step "Testing notification..."
    if curl -sf -X POST "https://ntfy.sh/$NTFY_TOPIC" \
        -H "Title: pocket-dev" \
        -H "Priority: low" \
        -H "Tags: white_check_mark" \
        -d "pocket-dev setup complete on $(hostname)" &>/dev/null; then
        log_success "Test notification sent"
    else
        log_warn "Could not send test notification"
    fi
    
    log_success "Notifications configured"
    log_info "Topic: $NTFY_TOPIC"
    log_info "Install ntfy app on iOS and subscribe to your topic"
else
    log_warn "No NTFY_TOPIC set - notifications disabled"
fi
