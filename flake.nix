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

    homebrew-services = {
      url = "github:homebrew/homebrew-services";
      flake = false;
    };

    koekeishiya-formulae = {
      url = "github:koekeishiya/homebrew-formulae";
      flake = false;
    };

    nikitabobko-tap = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };

    darksworm-tap = {
      url = "github:darksworm/homebrew-tap";
      flake = false;
    };

    cristianoliveira-tap = {
      url = "github:cristianoliveira/homebrew-tap";
      flake = false;
    };

    ovensh-bun = {
      url = "github:oven-sh/homebrew-bun";
      flake = false;
    };

    alajmo-tap = {
      url = "github:alajmo/homebrew-mani";
      flake = false;
    };

    charmbracelet-tap = {
      url = "github:charmbracelet/homebrew-tap";
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
    homebrew-services,
    koekeishiya-formulae,
    nikitabobko-tap,
    nvf,
    mac-app-util,
    darksworm-tap,
    cristianoliveira-tap,
    ovensh-bun,
    alajmo-tap,
    charmbracelet-tap,
    ...
  }: let
    configuration = {pkgs, config, ...}: {
      environment.systemPackages = [
        inputs.home-manager.packages.aarch64-darwin.home-manager
        pkgs.vim
        pkgs.granted
        pkgs.stow
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
        pkgs.pyenv
        pkgs.argocd
        pkgs.coreutils
        pkgs.delta
        pkgs.discord
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

      system.primaryUser = "ilmars";

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
          "kubelogin"

          "ca-certificates"
          "cryptography"

          "jenv"
          "pyenv"
          "awscli"  # Pre-built binary, much faster than building from source

          "darksworm/tap/aeroswitch"
          "cristianoliveira/tap/aerospace-scratchpad"
          "platformio"

          "k3d"
          "oven-sh/bun/bun"
          "alajmo/mani/mani"
          "charmbracelet/tap/crush"

          "wireshark"
          "gpg2"
          "gnupg"
          "pinentry-mac"
        ];

        caskArgs = {
          no_quarantine = true;
        };

        casks = [
          "proton-mail-bridge"
          "linear-linear"
          "docker-desktop"
          "datagrip"
          "jetbrains-toolbox"
          "intellij-idea"
          "obsidian"
          "flameshot"

          "wacom-tablet"

          "pritunl"

          "obs"
          "jordanbaird-ice"
          "arc"
          "1password"
          "flux"
          "slack"
          "firefox@developer-edition"
          "karabiner-elements"
          "spotify"

          "nikitabobko/tap/aerospace"
          "ghostty"

          "freecad"

          "traefiktop"
          "argonaut"
          "adobe-acrobat-reader"
          "wireshark-chmodbpf"
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
          inherit homebrew-services;
          inherit koekeishiya-formulae;
          inherit nikitabobko-tap;
          inherit darksworm-tap;
          inherit cristianoliveira-tap;
          inherit ovensh-bun;
          inherit alajmo-tap;
          inherit charmbracelet-tap;
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
