#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh"

log_section "Clone Repos"

USER_HOME=$(get_home)
REPOS_FILE="$POCKET_DEV_DIR/repos.txt"
CODE_DIR="$USER_HOME/Code"

if [[ ! -f "$REPOS_FILE" ]]; then
    log_warn "No repos.txt found"
    log_info "Create one from repos.txt.example:"
    log_info "  cp $POCKET_DEV_DIR/repos.txt.example $REPOS_FILE"
    exit 1
fi

ensure_dir "$CODE_DIR"

CLONED=0
SKIPPED=0

while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    read -r url path <<< "$line"
    
    if [[ -z "$path" ]]; then
        repo_name=$(basename "$url" .git)
        path="$CODE_DIR/$repo_name"
    fi
    
    path="${path/#\~/$USER_HOME}"

    if [[ -d "$path" ]]; then
        log_info "Exists: $path"
        SKIPPED=$((SKIPPED + 1))
    else
        log_step "Cloning $url"
        if git clone "$url" "$path"; then
            log_success "Cloned to $path"
            CLONED=$((CLONED + 1))
        else
            log_error "Failed to clone $url"
        fi
    fi
done < "$REPOS_FILE"

echo ""
log_success "Done: $CLONED cloned, $SKIPPED already existed"
