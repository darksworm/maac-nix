{ lib, ... }:
{
  home.activation = {
    syncJenvVersions = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ( if [ -f /opt/homebrew/bin/brew ]; then
        echo -e "Syncing JDK versions into jenv..."

        eval "$(/opt/homebrew/bin/brew shellenv)"

        brew list --formula |\
                grep openjdk |\
                xargs -I {} -n1 jenv add /opt/homebrew/opt/{}

        echo -e "Done syncing JDK versions into jenv."
      fi )
    '';
  };
}
