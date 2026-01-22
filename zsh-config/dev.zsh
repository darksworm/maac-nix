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

# Cache zoxide init output (avoids ~240ms subprocess call on cold cache)
_zoxide_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zoxide-init.zsh"
if [[ ! -f "$_zoxide_cache" ]]; then
  mkdir -p "${_zoxide_cache:h}"
  zoxide init zsh > "$_zoxide_cache"
  zcompile "$_zoxide_cache"
fi
source "$_zoxide_cache"
unset _zoxide_cache

# Lazy-load fnm: only initialize when entering a directory with Node config
_fnm_initialized=0

_lazy_fnm_hook() {
  if [[ $_fnm_initialized -eq 0 ]]; then
    if [[ -f .node-version ]] || [[ -f .nvmrc ]] || [[ -f package.json ]]; then
      _fnm_initialized=1
      eval "$(fnm env --use-on-cd --shell zsh)"
    fi
  fi
}

# Check on directory change
add-zsh-hook chpwd _lazy_fnm_hook

# Also provide manual trigger
fnm-init() {
  if [[ $_fnm_initialized -eq 0 ]]; then
    _fnm_initialized=1
    eval "$(fnm env --use-on-cd --shell zsh)"
  fi
}

# Make node/npm/npx commands auto-init fnm
for cmd in node npm npx yarn pnpm; do
  eval "${cmd}() { fnm-init; command ${cmd} \"\$@\" }"
done

# Claude Code: auto-install and run with Node 25
claude() {
  (
    eval "$(fnm env --use-on-cd --shell zsh)" && fnm use 25 && {
      if command -v claude &>/dev/null; then
        npm install -g @anthropic-ai/claude-code &>/dev/null &
        command claude "$@"
      else
        npm install -g @anthropic-ai/claude-code && command claude "$@"
      fi
    }
  )
}

