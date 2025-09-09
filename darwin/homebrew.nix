{
  nixpkgs,
  homebrew-core,
  homebrew-cask,
  homebrew-bundle,
  koekeishiya-formulae,
  nikitabobko-tap,
  homebrew-services,
  darksworm-tap,
  cristianoliveira-tap,
  ovensh-bun,
  alajmo-tap,
  charmbracelet-tap,
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
      "homebrew/homebrew-services" = homebrew-services;
      "koekeishiya/homebrew-formulae" = koekeishiya-formulae;
      "nikitabobko/homebrew-tap" = nikitabobko-tap;
      "darksworm/homebrew-tap" = darksworm-tap;
      "cristianoliveira/homebrew-tap" = cristianoliveira-tap;
      "oven-sh/homebrew-bun" = ovensh-bun;
      "alajmo/homebrew-mani" = alajmo-tap;
      "charmbracelet/homebrew-tap" = charmbracelet-tap;
    };

    # Optional: Enable fully-declarative tap management
    #
    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
    mutableTaps = false;
  };
}
