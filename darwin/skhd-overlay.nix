# skhd-overlay.nix
self: super: {
  # Ensure you're overriding the skhd package correctly
  skhd = super.skhd.overrideAttrs (oldAttrs: {
    # Modify the postInstall phase
    postInstall = ''
      mkdir -p $out/Library/LaunchDaemons
      cp ${./custom-org.nixos.skhd.plist} $out/Library/LaunchDaemons/org.nixos.skhd.plist
      substituteInPlace $out/Library/LaunchDaemons/org.nixos.skhd.plist --subst-var out
    '';
  });
}

