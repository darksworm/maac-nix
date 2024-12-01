# home.nix

{ config, pkgs, lib, ... }:

{
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
    pkgs.ncdu
    pkgs.tmux
    pkgs.ripgrep
    pkgs.dash
    pkgs.inetutils
    pkgs.ninja
    pkgs.cmake
    pkgs.atool
    pkgs.go
    pkgs.nmap
    pkgs.watch
    pkgs.wget
    pkgs.jq
    pkgs.readline

    pkgs.alacritty
    pkgs.ffmpeg
    pkgs.kcat
    pkgs.trivy
    pkgs.pwgen
    pkgs.gh
    pkgs.git-absorb
    pkgs.awscli
    pkgs.dive
    pkgs.mkcert

    pkgs.btop
    pkgs.direnv
    pkgs.zoxide
    pkgs.fnm

    pkgs.flameshot
    pkgs.raycast
    pkgs.aldente
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files hois through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/davish/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  home.activation = {
    syncJenvVersions = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -f /opt/homebrew/bin/brew ]; then
        echo -e "Syncing JDK versions into jenv..."

        eval "$(/opt/homebrew/bin/brew shellenv)"

        brew list --formula |\
                grep openjdk |\
                xargs -I {} -n1 jenv add /opt/homebrew/opt/{}

        echo -e "Done syncing JDK versions into jenv."
      fi
    '';

    allowYabaiLoadSA = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -f /opt/homebrew/bin/brew ]; then
        echo -e "Checking yabai load-sa permissions..."

        eval "$(/opt/homebrew/bin/brew shellenv)"

        YABAI_PATH=$(command -v yabai)

        SUDOERS_ENTRY="$(whoami) ALL=(root) NOPASSWD: sha256:$(/usr/bin/shasum -a 256 $YABAI_PATH | cut -d " " -f 1) $YABAI_PATH --load-sa"

        SUDOERS_FILE="/private/etc/sudoers.d/yabai"

        if [[ -f "$SUDOERS_FILE" ]]; then
            EXISTING_CONTENT=$(cat "$SUDOERS_FILE")

            if [[ "$EXISTING_CONTENT" == "$SUDOERS_ENTRY" ]]; then
                echo "yabai load-sa already configured. not making changes."
                exit 0
            fi
        fi

        echo "$SUDOERS_ENTRY" | /usr/bin/sudo tee "$SUDOERS_FILE" > /dev/null

        echo -e "Yabai load-sa permissions have been updated."
      fi
    '';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

    # Alacritty module configuration
  programs.alacritty = {
    enable = true;

    # Path to the custom theme file
    settings = {
      general = {
        import = [ "~/.config/alacritty/themes/oxocarbon.toml" ];
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
      nu = "( cd ~/.config/nix-darwin && ./bin/build )";
      htop = "btop";

      vim = "nvim";
      v = "nvim";

      "docker-compose" = "docker compose";
    };

    plugins = [
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

  home.file.".hushlogin".text = "";

  home.file.".docker/daemon.json".text = ''{
    "builder": {
      "gc": {
        "defaultKeepStorage": "20GB",
        "enabled": true
      }
    },
    "default-address-pools": [
      {
        "base": "172.240.0.0/8",
        "size": 24
      }
    ],
    "experimental": false,
    "log-driver": "json-file",
    "log-opts": {
      "max-file": "3",
      "max-size": "2m"
    }
  }'';

  home.file.".config/yabai/yabairc".text = ''
    yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
    sudo yabai --load-sa

    yabai -m config layout bsp
    yabai -m config window_placement second_child
    yabai -m config top_padding 4
    yabai -m config bottom_padding 4
    yabai -m config left_padding 4
    yabai -m config right_padding 4
    yabai -m config window_gap 4
    yabai -m config window_origin_display focused

    # center mouse on window with focus
    yabai -m config mouse_follows_focus on

    # modifier for clicking and dragging with mouse
    yabai -m config mouse_modifier alt
    # set modifier + left-click drag to move window
    yabai -m config mouse_action1 move
    # set modifier + right-click drag to resize window
    yabai -m config mouse_action2 resize


    # when window is dropped in center of another window, swap them (on edges it will split it)
    yabai -m mouse_drop_action swap

    yabai -m rule --add app="^System Settings$" manage=off
    yabai -m rule --add app="^Calculator$" manage=off
    yabai -m rule --add app="^Karabiner-Elements$" manage=off

    yabai -m config mouse_follows_focus          off
    yabai -m config focus_follows_mouse          autofocus

    yabai -m rule --add app="Riot Client" sticky=on manage=off
    yabai -m rule --add app="League of Legends" sticky=on manage=off
    yabai -m rule --add app="CameraController" sticky=on manage=off
    yabai -m rule --add app="^Discord$" manage=off grid=6:4:1:1:2:4
  '';
}
