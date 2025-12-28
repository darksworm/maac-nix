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
    pkgs.gnupg
    pkgs.ninja
    pkgs.cmake
    pkgs.atool
    pkgs.go
    pkgs.parallel

    pkgs.yt-dlp
    pkgs.gemini-cli

    # git gud
    pkgs.gh
    pkgs.git-absorb
    pkgs.git-lfs
    pkgs.mr

    pkgs.ffmpeg
    # pkgs.kcat  # Temporarily disabled due to avro-c++ build failure
    pkgs.trivy
    pkgs.pwgen
    # pkgs.awscli2  # Disabled - use homebrew version instead (brew install awscli)
    pkgs.dive
    pkgs.mkcert

    pkgs.direnv
    pkgs.zoxide
    pkgs.fnm
    pkgs.uv

    pkgs.raycast

    pkgs.kubectl
    pkgs.kubelogin-oidc
    pkgs.kustomize
    pkgs.krew

    pkgs.vscode
    pkgs.termshot
  ];

  imports = [
    ./dev
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    prefix = "C-a";

    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.pain-control
      tmuxPlugins.session-wizard
      tmuxPlugins.fzf-tmux-url
      (tmuxPlugins.mkTmuxPlugin {
        pluginName = "tmux-toggle-scratch";
        version = "unstable-2024-01-01";
        rtpPath = "share/tmux-plugins/tmux-toggle-scratch";
        src = fetchFromGitHub {
          owner = "momo-lab";
          repo = "tmux-toggle-scratch";
          rev = "28f9ab4f37cbb90a7da9419f14ab487648b22386";
          sha256 = "sha256-lzNMwf5o+Mg5vqLfdf+JU+MgetXbEyQQsPI+kRRnEIE=";
        };
        postInstall = ''
          cd $out/share/tmux-plugins/tmux-toggle-scratch
          ln -sf tmux-toggle-scratch.tmux tmux_toggle_scratch.tmux
        '';
      })
      (tmuxPlugins.mkTmuxPlugin {
        pluginName = "tmux-copy-toolkit";
        version = "unstable-2024-01-01";
        rtpPath = "share/tmux-plugins/tmux-copy-toolkit";
        src = fetchFromGitHub {
          owner = "CrispyConductor";
          repo = "tmux-copy-toolkit";
          rev = "c80c2c068059fe04f840ea9f125c21b83cb6f81f";
          sha256 = "sha256-cLeOoJ+4MF8lSpwy5lkcPakvB3cpgey0RfLbVTwERNk=";
        };
        postInstall = ''
          cd $out/share/tmux-plugins/tmux-copy-toolkit
          ln -sf copytk.tmux tmux_copy_toolkit.tmux
        '';
      })
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

      # Reload config with prefix + r
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

      # Unbind default s (choose-tree) and bind scratch terminal with toggle
      unbind -T prefix s
      bind s if-shell -F '#{==:#{session_name},scratch}' {
        detach-client
      } {
        display-popup -E -w "80%" -h "80%" "tmux new-session -A -s scratch -c '#{pane_current_path}'"
      }

      # Configure copy-toolkit to use system clipboard (macOS)
      set -g @copytk-copy-command 'pbcopy'
      set -g @copytk-no-default-keys 'false'

      # Status bar configuration
      set -g status on
      set -g status-interval 1
      set -g status-position bottom

      # Status bar colors
      set -g status-bg '#1b1b1b'
      set -g status-fg '#c0c0c0'

      # Status bar layout
      set -g status-justify centre

      # Left side - session name with nerd font icon
      set -g status-left-length 40
      set -g status-left '#[fg=#ffb86c,bold]  #S #[fg=#666666]│'

      # Window status format - centered
      set -g window-status-format '#[fg=#666666] #I:#W '
      set -g window-status-current-format '#[fg=#c0c0c0,bold] #I:#W '
      set -g window-status-separator ' '

      # Right side - hostname
      set -g status-right-length 40
      set -g status-right '#[fg=#666666]│#[fg=#8be9fd]  #h '

      # Window status alignment
      set -g status-justify centre

      # Pane styling - dim inactive panes
      setw -g window-active-style 'bg=black'
      setw -g window-style 'bg=#222222'

      # Better pane dimming using focus events (tmux 3.2+)
      set -g focus-events on
      set-hook -g pane-focus-in 'select-pane -P "bg=black"'
      set-hook -g pane-focus-out 'select-pane -P "bg=#1c1c1c,fg=#999999"'

      # Thicker border characters
      set -g pane-border-lines heavy

      # Show arrows pointing into the active pane
      set -g pane-border-indicators arrows

      # Colors: tweak to taste
      set -g pane-border-style 'fg=colour239'
      set -g pane-active-border-style 'fg=brightyellow'
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

    # TEMPORARY: zsh profiling - run `zprof` after shell starts to see results
    initExtraFirst = ''
      zmodload zsh/zprof
    '';

    initContent = ''
      export GPG_TTY=$(tty)
      export ENABLE_LSP_TOOL=1
    '';

    shellAliases = {
      dc = "docker compose";
      nix-upgrade = "~/.config/nix/bin/nix-upgrade";
      nix-sync = "~/.config/nix/bin/nix-sync";
      nix-gc = "~/.config/nix/bin/nix-gc";
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
      "completion"        # Tab completion (compinit)
      "syntax-highlighting" # Command coloring
      # Removed: terminal (window title - minor feature)
      # Removed: environment (Home Manager handles this)
      # Removed: autosuggestions (duplicate - using Home Manager's)
      # Removed: utility (custom aliases defined above)
    ];

    editor.keymap = "vi";
  };
}
