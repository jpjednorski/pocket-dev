#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

log_section "Git SSH Setup"

CURRENT_USER=$(get_user)
USER_HOME=$(get_home)
SSH_DIR="$USER_HOME/.ssh"
SSH_KEY="$SSH_DIR/id_ed25519"

ensure_dir "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [[ ! -f "$SSH_KEY" ]]; then
    log_step "Generating SSH key..."
    ssh-keygen -t ed25519 -f "$SSH_KEY" -N "" -C "pocket-dev@$(hostname)"
    log_success "SSH key generated"
else
    log_info "SSH key already exists"
fi

chown -R "$CURRENT_USER:$CURRENT_USER" "$SSH_DIR"
chmod 600 "$SSH_KEY"
chmod 644 "${SSH_KEY}.pub"

log_step "Configuring SSH for GitHub..."
SSH_CONFIG="$SSH_DIR/config"
if ! grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
    cat >> "$SSH_CONFIG" << 'EOF'

Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
EOF
    chown "$CURRENT_USER:$CURRENT_USER" "$SSH_CONFIG"
    chmod 600 "$SSH_CONFIG"
fi

log_step "Installing GitHub CLI..."
if ! has_cmd gh; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update -qq
    sudo apt-get install -y -qq gh
fi

echo ""
log_success "Git configured"
log_info "Your public key:"
echo ""
cat "${SSH_KEY}.pub"
echo ""
log_info "Run 'just auth' to authenticate with GitHub and register this key"
