#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

log_section "Shell Configuration"

CURRENT_USER=$(get_user)
USER_HOME=$(get_home)

log_step "Installing oh-my-zsh..."
if [[ ! -d "$USER_HOME/.oh-my-zsh" ]]; then
    sudo -u "$CURRENT_USER" sh -c 'RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'
fi

log_step "Setting zsh as default shell..."
if [[ "$(getent passwd "$CURRENT_USER" | cut -d: -f7)" != *"zsh"* ]]; then
    sudo chsh -s "$(which zsh)" "$CURRENT_USER"
fi

log_step "Configuring .zshrc..."
cp "$POCKET_DEV_DIR/dotfiles/.zshrc" "$USER_HOME/.zshrc"
chown "$CURRENT_USER:$CURRENT_USER" "$USER_HOME/.zshrc"

log_step "Configuring tmux..."
cp "$POCKET_DEV_DIR/config/tmux.conf" "$USER_HOME/.tmux.conf"
chown "$CURRENT_USER:$CURRENT_USER" "$USER_HOME/.tmux.conf"

log_step "Creating Code directory..."
ensure_dir "$USER_HOME/Code"
chown "$CURRENT_USER:$CURRENT_USER" "$USER_HOME/Code"

log_success "Shell configured"
log_info "Using zsh + oh-my-zsh with git plugin"
log_info "tmux prefix: C-a"
