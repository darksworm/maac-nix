#!/usr/bin/env sh
# Tmux plugin to dim inactive panes without feedback loops

# Use tmux's native pane styling with -P flag
# This doesn't trigger hooks and avoids loops

# Set up key binding to manually update dimming if needed
tmux bind-key U run-shell "
    active=\$(tmux display -p '#{pane_id}')
    tmux list-panes -F '#{pane_id}' | while read -r pane; do
        if [ \"\$pane\" = \"\$active\" ]; then
            tmux select-pane -t \"\$pane\" -P 'bg=default,fg=default'
        else
            tmux select-pane -t \"\$pane\" -P 'bg=#1c1c1c,fg=#888888'
        fi
    done
    tmux select-pane -t \"\$active\"
"

# Use client-attached hook instead of select-pane hooks
tmux set-hook -g client-attached "run-shell \"
    active=\$(tmux display -p '#{pane_id}')
    tmux list-panes -F '#{pane_id}' | while read -r pane; do
        if [ \"\$pane\" = \"\$active\" ]; then
            tmux select-pane -t \"\$pane\" -P 'bg=default,fg=default'
        else
            tmux select-pane -t \"\$pane\" -P 'bg=#1c1c1c,fg=#888888'
        fi
    done
    tmux select-pane -t \"\$active\"
\""

# Alternative: Use pane-focus-in/out if available (tmux 3.2+)
tmux set-hook -g pane-focus-in "select-pane -P 'bg=default,fg=default'"
tmux set-hook -g pane-focus-out "select-pane -P 'bg=#1c1c1c,fg=#888888'"