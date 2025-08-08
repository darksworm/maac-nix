{pkgs, ...}: {
  programs.nvf = {
    enable = true;

    # This is the sample configuration for nvf, aiming to give you a feel of the default options
    # while certain plugins are enabled. While it may partially act as one, this is *not* quite
    # an overview of nvf's module options. To find a complete and curated list of nvf module
    # options, examples, instruction tutorials and more; please visit the online manual.
    # https://notashelf.github.io/nvf/options.html
    settings.vim = {
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
        markdown.enable = true;

        # Languages that are enabled in the maximal configuration.
        bash.enable = true;
        css.enable = true;
        tailwind.enable = false;
        html.enable = true;
        sql.enable = true;
        java.enable = true;
        kotlin.enable = true;
        php.enable = true;
        ts.enable = true;
        go.enable = true;
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
          theme = "oxocarbon";
        };
      };

      theme = {
        enable = true;
        name = "oxocarbon";
        style = "dark";
        transparent = false;
      };

      # https://github.com/windwp/nvim-autopairs
      autopairs.nvim-autopairs.enable = true;

      autocomplete.nvim-cmp.enable = true;
      snippets.luasnip.enable = true;

      filetree = {
        neo-tree = {
          enable = true;
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
        obsidian.enable = false; # FIXME: neovim fails to build if obsidian is enabled
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

  # sudo with touch id (wow)
  security.pam.services.sudo_local.touchIdAuth = true;

  # to permit the sudo touchid also in tmux
  environment.etc."pam.d/sudo_local".text = ''
    # Managed by Nix Darwin
    auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
    auth       sufficient     pam_tid.so
  '';

  launchd = {
    user = {
      agents = {
        clear-logs = {
          command = "/Users/ilmars/Dev/devenv/bin/clear-logs";
          serviceConfig = {
            KeepAlive = false;
            RunAtLoad = true;
            StandardOutPath = "/tmp/clear-logs.out.log";
            StandardErrorPath = "/tmp/clear-logs.err.log";
          };
        };
      };
    };
  };

  system = {
    keyboard = {
      enableKeyMapping = true;
      # remapCapsLockToEscape = true; # TODO: this is handled by karabiner
    };

    defaults = {
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        orientation = "bottom";
        dashboard-in-overlay = true;
        largesize = 85;
        tilesize = 50;
        magnification = true;
        launchanim = false;
        mru-spaces = false;
        show-recents = false;
        show-process-indicators = false;
        static-only = true;
      };

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        CreateDesktop = false;
        FXDefaultSearchScope = "SCcf"; # current folder
        QuitMenuItem = true;
      };

      NSGlobalDomain = {
        _HIHideMenuBar = false;
        AppleFontSmoothing = 0;
        AppleInterfaceStyle = "Dark";
        AppleKeyboardUIMode = 3;
        AppleScrollerPagingBehavior = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        InitialKeyRepeat = 10;
        KeyRepeat = 2;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        NSWindowResizeTime = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };
    };
  };
}
