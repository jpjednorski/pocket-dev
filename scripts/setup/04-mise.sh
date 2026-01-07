#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

log_section "mise (Runtime Manager)"

CURRENT_USER=$(get_user)
USER_HOME=$(get_home)

if ! has_cmd mise; then
    log_step "Installing mise..."
    curl https://mise.run | sh
fi

MISE_BIN="$USER_HOME/.local/bin/mise"

log_step "Activating mise..."
eval "$("$MISE_BIN" activate bash)"

log_step "Copying tools.toml..."
ensure_dir "$USER_HOME/.config/mise"
cp "$POCKET_DEV_DIR/tools.toml" "$USER_HOME/.config/mise/config.toml"
chown -R "$CURRENT_USER:$CURRENT_USER" "$USER_HOME/.config/mise"

log_step "Installing pinned tools (this may take a few minutes)..."
sudo -u "$CURRENT_USER" "$MISE_BIN" install --yes

log_step "Installed tools:"
sudo -u "$CURRENT_USER" "$MISE_BIN" current

log_success "mise configured"
