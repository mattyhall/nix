{ pkgs, git-email ? "matthew@quickbeam.me.uk", extra-programs ? { }, ... }: {
  home = {
    username = "mjh";
    homeDirectory = "/home/mjh";
    stateVersion = "22.05";
  };

  programs = {
    home-manager.enable = true;

    fzf = {
      enable = true;
      enableFishIntegration = true;
      defaultCommand = "fd --type f";
    };

    git = {
      enable = true;

      userName = "Matt Hall";
      userEmail = git-email;

      delta.enable = true;

      extraConfig = {
        merge.conflictStyle = "diff3";
        init.defaultBranch = "main";
      };
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    fish = {
      enable = true;

      shellInit = ''
        direnv hook fish | source
      '';

      shellAliases = {
        gs = "git status";
        gb = "git branch | fzf | git switch";
        e = "$EDITOR";
      };
    };

    tmux = {
      enable = true;

      shortcut = "a";

      keyMode = "vi";
      customPaneNavigationAndResize = true;

      escapeTime = 0;

      extraConfig = builtins.readFile ./extra/tmux.conf;
    };
  } // extra-programs;

  home.sessionVariables = { EDITOR = "nvim"; };

  home.packages = with pkgs; [
    ripgrep
    fd
    httpie
    jq
    delta
    htop
    openssh
    less
    neovim
  ];

  xdg.configFile."nvim/init.lua".source = ./extra/nvim/init.lua;

  xdg.configFile."river/init" = {
    source = ./extra/river;
    executable = true;
  };
}
