export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH:/run/current-system/sw/bin"

# Lazy-load direnv: only initialize when entering a directory with .envrc
_direnv_hook_initialized=0

_lazy_direnv_hook() {
  if [[ $_direnv_hook_initialized -eq 0 ]]; then
    if [[ -f .envrc ]] || [[ -f .env ]]; then
      _direnv_hook_initialized=1
      emulate zsh -c "$(direnv hook zsh)"
      _direnv_hook  # Run immediately after initializing
    fi
  fi
}

# Check on directory change
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _lazy_direnv_hook

# Also provide manual trigger: run `direnv-init` to force initialization
direnv-init() {
  if [[ $_direnv_hook_initialized -eq 0 ]]; then
    _direnv_hook_initialized=1
    emulate zsh -c "$(direnv hook zsh)"
    _direnv_hook
  fi
}

eval "$(zoxide init zsh)"
eval "$(fnm env --use-on-cd --shell zsh)"

