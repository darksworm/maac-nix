{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    nvf.url = "github:notashelf/nvf";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    koekeishiya-formulae = {
      url = "github:koekeishiya/homebrew-formulae";
      flake = false;
    };

    ovensh-bun = {
      url = "github:oven-sh/homebrew-bun";
      flake = false;
    };

    nikitabobko-tap = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };

    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    home-manager,
    nix-homebrew,
    homebrew-core,
    homebrew-cask,
    homebrew-bundle,
    koekeishiya-formulae,
    ovensh-bun,
    nikitabobko-tap,
    nvf,
    mac-app-util,
    ...
  }: let
    configuration = {pkgs, ...}: {
      environment.systemPackages = [
        inputs.home-manager.packages.aarch64-darwin.home-manager
        pkgs.vim
        pkgs.granted
        pkgs.stow
        pkgs.neofetch
        pkgs.blueutil
        pkgs.nmap
        pkgs.watch
        pkgs.wget
        pkgs.jq
        pkgs.readline
        pkgs.inetutils
        pkgs.tmux
        pkgs.ncdu
        pkgs.ripgrep
        pkgs.btop
        pkgs.fzf
        pkgs.websocat
        pkgs.ollama
        pkgs.kopia
        pkgs.pyenv
        pkgs.bun
        pkgs.podman
      ];

      nix.settings = {
        experimental-features = "nix-command flakes";
        download-buffer-size = 524288000;
      };

      nix.gc = {
        automatic = true;
        options = "--delete-older-than 7d";
      };

      # Enable alternative shell support in nix-darwin.
      programs.zsh.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
      nixpkgs.config.allowUnfree = true;

      users.users.ilmars = {
        name = "ilmars";
        home = "/Users/ilmars";
        shell = pkgs.zsh;
      };

      homebrew = {
        enable = true;

        onActivation = {
          autoUpdate = true;
          cleanup = "uninstall";
          upgrade = true;
        };

        brews = [
          # bunch of java versions
          "openjdk@11"
          "openjdk@17"
          "openjdk@21"

          # k8s crap for work
          "helm"

          "ca-certificates"
          "cryptography"

          "jenv"
          "pyenv"

          "kopia"

          "oven-sh/bun/bun"

          "podman"
        ];

        caskArgs = {
          no_quarantine = true;
        };

        casks = [
          "docker"
          "datagrip"
          "jetbrains-toolbox"
          "intellij-idea"
          "trae"

          "wacom-tablet"
          "xournal++"

          "obs"
          "jordanbaird-ice"
          "arc"
          "1password"
          "flux"
          "slack"
          "firefox@developer-edition"
          "karabiner-elements"
          "spotify"
          "private-internet-access"

          "kopiaui"
          "nikitabobko/tap/aerospace"
          "hazeover"
          "ghostty"
          "doll"

          "osu"
        ];
      };
    };
  in {
    darwinConfigurations."maac" = nix-darwin.lib.darwinSystem {
      modules = [
        nvf.nixosModules.default

        ./darwin

        configuration

        nix-homebrew.darwinModules.nix-homebrew
        (import ./darwin/homebrew.nix {
          inherit nixpkgs;
          inherit homebrew-core;
          inherit homebrew-cask;
          inherit homebrew-bundle;
          inherit koekeishiya-formulae;
          inherit ovensh-bun;
          inherit nikitabobko-tap;
        })

        mac-app-util.darwinModules.default

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.ilmars = import ./home.nix;
          home-manager.sharedModules = [
            mac-app-util.homeManagerModules.default
          ];
        }
      ];
    };
  };
}
