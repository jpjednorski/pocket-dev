#!/usr/bin/env bash
# Shared functions for pocket-dev scripts

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Paths
export POCKET_DEV_DIR="${POCKET_DEV_DIR:-$HOME/.pocket-dev}"

# Load .env if exists
load_env() {
    if [[ -f "$POCKET_DEV_DIR/.env" ]]; then
        set -a
        # shellcheck source=/dev/null
        source "$POCKET_DEV_DIR/.env"
        set +a
    fi
}

# Auto-load env
load_env

# Logging functions
log_section() {
    echo ""
    echo -e "${BLUE}${BOLD}══════════════════════════════════════${NC}"
    echo -e "${BLUE}${BOLD}  $1${NC}"
    echo -e "${BLUE}${BOLD}══════════════════════════════════════${NC}"
}

log_step() {
    echo -e "${BLUE}▸${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if command exists
has_cmd() {
    command -v "$1" &>/dev/null
}

# Check if running as root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Get current user (works even when running with sudo)
get_user() {
    if [[ -n "${SUDO_USER:-}" ]]; then
        echo "$SUDO_USER"
    else
        whoami
    fi
}

# Get home directory for current user
get_home() {
    local user
    user=$(get_user)
    eval echo "~$user"
}

# Idempotent: ensure line exists in file
ensure_line() {
    local file="$1"
    local line="$2"
    if ! grep -qF "$line" "$file" 2>/dev/null; then
        echo "$line" >> "$file"
    fi
}

# Idempotent: ensure line does NOT exist in file
remove_line() {
    local file="$1"
    local pattern="$2"
    if [[ -f "$file" ]]; then
        sed -i "/$pattern/d" "$file"
    fi
}

# Idempotent: install apt package if not installed
ensure_apt() {
    local pkg="$1"
    if ! dpkg -l "$pkg" &>/dev/null; then
        sudo apt-get install -y -qq "$pkg"
    fi
}

# Idempotent: create directory if not exists
ensure_dir() {
    local dir="$1"
    [[ -d "$dir" ]] || mkdir -p "$dir"
}

# Idempotent: symlink
ensure_symlink() {
    local src="$1"
    local dst="$2"
    if [[ -L "$dst" ]]; then
        rm "$dst"
    elif [[ -e "$dst" ]]; then
        mv "$dst" "${dst}.backup.$(date +%s)"
    fi
    ln -s "$src" "$dst"
}

# Wait for service to be ready
wait_for_service() {
    local service="$1"
    local max_attempts="${2:-30}"
    local attempt=0
    
    while ! systemctl is-active --quiet "$service"; do
        attempt=$((attempt + 1))
        if [[ $attempt -ge $max_attempts ]]; then
            log_error "Service $service failed to start"
            return 1
        fi
        sleep 1
    done
}

# Detect if we're in SSH session
is_ssh() {
    [[ -n "${SSH_CONNECTION:-}" ]]
}

# Get Tailscale IP
get_tailscale_ip() {
    tailscale ip -4 2>/dev/null || echo "not-connected"
}
