#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

log_section "AI Tools"

CURRENT_USER=$(get_user)
USER_HOME=$(get_home)
MISE_BIN="$USER_HOME/.local/bin/mise"

eval "$("$MISE_BIN" activate bash)"

log_step "Installing Claude Code..."
if ! has_cmd claude; then
    npm install -g @anthropic-ai/claude-code
fi

log_step "Installing OpenCode..."
export PATH="$USER_HOME/.opencode/bin:$PATH"
if ! has_cmd opencode; then
    curl -fsSL https://opencode.ai/install | bash
fi

log_step "Installing oh-my-opencode plugin..."
eval "$("$MISE_BIN" activate bash)"
OMO_CLAUDE="${OMO_CLAUDE:-yes}"
OMO_CHATGPT="${OMO_CHATGPT:-no}"
OMO_GEMINI="${OMO_GEMINI:-no}"
bunx oh-my-opencode install --no-tui --claude="$OMO_CLAUDE" --chatgpt="$OMO_CHATGPT" --gemini="$OMO_GEMINI"

log_step "Configuring Claude hooks..."
CLAUDE_DIR="$USER_HOME/.claude"
ensure_dir "$CLAUDE_DIR/hooks"

cp "$POCKET_DEV_DIR/dotfiles/.claude/settings.json" "$CLAUDE_DIR/"
cp "$POCKET_DEV_DIR/dotfiles/.claude/hooks/notify.sh" "$CLAUDE_DIR/hooks/"
chmod +x "$CLAUDE_DIR/hooks/notify.sh"
chown -R "$CURRENT_USER:$CURRENT_USER" "$CLAUDE_DIR"

log_step "Configuring OpenCode..."
OPENCODE_DIR="$USER_HOME/.config/opencode"
ensure_dir "$OPENCODE_DIR"
if [[ -f "$POCKET_DEV_DIR/dotfiles/.config/opencode/config.toml" ]]; then
    cp "$POCKET_DEV_DIR/dotfiles/.config/opencode/config.toml" "$OPENCODE_DIR/"
fi
chown -R "$CURRENT_USER:$CURRENT_USER" "$OPENCODE_DIR"

log_step "Installing Linearis (Linear CLI)..."
if ! has_cmd linearis; then
    npm install -g linearis
fi

if [[ -n "${LINEAR_API_TOKEN:-}" ]]; then
    log_step "Configuring Linearis..."
    echo "$LINEAR_API_TOKEN" > "$USER_HOME/.linear_api_token"
    chmod 600 "$USER_HOME/.linear_api_token"
    chown "$CURRENT_USER:$CURRENT_USER" "$USER_HOME/.linear_api_token"
    log_success "Linearis configured with API token"
else
    log_info "LINEAR_API_TOKEN not set - configure later with: echo 'token' > ~/.linear_api_token"
fi

log_success "AI tools installed"
log_info "Run 'just auth' to authenticate with Claude and OpenCode"
