# pocket-dev - mobile AI coding environment
# https://github.com/YOUR_USERNAME/pocket-dev

set dotenv-load
set shell := ["bash", "-cu"]

export POCKET_DEV_DIR := env_var_or_default("POCKET_DEV_DIR", "~/.pocket-dev")

# Default: show help
default:
    @just --list

# ══════════════════════════════════════
# SETUP
# ══════════════════════════════════════

# Full installation (run on fresh VPS)
install:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
    
    echo "🚀 Starting pocket-dev installation..."
    echo ""
    
    # Make scripts executable
    chmod +x scripts/setup/*.sh scripts/commands/*.sh scripts/lib/*.sh 2>/dev/null || true
    
    # Run setup scripts in order
    ./scripts/setup/00-prereqs.sh
    ./scripts/setup/01-security.sh
    ./scripts/setup/02-tailscale.sh
    ./scripts/setup/03-shell.sh
    ./scripts/setup/04-mise.sh
    ./scripts/setup/05-ai-tools.sh
    ./scripts/setup/06-notifications.sh
    ./scripts/setup/07-git.sh
    
    echo ""
    echo "════════════════════════════════════════════════"
    echo "  ✅ Installation complete!"
    echo "════════════════════════════════════════════════"
    echo ""
    echo "Next steps:"
    echo "  1. Reconnect via Tailscale:"
    echo "     mosh $(tailscale ip -4 2>/dev/null || echo '<tailscale-ip>')@$(hostname)"
    echo ""
    echo "  2. Run authentication:"
    echo "     just auth"
    echo ""
    echo "  3. Add repos to repos.txt, then:"
    echo "     just clone-repos"
    echo ""

# Interactive authentication (claude, gh, opencode)
auth:
    @./scripts/commands/auth.sh

# Clone repos from repos.txt
clone-repos:
    @./scripts/commands/clone-repos.sh

# ══════════════════════════════════════
# TOOLS
# ══════════════════════════════════════

# Add a new tool via mise (e.g., just add-tool go 1.22.0)
add-tool tool version:
    mise use --global {{tool}}@{{version}}
    mise install

# Update all mise tools to latest within pinned major versions
update-tools:
    mise upgrade

# List installed tools
tools:
    mise current

# ══════════════════════════════════════
# NOTIFICATIONS
# ══════════════════════════════════════

# Test push notification
test-notify:
    @./scripts/commands/test-notify.sh

# ══════════════════════════════════════
# MAINTENANCE
# ══════════════════════════════════════

# Update pocket-dev to latest version
update:
    #!/usr/bin/env bash
    set -euo pipefail
    cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
    git pull --rebase
    just install

# Check system status
status:
    #!/usr/bin/env bash
    set -euo pipefail
    source scripts/lib/common.sh
    
    log_section "System Status"
    
    echo ""
    echo "Tailscale:"
    if has_cmd tailscale; then
        tailscale status 2>/dev/null || echo "  Not connected"
    else
        echo "  Not installed"
    fi
    
    echo ""
    echo "Services:"
    for svc in tailscaled fail2ban nftables ssh; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            echo "  ✓ $svc"
        else
            echo "  ✗ $svc"
        fi
    done
    
    echo ""
    echo "Tools:"
    if has_cmd mise; then
        mise current 2>/dev/null | head -10
    else
        echo "  mise not installed"
    fi
    
    echo ""
    echo "AI Tools:"
    has_cmd claude && echo "  ✓ claude" || echo "  ✗ claude"
    has_cmd opencode && echo "  ✓ opencode" || echo "  ✗ opencode"

# Show connection info for mobile
connect-info:
    #!/usr/bin/env bash
    set -euo pipefail
    echo ""
    echo "📱 Connect from mobile:"
    echo ""
    echo "  mosh $(whoami)@$(tailscale ip -4 2>/dev/null || echo '<tailscale-ip>')"
    echo ""
    echo "Or in Termius:"
    echo "  Host: $(tailscale ip -4 2>/dev/null || echo '<tailscale-ip>')"
    echo "  User: $(whoami)"
    echo "  Use mosh: ON"
    echo ""

# ══════════════════════════════════════
# DEVELOPMENT
# ══════════════════════════════════════

# Validate all scripts with shellcheck
lint:
    shellcheck scripts/**/*.sh

# Run a specific setup script (for testing)
run-script script:
    ./scripts/setup/{{script}}.sh
