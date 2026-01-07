#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

log_section "Authentication"

USER_HOME=$(get_home)
SSH_KEY="$USER_HOME/.ssh/id_ed25519.pub"

echo ""
log_step "GitHub CLI Authentication"
if gh auth status &>/dev/null; then
    log_info "Already authenticated with GitHub"
else
    log_info "Opening GitHub authentication..."
    gh auth login --web --git-protocol ssh
fi

if [[ -f "$SSH_KEY" ]]; then
    log_step "Adding SSH key to GitHub..."
    KEY_TITLE="pocket-dev-$(hostname)-$(date +%Y%m%d)"
    if gh ssh-key add "$SSH_KEY" --title "$KEY_TITLE" 2>/dev/null; then
        log_success "SSH key added to GitHub"
    else
        log_info "Key may already exist on GitHub (this is fine)"
    fi
fi

log_step "Configuring git user from GitHub profile..."
if ! git config --global user.name &>/dev/null; then
    GH_NAME=$(gh api user --jq '.name' 2>/dev/null || echo "")
    if [[ -n "$GH_NAME" ]]; then
        git config --global user.name "$GH_NAME"
        log_info "Set git user.name: $GH_NAME"
    fi
fi

if ! git config --global user.email &>/dev/null; then
    GH_EMAIL=$(gh api user/emails --jq '.[0].email' 2>/dev/null || echo "")
    if [[ -n "$GH_EMAIL" ]]; then
        git config --global user.email "$GH_EMAIL"
        log_info "Set git user.email: $GH_EMAIL"
    fi
fi

echo ""
log_step "Claude Code Authentication"
log_info "This will open a browser for OAuth..."
if has_cmd claude; then
    claude login || log_warn "Claude login skipped or failed"
else
    log_warn "Claude not installed"
fi

echo ""
log_step "OpenCode Authentication"
if has_cmd opencode; then
    opencode auth || log_warn "OpenCode auth skipped or failed"
else
    log_warn "OpenCode not installed"
fi

echo ""
log_success "Authentication complete!"
echo ""
log_info "Next: Add repos to repos.txt, then run 'just clone-repos'"
