{pkgs, ...}: {
  home = {
    username = "mjh";
    homeDirectory = "/home/mjh";
    stateVersion = "22.05";

    sessionVariables = {EDITOR = "nvim";};

    packages = with pkgs; [
      ripgrep
      fd
      httpie
      jq
      delta
      htop
      openssh
      less
      neovim
      nil
    ];
  };

  xdg.configFile."nvim/init.lua".source = ./extra/nvim/init.lua;

  xdg.configFile."kak-lsp/kak-lsp.toml".source = ./extra/kak/kak-lsp.toml;
  xdg.configFile."kak/colors/dracula.kak".source = ./extra/kak/dracula.kak;
  xdg.configFile."kak/colors/dracula-transparent.kak".source = ./extra/kak/dracula-transparent.kak;

  programs = {
    home-manager.enable = true;

    kakoune = {
      enable = true;

      config = {
        keyMappings = [
          # splits
          {
            mode = "normal";
            key = "<c-w>";
            effect = ":enter-user-mode<space>splits<ret>";
            docstring = "enter splits mode";
          }
          {
            mode = "splits";
            key = "s";
            effect = ":vsplit<ret>";
            docstring = "split vertically";
          }
          {
            mode = "splits";
            key = "v";
            effect = ":hsplit<ret>";
            docstring = "split horizontally";
          }
          {
            mode = "splits";
            key = "c";
            effect = ":quit!<ret>";
            docstring = "quit";
          }

          # fzf
          {
            mode = "user";
            key = "/";
            effect = ":fzf-mode<ret>g";
            docstring = "grep";
          }
          {
            mode = "user";
            key = "<space>";
            effect = ":fzf-mode<ret>v";
            docstring = "find files (vcs)";
          }
          {
            mode = "user";
            key = "f";
            effect = ":fzf-mode<ret>f";
            docstring = "find files";
          }
          {
            mode = "user";
            key = ",";
            effect = ":fzf-mode<ret>b";
            docstring = "find buffers";
          }
        ];

        numberLines = {
          enable = true;
          relative = true;
          highlightCursor = true;
        };

        colorScheme = "dracula";

        tabStop = 4;
      };

      plugins = with pkgs.kakounePlugins; [
        kak-fzf
        kak-lsp
      ];

      extraConfig = ''
        # splits
        define-command -docstring "vsplit <filename>: open file in vertical tmux split" \
        vsplit -params 0.. -file-completion %{
          tmux-terminal-vertical kak -c %val{session} %arg{@}
        }
        define-command -docstring "hsplit <filename>: open file in horizontal tmux split" \
        hsplit -params 0.. -file-completion %{
          tmux-terminal-horizontal kak -c %val{session} %arg{@}
        }

        # lsp
        eval %sh{kak-lsp --kakoune -s $kak_session}
        lsp-enable
        map global user c %{: enter-user-mode lsp<ret>} -docstring "LSP mode"

        # rulers
        add-highlighter global/ column 50 default,rgb:44475a
        add-highlighter global/ column 72 default,rgb:44475a
        add-highlighter global/ column 120 default,rgb:44475a
      '';
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
      defaultCommand = "fd --type f";
    };

    git = {
      enable = true;

      userName = "Matt Hall";

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
        gb = "git branch | fzf | xargs git switch";
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
  };
}
