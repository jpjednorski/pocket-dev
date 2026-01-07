#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

log_section "Security"

log_step "Installing security packages..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    fail2ban \
    nftables

log_step "Configuring nftables (Tailscale-only access)..."
sudo cp "$POCKET_DEV_DIR/config/nftables.conf" /etc/nftables.conf
sudo systemctl enable nftables
sudo systemctl restart nftables

log_step "Configuring fail2ban..."
sudo cp "$POCKET_DEV_DIR/config/fail2ban.local" /etc/fail2ban/jail.local
sudo systemctl enable fail2ban
sudo systemctl restart fail2ban

log_step "Hardening SSH..."
sudo cp "$POCKET_DEV_DIR/config/sshd_hardened.conf" /etc/ssh/sshd_config.d/99-pocket-dev.conf

CURRENT_USER=$(get_user)
if ! grep -q "AllowUsers" /etc/ssh/sshd_config.d/99-pocket-dev.conf; then
    echo "AllowUsers $CURRENT_USER" | sudo tee -a /etc/ssh/sshd_config.d/99-pocket-dev.conf > /dev/null
fi

sudo systemctl reload ssh || sudo systemctl reload sshd

log_step "Disabling UFW if present (using nftables instead)..."
if systemctl is-active --quiet ufw 2>/dev/null; then
    sudo ufw disable
    sudo systemctl stop ufw
    sudo systemctl disable ufw
fi

log_success "Security configured"
log_info "Firewall: Only Tailscale traffic allowed"
