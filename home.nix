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

    # zsh plugins (lazy-loaded)
    pkgs.zsh-vi-mode
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
    enableCompletion = false;  # Already done in /etc/zshrc by nix-darwin

    autosuggestion.enable = true;

    history = {
      size = 10000;
      extended = true;
    };

    # Set Homebrew env early (in .zshenv) to skip slow `brew shellenv` in /etc/zshrc
    envExtra = ''
      export HOMEBREW_PREFIX="/opt/homebrew"
      export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
      export HOMEBREW_REPOSITORY="/opt/homebrew/Library/.homebrew-is-managed-by-nix"
      export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
      export MANPATH="/opt/homebrew/share/man''${MANPATH+:$MANPATH}:"
      export INFOPATH="/opt/homebrew/share/info:''${INFOPATH:-}"
    '';

    initContent = lib.mkMerge [
      (lib.mkOrder 1200 ''
        export GPG_TTY=$(tty)
        export ENABLE_LSP_TOOL=1
      '')
      # Starship - cached and compiled for speed
      (lib.mkOrder 1500 ''
        _starship_cache="''${XDG_CACHE_HOME:-$HOME/.cache}/starship-init.zsh"
        if [[ ! -f "$_starship_cache" ]]; then
          mkdir -p "''${_starship_cache:h}"
          starship init zsh > "$_starship_cache"
          zcompile "$_starship_cache"
        fi
        source "$_starship_cache"
        unset _starship_cache
      '')
    ];

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
        name = "zsh-fzf-history-search";
        src = pkgs.zsh-fzf-history-search;
        file = "share/zsh-fzf-history-search/zsh-fzf-history-search.plugin.zsh";
      }
      {
        name = "dev";
        src = ./zsh-config;
        file = "dev.zsh";
      }
      {
        name = "fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting;
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
      }
    ];
  };

  # Starship prompt - cached for speed
  programs.starship = {
    enable = true;
    enableZshIntegration = false;  # We use cached init below
    settings = {
      # Minimal, fast config
      add_newline = false;

      format = "$directory$git_branch$git_status$character";
      right_format = "$kubernetes$aws$java$cmd_duration";

      character = {
        success_symbol = "[❯](green)";
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](yellow)";
      };

      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "blue bold";
      };

      git_branch = {
        format = "[$branch]($style) ";
        style = "purple";
      };

      git_status = {
        format = "[$all_status$ahead_behind]($style) ";
        style = "red";
      };

      kubernetes = {
        disabled = false;
        format = "[$symbol$context]($style) ";
        style = "cyan";
        symbol = "⎈ ";
      };

      aws = {
        format = "[$symbol$profile]($style) ";
        style = "yellow";
        symbol = " ";
      };

      java = {
        format = "[$symbol$version]($style) ";
        style = "red";
        symbol = " ";
      };

      cmd_duration = {
        min_time = 2000;
        format = "[$duration]($style) ";
        style = "yellow";
      };
    };
  };

  # Prezto disabled - using standalone plugins instead
  # programs.zsh.prezto.enable = false;

  programs.nvf = {
    enable = true;

    # This is the sample configuration for nvf, aiming to give you a feel of the default options
    # while certain plugins are enabled. While it may partially act as one, this is *not* quite
    # an overview of nvf's module options. To find a complete and curated list of nvf module
    # options, examples, instruction tutorials and more; please visit the online manual.
    # https://notashelf.github.io/nvf/options.html
    settings.vim = {
      # Extra plugins not covered by nvf modules
      extraPlugins = {
        cyberdream-nvim = {
          package = pkgs.vimUtils.buildVimPlugin {
            name = "cyberdream-nvim";
            src = pkgs.fetchFromGitHub {
              owner = "scottmckendry";
              repo = "cyberdream.nvim";
              rev = "main";
              sha256 = "sha256-EJ6D9IS5ZwOgC44Nr+gQCK+audxBPEpGVOWhIGSe0Tc=";
            };
          };
          setup = ''
            require("cyberdream").setup({
              transparent = false,
              italic_comments = true,
              hide_fillchars = true,
              borderless_telescope = true,
              terminal_colors = true,
              theme = {
                variant = "default",
                highlights = {
                  Comment = { fg = "#696969", bg = "NONE", italic = true },
                },
                colors = {},
              },
              extensions = {
                telescope = true,
                notify = true,
                mini = true,
              },
            })
            vim.cmd("colorscheme cyberdream")
          '';
        };

        mason-nvim = {
          package = pkgs.vimPlugins.mason-nvim;
        };

        mason-lspconfig = {
          package = pkgs.vimPlugins.mason-lspconfig-nvim;
        };

        kotlin-nvim = {
          package = pkgs.vimUtils.buildVimPlugin {
            name = "kotlin-nvim";
            src = pkgs.fetchFromGitHub {
              owner = "AlexandrosAlexiou";
              repo = "kotlin.nvim";
              rev = "main";
              sha256 = "sha256-ZrkTbAVRVa6cUWHLg+65CJLbvVK3SlBWvGdQO08IM/8=";
            };
          };
          # Setup all three in correct order here
          setup = ''
            require("mason").setup({
              PATH = "append",  -- Append to PATH so jenv's java takes precedence
            })
            require("mason-lspconfig").setup({
              automatic_installation = true,
            })
            require("kotlin").setup({
              root_markers = { "gradlew", ".git", "settings.gradle", "settings.gradle.kts" },
              inlay_hints = {
                enabled = true,
              },
            })
          '';
        };
      };

      keymaps = [
        {
          key = "<leader>ddt";
          mode = ["n"];
          silent = true;

          action = ":lua if vim.g.diagnostics_active == nil then vim.g.diagnostics_active = true end; vim.g.diagnostics_active = not vim.g.diagnostics_active; if vim.g.diagnostics_active then vim.diagnostic.enable() print('Diagnostics enabled') else vim.diagnostic.disable() print('Diagnostics disabled') end<CR>";

          desc = "Toggle inline diagnostics";
        }
        {
          key = "<leader>wq";
          mode = ["n"];
          action = ":wq<CR>";
          silent = true;
          desc = "Save file and quit";
        }
        {
          key = "<leader>n";
          mode = ["n"];
          action = "<Cmd>Neotree toggle<CR>";
        }
        {
          key = "<leader>o";
          mode = ["n"];
          action = "<Cmd>Telescope buffers<CR>";
        }
      ];

      viAlias = true;
      vimAlias = true;
      debugMode = {
        enable = false;
        level = 16;
        logFile = "/tmp/nvim.log";
      };

      spellcheck = {
        enable = true;
      };

      lsp = {
        formatOnSave = false;
        lspkind.enable = false;
        lightbulb.enable = true;
        lspsaga.enable = false;
        trouble.enable = true;
        lspSignature.enable = true;
        otter-nvim.enable = true;
        nvim-docs-view.enable = true;
      };

      debugger = {
        nvim-dap = {
          enable = true;
          ui.enable = true;
        };
      };

      lsp.enable = true;

      # This section does not include a comprehensive list of available language modules.
      # To list all available language module options, please visit the nvf manual.
      languages = {
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;

        # Languages that will be supported in default and maximal configurations.
        nix.enable = true;
        markdown.enable = false;  # Disabled to avoid building dotnet (marksman dependency)

        # Languages that are enabled in the maximal configuration.
        bash.enable = true;
        css.enable = true;
        tailwind.enable = false;
        html.enable = true;
        sql.enable = true;
        java.enable = true;
        kotlin.enable = false; # Using kotlin.nvim + Mason for JetBrains kotlin-lsp
        php.enable = true;
        ts.enable = true;
        go.enable = true;
        yaml.enable = true;
      };

      visuals = {
        nvim-scrollbar.enable = true;
        nvim-web-devicons.enable = true;

        # smooth scrolling? https://github.com/declancm/cinnamon.nvim
        nvim-cursorline.enable = true;
        cinnamon-nvim.enable = true;

        # progress messages https://github.com/j-hui/fidget.nvim
        fidget-nvim.enable = true;

        highlight-undo.enable = true;
        indent-blankline.enable = false;

        # Fun
        cellular-automaton.enable = false;
      };

      statusline = {
        lualine = {
          enable = true;
          theme = "auto"; # Will automatically use cyberdream's lualine theme
        };
      };

      theme = {
        enable = false; # Disabled since we're using cyberdream via extraConfigLua
      };

      # https://github.com/windwp/nvim-autopairs
      autopairs.nvim-autopairs.enable = true;

      autocomplete.nvim-cmp.enable = true;
      snippets.luasnip.enable = true;

      filetree = {
        neo-tree = {
          enable = true;
          setupOpts = {
            filesystem = {
              filtered_items = {
                visible = true;
                hide_dotfiles = false;
                hide_gitignored = false;
              };
            };
          };
        };
      };

      tabline = {
        nvimBufferline.enable = true;
      };

      treesitter.context.enable = true;

      binds = {
        whichKey.enable = true;
        cheatsheet.enable = true;
      };

      telescope.enable = true;

      git = {
        enable = true;
        gitsigns.enable = true;
        gitsigns.codeActions.enable = false; # throws an annoying debug message
      };

      # shows the map on the side of a file of indendation and code blocks
      # I don't think I care about it tbh
      minimap = {
        minimap-vim.enable = false;
        codewindow.enable = false; # lighter, faster, and uses lua for configuration
      };

      dashboard = {
        dashboard-nvim.enable = false;
        alpha.enable = true;
      };

      notify = {
        # https://github.com/rcarriga/nvim-notify
        nvim-notify.enable = true;
      };

      projects = {
        # https://github.com/ahmedkhalf/project.nvim
        project-nvim.enable = true;
      };

      utility = {
        ccc.enable = false;
        vim-wakatime.enable = false;
        icon-picker.enable = false;

        # this one seems cool but I don't know how to use it.
        surround.enable = false;
        diffview-nvim.enable = true;
        yanky-nvim.enable = false;
        motion = {
          # space h, type
          hop.enable = true;
          # this, I think is the same as hop, basically, so I'll use only one
          leap.enable = false;
          # the thing that helps discover notions and adds the comment lines with chars
          precognition.enable = false;
        };

        images = {
          image-nvim.enable = false;
        };
      };

      notes = {
        obsidian = {
          enable = true;
          setupOpts = {
            completion.nvim-cmp = true;
            workspaces = [
              {
                name = "2ndbrain";
                path = "/Users/ilmars/Dev/private/2ndbrain";
              }
            ];
          };
        };
        neorg.enable = false;
        orgmode.enable = false;
        mind-nvim.enable = false;
        todo-comments.enable = true;
      };

      ui = {
        borders.enable = true;
        noice.enable = true;
        colorizer.enable = true;
        modes-nvim.enable = false; # the theme looks terrible with catppuccin
        illuminate.enable = true;
        breadcrumbs = {
          enable = true;
          navbuddy.enable = true;
        };
        smartcolumn = {
          enable = true;
          setupOpts.custom_colorcolumn = {
            # this is a freeform module, it's `buftype = int;` for configuring column position
            nix = "110";
            ruby = "120";
            java = "130";
            go = ["90" "130"];
          };
        };
        fastaction.enable = true;
      };

      assistant = {
        chatgpt.enable = false;
        copilot = {
          enable = false;
          cmp.enable = true;
        };
      };

      session = {
        nvim-session-manager.enable = false;
      };

      gestures = {
        gesture-nvim.enable = false;
      };

      comments = {
        comment-nvim.enable = true;
      };

      presence = {
        neocord.enable = false;
      };
    };
  };
}
