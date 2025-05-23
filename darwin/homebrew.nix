{
  nixpkgs,
  homebrew-core,
  homebrew-cask,
  homebrew-bundle,
  koekeishiya-formulae,
  ovensh-bun,
  nikitabobko-tap,
  ...
}: {
  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;

    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = true;

    # User owning the Homebrew prefix
    user = "ilmars";

    # Optional: Declarative tap management
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "homebrew/homebrew-bundle" = homebrew-bundle;
      "koekeishiya/homebrew-formulae" = koekeishiya-formulae;
      "oven-sh/homebrew-bun" = ovensh-bun;
      "nikitabobko/homebrew-tap" = nikitabobko-tap;
    };

    # Optional: Enable fully-declarative tap management
    #
    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
    mutableTaps = false;
  };
}
