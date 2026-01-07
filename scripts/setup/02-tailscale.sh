#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

log_section "Tailscale"

if ! has_cmd tailscale; then
    log_step "Installing Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
fi

log_step "Enabling Tailscale service..."
sudo systemctl enable tailscaled
sudo systemctl start tailscaled

if [[ -n "${TAILSCALE_AUTH_KEY:-}" ]]; then
    log_step "Authenticating with Tailscale..."
    sudo tailscale up --auth-key="$TAILSCALE_AUTH_KEY" --ssh --accept-routes
    
    sleep 2
    
    TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "pending")
    log_success "Tailscale connected"
    log_info "Tailscale IP: $TAILSCALE_IP"
else
    log_warn "No TAILSCALE_AUTH_KEY set"
    log_info "Run manually: sudo tailscale up --ssh"
fi

log_step "Tailscale status:"
tailscale status 2>/dev/null || log_info "Not yet connected"
