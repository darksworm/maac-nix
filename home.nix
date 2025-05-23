# home.nix
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.dash
    pkgs.ninja
    pkgs.cmake
    pkgs.atool
    pkgs.go
    pkgs.parallel

    # git gud
    pkgs.gh
    pkgs.git-absorb
    pkgs.mr

    # tty
    pkgs.alacritty

    pkgs.ffmpeg
    pkgs.kcat
    pkgs.trivy
    pkgs.pwgen
    pkgs.awscli2
    pkgs.dive
    pkgs.mkcert

    pkgs.direnv
    pkgs.zoxide
    pkgs.fnm
    pkgs.uv

    pkgs.flameshot
    pkgs.raycast
    pkgs.aldente

    pkgs.kubectl
    pkgs.kubelogin
    pkgs.kubelogin-oidc
    pkgs.kustomize
  ];

  imports = [
    ./dev
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Alacritty module configuration
  programs.alacritty = {
    enable = true;

    # Path to the custom theme file
    settings = {
      general = {
        import = ["~/.config/alacritty/themes/oxocarbon.toml"];
      };

      font = {
        size = 19;
      };

      window = {
        decorations = "Buttonless";
        padding = {
          x = 6;
          y = 12;
        };
      };
    };
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    prefix = "C-a";

    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.pain-control
    ];

    extraConfig = ''
      set -g default-command ${pkgs.zsh}/bin/zsh

      set -g mouse on

      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      bind -n M-H previous-window
      bind -n M-L next-window

      # Set the background and foreground colors for the tmux status bar
      set -g status-bg '#1b1b1b'
      set -g status-fg '#ffffff'
    '';
  };

  programs.zsh = {
    enable = true;
    enableCompletion = false;

    autosuggestion = {
      enable = true;
    };

    history = {
      size = 10000;
      extended = true;
    };

    shellAliases = {
      dc = "docker compose";
      nix-upgrade = "~/.config/nix-darwin/bin/nix-upgrade";
      nix-sync = "~/.config/nix-darwin/bin/nix-sync";
      nix-gc = "~/.config/nix-darwin/bin/nix-gc";
      htop = "btop";

      "docker-compose" = "docker compose";
      "devenv" = "cd ~/Dev/devenv && docker-compose";
    };

    plugins = [
      {
        name = "base";
        src = ./zsh-config;
        file = "base.zsh";
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = ./zsh-config;
        file = "p10k.zsh";
      }
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
      {
        name = "zsh-fzf-history-search";
        src = pkgs.zsh-fzf-history-search;
        file = "share/zsh-fzf-history-search/zsh-fzf-history-search.plugin.zsh";
      }
      {
        name = "dev";
        src = ./zsh-config;
        file = "dev.zsh";
      }
    ];
  };

  programs.zsh.prezto = {
    enable = true;
    color = true;

    pmodules = [
      "syntax-highlighting"
      "terminal"
      "environment"
      "autosuggestions"
      "completion"
      "utility"
    ];

    editor.keymap = "vi";
  };
}
