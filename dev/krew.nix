{ lib, ... }:
{
  home.activation = {
    installKrewPlugins = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ( if command -v krew >/dev/null 2>&1 || [ -f "$HOME/.krew/bin/kubectl-krew" ]; then
        echo -e "Installing kubectl sniff plugin via krew..."

        # Ensure krew bin is in PATH for this session
        export PATH="$HOME/.krew/bin:$PATH"

        # Update krew index first
        kubectl krew update || true

        # Install sniff plugin if not already installed
        if ! kubectl krew list | grep -q "^sniff"; then
          kubectl krew install sniff
          echo -e "kubectl sniff plugin installed successfully."
        else
          echo -e "kubectl sniff plugin already installed."
        fi
      else
        echo -e "Krew not found, skipping plugin installation. You may need to initialize krew first."
      fi )
    '';
  };
}