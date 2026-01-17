{pkgs, lib, ...}: {
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
