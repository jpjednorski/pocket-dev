export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git)

source $ZSH/oh-my-zsh.sh

if [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
    tmux attach -t main 2>/dev/null || tmux new -s main
fi

eval "$(~/.local/bin/mise activate zsh)"

export EDITOR="vim"
export VISUAL="vim"

alias c="claude"
alias oc="opencode"
alias g="git"
alias gs="git status"
alias gd="git diff"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline -10"
alias code="cd ~/Code"
alias ll="ls -la"
alias ..="cd .."
alias ...="cd ../.."

[[ -f ~/.pocket-dev.env ]] && source ~/.pocket-dev.env

ping-phone() {
    local msg="${1:-ping from pocket-dev}"
    curl -s -d "$msg" "ntfy.sh/${NTFY_TOPIC:-pocket-dev}" > /dev/null
    echo "Notification sent"
}

notify-done() {
    local cmd="$*"
    eval "$cmd"
    local status=$?
    if [[ $status -eq 0 ]]; then
        ping-phone "Done: $cmd"
    else
        ping-phone "Failed ($status): $cmd"
    fi
    return $status
}
