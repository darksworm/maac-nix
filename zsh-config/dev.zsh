eval "$(direnv hook zsh)"
eval "$(zoxide init zsh)"
eval "$(fnm env --use-on-cd --shell zsh)"

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

