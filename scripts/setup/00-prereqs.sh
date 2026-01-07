#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

log_section "Prerequisites"

log_step "Updating package lists..."
sudo apt-get update -qq

log_step "Installing essential packages..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    curl \
    wget \
    git \
    jq \
    unzip \
    build-essential \
    mosh \
    tmux \
    htop \
    ncdu \
    tree \
    ripgrep \
    fd-find \
    zsh

log_success "Prerequisites installed"
