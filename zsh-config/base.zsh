export EDITOR=nvim
export ZVM_INIT_MODE=sourcing

# Fast SSH detection for Powerlevel10k (~215ms savings)
# The default _p9k_init_ssh runs slow commands like `who am i`
# This quick check covers 99% of cases
if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" || -n "$SSH_CONNECTION" ]]; then
  typeset -g P9K_SSH=1
else
  typeset -g P9K_SSH=0
fi

