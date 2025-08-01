export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH:/run/current-system/sw/bin"

emulate zsh -c "$(direnv hook zsh)"

eval "$(zoxide init zsh)"
eval "$(fnm env --use-on-cd --shell zsh)"

